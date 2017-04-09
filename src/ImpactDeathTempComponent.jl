using Mimi

@defcomp impactdeathtemp begin
    regions = Index()

    #Variables
    ypc                = Variable(index=[time,regions])
    logypc             = Variable(index=[time,regions])
    morttempeffect     = Variable(index=[time,regions])
    gcpdead            = Variable(index=[time,regions])
    dead               = Variable(index=[time,regions])
    gcpdeadcost        = Variable(index=[time,regions])

    #Parameters
    vsl            = Parameter(index=[time,regions])
    populationin1  = Parameter(index=[time,regions])
    population     = Parameter(index=[time,regions])
    income         = Parameter(index=[time,regions])
    area           = Parameter(index=[time,regions])
    temp           = Parameter(index=[time])
    #funddead       = Parameter(index=[time,regions])

    #betaconstant   = Parameter(index=[regions])

    gammatemp1     = Parameter(index=[regions])
    gammatemp2     = Parameter(index=[regions])
    gammagdppc     = Parameter(index=[regions])

end


function run_timestep(s::impactdeathtemp, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.regions

        # Adjusted for inflation: 1995 to 2005 USD https://www.bls.gov/data/inflation_calculator.htm
        v.ypc[t, r] = ((p.income[t, r] * 1.28) / p.population[t, r]) * 1_000                                 # <- income = billions USD'95, population = millions,
                                                                                                             #    then *1.28 for inflation and *1_000 to even out units
        v.logypc[t, r] = log(v.ypc[t, r])

        # v.logpopop_new = (populationin1_urban + populationin1_rural) / (area_urban + area_rural)           #  <- same as simple popop

        # Calc urban from http://www.naturalearthdata.com/downloads/10m-cultural-vectors/ "Urban Areas"

        # logpopop_complex = ((populationin1_urban / area_urban) * (populationin1_urban / populationin1)) +
        # ((populationin1_rural / area_rural) * (populationin1_rural / populationin1))                       # <- complex: includes urban/rural approximation


        # Using CIL data, this amounts to the change in mortality rate from a baseline of 2001-2010
        # For plotting purposes, this value is referred to as "gcpmortrate"
        # UNITS = deaths per person
        v.morttempeffect[t, r] = (p.gammatemp1[r] * p.temp[t] +
                                  p.gammatemp2[r] * p.temp[t]^2) * exp(p.gammagdppc[r] * v.logypc[t, r])


        # Calculate deaths; multiply by 1 million to achieve same units as dead in impactdeathmorbidity component
        # HOWEVER do not multiply by 1 million until Results.jl component; if do so here will throw results for
        # impactdeathmorbidity via "dead_other" variable
        v.gcpdead[t, r] = (v.morttempeffect[t, r] * p.population[t, r] * 1_000_000)

        # Calculate cost for strictly GCP data. Divide by 1 billion to have units of $B.
        v.gcpdeadcost[t, r] = (p.vsl[t, r] * v.gcpdead[t, r])/1_000_000_000.0

      end

end
