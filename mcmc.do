program define mcmc
args model n_chains n_iter n_burnin alpha_0 theta_0 beta_0

do "functions/nhpp_traj.ado"
*do "../processo de poisson/functions/nhpp_mean.ado"
do "functions/sample_alpha.ado"
do "functions/sample_theta.ado"
do "functions/sample_beta.ado"
do "functions/loglik.ado"
do "functions/sintonizar.ado"
do "functions/chain_graph.ado"
do "functions/mcmc_dic.ado"
do "functions/mcmc_convergence.ado"

* carrega dados da memória
use "trajectories/dataS15.dta"
*use "trajectories/nhpp_weibull_t_10_alpha_3_theta_2.dta"
*use "trajectories/nhpp_musa_t_1000_alpha_2_theta_20.dta"
*use "trajectories/nhpp_goel_t_10_alpha_2_theta_50_beta_10.dta"

* gera dados do processo
*nhpp_traj `model' 10 0.5 20 10
*rename t_nhpp x
rename value x

* valores iniciais das cadeias
matrix alpha_0 = (0.5, 0.5, 1, 1)
matrix theta_0 = (15, 25, 15, 25)
if "`model'" == "goel" {
	matrix beta_0 = (2, 2, 3, 3)
}

* hiperparâmetros das prioris
scalar a_alpha = 0.001
scalar b_alpha = 0.001
scalar a_theta = 0.001
scalar b_theta = 0.001
if "`model'" == "goel" {
	scalar a_beta = 0.001
	scalar b_beta = 0.001
}

* parâmetros sintonização
if "`model'" == "weibull" {
	scalar tuning_alpha_0 = 2000
}
else if "`model'" == "musa" {
	scalar tuning_alpha_0 = 100
}
else if "`model'" == "goel" {
	scalar tuning_alpha_0 = 100
	scalar tuning_beta_0 = 100
}
scalar taxa = 0.44
scalar intervalo = 50

* estatísticas fixas
scalar n_x = _N
scalar max_x = x[_N]
if "`model'" == "weibull" | "`model'" == "goel" {
	generate log_x = log(x)
	quietly summarize log_x
	scalar sum_log_x = r(sum)	
}

if "`model'" == "weibull" | "`model'" == "musa" {
	frame create results_full ///
		chain iter id alpha accep_alpha theta loglik
}
else if "`model'" == "goel" {
	frame create results_full ///
		chain iter id alpha accep_alpha beta accep_beta theta loglik
}

forvalues j = 1/`n_chains' {
	
	* get chain initial values
	scalar alpha_i = alpha_0[1, `j']
	scalar theta_i = theta_0[1, `j']
	scalar tuning_alpha = tuning_alpha_0
	
	if "`model'" == "goel" {
		scalar beta_i = beta_0[1, `j']
		scalar tuning_beta = tuning_beta_0
	}

	forvalues i = 1/`n_iter' {
		local id = (`j'-1)*`n_iter' + `i'
		
		* sample parameter values
		sample_alpha `model'
		scalar alpha_i = r(next)
		scalar accep_alpha_i = r(acceptance)
		
		if "`model'" == "goel" {
			sample_beta `model'
			scalar beta_i = r(next)
			scalar accep_beta_i = r(acceptance)
		}
		
		sample_theta `model'
		scalar theta_i = r(next)
		
		if "`model'" == "weibull" | "`model'" == "musa" {
			loglik `model' alpha_i theta_i
		}
		else if "`model'" == "goel" {
			loglik `model' alpha_i theta_i beta_i
		}
		
		scalar loglik_i = r(loglik)
		
		* post results to frame
		if "`model'" == "weibull" | "`model'" == "musa" {
			frame post results_full ///
				(`j') (`i') (`id') (alpha_i) (accep_alpha_i) ///
				(theta_i) (loglik_i)
		}
		else if "`model'" == "goel" {
			frame post results_full ///
				(`j') (`i') (`id') (alpha_i) (accep_alpha_i) ///
				(beta_i) (accep_beta_i) (theta_i) (loglik_i)
		}
		
		* tuning
		if mod(`i', intervalo) == 0 & `i' <= `n_burnin' {
			frame change results_full
			
			sintonizar accep_alpha taxa tuning_alpha intervalo id `i'
			scalar tuning_alpha = r(SU)
			scalar accep_prop_alpha = r(accep_prop)
			
			if "`model'" == "goel" {
				sintonizar accep_beta taxa tuning_beta intervalo id `i'
				scalar tuning_beta = r(SU)
				scalar accep_prop_beta = r(accep_prop)
			}
			
			frame change default
		}
		
		* display progress
		if mod(`i', 500) == 0 {
			display "(" `id' ") " `j' "-" `i'
			display accep_prop_alpha " " tuning_alpha
			
			if "`model'" == "goel" {
				display accep_prop_beta " " tuning_beta
			}
		}
		
	}
}

frame copy results_full results
frame change results
drop if iter <= `n_burnin'
if "`model'" == "weibull" | "`model'" == "musa" {
	by chain, sort: summarize alpha accep_alpha theta
	summarize alpha accep_alpha theta	
}
else if "`model'" == "goel" {
	by chain, sort: summarize alpha accep_alpha beta accep_beta theta
	summarize alpha accep_alpha beta accep_beta theta	
}

* plot chain trajectories
by chain, sort: egen media_alpha = mean(alpha)
by chain, sort: egen media_theta = mean(theta)
if "`model'" == "goel" {
	by chain, sort: egen media_beta = mean(beta)	
}
capture mkdir imagens
chain_graph alpha
chain_graph theta "stgreen"
if "`model'" == "goel" {
	chain_graph beta "stred"
}

if "`model'" == "weibull" | "`model'" == "musa" {
	graph combine ///
		"imagens/graph_alpha" "imagens/graph_theta"
}
else if "`model'" == "goel" {
	graph combine ///
		"imagens/graph_alpha" "imagens/graph_theta" "imagens/graph_beta"
}

mcmc_dic `model'

* chain convergence diagnostics
mcmc_convergence `n_chains' `n_iter' `n_burnin' results alpha
mcmc_convergence `n_chains' `n_iter' `n_burnin' results theta		
if "`model'" == "goel" {
	mcmc_convergence `n_chains' `n_iter' `n_burnin' results beta
}

end