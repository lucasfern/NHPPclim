program define sample_theta, rclass
	args model
	
	if "`model'" == "weibull" {
		
		scalar theta_new = rgamma( ///
			n_x + a_theta, ///
			1/(max_x^alpha_i + b_theta) ///
		)
	}
	else if "`model'" == "musa"{
		
		scalar theta_new = rgamma( ///
			a_theta + n_x, ///
			1/(b_theta + log(1 + max_x/alpha_i)) ///
		)
		
	}
	else if "`model'" == "goel" {
		
		scalar theta_new = rgamma( ///
			a_theta + n_x, ///
			1/(b_theta + 1 - exp(-beta_i*max_x^alpha_i)) ///
		)
		
	}
	
	return scalar next = theta_new
	
end