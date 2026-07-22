program define dic
	args model
	
	frame change results
	
	gen D_mcmc = -2 * loglik

	quietly summarize D_mcmc
	scalar D_mean = r(mean) 

	quietly summarize alpha
	scalar alpha_mean = r(mean)

	quietly summarize theta
	scalar theta_mean = r(mean)
	
	if "`model'" == "goel" {
		quietly summarize b
		scalar beta_mean = r(mean)
	}
	
	frame change default
	loglik `model' alpha_mean theta_mean beta_mean
	scalar loglik_mean = r(loglik)
	
	scalar D_hat = -2 * loglik_mean
	scalar pD = D_mean - D_hat
	scalar DIC = D_mean + pD
	
	display "Model: " "`model'"
	display "DIC = " DIC
	display "D_mean = " = D_mean,
    display "D_hat = " = D_hat,
    display "pD = " = pD

end