program define mcmc_dic
	args model
	gen D_mcmc = -2 * loglik

	quietly summarize D_mcmc
	scalar D_bar = r(mean) 

	quietly summarize alpha
	scalar alpha_bar = r(mean)

	quietly summarize theta
	scalar theta_bar = r(mean)

	loglik `model' alpha_bar theta_bar
	scalar loglik_mean = r(loglik)

	scalar D_hat = -2 * loglik_mean
	scalar pD = D_bar - D_hat
	scalar DIC = D_bar + pD

	display "DIC = " DIC

end