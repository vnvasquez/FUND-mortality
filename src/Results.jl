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

#####################################################################
# GCP Mortality: Create dataframes to view results
#####################################################################

# GCP rate
gcpmortrate_df = getdataframe(results,:impactdeathtemp, :morttempeffect)
gcpmortrate_region_df = unstack(gcpmortrate_df, :time, :regions, :morttempeffect)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\gcpmortrate.csv", gcpmortrate_region_df)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\t_gcpmortrate.csv", gcpmortrate_df)

#=Play with plotting options
R"install.packages(ggplot2)"
R"library(ggplot2)"
testplot = scatter(gcpmortrate_df, :time, :regions)
regions = [:USA :CAN :WEU :JPK :ANZ :EEU :FSU :MDE :CAM :LAM :SAS :SEA :CHI :MAF :SSA :SIS]=#

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
# Total Mortality: Create dataframes to view results
#####################################################################

#= Total rate
totmortrate_df = DataFrame(results[:impactdeathmorbidity, :morttempeffect])
totmortrate_region_df = unstack(totmortrate_df , :time, :regions, :morttempeffect)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\totmortrate_febdata.csv", totmortrate_region_df)=#

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
# VSLstandard: Create dataframes to view results
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
VSL_standard = getdataframe(results,:vslvmorb, :vsl)
VSL_standard = unstack(VSL_standard, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\vslstandard.csv", VSL_standard)

#####################################################################
# VSLaltered_1 (SET VERSION): Create dataframes to view results
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
VSL_altered1 = getdataframe(results,:vslvmorb, :vsl)
VSL_altered1 = unstack(VSL_altered1, :time, :regions, :vsl)
writetable("C:\\Users\\Valeri\\Dropbox\\Master\\Data\\Results\\vslaltered1.csv", VSL_altered1)

#####################################################################
# VSLaltered_2 (FLEXIBLE VERSION): Create dataframes to view results
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
