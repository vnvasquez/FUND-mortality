using Mimi

@defcomp impactdeathtemp begin
    regions = Index()

    #Variables
    logypc             = Variable(index=[time,regions])
    logpopop           = Variable(index=[time,regions])
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
    temp           = Parameter(index=[time,regions])
    #funddead       = Parameter(index=[time,regions])

    #betaconstant   = Parameter(index=[regions])

    gammatemp1     = Parameter(index=[regions])
    gammagdppc1    = Parameter(index=[regions])
    gammapopop1    = Parameter(index=[regions])

    gammatemp2     = Parameter(index=[regions])
    gammagdppc2    = Parameter(index=[regions])
    gammapopop2    = Parameter(index=[regions])

end


function run_timestep(s::impactdeathtemp, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    for r in d.regions

        v.logypc[t, r] = log((p.income[t, r] / p.population[t, r]) * 1000.0)

        v.logpopop[t, r] = log(p.populationin1[t, r] / p.area[t, r])                                                # <- simple popop

        # v.logpopop_new = (populationin1_urban + populationin1_rural) / (area_urban + area_rural)                  #  <- same as simple popop

        # Calc urban from http://www.naturalearthdata.com/downloads/10m-cultural-vectors/ "Urban Areas"

        # logpopop_complex = ((populationin1_urban / area_urban) * (populationin1_urban / populationin1)) +
        # ((populationin1_rural / area_rural) * (populationin1_rural / populationin1))                              # <- complex: includes urban/rural approximation



        # Using CIL data, this amounts to the change in mortality rate from a baseline of 2001-2010
        # For plotting purposes, this value is referred to as "gcpmortrate"
        # UNITS = deaths per person
        v.morttempeffect[t, r] = (p.gammatemp1[r] * p.temp[t , r]) + (p.gammatemp2[r] * (p.temp[t, r])^2) +
                                (p.gammagdppc1[r] * p.temp[t, r] * v.logypc[t, r]) + (p.gammagdppc2[r] * (p.temp[t, r])^2 * v.logypc[t, r]) +
                                (p.gammapopop1[r] * (p.temp[t, r]) * v.logpopop[t, r]) + (p.gammapopop2[r] * (p.temp[t, r])^2 * v.logpopop[t, r])

        # Calculate deaths; multiply by 1 million to achieve same units as dead in impactdeathmorbidity component
        # HOWEVER do not multiply by 1 million until Results.jl component; if do so here will throw results for
        # impactdeathmorbidity via "dead_other" variable
        v.gcpdead[t, r] = v.morttempeffect[t, r] * p.population[t, r] * 1_000_000

        # Calculate cost for strictly GCP data. Divide by 1 billion to have units of $B.
        v.gcpdeadcost[t, r] = (p.vsl[t, r] * v.gcpdead[t, r])/1_000_000_000.0

      end

end
