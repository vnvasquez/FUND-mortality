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

# Zero out double counted elements for integrated model
setparameter(results,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(results,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(results,:impactdeathmorbidity,:resp, zeros(1051,16))

# Run
run(results)

# Call necessary packages
using DataArrays, DataFrames

# Extract populationin1 to use for constructing global mortrate (need population weighted)
results_pop = getdataframe(results, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\results_pop.csv", results_pop)
results_popT = unstack(results_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\results_popT.csv", results_popT)


#####################################################################
# GCP ALONE: VSL FLEX 1.5
#####################################################################

# GCP rate:THESE ARE THE NUMBERS THAT MATCH JR'S RESULTS WHEN MULTIPLIED BY 100_000.00
mortrate_GCP = getdataframe(results,:impactdeathtemp, :morttempeffect)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_GCP.csv", mortrate_GCP)
mortrate_GCP_regional = unstack(mortrate_GCP, :time, :regions, :morttempeffect)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_GCP_regional.csv", mortrate_GCP_regional)

# GCP dead
dead_GCP = getdataframe(results,:impactdeathtemp, :gcpdead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_GCP.csv", dead_GCP)
dead_GCP_regional = unstack(dead_GCP, :time, :regions, :gcpdead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_GCP_regional.csv", dead_GCP_regional)

# GCP cost
cost_GCP = getdataframe(results,:impactdeathtemp, :gcpdeadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_GCP.csv", cost_GCP)
cost_GCP_regional = unstack(cost_GCP, :time, :regions, :gcpdeadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_GCP_regional.csv", cost_GCP_regional)

# GCP VSLs @ 1.5 flex (hardcoded into data csv in current versin of model)
vsl_GCP = getdataframe(results,:vslvmorb, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_GCP.csv", vsl_GCP)
unstack(vsl_GCP, :time, :regions, :vsl)
vsl_GCP_regional = unstack(vsl_GCP, :time, :regions, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_GCP_regional.csv", vsl_GCP_regional)

#####################################################################
# Integrated (FUND + GCP): VSL FLEX 1.5
#####################################################################

#Total rate
mortrate_combo = getdataframe(results,:impactdeathmorbidity, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_combo.csv", mortrate_combo)
mortrate_combo_regional = unstack(mortrate_combo, :time, :regions, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_combo_regional.csv", mortrate_combo_regional)

# Total dead
dead_combo = getdataframe(results,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_combo.csv", dead_combo)
dead_combo_regional = unstack(dead_combo, :time, :regions, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_combo_regional.csv", dead_combo_regional)

# Total cost
cost_combo = getdataframe(results,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_combo.csv", cost_combo)
cost_combo_regional = unstack(cost_combo, :time, :regions, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_combo_regional.csv", cost_combo_regional)

# Total VSLs @ 1.5 flex (hardcoded into data csv in current versin of model)
vsl_combo = getdataframe(results,:vslvmorb, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_combo.csv", vsl_combo)
vsl_combo_regional = unstack(vsl_combo, :time, :regions, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_combo_regional.csv", vsl_combo_regional)

#####################################################################
# FUND ALONE: VSL FLEX 1.5
#####################################################################

# Run FUND alone to enable direct comparison  (GCP vs. FUND)
soloFUND_run = getfund()

#Change parameters to fit this case: replace dead_other (fed by GCP data) with matrix of zeros
setparameter(soloFUND_run, :impactdeathmorbidity, :dead_other, zeros(1051,16))

#Run model
run(soloFUND_run)

# Check to make sure it zeroed out GCP
check1 = println(soloFUND_run[:impactdeathmorbidity, :dead_other])

# Extract populationin1 to use for constructing global mortrate (need population weighted)
soloFUND_pop = getdataframe(soloFUND_run, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\soloFUND_pop.csv", soloFUND_pop)
soloFUND_popT = unstack(soloFUND_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\soloFUND_popT.csv", soloFUND_popT)

###

#FUND dead
dead_FUND = getdataframe(soloFUND_run,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_FUND.csv",dead_FUND)
dead_FUND_regional = unstack(dead_FUND, :time, :regions, :dead)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_FUND_regional.csv",dead_FUND_regional)

# FUND cost
cost_FUND = getdataframe(soloFUND_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_FUND.csv", cost_FUND)
cost_FUND_regional = unstack(cost_FUND, :time, :regions, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_FUND_regional.csv", cost_FUND_regional)

#FUND rate
mortrate_FUND = getdataframe(soloFUND_run,:impactdeathmorbidity, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_FUND.csv",mortrate_FUND)
mortrate_FUND_regional = unstack(mortrate_FUND, :time, :regions, :deadrate)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_FUND_regional.csv",mortrate_FUND_regional)

# FUND VSLs @ 1.5 flex (hardcoded into data csv in current versin of model)
vsl_FUND = getdataframe(soloFUND_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_FUND.csv", vsl_FUND)
vsl_FUND_regional = unstack(vsl_FUND, :time, :regions, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_FUND_regional.csv", vsl_FUND_regional)

#####################################################################
# VSL: 1.0 for all - FUND
#####################################################################

fund10_run = getfund()

#Change parameters to fit this case
setparameter(fund10_run, :vslvmorb, :vslel_highest, 1.0)
setparameter(fund10_run, :vslvmorb, :vslel_high, 1.0)
setparameter(fund10_run, :vslvmorb, :vslel_mid, 1.0)
setparameter(fund10_run, :vslvmorb, :vslel_low, 1.0)
setparameter(fund10_run, :impactdeathmorbidity, :dead_other, zeros(1051,16))

#Run model
run(fund10_run)

# Extract populationin1 to use for constructing global mortrate (need population weighted)
fund10_pop = getdataframe(fund10_run, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\fund10_pop.csv",fund10_pop)
fund10_popT = unstack(fund10_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\fund10_popT.csv", fund10_popT)

###

# View VSLs
VSL_fund10value = getdataframe(fund10_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund10value.csv", VSL_fund10value)
VSL_fund10valueT = unstack(VSL_fund10value, :time, :regions, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund10valueT.csv", VSL_fund10valueT)

# View cost
VSL_fund10cost = getdataframe(fund10_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund10cost.csv", VSL_fund10cost)
VSL_fund10costT = unstack(VSL_fund10cost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund10costT.csv", VSL_fund10costT)

#####################################################################
# VSL: 1.0 for all - COMBO
#####################################################################

combo10_run = getfund()

#Change parameters to fit this case
setparameter(combo10_run, :vslvmorb, :vslel_highest, 1.0)
setparameter(combo10_run, :vslvmorb, :vslel_high, 1.0)
setparameter(combo10_run, :vslvmorb, :vslel_mid, 1.0)
setparameter(combo10_run, :vslvmorb, :vslel_low, 1.0)

# Zero out double counted elements for integrated model
setparameter(combo10_run,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(combo10_run,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(combo10_run,:impactdeathmorbidity,:resp, zeros(1051,16))

#Run model
run(combo10_run)

# Extract populationin1 to use for constructing global mortrate (need population weighted)
combo10_pop = getdataframe(combo10_run, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\combo10_pop.csv",combo10_pop)
combo10_popT = unstack(combo10_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\combo10_popT.csv", combo10_popT)

###

# View VSLs
VSL_combo10value = getdataframe(combo10_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo10value.csv", VSL_combo10value)
VSL_combo10valueT = unstack(VSL_combo10value, :time, :regions, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo10valueT.csv", VSL_combo10valueT)

# View cost
VSL_combo10cost = getdataframe(combo10_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo10cost.csv", VSL_combo10cost)
VSL_combo10costT = unstack(VSL_combo10cost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo10costT.csv", VSL_combo10costT)

#####################################################################
# VSL: 0.5 for all - FUND
#####################################################################

fund05_run = getfund()

#Change parameters to fit this case
setparameter(fund05_run, :vslvmorb, :vslel_highest, 0.5)
setparameter(fund05_run, :vslvmorb, :vslel_high, 0.5)
setparameter(fund05_run, :vslvmorb, :vslel_mid, 0.5)
setparameter(fund05_run, :vslvmorb, :vslel_low, 0.5)
setparameter(fund05_run, :impactdeathmorbidity, :dead_other, zeros(1051,16))

#Run model
run(fund05_run)

# Extract populationin1 to use for constructing global mortrate (need population weighted)
fund05_pop = getdataframe(fund05_run, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\fund05_pop.csv",fund05_pop)
fund05_popT = unstack(fund05_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\fund05_popT.csv", fund05_popT)

###

# View VSLs
VSL_fund05value = getdataframe(fund05_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund05value.csv", VSL_fund05value)
VSL_fund05valueT = unstack(VSL_fund05value, :time, :regions, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund05valueT.csv", VSL_fund05valueT)

# View cost
VSL_fund05cost = getdataframe(fund05_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund05cost.csv", VSL_fund05cost)
VSL_fund05costT = unstack(VSL_fund05cost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund05costT.csv", VSL_fund05costT)

#####################################################################
# VSL: 0.5 for all - COMBO
#####################################################################

combo05_run = getfund()

#Change parameters to fit this case
setparameter(combo05_run, :vslvmorb, :vslel_highest, 0.5)
setparameter(combo05_run, :vslvmorb, :vslel_high, 0.5)
setparameter(combo05_run, :vslvmorb, :vslel_mid, 0.5)
setparameter(combo05_run, :vslvmorb, :vslel_low, 0.5)

# Zero out double counted elements for integrated model
setparameter(combo05_run,:impactdeathmorbidity,:cardheat, zeros(1051,16))
setparameter(combo05_run,:impactdeathmorbidity,:cardcold, zeros(1051,16))
setparameter(combo05_run,:impactdeathmorbidity,:resp, zeros(1051,16))

#Run model
run(combo05_run)

# Extract populationin1 to use for constructing global mortrate (need population weighted)
combo05_pop = getdataframe(combo05_run, :population, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\combo05_pop.csv",combo05_pop)
combo05_popT = unstack(combo05_pop, :time, :regions, :populationin1)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\combo05_popT.csv", combo05_popT)

###

# View VSLs
VSL_combo05value = getdataframe(combo05_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo05value.csv", VSL_combo05value)
VSL_combo05valueT = unstack(VSL_combo05value, :time, :regions, :vsl)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo05valueT.csv", VSL_combo05valueT)

# View cost
VSL_combo05cost = getdataframe(combo05_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo05cost.csv", VSL_combo05cost)
VSL_combo05costT = unstack(VSL_combo05cost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo05costT.csv", VSL_combo05costT)

#####################################################################
# VSL: Comparing effect of elasticities across regions
#####################################################################

# FUND 1.5flex vs 1.0
VSL_elastdiff = fund10_run[:vslvmorb, :vsl] .- soloFUND_run[:vslvmorb, :vsl]
VSL_elastpercentchange = (VSL_elastdiff ./ fund10_run[:vslvmorb, :vsl]) * 100
VSL_elastdiff = DataFrame(VSL_elastdiff)
VSL_elastpercentchange = DataFrame(VSL_elastpercentchange)

writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastdiff_15v10.csv", VSL_elastdiff)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastpercentchange_15v10.csv", VSL_elastpercentchange)

# FUND 0.5 vs 1.0
VSL_elastdiff = fund05_run[:vslvmorb, :vsl] .- fund10_run[:vslvmorb, :vsl]
VSL_elastpercentchange = (VSL_elastdiff ./ fund10_run[:vslvmorb, :vsl]) * 100
VSL_elastdiff = DataFrame(VSL_elastdiff)
VSL_elastpercentchange = DataFrame(VSL_elastpercentchange)

writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastdiff_05v10.csv", VSL_elastdiff)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastpercentchange_05v10.csv", VSL_elastpercentchange)

# combo1.5 vs 1.0
VSL_elastdiff = results[:vslvmorb, :vsl] .- combo10_run[:vslvmorb, :vsl]
VSL_elastpercentchange = (VSL_elastdiff ./ combo10_run[:vslvmorb, :vsl]) * 100
VSL_elastdiff = DataFrame(VSL_elastdiff)
VSL_elastpercentchange = DataFrame(VSL_elastpercentchange)

writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastdiff_15v10_combo.csv", VSL_elastdiff)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastpercentchange_15v10_combo.csv", VSL_elastpercentchange)

# Combo 0.5 vs 1.0
VSL_elastdiff = combo05_run[:vslvmorb, :vsl] .- combo10_run[:vslvmorb, :vsl]
VSL_elastpercentchange = (VSL_elastdiff ./ combo10_run[:vslvmorb, :vsl]) * 100
VSL_elastdiff = DataFrame(VSL_elastdiff)
VSL_elastpercentchange = DataFrame(VSL_elastpercentchange)

writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastdiff_05v10_combo.csv", VSL_elastdiff)
writetable("C:\\Users\\Valer\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastpercentchange_05v10_combo.csv", VSL_elastpercentchange)
