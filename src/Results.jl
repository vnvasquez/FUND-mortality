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

#####################################################################
# MORTALITY: Create dataframes to view results
#####################################################################

using DataArrays, DataFrames

# GCP rate
mortrate_df = DataFrame(results[:impactdeathtemp, :morttempeffect])
writetable("mortrate_febdata.csv", mortrate_df)

# GCP dead
gcpdead_df = DataFrame(results[:impactdeathtemp, :gcpdead])
writetable("gcpdead_febdata.csv", gcpdead_df)

# Total rate - calculate?

# Total dead
totaldead_df = DataFrame(results[:impactdeathmorbidity, :dead])

# Total cost
totalcost_df = DataFrame(results[:impactdeathmorbidity, :deadcost])

#####################################################################
# VSLstandard: Create dataframes to view results
#####################################################################

# VSL standard run (all elasticities equal to 1)
standard_run = getfund()

#Change parameters to fit this case
setparameter(standard_run, :vslvmorb, :vslel_high, 1.0)
setparameter(standard_run, :vslvmorb, :vslel_mid, 1.0)

#Run model
run(standard_run)

# View results with all VSL elasticities = 1.0 (FUND's business as usual)
VSL_standard = DataFrame(standard_run[:vslvmorb, :vsl])
writetable("vslstandard_febdata.csv", VSL_standard)

#####################################################################
# VSLaltered_1 (SET VERSION): Create dataframes to view results
#####################################################################

# VSL altered run (elasticities equal to 1.5 and 1.0, per ypc value)
# QUESTION: metric by which to establish 0.5 VSL values? 2.0 values?
altered1_run = getfund()

#Change parameter to fit this case.
setparameter(altered1_run, :vslvmorb, :vslel_high, 1.5)
setparameter(altered1_run, :vslvmorb, :vslel_mid, 1.0)

#Run model
run(altered1_run)

# View results
VSL_altered1 = DataFrame(altered1_run[:vslvmorb, :vsl])
writetable("vslaltered1_febdata.csv", VSL_altered1)

#####################################################################
# VSLaltered_2 (FLEXIBLE VERSION): Create dataframes to view results
#####################################################################

# VSL altered run (elasticities allowed to vary between 1.5 and 0.5)
altered2_run = getfund()

#Change parameter to fit this case.
setparameter(altered2_run, :vslvmorb, :vslel_high, XXXXXXX)
setparameter(altered1_run, :vslvmorb, :vslel_mid, XXXXXXX)

#Run model
run(altered2_run)

# View results
VSL_altered2 = DataFrame(altered2_run[:vslvmorb, :vsl])
writetable("vslaltered2_febdata.csv", VSL_altered2)
