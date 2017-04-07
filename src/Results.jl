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
run(results)

# Call necessary packages
using DataArrays, DataFrames, Plots, PyPlot, StatPlots, RCall

# For StatPlots, which is necessary due to DataFrames incompatibility
gr(size=(400,300))


#check values - verify units with James
verify1 = getdataframe(results, :impactdeathtemp, :logypc)
unstack(verify1, :time, :regions, :logypc)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\check_logypc.csv", verify1)

verify2 = getdataframe(results, :impactdeathtemp, :logpopop)
unstack(verify2, :time, :regions, :logpopop)

verify3 = getdataframe(results, :climateregional, :temp)
unstack(verify3, :time, :regions, :temp)


#####################################################################
# GCP Mortality
#####################################################################

# GCP rate
gcpmortrate_df = getdataframe(results,:impactdeathtemp, :morttempeffect)
gcpmortrate_region_df = unstack(gcpmortrate_df, :time, :regions, :morttempeffect)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\gcpmortrate.csv", gcpmortrate_region_df)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_gcpmortrate.csv", gcpmortrate_df)

# GCP dead
gcpdead_df = getdataframe(results,:impactdeathtemp, :gcpdead)
gcpdead_region_df = unstack(gcpdead_df, :time, :regions, :gcpdead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\gcpdead.csv", gcpdead_region_df)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_gcpdead.csv", gcpdead_df)

# GCP cost
gcpcost_df = getdataframe(results,:impactdeathtemp, :gcpdeadcost)
gcpcost_region_df = unstack(gcpcost_df, :time, :regions, :gcpdeadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\gcpcost.csv", gcpcost_region_df)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_gcpcost.csv", gcpcost_df)

#####################################################################
# Total Mortality
#####################################################################

#Extract population (in millions) from existing component
population_df = getdataframe(results,:population, :population)
population_region_df = unstack(population_df, :time, :regions, :population)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\population.csv", population_region_df)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_population.csv", population_df)

#Total rate
totmortrate_df = getdataframe(results,:impactdeathmorbidity, :deadrate)
totmortrate_region_df = unstack(totmortrate_df , :time, :regions, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\totmortrate.csv", totmortrate_region_df)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_totmortrate.csv", totmortrate_df)

# Total dead
totaldead_df = getdataframe(results,:impactdeathmorbidity, :dead)
totaldead_region_df = unstack(totaldead_df, :time, :regions, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\totaldead.csv", totaldead_region_df)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_totaldead.csv", totaldead_df)

# Total cost
totalcost_df = getdataframe(results,:impactdeathmorbidity, :deadcost)
totalcost_region_df = unstack(totalcost_df, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\totalcost.csv", totalcost_region_df)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_totalcost.csv", totalcost_df)

#####################################################################
# Direct Comparison of Total Mortality (GCP v. FUND)
#####################################################################

# Run FUND with GCP numbers set to zero (aka, run original FUND)
soloFUND_run = getfund()

#Change parameters to fit this case: replace dead_other (fed by GCP data) with matrix of zeros
solomatrix = zeros(1051,16)

setparameter(soloFUND_run, :impactdeathmorbidity, :dead_other, solomatrix)

#Run model
run(soloFUND_run)

# check to make sure it worked to zero out GCP effect
println(soloFUND_run[:impactdeathmorbidity, :dead_other])

#View dead
solo_FUNDdead = getdataframe(soloFUND_run,:impactdeathmorbidity, :dead)
solo_FUNDdead_unstacked = unstack(solo_FUNDdead, :time, :regions, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\funddead.csv",solo_FUNDdead_unstacked)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_funddead.csv",solo_FUNDdead)

#View cost
solo_FUNDcost = getdataframe(soloFUND_run,:impactdeathmorbidity, :deadcost)
solo_FUNDcost_unstacked = unstack(solo_FUNDcost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\fundcost.csv",solo_FUNDcost_unstacked)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_fundcost.csv",solo_FUNDcost)

#View rate
solo_FUNDrate = getdataframe(soloFUND_run,:impactdeathmorbidity, :deadrate)
solo_FUNDrate_unstacked = unstack(solo_FUNDrate, :time, :regions, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\fundrate.csv",solo_FUNDrate_unstacked)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_fundrate.csv",solo_FUNDrate)

# View population
solo_FUNDpop = getdataframe(soloFUND_run,:population, :population)
solo_FUNDpop_unstacked = unstack(solo_FUNDpop, :time, :regions, :population)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\fundpop.csv",solo_FUNDpop_unstacked)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_fundpop.csv",solo_FUNDpop)

#####################################################################
# Marginal Mortality: FUND and GCP Joint
#####################################################################

