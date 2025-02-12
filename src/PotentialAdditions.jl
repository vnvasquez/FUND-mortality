#####################################################################
# Run once upon initializing to avoid dict-kv issue. This
# may soon change within Mimi to make the structure more robust.
cd("src")
#####################################################################

# Call necessary packages
using Mimi
using DataArrays, DataFrames

####################################################################
# Sensitivity Analysis: Retain FUND's original income elasticity
####################################################################

#Load function to construct model
include("fund.jl")

#Create model for test run
dv_elast = getfund()

# Set elasticity (gammalogypc) to FUND's original
setparameter(dv_elast, :impactdeathtemp, :gammalogypc, fill(-2.65, 16))

# Zero out double counted elements for integrated model
setparameter(dv_elast,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(dv_elast,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(dv_elast,:impactdeathmorbidity,:resp, zeros(1051,16))

# Run
run(dv_elast)




# Extract populationin1 to use for constructing global mortrate (need population weighted)
dv_elast_pop = getdataframe(dv_elast, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_pop.csv", dv_elast_pop)
dv_elast_popT = unstack(dv_elast_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_popT.csv", dv_elast_popT)

###

# GCP death rate with gammalogypc set to FUND income elasticity of -2.65
dv_elast_GCPrate = getdataframe(dv_elast, :impactdeathtemp, :morttempeffect)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_GCPrate.csv", dv_elast_GCPrate)
dv_elast_GCPrateT = unstack(dv_elast_GCPrate, :time, :regions, :morttempeffect)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_GCPrateT.csv", dv_elast_GCPrateT)

# GCP total dead
dv_elast_GCPdead = getdataframe(dv_elast, :impactdeathtemp, :gcpdead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_GCPdead.csv", dv_elast_GCPdead)
dv_elast_GCPdeadT = unstack(dv_elast_GCPdead, :time, :regions, :gcpdead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_GCPdeadT.csv", dv_elast_GCPdeadT)

# GCP total cost
dv_elast_GCPcost = getdataframe(dv_elast, :impactdeathtemp, :gcpdeadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_GCPdead.csv", dv_elast_GCPcost)
dv_elast_GCPcostT = unstack(dv_elast_GCPcost, :time, :regions, :gcpdeadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_GCPdeadT.csv", dv_elast_GCPcostT)

###

# Integrated death rate with gammalogypc set to FUND income elasticity of -2.65
dv_elast_COMBOrate = getdataframe(dv_elast, :impactdeathmorbidity, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_COMBOrate.csv", dv_elast_COMBOrate)
dv_elast_COMBOrateT = unstack(dv_elast_COMBOrate, :time, :regions, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_COMBOrateT.csv", dv_elast_COMBOrateT)

# Integrated total dead
dv_elast_COMBOdead = getdataframe(dv_elast, :impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_COMBOdead.csv", dv_elast_COMBOdead)
dv_elast_COMBOdeadT = unstack(dv_elast_COMBOdead, :time, :regions, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_COMBOdeadT.csv", dv_elast_COMBOdeadT)

# Integrated cost
dv_elast_COMBOcost = getdataframe(dv_elast, :impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_COMBOcost.csv", dv_elast_COMBOcost)
dv_elast_COMBOcostT = unstack(dv_elast_COMBOcost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast_COMBOcostT.csv", dv_elast_COMBOcostT)


#####################################################################
# Dynamic Vulnerability, Integrated Model: Hold socioeconomic to 1990 levels
#####################################################################

#Load function to construct model
include("fund.jl")

#Create model for test run
dv_hold90 = getfund()

# Zero out double counted elements for integrated model
setparameter(dv_hold90,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(dv_hold90,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(dv_hold90,:impactdeathmorbidity,:resp, zeros(1051,16))

#= Set socioeconomic (ypc and population) to 1990 levels
setparameter(dv_hold90,:impactdeathtemp,:income,:gdp90)
setparameter(dv_hold90,:impactdeathtemp,:population,:pop90)=#

# Run
run(dv_hold90)

# Verify values for per capita income
dv_hold90_ypc = getdataframe(dv_hold90, :impactdeathtemp, :ypc)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\verify_ypc.csv", dv_hold90_ypc)
dv_hold90_ypcT = unstack(dv_hold90_ypc, :time, :regions, :ypc)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\verify_ypcT.csv", dv_hold90_ypcT)

# Extract populationin1 to use for constructing global mortrate (need population weighted)
dv_hold90_pop = getdataframe(dv_hold90, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_pop.csv", dv_hold90_pop)
dv_hold90_popT = unstack(dv_hold90_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_popT.csv", dv_hold90_popT)

###

# GCP death rate holding at 1990 levels
dv_hold90_GCPrate = getdataframe(dv_hold90, :impactdeathtemp, :morttempeffect)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_GCPrate.csv", dv_hold90_GCPrate)
dv_hold90_GCPrateT = unstack(dv_hold90_GCPrate, :time, :regions, :morttempeffect)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_GCPrateT.csv", dv_hold90_GCPrateT)

# GCP total dead holding at 1990 levels
dv_hold90_GCPdead = getdataframe(dv_hold90, :impactdeathtemp, :gcpdead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_GCPdead.csv", dv_hold90_GCPdead)
dv_hold90_GCPdeadT = unstack(dv_hold90_GCPdead, :time, :regions, :gcpdead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_GCPdeadT.csv", dv_hold90_GCPdeadT)

# GCP cost holding at 1990 levels
dv_hold90_GCPcost = getdataframe(dv_hold90, :impactdeathtemp, :gcpdeadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_GCPcost.csv", dv_hold90_GCPcost)
dv_hold90_GCPcostT = unstack(dv_hold90_GCPcost, :time, :regions, :gcpdeadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_GCPcostT.csv", dv_hold90_GCPcostT)

###

# Integrated death rate holding at 1990 levels
dv_hold90_COMBOrate = getdataframe(dv_hold90, :impactdeathmorbidity, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_COMBOrate.csv", dv_hold90_COMBOrate)
dv_hold90_COMBOrateT = unstack(dv_hold90_COMBOrate, :time, :regions, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_COMBOrateT.csv", dv_hold90_COMBOrateT)

# Integrated total dead holding at 1990 levels
dv_hold90_COMBOdead = getdataframe(dv_hold90, :impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_COMBOdead.csv", dv_hold90_COMBOdead)
dv_hold90_COMBOdeadT = unstack(dv_hold90_COMBOdead, :time, :regions, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_COMBOdeadT.csv", dv_hold90_COMBOdeadT)

# Integrated cost holding at 1990 levels
dv_hold90_COMBOcost = getdataframe(dv_hold90, :impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_COMBOcost.csv", dv_hold90_COMBOcost)
dv_hold90_COMBOcostT = unstack(dv_hold90_COMBOcost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_hold90_COMBOcostT.csv", dv_hold90_COMBOcostT)

#####################################################################
# Dynamic Vulnerability, Integrated Model: Set gammalogypc to 0
#####################################################################

# establish test models
dv_basecase = getfund()
dv_elast0 = getfund()

# Change parameter to fit these cases
# Recall, regressions from GCP team furnished 1 valuue per region: hence zeros(16)
setparameter(dv_elast0, :impactdeathtemp, :gammalogypc, zeros(16))

# Zero out double counted elements for integrated model BASECASE
setparameter(dv_basecase,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(dv_basecase,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(dv_basecase,:impactdeathmorbidity,:resp, zeros(1051,16))

# Zero out double counted elements for integrated model NEW
setparameter(dv_elast0,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(dv_elast0,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(dv_elast0,:impactdeathmorbidity,:resp, zeros(1051,16))

#Run model
run(dv_basecase)
run(dv_elast0)

#####

# BASECASE - Extract populationin1 to use for constructing global mortrate (need population weighted)
dv_basecase_pop = getdataframe(dv_basecase, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_basecase_pop.csv", dv_basecase_pop)
dv_basecase_popT = unstack(dv_basecase_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_basecase_popT.csv", dv_basecase_popT)

# NEW CASE - Extract populationin1 to use for constructing global mortrate (need population weighted)
dv_elast0_pop = getdataframe(dv_elast0, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast0_pop.csv", dv_elast0_pop)
dv_elast0_popT = unstack(dv_elast0_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast0_popT.csv", dv_elast0_popT)

#####

# With gammalogypc set to 0: DEAD RATE testing dynamic vulnerability
dv_elast0_COMBOrate = getdataframe(dv_elast0, :impactdeathmorbidity, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast0_COMBOrate.csv", dv_elast0_COMBOrate)
dv_elast0_COMBOrateT = unstack(dv_elast0_COMBOrate, :time, :regions, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast0_COMBOrateT.csv", dv_elast0_COMBOrateT)

# With gammalogypc set to 0: TOTAL DEAD testing dynamic vulnerability
dv_elast0_COMBOdead = getdataframe(dv_elast0, :impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast0_COMBOdead.csv", dv_elast0_COMBOdead)
dv_elast0_COMBOdeadT = unstack(dv_elast0_COMBOdead, :time, :regions, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast0_COMBOdeadT.csv", dv_elast0_COMBOdeadT)

# With gammalogypc set to 0: DEAD COST testing dynamic vulnerability
dv_elast0_COMBOcost = getdataframe(dv_elast0, :impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast0_COMBOcost.csv", dv_elast0_COMBOcost)
dv_elast0_COMBOcostT = unstack(dv_elast0_COMBOcost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\PotentialAdditions\\dv_elast0_COMBOcostT.csv", dv_elast0_COMBOcostT)


#####################################################################
# Monte Carlo Simulation: Use PAGE as basis?
#####################################################################


### DONT FORGET TO SET APROPRIATE parameters TO ZERO

cd("src")
using Mimi 
using Distributions

# load and run model
include("fund.jl")
m = getfund()

# Zero out double counted elements for integrated model
setparameter(m,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(m,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(m,:impactdeathmorbidity,:resp, zeros(1051,16))

run(m)

# test temperature for iteration "0" -> originally was push!(temptest, m[:climatedynamics,:temp][11]) 
temptest = Dict(
  "0" => m[:climatedynamics,:temp])

climate_sens_v = [0.0]; 

# test mortality for iteration "0" 
morttest = Dict(
  "0"  => m[:impactdeathmorbidity, :dead_other])

# Define uncertain parameters using dictionary 
uncertain_params=Dict()
uncertain_params[:climatedynamics,:ClimateSensitivity]=Gamma(6.48, 0.55)

# Number of iterations 
nit=50

# Loop to run Monte Carlo 
@time for i in 1:nit
for ((p_comp, p_name), p_dist) in uncertain_params
  v = rand(p_dist)
  push!(climate_sens_v,v)
  setparameter(m, p_comp,p_name, v)
end
run(m)
# test temperature again, compare to original values  
key = string(i)
morttest[key] = m[:impactdeathmorbidity, :dead_other]
temptest[key] = m[:climatedynamics,:temp]

# Zero out double counted elements for integrated model
setparameter(m,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(m,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(m,:impactdeathmorbidity,:resp, zeros(1051,16))

end 

