program define sintonizar, rclass
	args varname taxa SU0 intervalo id iter
	
	quietly summarize `varname' if `id' > _N - `intervalo'
	scalar accep_prop = r(mean)
	scalar delta = min(0.01, (`iter'/`intervalo' + 1)^(-0.5))
	
	if accep_prop >= `taxa' {
		scalar temp = log(`SU0') - delta
	}
	else {
		scalar temp = log(`SU0') + delta
	}
	
	return scalar SU = exp(temp)
	return scalar accep_prop = accep_prop
end