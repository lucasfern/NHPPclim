program define chain_graph
	args varname color
	
	line `varname' iter, ///
	lcolor(`color') ///
	by(chain, legend(pos(5))) || ///
	line media_`varname' iter, ///
	lpattern(dash) legend(label(2 "Média") col(2)) ///
	saving("imagens/graph_`varname'", replace)

	graph export "imagens/graph_`varname'.png", replace
end