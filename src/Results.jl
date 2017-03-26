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

#=Play with plotting options
R"install.packages(ggplot2)"
R"library(ggplot2)"
testplot = scatter(gcpmortrate_df, :time, :regions)
regions = [:USA :CAN :WEU :JPK :ANZ :EEU :FSU :MDE :CAM :LAM :SAS :SEA :CHI :MAF :SSA :SIS]=#

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

println(soloFUND_run[:impactdeathmorbidity, :dead_other])

#Change parameters to fit this case: replace dead_other (fed by GCP data) with matrix of zeros
setparameter(soloFUND_run, :impactdeathmorbidity, :dead_other, zeros(1051,16))

#Run model
run(soloFUND_run)

#View dead
solo_FUNDdead = getdataframe(results,:impactdeathmorbidity, :dead)
solo_FUNDdead_unstacked = unstack(solo_FUNDdead, :time, :regions, :dead)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\funddead.csv",solo_FUNDdead_unstacked)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_funddead.csv",solo_FUND)

#View cost
solo_FUNDcost = getdataframe(results,:impactdeathmorbidity, :deadcost)
solo_FUNDcost_unstacked = unstack(solo_FUNDcost, :time, :regions, :deadcost)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\fundcost.csv",solo_FUNDcost_unstacked)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_fundcost.csv",solo_FUNDcost)

#View rate
solo_FUNDrate = getdataframe(results,:impactdeathmorbidity, :deadrate)
solo_FUNDrate_unstacked = unstack(solo_FUNDrate, :time, :regions, :deadrate)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\fundrate.csv",solo_FUNDrate_unstacked)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_fundrate.csv",solo_FUNDrate)


#####################################################################
# Marginal Mortality
#####################################################################

# Compute derivatives using finite differencing scheme







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
VSL_standarda = getdataframe(results,:vslvmorb, :vsl)
VSL_standardb = unstack(VSL_standarda, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\vslstandard.csv", VSL_standardb)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_vslstandard.csv", VSL_standarda)

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
VSL_altered1a = getdataframe(results,:vslvmorb, :vsl)
VSL_altered1b = unstack(VSL_altered1a, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\vslaltered1.csv", VSL_altered1b)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_vslaltered1.csv", VSL_altered1a)

# PLOT THE DIFFERENCE FOR ALL YEARS AS A PERCENTAGE CHANGE IN VSL
println(altered1_run[:vslvmorb, :vsl][60,:] .- standard_run[:vslvmorb, :vsl][60,:])

VSLcompare = altered1_run[:vslvmorb, :vsl] .- standard_run[:vslvmorb, :vsl]

VSLpercentchange = VSLcompare ./ standard_run[:vslvmorb, :vsl]

VSLplot = DataFrame(VSLpercentchange)

writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\VSLpercentchange.csv", VSLpercentchange)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\VSLdifference.csv", VSLcompare)


#####################################################################
# VSLaltered_2 (FLEXIBLE VERSION)
#####################################################################

# VSL altered run (elasticities allowed to vary between 1.5 - or possibly 2.0 - and 0.5)
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
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\vslaltered2.csv", VSL_altered2)
