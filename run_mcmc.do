version 19.0
clear all
do "mcmc.do"

local model = "weibull"

* características do mcmc
local n_chains = 4
local n_iter = 100000
local n_burnin = 80000

mcmc `model' `n_chains' `n_iter' `n_burnin'
