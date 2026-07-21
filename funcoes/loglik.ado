program define loglik, rclass
	args model alpha theta beta

	if "`model'" == "weibull" {
		
		scalar ll = ///
			n_x * (log(`alpha') + log(`theta')) - ///
			`theta' * max_x^`alpha' + ///
			(`alpha' - 1) * sum_log_x	
	
	}
	else if "`model'" == "musa" {
		
		generate log_x_plus_alpha = log(x + `alpha') 
		quietly summarize log_x_plus_alpha
		scalar sum_log_x_plus_alpha = r(sum)
		
		drop log_x_plus_alpha
		
		scalar ll = ///
			n_x * log(`theta') - ///
			`theta' * log((max_x + `alpha') / `alpha') - ///
			sum_log_x_plus_alpha
			
	}
	else if "`model'" == "goel" {
		
		generate x_to_alpha = x^`alpha'
		quietly summarize x_to_alpha
		scalar sum_x_to_alpha = r(sum)
		
		drop x_to_alpha
		
		scalar ll = ///
			n_x * (log(`alpha') + log(`beta') + log(`theta')) + ///
			(`alpha' - 1) * sum_log_x - ///
			`beta' * sum(x^`alpha') - ///
			`theta' * (1 - exp(-`beta' * max_x^`alpha'))
	
	}
	
	return scalar loglik = ll
	
end



