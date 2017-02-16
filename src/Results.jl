cd("src")

using Mimi

#Load function to construct model
include("fund.jl")

#Create model for test run
results = getfund()
run(results)

#Results
CILcoeff_results = DataFrame(MortRate=results[:impactdeathtemp, :morttempeffect], DeadTot=testrun[:impactdeathtemp, :dead], CostTot=testrun[:impactdeathtemp, :deadcost])

VSL_results = DataFrame(VSLdiffelast=results[:vslvmorb, :vsl])
