#####################################################################
# Run once upon initializing to avoid dict-kv issue. This
# may soon change within Mimi to make the structure more robust.
cd("src")
#####################################################################

# Call necessary packages
using Mimi
using DataArrays, DataFrames, Plots, PyPlot, StatPlots, RCall
# For StatPlots, which is necessary due to DataFrames incompatibility
gr(size=(400,300))

######################################################################
# Integrated Model: Rates, Total Dead, Costs
######################################################################

#Load function to construct model
include("fund.jl")

#Create model for test run
results = getfund()

# Zero out double counted elements for integrated model
setparameter(results,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(results,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(results,:impactdeathmorbidity,:resp, zeros(1051,16))
#=setparameter(results, :socioeconomic, :runwithoutdamage, true)
setparameter(results, :population, :runwithoutpopulationperturbation, true)=#

# Run
run(results)

#check values
verify1 = getdataframe(results, :impactdeathtemp, :ypc)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\verify_ypc.csv", verify1)
unstack(verify1, :time, :regions, :ypc)

# Extract populationin1 to use for constructing global mortrate (need population weighted)
results_pop = getdataframe(results, :population, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\results_pop.csv",results_pop)
results_popT = unstack(results_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\results_popcT.csv", results_popT)

###

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
# GCP Model: Rates, Total Dead, Costs
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
# FUND Model: Rates, Total Dead, Costs
#####################################################################

# Run FUND alone to enable direct comparison  (GCP vs. FUND)
soloFUND_run = getfund()

#Change parameters to fit this case: replace dead_other (fed by GCP data) with matrix of zeros
setparameter(soloFUND_run, :impactdeathmorbidity, :dead_other, zeros(1051,16))

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
# Marginal Damages - INTEGRATED MODEL
#####################################################################
# Compute derivatives using finite differencing scheme

# Using one ton pulse for single year (if desire 1 ton/year for ten years
# or if wish to compare other gases, see original code)
# Source: marginaldamages3 component, FUND3.9 JUlia version
function getmarginaldamages1(;emissionyear=2010,parameters=nothing,yearstoaggregate=1000,gas=:C)
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)

    m1 = getfund(nsteps=yearstorun,params=parameters)
    m2 = getfund(nsteps=yearstorun,params=parameters)

    # Zero out double counted elements for integrated model in both runs
    setparameter(m1,:impactdeathmorbidity,:cardheat, zeros(1051,16))
    setparameter(m1,:impactdeathmorbidity,:cardcold, zeros(1051,16))
    setparameter(m1,:impactdeathmorbidity,:resp, zeros(1051,16))

    setparameter(m2,:impactdeathmorbidity,:cardheat, zeros(1051,16))
    setparameter(m2,:impactdeathmorbidity,:cardcold, zeros(1051,16))
    setparameter(m2,:impactdeathmorbidity,:resp, zeros(1051,16))

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
marginaldamage = getmarginaldamages1()
marginal_combo = DataFrame(marginaldamage)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\marginal_combo.csv", marginal_combo)

#####################################################################
# SCC - INTEGRATED MODEL
#####################################################################

function marginaldamage3(;emissionyear=2010,parameters=nothing,yearstoaggregate=1000,gas=:C,useequityweights=false,eta=1.0,prtp=0.001)
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)

    m1, m2 = getmarginalmodels(emissionyear=emissionyear, parameters=parameters,yearstorun=yearstorun,gas=gas)

    damage1 = m1[:impactaggregation,:loss]
    # Take out growth effect effect of run 2 by transforming
    # the damage from run 2 into % of GDP of run 2, and then
    # multiplying that with GDP of run 1
    damage2 = m2[:impactaggregation,:loss]./m2[:socioeconomic,:income].*m1[:socioeconomic,:income]

    # Calculate the marginal damage between run 1 and 2 for each
    # year/region
    marginaldamage = (damage2.-damage1)/10000000.0

    ypc = m1[:socioeconomic,:ypc]

    df = zeros(yearstorun+1,16)
    if !useequityweights
        for r=1:16
            x = 1.
            for t=getindexfromyear(emissionyear):yearstorun
                df[t,r] = x
                gr = (ypc[t,r]-ypc[t-1,r])/ypc[t-1,r]
                x = x / (1. + prtp + eta * gr)
            end
        end
    else
        globalypc = m1[:socioeconomic,:globalypc]
        df = float64([t>=getindexfromyear(emissionyear) ? (globalypc[getindexfromyear(emissionyear)]/ypc[t,r])^eta / (1.0+prtp)^(t-getindexfromyear(emissionyear)) : 0.0 for t=1:yearstorun,r=1:16])
    end

    scc = sum(marginaldamage[2:end,:].*df[2:end,:])

    return scc
end

# View results
scc = marginaldamage3()
scc_combo = DataFrame(scc)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\scc_combo.csv", scc_combo)



###################################################################################
# Marginal Damages - FUND MODEL ALONE
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


#####################################################################
# SCC - FUND MODEL ALONE
#####################################################################

function marginaldamage3(;emissionyear=2010,parameters=nothing,yearstoaggregate=1000,gas=:C,useequityweights=false,eta=1.0,prtp=0.001)
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)

    m1, m2 = getmarginalmodels(emissionyear=emissionyear, parameters=parameters,yearstorun=yearstorun,gas=gas)
    # Zero out GCP numbers for both model runs
    setparameter(m1, :impactdeathmorbidity, :dead_other, zeros(1051,16))
    setparameter(m2, :impactdeathmorbidity, :dead_other, zeros(1051,16))

    damage1 = m1[:impactaggregation,:loss]
    # Take out growth effect effect of run 2 by transforming
    # the damage from run 2 into % of GDP of run 2, and then
    # multiplying that with GDP of run 1
    damage2 = m2[:impactaggregation,:loss]./m2[:socioeconomic,:income].*m1[:socioeconomic,:income]

    # Calculate the marginal damage between run 1 and 2 for each
    # year/region
    marginaldamage = (damage2.-damage1)/10000000.0

    ypc = m1[:socioeconomic,:ypc]

    df = zeros(yearstorun+1,16)
    if !useequityweights
        for r=1:16
            x = 1.
            for t=getindexfromyear(emissionyear):yearstorun
                df[t,r] = x
                gr = (ypc[t,r]-ypc[t-1,r])/ypc[t-1,r]
                x = x / (1. + prtp + eta * gr)
            end
        end
    else
        globalypc = m1[:socioeconomic,:globalypc]
        df = float64([t>=getindexfromyear(emissionyear) ? (globalypc[getindexfromyear(emissionyear)]/ypc[t,r])^eta / (1.0+prtp)^(t-getindexfromyear(emissionyear)) : 0.0 for t=1:yearstorun,r=1:16])
    end

    scc = sum(marginaldamage[2:end,:].*df[2:end,:])

    return scc
end



#=Play with plotting options
R"install.packages(ggplot2)"
R"library(ggplot2)"
testplot = scatter(gcpmortrate_df, :time, :regions)
regions = [:USA :CAN :WEU :JPK :ANZ :EEU :FSU :MDE :CAM :LAM :SAS :SEA :CHI :MAF :SSA :SIS]=#