# Compute derivatives using finite differencing scheme

# Using one ton pulse for single year
function getmarginaldamages1(;emissionyear=2010,parameters=nothing,yearstoaggregate=1000,gas=:C)
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)

    m1 = getfund(nsteps=yearstorun,params=parameters)
    m2 = getfund(nsteps=yearstorun,params=parameters)
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

# Using one ton pulse each year for ten years
#=function getmarginaldamages10(;emissionyear=2010,parameters=nothing,yearstoaggregate=1000,gas=:C)
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)

    m1 = getfund(nsteps=yearstorun,params=parameters)
    m2 = getfund(nsteps=yearstorun,params=parameters)
    addcomponent(m2, adder, :marginalemission, before=:climateco2cycle)
    addem = zeros(yearstorun+1)
    addem[getindexfromyear(emissionyear):getindexfromyear(emissionyear)+9] = 1.0
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
    # NB that 10000000.0 = because 10 years worth of emissions
    marginaldamage10 = (damage2.-damage1)/10_000_000.0

    return marginaldamage10
end
=#
# View results
marginaldamage1 = getmarginaldamages1()
#marginaldamage10 = getmarginaldamages10()

md1 = DataFrame(marginaldamage1)
#md10 = DataFrame(marginaldamage10)

writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\marginaldamage1.csv",md1)
#writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\marginaldamage10.csv",md10)

###################################################################################
# Marginal with FUND alone
###################################################################################

# Using one ton pulse for single year
function getmarginaldamages1(;emissionyear=2010,parameters=nothing,yearstoaggregate=1000,gas=:C)
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)

    m1 = getfund(nsteps=yearstorun,params=parameters)
    m2 = getfund(nsteps=yearstorun,params=parameters)

    setparameter(m1, :impactdeathmorbidity, :dead_other, zeros(1051,16))
    setparameter(m2, :impactdeathmorbidity, :dead_other, zeros(1051,16))

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

fund_md1 = DataFrame(fund_marginal1)

writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\fund_marginaldamage1.csv",fund_md1)




#=first approach: compute MD and SCC

SCC_1ton = sum(marginaldamage1[2:end,:].*df[2:end,:])
SCC_10ton = sum(marginaldamage10[2:end,:].*df[2:end,:])

base_run = getfund()
marginal_run1 = getfund()
marginal_run2 = getfund()

#Change parameters to fit this case
setparameter(base_run, :Emissions, :x, 1.0)
setparameter(marginal_run1, :Emissions, :x, 1.0)
setparameter(marginal_run2, :Emissions, :x, 1.0)

#Run model
run(base_run)
run(marginal_run1)
run(marginal_run2)

scc = sum(marginaldamageX[2:end,:].*df[2:end,:])

#Temperature
Temp = DataFrame(Base=base_run[:climatedynamics, :temp], Marginal=marginal_run1[:climatedynamics, :temp], High = marginal_run2[:climatedynamics, :temp])
#Damages
Damages = DataFrame(Base=base_run[:damages, :dam_dollar], Low=low_run[:damages, :dam_dollar], High = high_run[:damages, :dam_dollar])=#

#####################################################################
# Test Dynamic Vulnerability
#####################################################################

# establish test models
adapt_basecase = getfund()
adapt_temp = getfund()
adapt_gdp = getfund()
adapt_pop = getfund()

# Change parameter to fit these cases
# Recall, regressions from GCP team furnished 1 valuue per region: hence zeros(16)
setparameter(adapt_temp, :impactdeathtemp, :gammatemp1, zeros(16))
setparameter(adapt_temp, :impactdeathtemp, :gammatemp2, zeros(16))

setparameter(adapt_gdp, :impactdeathtemp, :gammagdppc1, zeros(16))
setparameter(adapt_gdp, :impactdeathtemp, :gammagdppc2, zeros(16))

setparameter(adapt_pop, :impactdeathtemp, :gammapopop1, zeros(16))
setparameter(adapt_pop, :impactdeathtemp, :gammapopop2, zeros(16))

#Run model
run(adapt_basecase)
run(adapt_temp)
run(adapt_gdp)
run(adapt_pop)

# View results
adapt_basecase_gcp = getdataframe(adapt_basecase,:impactdeathtemp, :gcpdead) # in millions
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_basecase_gcp.csv", adapt_basecase_gcp)
adapt_basecase_total = getdataframe(adapt_basecase,:impactdeathmorbidity, :dead) # per person
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_basecase_total.csv", adapt_basecase_total)

