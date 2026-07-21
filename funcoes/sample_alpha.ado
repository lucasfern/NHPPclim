program define sample_alpha, rclass
	args model
	
	scalar alpha_new = rgamma(alpha_i*tuning_alpha, 1/tuning_alpha)
	
	if "`model'" == "weibull" {
		
		scalar log_p_alpha = ///
			(n_x + a_alpha - 1) * log(alpha_i) - ///
			theta_i * max_x^alpha_i + ///
			alpha_i * (sum_log_x - b_alpha)
					  
		scalar log_p_alpha_new = ///
			(n_x + a_alpha - 1) * log(alpha_new) - ///
			theta_i * max_x^alpha_new + ///
			alpha_new * (sum_log_x - b_alpha)
			
	}
	else if "`model'" == "musa" {
		
		generate log_x_plus_alpha = log(x + alpha_i) 
		quietly summarize log_x_plus_alpha
		scalar sum_log_x_plus_alpha = r(sum)
		
		generate log_x_plus_alpha_new = log(x + alpha_new) 
		quietly summarize log_x_plus_alpha_new
		scalar sum_log_x_plus_alpha_new = r(sum)
		
		drop log_x_plus_alpha log_x_plus_alpha_new
		
		scalar log_p_alpha = ///
			(a_alpha - 1) * log(alpha_i) - ///
			b_alpha * alpha_i - ///
			theta_i * log(1 + max_x/alpha_i) - ///
			sum_log_x_plus_alpha
		
		scalar log_p_alpha_new = ///
			(a_alpha - 1) * log(alpha_new) - ///
			b_alpha * alpha_new - ///
			theta_i * log(1 + max_x/alpha_new) - ///
			sum_log_x_plus_alpha_new
	
	}
	else if "`model'" == "goel" {
		
		generate x_to_alpha = x^alpha_i
		quietly summarize x_to_alpha
		scalar sum_x_to_alpha = r(sum)
		
		generate x_to_alpha_new = x^alpha_new
		quietly summarize x_to_alpha_new
		scalar sum_x_to_alpha_new = r(sum)
		
		drop x_to_alpha x_to_alpha_new
		
		scalar log_p_alpha = ///
			(n_x + a_alpha - 1) * log(alpha_i) + ///
			(alpha_i - 1) * sum_log_x - ///
			beta_i * sum_x_to_alpha + ///
			theta_i * exp(-beta_i * max_x^alpha_i) - ///
			b_alpha * alpha_i
				  
		scalar log_p_alpha_new = ///
			(n_x + a_alpha - 1) * log(alpha_new) + ///
			(alpha_new - 1) * sum_log_x - ///
			beta_i * sum_x_to_alpha_new + ///
			theta_i * exp(-beta_i * max_x^alpha_new) - ///
			b_alpha * alpha_new
	
	}
	
	scalar log_r = ///
		log_p_alpha_new + ///
		log(gammaden(alpha_new*tuning_alpha, 1/tuning_alpha, 0, alpha_i)) - ///
		log_p_alpha - ///
		log(gammaden(alpha_i*tuning_alpha, 1/tuning_alpha, 0, alpha_new))
			
	scalar accep_prob = min(1, exp(log_r))
	scalar u = runiform()
	
	if u < accep_prob {
		return scalar next = alpha_new
		return scalar acceptance = 1
	}
	else {
		return scalar next = alpha_i
		return scalar acceptance = 0
	}
	
end
