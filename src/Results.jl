#Run once upon initializing to avoid dict-kv issue
cd("src")

using Mimi

#Load function to construct model
include("fund.jl")

#Create model for test run
results = getfund()
run(results)

#Results
using DataFrames
CILcoeff_results = DataFrame(MortRate=results[:impactdeathtemp, :morttempeffect],DeadTot=results[:impactdeathtemp, :dead],
CostTot=results[:impactdeathtemp, :deadcost])

VSL_results = DataFrame(VSLdiffelast=results[:vslvmorb, :vsl])
