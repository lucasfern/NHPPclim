program define sample_beta, rclass
	args model
	
	scalar beta_new = rgamma(beta_i*tuning_beta, 1/tuning_beta)
	
	if "`model'" == "goel" {
		generate x_to_alpha = x^alpha_i
		quietly summarize x_to_alpha
		scalar sum_x_to_alpha = r(sum)
		
		drop x_to_alpha
		
		scalar log_p_beta = ///
			(n_x + a_beta - 1) * log(beta_i) - ///
			beta_i * (b_beta + sum_x_to_alpha) + ///
			theta_i * exp(-beta_i * max_x^alpha_i)
		
		scalar log_p_beta_new = ///
			(n_x + a_beta - 1) * log(beta_new) - ///
			beta_new * (b_beta + sum_x_to_alpha) + ///
			theta_i * exp(-beta_new * max_x^alpha_i)
	}
	
	scalar log_r = ///
		log_p_beta_new + ///
		log(gammaden(beta_new*tuning_beta, 1/tuning_beta, 0, beta_i)) - ///
		log_p_beta - ///
		log(gammaden(beta_i*tuning_beta, 1/tuning_beta, 0, beta_new))
	
	scalar accep_prob = min(1, exp(log_r))
	scalar u = runiform()
	
	if u < accep_prob {
		return scalar next = beta_new
		return scalar acceptance = 1
	}
	else {
		return scalar next = beta_i
		return scalar acceptance = 0
	}
	
end