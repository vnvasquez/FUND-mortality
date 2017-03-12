###############################################################
#Run once upon initializing to avoid dict-kv issue. This
#may soon change within Mimi to make the structure more robust.
cd("src")
###############################################################

using Mimi

#Load function to construct model
include("fund.jl")

#Create model for test run
results = getfund()
run(results)

###############################################################
#Create dataframes to view results
###############################################################

using DataArrays, DataFrames

# Mortality rate
mortrate_df = DataFrame(results[:impactdeathtemp, :morttempeffect])
writetable("mortrate_febdata.csv", mortrate_df)

# Total dead
gcpdead_df = DataFrame(results[:impactdeathtemp, :gcpdead])
writetable("gcpdead_febdata.csv", gcpdead_df)

totaldead_df = DataFrame(results[:impactdeathmorbidity, :dead])

# Total cost
totalcost_df = DataFrame(results[:impactdeathmorbidity, :deadcost])

# VSL results
vsl_df = DataFrame(results[:vslvmorb, :vsl])
writetable("vsl_high mid.csv", vsl_df)
