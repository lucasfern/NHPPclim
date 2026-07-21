version 19.0
clear all
do "funcoes/nhpp_traj.ado"
do "funcoes/nhpp_mean.ado"

* single trajectory
* nhpp_traj weibull 10 3 2

local lambda_f = "goel"
scalar t = 10
scalar alpha = 2
scalar theta = 50
scalar beta = 10  // apenas goel

* Sintaxe da função: nhpp_traj lambda_f t alpha theta (beta)
nhpp_traj `lambda_f' t alpha theta beta
nhpp_mean `lambda_f' t alpha theta beta
display "Valor real = " _N