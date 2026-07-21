program define mcmc_convergence
	args n_chains n_iter n_burnin framename varname
	
	frames copy `framename' convergence_`varname'
	frame change convergence_`varname'
	
	collapse (mean)  `varname'_mean = `varname' ///
		     (sd)    `varname'_sd = `varname', by(chain)
			 
			 
	generate `varname'_mean2 = `varname'_mean^2 
	generate `varname'_var = `varname'_sd^2  // s2_i
	
	quietly summarize `varname'_var
	scalar W = r(mean)
	scalar `varname'_var_var = r(Var)

	quietly summarize `varname'_mean
	scalar `varname'_gmean = r(mean)  // global mean
	generate `varname'_diff_mean2 = (`varname'_mean - `varname'_gmean)^2
	
	scalar m = `n_chains'
	scalar n = `n_iter' - `n_burnin'
	
	quietly summarize `varname'_diff_mean2
	scalar B = n/(m-1) * r(sum)

	scalar sigma2_hat = ((n-1)/n)*W + (1/n)*B
	scalar Vhat = sigma2_hat + B/(m*n)
		
	quietly correlate `varname'_var `varname'_mean2, covariance
	scalar cov_s2_mean2 = r(cov_12)

	quietly correlate `varname'_var `varname'_mean, covariance
	scalar cov_s2_mean = r(cov_12)
	
	scalar var_Vhat = ((n-1)/n)^2 * (1/m) * `varname'_var_var + ///
				      ((m+1)/(m*n))^2 * (2/(m-1)) * B^2 + ///
				      (2*(m+1)*(n-1))/(m*n^2) * (n/m) * ///
					  (cov_s2_mean2 - 2*`varname'_gmean*cov_s2_mean)
					  
	scalar df = (2*Vhat^2)/var_Vhat
	scalar Rhat_GR = (Vhat/W) * (df/(df-2))
	scalar Rhat_coda = sqrt((Vhat/W) * ((df+3)/(df+1))) 
	
	display "(`varname')"
	
	* dist. t com
	* média: global_mean
	* variância: sqrt(Vhat)
	* graus de liberdade: df
	display "Média = " `varname'_gmean
	display "IC 95% = [" ///
			round(invnt(df, `varname'_gmean, 0.025), 0.0001) ", " ///
			round(invnt(df, `varname'_gmean, 0.975), 0.0001) "]"
	display "Rhat_GR = " Rhat_GR
	display "Rhat_coda = " Rhat_coda
end

