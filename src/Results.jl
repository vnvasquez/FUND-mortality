#Load function to construct model
include("fund.jl")

#Create model for test run
testrun = zeros(length(1950:3000));
testrun = getfund(testrun);
run(testrun)

#Results
CILcoeff_results = DataFrame(MortRate=testrun[:impactdeathtemp, :morttempeffect], DeadTot=testrun[:impactdeathtemp, :dead], CostTot=testrun[:impactdeathtemp, :deadcost])
