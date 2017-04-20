#####################################################################
# Run once upon initializing to avoid dict-kv issue. This
# may soon change within Mimi to make the structure more robust.
cd("src")
#####################################################################

using Mimi

#Load function to construct model
include("fund.jl")

#Create model for test run
results = getfund()

# Set parameters
setparameter(results, :vslvmorb, :vslel_highest, 1.5)
setparameter(results, :vslvmorb, :vslel_high, 1.5)
setparameter(results, :vslvmorb, :vslel_mid, 1.0)
setparameter(results, :vslvmorb, :vslel_low, 1.0)
#=setparameter(results, :socioeconomic, :runwithoutdamage, true)
setparameter(results, :population, :runwithoutpopulationperturbation, true)=#

# Run
run(results)

# Call necessary packages
using DataArrays, DataFrames, Plots, PyPlot, StatPlots, RCall

# For StatPlots, which is necessary due to DataFrames incompatibility
gr(size=(400,300))

#check values
verify1 = getdataframe(results, :impactdeathtemp, :ypc)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\verify_ypc.csv", verify1)
unstack(verify1, :time, :regions, :ypc)

verify2 = getdataframe(results, :climatedynamics, :temp)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\verify_temp.csv", verify2)

verify3 = getdataframe(results,:population, :population)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\verify_pop.csv", verify3)
unstack(verify3, :time, :regions, :population)

#####################################################################
# GCP
#####################################################################

# GCP rate:THESE ARE THE NUMBERS THAT MATCH JR'S RESULTS WHEN MULTIPLIED BY 100_000.00
mortrate_GCP = getdataframe(results,:impactdeathtemp, :morttempeffect)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\mortrate_GCP.csv", mortrate_GCP)
mortrate_GCP_regional = unstack(mortrate_GCP, :time, :regions, :morttempeffect)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\mortrate_GCP_regional.csv", mortrate_GCP_regional)

