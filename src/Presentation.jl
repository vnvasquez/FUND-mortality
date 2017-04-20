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

# Set Parameter
setparameter(results, :vslvmorb, :vslel_highest, 1.5)
setparameter(results, :vslvmorb, :vslel_high, 1.5)
setparameter(results, :vslvmorb, :vslel_mid, 1.0)
setparameter(results, :vslvmorb, :vslel_low, 1.0)

# Run
run(results)

# Call necessary packages
using DataArrays, DataFrames

# Verify values for per capita income (to check WB threshold validity)
verify1 = getdataframe(results, :vslvmorb, :ypc)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\verify_ypc.csv", verify1)
unstack(verify1, :time, :regions, :ypc)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\verify_ypcT.csv", verify1)

#####################################################################
# GCP ALONE
#####################################################################

# GCP rate:THESE ARE THE NUMBERS THAT MATCH JR'S RESULTS WHEN MULTIPLIED BY 100_000.00
mortrate_GCP = getdataframe(results,:impactdeathtemp, :morttempeffect)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_GCP.csv", mortrate_GCP)
mortrate_GCP_regional = unstack(mortrate_GCP, :time, :regions, :morttempeffect)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_GCP_regional.csv", mortrate_GCP_regional)

# GCP dead
dead_GCP = getdataframe(results,:impactdeathtemp, :gcpdead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_GCP.csv", dead_GCP)
dead_GCP_regional = unstack(dead_GCP, :time, :regions, :gcpdead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_GCP_regional.csv", dead_GCP_regional)

# GCP cost
cost_GCP = getdataframe(results,:impactdeathtemp, :gcpdeadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_GCP.csv", cost_GCP)
cost_GCP_regional = unstack(cost_GCP, :time, :regions, :gcpdeadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_GCP_regional.csv", cost_GCP_regional)

# GCP VSLs @ 1.5 flex (hardcoded into data csv in current versin of model)
vsl_GCP = getdataframe(results,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_GCP.csv", vsl_GCP)
unstack(vsl_GCP, :time, :regions, :vsl)
vsl_GCP_regional = unstack(vsl_GCP, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_GCP_regional.csv", vsl_GCP_regional)

#####################################################################
# Total (FUND + GCP)
#####################################################################

#Total rate
mortrate_combo = getdataframe(results,:impactdeathmorbidity, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_combo.csv", mortrate_combo)
mortrate_combo_regional = unstack(mortrate_combo, :time, :regions, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_combo_regional.csv", mortrate_combo_regional)

# Total dead
dead_combo = getdataframe(results,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_combo.csv", dead_combo)
dead_combo_regional = unstack(dead_combo, :time, :regions, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_combo_regional.csv", dead_combo_regional)

# Total cost
cost_combo = getdataframe(results,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_combo.csv", cost_combo)
cost_combo_regional = unstack(cost_combo, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_combo_regional.csv", cost_combo_regional)

# Total VSLs @ 1.5 flex (hardcoded into data csv in current versin of model)
vsl_combo = getdataframe(results,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_combo.csv", vsl_combo)
vsl_combo_regional = unstack(vsl_combo, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_combo_regional.csv", vsl_combo_regional)

#####################################################################
# FUND ALONE
#####################################################################

# Run FUND alone to enable direct comparison  (GCP vs. FUND)
soloFUND_run = getfund()

#Change parameters to fit this case: replace dead_other (fed by GCP data) with matrix of zeros
setparameter(soloFUND_run, :impactdeathmorbidity, :dead_other, zeros(1051,16))
# Double check 1.5 values
setparameter(soloFUND_run, :vslvmorb, :vslel_highest, 1.5)
setparameter(soloFUND_run, :vslvmorb, :vslel_high, 1.5)
setparameter(soloFUND_run, :vslvmorb, :vslel_mid, 1.0)
setparameter(soloFUND_run, :vslvmorb, :vslel_low, 1.0)

#Run model
run(soloFUND_run)

# Check to make sure it zeroed out GCP
check1 = println(soloFUND_run[:impactdeathmorbidity, :dead_other])

#FUND dead
dead_FUND = getdataframe(soloFUND_run,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_FUND.csv",dead_FUND)
dead_FUND_regional = unstack(dead_FUND, :time, :regions, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\dead_FUND_regional.csv",dead_FUND_regional)

# FUND cost
cost_FUND = getdataframe(soloFUND_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_FUND.csv", cost_FUND)
cost_FUND_regional = unstack(cost_FUND, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\cost_FUND_regional.csv", cost_FUND_regional)

#FUND rate
mortrate_FUND = getdataframe(soloFUND_run,:impactdeathmorbidity, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_FUND.csv",mortrate_FUND)
mortrate_FUND_regional = unstack(mortrate_FUND, :time, :regions, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\mortrate_FUND_regional.csv",mortrate_FUND_regional)

# FUND VSLs @ 1.5 flex (hardcoded into data csv in current versin of model)
vsl_FUND = getdataframe(soloFUND_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_FUND.csv", vsl_FUND)
vsl_FUND_regional = unstack(vsl_FUND, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\vsl_FUND_regional.csv", vsl_FUND_regional)

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

# View VSLs
VSL_fund10value = getdataframe(fund10_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund10value.csv", VSL_fund10value)
VSL_fund10valueT = unstack(VSL_fund10value, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund10valueT.csv", VSL_fund10valueT)

# View cost
VSL_fund10cost = getdataframe(fund10_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund10cost.csv", VSL_fund10cost)
VSL_fund10costT = unstack(VSL_fund10cost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund10costT.csv", VSL_fund10costT)

#####################################################################
# VSL: 1.0 for all - COMBO
#####################################################################

combo10_run = getfund()

#Change parameters to fit this case
setparameter(combo10_run, :vslvmorb, :vslel_highest, 1.0)
setparameter(combo10_run, :vslvmorb, :vslel_high, 1.0)
setparameter(combo10_run, :vslvmorb, :vslel_mid, 1.0)
setparameter(combo10_run, :vslvmorb, :vslel_low, 1.0)

#Run model
run(combo10_run)

# View VSLs
VSL_combo10value = getdataframe(combo10_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo10value.csv", VSL_combo10value)
VSL_combo10valueT = unstack(VSL_combo10value, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo10valueT.csv", VSL_combo10valueT)

# View cost
VSL_combo10cost = getdataframe(combo10_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo10cost.csv", VSL_combo10cost)
VSL_combo10costT = unstack(VSL_combo10cost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo10costT.csv", VSL_combo10costT)

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

# View VSLs
VSL_fund05value = getdataframe(fund05_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund05value.csv", VSL_fund05value)
VSL_fund05valueT = unstack(VSL_fund05value, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund05valueT.csv", VSL_fund05valueT)

# View cost
VSL_fund05cost = getdataframe(fund05_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund05cost.csv", VSL_fund05cost)
VSL_fund05costT = unstack(VSL_fund05cost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fund05costT.csv", VSL_fund05costT)

#####################################################################
# VSL: 0.5 for all - COMBO
#####################################################################

combo05_run = getfund()

#Change parameters to fit this case
setparameter(combo05_run, :vslvmorb, :vslel_highest, 0.5)
setparameter(combo05_run, :vslvmorb, :vslel_high, 0.5)
setparameter(combo05_run, :vslvmorb, :vslel_mid, 0.5)
setparameter(combo05_run, :vslvmorb, :vslel_low, 0.5)

#Run model
run(combo05_run)

# View VSLs
VSL_combo05value = getdataframe(combo05_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo05value.csv", VSL_combo05value)
VSL_combo05valueT = unstack(VSL_combo05value, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo05valueT.csv", VSL_combo05valueT)

# View cost
VSL_combo05cost = getdataframe(combo05_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo05cost.csv", VSL_combo05cost)
VSL_combo05costT = unstack(VSL_combo05cost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_combo05costT.csv", VSL_combo05costT)

#####################################################################
# VSL: Comparing effect of elasticities across regions
#####################################################################

# FUND 1.5flex vs 1.0
VSL_elastdiff = fund10_run[:vslvmorb, :vsl] .- soloFUND_run[:vslvmorb, :vsl]
VSL_elastpercentchange = (VSL_elastdiff ./ fund10_run[:vslvmorb, :vsl]) * 100
VSL_elastdiff = DataFrame(VSL_elastdiff)
VSL_elastpercentchange = DataFrame(VSL_elastpercentchange)

writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastdiff_15v10.csv", VSL_elastdiff)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastpercentchange_15v10.csv", VSL_elastpercentchange)

# FUND 0.5 vs 1.0
VSL_elastdiff = fund05_run[:vslvmorb, :vsl] .- fund10_run[:vslvmorb, :vsl]
VSL_elastpercentchange = (VSL_elastdiff ./ fund10_run[:vslvmorb, :vsl]) * 100
VSL_elastdiff = DataFrame(VSL_elastdiff)
VSL_elastpercentchange = DataFrame(VSL_elastpercentchange)

writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastdiff_05v10.csv", VSL_elastdiff)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastpercentchange_05v10.csv", VSL_elastpercentchange)

# combo1.5 vs 1.0
VSL_elastdiff = results[:vslvmorb, :vsl] .- combo10_run[:vslvmorb, :vsl]
VSL_elastpercentchange = (VSL_elastdiff ./ combo10_run[:vslvmorb, :vsl]) * 100
VSL_elastdiff = DataFrame(VSL_elastdiff)
VSL_elastpercentchange = DataFrame(VSL_elastpercentchange)

writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastdiff_15v10_combo.csv", VSL_elastdiff)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastpercentchange_15v10_combo.csv", VSL_elastpercentchange)

# Combo 0.5 vs 1.0
VSL_elastdiff = combo05_run[:vslvmorb, :vsl] .- combo10_run[:vslvmorb, :vsl]
VSL_elastpercentchange = (VSL_elastdiff ./ combo10_run[:vslvmorb, :vsl]) * 100
VSL_elastdiff = DataFrame(VSL_elastdiff)
VSL_elastpercentchange = DataFrame(VSL_elastpercentchange)

writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastdiff_05v10_combo.csv", VSL_elastdiff)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_elastpercentchange_05v10_combo.csv", VSL_elastpercentchange)

#####################################################################
# VSL: Extremely Flexible - FUND
#####################################################################

# Here, allow elasticities vary according to ypc value using 4 thresholds.
# This is implemented directly in the new component, so just need to call
# and run a fresh version of the model

# NB Set GCP values to zero to view effect on FUND alone

# Call model
fundflex_run = getfund()

# Set parameters
setparameter(fundflex_run, :impactdeathmorbidity, :dead_other, zeros(1051,16))

# Run model
run(fundflex_run)

# View VSLs
VSL_fundflexvalue = getdataframe(fundflex_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fundflexvalue.csv", VSL_fundflexvalue)
unstack(VSL_fundflexvalue, :time, :regions, :vsl)

# View cost
VSL_fundflexcost = getdataframe(fundflex_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_fundflexcost.csv", VSL_fundflexcost)
unstack(VSL_fundflexcost, :time, :regions, :deadcost)


#####################################################################
# VSL: Extremely Flexible - COMBO
#####################################################################

# Here, allow elasticities vary according to ypc value using 4 thresholds.
# This is implemented directly in the new component, so just need to call
# and run a fresh version of the model

# Call model
comboflex_run = getfund()

# Run model
run(comboflex_run)

# View VSLs
VSL_comboflexvalue = getdataframe(comboflex_run,:vslvmorb, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_comboflexvalue.csv", VSL_comboflexvalue)
unstack(VSL_comboflexvalue, :time, :regions, :vsl)

# View cost
VSL_comboflexcost = getdataframe(comboflex_run,:impactdeathmorbidity, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\VSL_comboflexcost.csv", VSL_comboflexcost)
unstack(VSL_comboflexcost, :time, :regions, :deadcost)

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
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\adapt_baseGCP.csv", adapt_baseGCP)

adapt_baseCOMBO = getdataframe(adapt_basecase,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\adapt_baseCOMBO.csv", adapt_baseCOMBO)

# Without gdp: testing dynamic vulnerability
adapt_gdpGCP = getdataframe(adapt_gdp,:impactdeathtemp, :gcpdead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\adapt_gdpGCP.csv", adapt_gdpGCP)

adapt_gdpCOMBO = getdataframe(adapt_gdp,:impactdeathmorbidity, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\Presentation\\adapt_gdpCOMBO.csv", adapt_gdpCOMBO)
