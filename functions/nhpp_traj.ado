program define nhpp_traj
	args lambda_f t alpha theta beta
	drop _all 
	generate tau = .
	generate t_hpp = .
	generate t_nhpp = .

	while 1 {
		quietly insobs 1
		quietly replace tau = rexponential(1) in l
		quietly replace t_hpp = sum(tau)
		
		if "`lambda_f'" == "weibull" {
			quietly replace t_nhpp = ///
				(t_hpp/`theta')^(1/`alpha') in l
		}
		else if "`lambda_f'" == "musa" {
			quietly replace t_nhpp = ///
				`alpha'*(exp(t_hpp/`theta') - 1) in l
		}
		else if "`lambda_f'" == "goel" {
			quietly replace t_nhpp = ///
				((-1/`beta')*log(1 - t_hpp/`theta'))^(1/`alpha') in l
		}
		
		if (t_nhpp[_N] > `t') continue, break
	}

	quietly drop if t_nhpp > `t'
end