# GCP dead
dead_GCP = getdataframe(results,:impactdeathtemp, :gcpdead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\dead_GCP.csv", dead_GCP)
dead_GCP_regional = unstack(dead_GCP, :time, :regions, :gcpdead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\dead_GCP_regional.csv", dead_GCP_regional)

# GCP cost
cost_GCP = getdataframe(results,:impactdeathtemp, :gcpdeadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\cost_GCP.csv", cost_GCP)
unstack(cost_GCP, :time, :regions, :gcpdeadcost)

#####################################################################
# Total (FUND + GCP)
#####################################################################

#Total rate
mortrate_combo = getdataframe(results,:impactdeathmorbidity, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\mortrate_combo.csv", mortrate_combo)
mortrate_combo_regional = unstack(mortrate_combo, :time, :regions, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\mortrate_combo_regional.csv", mortrate_combo_regional)

# Total dead
dead_combo = getdataframe(results,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\dead_combo.csv", dead_combo)
dead_combo_regional = unstack(dead_combo, :time, :regions, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\dead_combo_regional.csv", dead_combo_regional)

# Total cost
cost_combo = getdataframe(results,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\cost_combo.csv", cost_combo)
cost_combo_regional = unstack(cost_combo, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\cost_combo_regional.csv", cost_combo_regional)

#####################################################################
# FUND
#####################################################################

# Run FUND alone to enable direct comparison  (GCP vs. FUND)
soloFUND_run = getfund()

#Change parameters to fit this case: replace dead_other (fed by GCP data) with matrix of zeros
setparameter(soloFUND_run, :impactdeathmorbidity, :dead_other, zeros(1051,16))
setparameter(soloFUND_run, :vslvmorb, :vslel_highest, 1.5)
setparameter(soloFUND_run, :vslvmorb, :vslel_high, 1.5)
setparameter(soloFUND_run, :vslvmorb, :vslel_mid, 1.0)
setparameter(soloFUND_run, :vslvmorb, :vslel_low, 1.0)
#Run model
run(soloFUND_run)

# Check to make sure it zeroed out GCP
check1 = println(soloFUND_run[:impactdeathmorbidity, :dead_other])
check2 = println(soloFUND_run[:population, :population])

#FUND dead
dead_FUND = getdataframe(soloFUND_run,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\dead_FUND.csv",dead_FUND)
dead_FUND_regional = unstack(dead_FUND, :time, :regions, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\dead_FUND_regional.csv",dead_FUND_regional)

# FUND cost
cost_FUND = getdataframe(soloFUND_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\cost_FUND.csv", cost_FUND)
cost_FUND_regional = unstack(cost_FUND, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\cost_FUND_regional.csv", cost_FUND_regional)

#FUND rate
mortrate_FUND = getdataframe(soloFUND_run,:impactdeathmorbidity, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\mortrate_FUND.csv",mortrate_FUND)
mortrate_FUND_regional = unstack(mortrate_FUND, :time, :regions, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\mortrate_FUND_regional.csv",mortrate_FUND_regional)


#####################################################################
# Marginal Damages
#####################################################################
# Compute derivatives using finite differencing scheme

# Using one ton pulse for single year (if desire 1 ton/year for ten years
# or if wish to compare other gases, see original code)
# Source: marginaldamages3 component, FUND3.9 JUlia version
function getmarginaldamages1(;emissionyear=2010,parameters=nothing,yearstoaggregate=1000,gas=:C)
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)

    m1 = getfund(nsteps=yearstorun,params=parameters)
    m2 = getfund(nsteps=yearstorun,params=parameters)

    # Add pulse only to second model run
    addcomponent(m2, adder, :marginalemission, before=:climateco2cycle)
    addem = zeros(yearstorun+1)
    addem[getindexfromyear(emissionyear)] = 1.0
    setparameter(m2,:marginalemission,:add,addem)

    if gas==:C
        connectparameter(m2,:marginalemission,:input,:emissions,:mco2)
        connectparameter(m2,:climateco2cycle,:mco2,:marginalemission,:output)
    else
        error("Unknown gas.")
    end

    run(m1)
    run(m2)

    damage1 = m1[:impactaggregation,:loss]
    damage2 = m2[:impactaggregation,:loss]

    # Calculate the marginal damage between run 1 and 2 for each year/region
    marginaldamage1 = (damage2.-damage1)/1_000_000.0

    return marginaldamage1
end

# View results
marginaldamage1 = getmarginaldamages1()
marginal_combo = DataFrame(marginaldamage1)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\marginal_combo.csv", marginal_combo)

###################################################################################
# Marginal with FUND alone
###################################################################################

# Using one ton pulse for single year
function getmarginaldamages1(;emissionyear=2010,parameters=nothing,yearstoaggregate=1000,gas=:C)
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)

    m1 = getfund(nsteps=yearstorun,params=parameters)
    m2 = getfund(nsteps=yearstorun,params=parameters)

    # Zero out GCP numbers for both model runs
    setparameter(m1, :impactdeathmorbidity, :dead_other, zeros(1051,16))
    setparameter(m2, :impactdeathmorbidity, :dead_other, zeros(1051,16))

    # Add pulse only to second model run
    addcomponent(m2, adder, :marginalemission, before=:climateco2cycle)
    addem = zeros(yearstorun+1)
    addem[getindexfromyear(emissionyear)] = 1.0
    setparameter(m2,:marginalemission,:add,addem)

    if gas==:C
        connectparameter(m2,:marginalemission,:input,:emissions,:mco2)
        connectparameter(m2,:climateco2cycle,:mco2,:marginalemission,:output)
    else
        error("Unknown gas.")
    end

    run(m1)
    run(m2)

    damage1 = m1[:impactaggregation,:loss]
    damage2 = m2[:impactaggregation,:loss]

    # Calculate the marginal damage between run 1 and 2 for each year/region
    marginaldamage1 = (damage2.-damage1)/1_000_000.0

    return marginaldamage1
end

# View results
fund_marginal1 = getmarginaldamages1()
marginal_FUND = DataFrame(fund_marginal1)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\marginal_FUND.csv",marginal_FUND)

#####################################################################
# Test Dynamic Vulnerability
#####################################################################

# establish test models
adapt_basecase = getfund()
adapt_temp = getfund()
adapt_gdp = getfund()

# Change parameter to fit these cases
# Recall, regressions from GCP team furnished 1 valuue per region: hence zeros(16)
setparameter(adapt_temp, :impactdeathtemp, :gammatemp1, zeros(16))
setparameter(adapt_temp, :impactdeathtemp, :gammatemp2, zeros(16))
setparameter(adapt_gdp, :impactdeathtemp, :gammalogypc, zeros(16))

#Run model
run(adapt_basecase)
run(adapt_temp)
run(adapt_gdp)

# Base case
adapt_baseGCP = getdataframe(adapt_basecase,:impactdeathtemp, :gcpdead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_baseGCP.csv", adapt_baseGCP)

adapt_baseCOMBO = getdataframe(adapt_basecase,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_baseCOMBO.csv", adapt_baseCOMBO)

# Without gdp: testing dynamic vulnerability
adapt_gdpGCP = getdataframe(adapt_gdp,:impactdeathtemp, :gcpdead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_gdpGCP.csv", adapt_gdpGCP)

adapt_gdpCOMBO = getdataframe(adapt_gdp,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_gdpCOMBO.csv", adapt_gdpCOMBO)

#= Without temperature: testing dynamic vulnerability
adapt_tempGCP = getdataframe(adapt_temp,:impactdeathtemp, :gcpdead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_tempGCP", adapt_tempGCP)

adapt_tempCOMBO= getdataframe(adapt_temp,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_tempCOMBO.csv", adapt_tempCOMBO)=#

#####################################################################
# VSL: Original version
#####################################################################

# VSL standard run (all elasticities equal to 1)
standard_run = getfund()

#Change parameters to fit this case
setparameter(standard_run, :vslvmorb, :vslel_highest, 1.0)
setparameter(standard_run, :vslvmorb, :vslel_high, 1.0)
setparameter(standard_run, :vslvmorb, :vslel_mid, 1.0)
setparameter(standard_run, :vslvmorb, :vslel_low, 1.0)

#Run model
run(standard_run)

# View results with all VSL elasticities = 1.0 (FUND's business as usual)
VSL_old = getdataframe(standard_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\VSL_old.csv", VSL_old)
unstack(VSL_old, :time, :regions, :vsl)

# View cost with elasticities set to zero
cost_combo_VSL1 = getdataframe(standard_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\cost_combo_VSL1.csv", cost_combo_VSL1)
cost_combo_VSL1_regional = unstack(cost_combo_VSL1, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\cost_combo_VSL1_regional.csv", cost_combo_VSL1_regional)

# View dead
dead_combo_VSL1 = getdataframe(standard_run,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\dead_combo_VSL1.csv", dead_combo_VSL1)
dead_combo_VSL1_regional = unstack(dead_combo_VSL1, :time, :regions, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\dead_combo_VSL1_regional.csv", dead_combo_VSL1_regional)

#####################################################################
# VSL: New version
#####################################################################

# Here, allow elasticities vary according to ypc value.
# This is implemented directly in the new component, so just need to call
# and run a fresh version of the model

# Call model
altered_run = getfund()

# Run model
run(altered_run)

# View results
VSL_new = getdataframe(altered_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\VSL_new.csv", VSL_new)
unstack(VSL_new, :time, :regions, :vsl)

#####################################################################
# VSL: Comparing old and new values
#####################################################################

# PLOT THE DIFFERENCE FOR ALL YEARS post 2010 AS A PERCENTAGE CHANGE IN VSL
println(altered_run[:vslvmorb, :vsl][60,:] .- standard_run[:vslvmorb, :vsl][60,:])

VSLcompare = altered_run[:vslvmorb, :vsl] .- standard_run[:vslvmorb, :vsl]
VSLpercentchange = (VSLcompare ./ standard_run[:vslvmorb, :vsl]) * 100

VSLplotpercent = DataFrame(VSLpercentchange)
VSLplotdifference = DataFrame(VSLcompare)

writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\VSL_percentchange.csv", VSLplotpercent)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\VSL_difference.csv", VSLplotdifference)

#####################################################################
# Monte Carlo Simulation: Use PAGE as basis
#####################################################################

#=
include("getpagefunction.jl")
 getpage()
 run(m)
-temp=m[:ClimateTemperature,:rt_g_globaltemperature][10]
+temp=[m[:ClimateTemperature,:rt_g_globaltemperature][10]]

 #Define uncertin parameters based on PAGE 2009 documentation
 uncertain_params=Dict()
-uncertain_params[:res_CO2atmlifetime]=TriangularDist(50., 100., 70.)
+uncertain_params[:co2cycle,:res_CO2atmlifetime]=TriangularDist(50., 100., 70.)

-nit=2
-for i in 1:nit
-    for (p_name, p_dist) in uncertain_params
+nit=50
+@time for i in 1:nit
+    for ((p_comp, p_name), p_dist) in uncertain_params
         v = rand(p_dist)
-        setparameter(m, p_name, v)
+        setparameter(m, p_comp,p_name, v)
     end
     run(m)
     push!(temp, m[:ClimateTemperature,:rt_g_globaltemperature][10]) =#


#=Play with plotting options
R"install.packages(ggplot2)"
R"library(ggplot2)"
testplot = scatter(gcpmortrate_df, :time, :regions)
regions = [:USA :CAN :WEU :JPK :ANZ :EEU :FSU :MDE :CAM :LAM :SAS :SEA :CHI :MAF :SSA :SIS]=#
