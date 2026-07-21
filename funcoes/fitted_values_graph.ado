frame change default

gen mean_consec_x = cond(_n == 1, x/2, (x + x[_n - 1])/2)
gen mean_y = .
gen p025_y = .
gen p975_y = .

forvalues i = 1/`=scalar(n_x)' {

	scalar mean_consec_x_i = mean_consec_x[`i']

	frame change results

	gen y_i = theta[_n] * mean_consec_x_i^alpha[_n]

	quietly summarize y_i
	scalar mean_yi = r(mean)
	
	_pctile y_i, percentiles(2.5 97.5)
	scalar p025_yi = r(r1)
	scalar p975_yi = r(r2)
	
	drop y_i
	
	frame change default
	
	quietly replace mean_y = mean_yi in `i'
	quietly replace p025_y = p025_yi in `i'
	quietly replace p975_y = p975_yi in `i'
	
	display `i'
	
}

gen aux = _n - 1/2

line mean_y mean_consec_x || line aux mean_consec_x