adapt_temp_gcp = getdataframe(adapt_temp,:impactdeathtemp, :gcpdead) # recall that this figure is in millions
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_temp_gcp.csv", adapt_temp_gcp)
adapt_temp_total = getdataframe(adapt_temp,:impactdeathmorbidity, :dead) # this one is in per person units
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_temp_total.csv", adapt_temp_total)

adapt_gdp_gcp = getdataframe(adapt_gdp,:impactdeathtemp, :gcpdead) # in millions
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_gdp_gcp.csv", adapt_gdp_gcp)
adapt_gdp_total = getdataframe(adapt_gdp,:impactdeathmorbidity, :dead) # per person
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_gdp_total.csv", adapt_gdp_total)

adapt_pop_gcp = getdataframe(adapt_pop,:impactdeathtemp, :gcpdead) # in millions
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_pop_gcp.csv", adapt_pop_gcp)
adapt_pop_total = getdataframe(adapt_pop,:impactdeathmorbidity, :dead) # per person
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\adapt_pop_total.csv", adapt_pop_total)


#####################################################################
# VSLstandard
#####################################################################

# VSL standard run (all elasticities equal to 1)
# QUESTION: Have currently omitted all morb values. Worth examining morbel, as well?
standard_run = getfund()

#Change parameters to fit this case
setparameter(standard_run, :vslvmorb, :vslel_high, 1.0)
setparameter(standard_run, :vslvmorb, :vslel_mid, 1.0)
#setparameter(standard_run, :vslvmorb, :vslel_low, 1.0)

#Run model
run(standard_run)

# View results with all VSL elasticities = 1.0 (FUND's business as usual)
VSL_standarda = getdataframe(standard_run,:vslvmorb, :vsl)
VSL_standardb = unstack(VSL_standarda, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\vslstandard.csv", VSL_standardb)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_vslstandard.csv", VSL_standarda)

ypc_standard = getdataframe(standard_run, :vslvmorb, :ypc)
ypc_standard_t = unstack(ypc_standard, :time, :regions, :ypc)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\ypcstandard.csv", ypc_standard)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_ypcstandard.csv", ypc_standard_t)

#####################################################################
# VSLaltered_1 (SET VERSION)
#####################################################################

# VSL altered run (elasticities equal to 1.5 and 1.0, per ypc value)
# QUESTION: metric by which to establish 0.5 VSL values? 2.0 values?
altered1_run = getfund()

#Change parameter to fit this case.
setparameter(altered1_run, :vslvmorb, :vslel_high, 1.5)
setparameter(altered1_run, :vslvmorb, :vslel_mid, 1.0)
#setparameter(altered1_run, :vslvmorb, :vslel_low, 0.5)

#Run model
run(altered1_run)

# View results
VSL_altered1a = getdataframe(altered1_run,:vslvmorb, :vsl)
VSL_altered1b = unstack(VSL_altered1a, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\vslaltered1.csv", VSL_altered1b)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_vslaltered1.csv", VSL_altered1a)

# PLOT THE DIFFERENCE FOR ALL YEARS AS A PERCENTAGE CHANGE IN VSL
println(altered1_run[:vslvmorb, :vsl][60,:] .- standard_run[:vslvmorb, :vsl][60,:])

VSLcompare = altered1_run[:vslvmorb, :vsl] .- standard_run[:vslvmorb, :vsl]

VSLpercentchange = (VSLcompare ./ standard_run[:vslvmorb, :vsl]) * 100

VSLplotpercent = DataFrame(VSLpercentchange)
VSLplotdifference = DataFrame(VSLcompare)

writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\VSLpercentchange.csv", VSLplotpercent)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\VSLdifference.csv", VSLplotdifference)


#####################################################################
# VSLaltered_2 (FLEXIBLE VERSION)
#####################################################################

#=VSL altered run (elasticities allowed to vary between 1.5 - or possibly 2.0 - and 0.5)
altered2_run = getfund()

#Change parameter to fit this case.
setparameter(altered2_run, :vslvmorb, :vslel_high, XXXXXXX)
setparameter(altered2_run, :vslvmorb, :vslel_mid, XXXXXXX)
#setparameter(altered2_run, :vslvmorb, :vslel_low, XXXXXXX)

#Run model
run(altered2_run)

# View results
VSL_altered2 = getdataframe(results,:vslvmorb, :vsl)
VSL_altered2 = unstack(VSL_altered2, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\vslaltered2.csv", VSL_altered2)=#

#=Play with plotting options
R"install.packages(ggplot2)"
R"library(ggplot2)"
testplot = scatter(gcpmortrate_df, :time, :regions)
regions = [:USA :CAN :WEU :JPK :ANZ :EEU :FSU :MDE :CAM :LAM :SAS :SEA :CHI :MAF :SSA :SIS]=#
