using Mimi

@defcomp impactdeathtemp begin
    regions = Index()

    #Parameters
    vsl            = Parameter(index=[time,regions])
    populationin1  = Parameter(index=[time,regions])
    population     = Parameter(index=[time,regions])
    income         = Parameter(index=[time,regions])
    area           = Parameter(index=[time,regions])
    temp           = Parameter(index=[time])

    betaconstant   = Parameter()

    gammatemp1     = Parameter()
    gammagdppc1    = Parameter()
    gammapopop1    = Parameter()

    gammatemp2     = Parameter()
    gammagdppc2    = Parameter()
    gammapopop2    = Parameter()

    #Variables
    logypc             = Variable(index=[time,regions])
    logpopop           = Variable(index=[time,regions])
    morttempeffect     = Variable(index=[time,regions])
    dead               = Variable(index=[time,regions])
    deadcost           = Variable(index=[time,regions])

end


function run_timestep(s::impactdeathtemp, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    if t>1
      for r in d.regions

        v.logypc = log(p.income[t, r] / p.population[t, r] * 1000.0)

        v.logpopop = log(p.populationin1[t, r] / p.area[t, r])

        # Using CIL data, this amounts to the change in mortality rate from a baseline of 2001-2010
        v.morttempeffect = p.betaconstant + (p.gammatemp1 * p.temp[t - 7]) + (p.gammatemp2 * (p.temp[t - 7])^2) + (p.gammagdppc1 * p.temp[t - 7] * p.logypc[r, t]) +
                          (p.gammagdppc2 * (p.temp[t - 7])^2 * p.logypc[r, t]) + (p.gammapopop1 * (p.temp[t - 7]) * v.logpopop) + (p.gammapopop2 * (p.temp[t - 7])^2 * v.logpopop)

        # Calculate number dead
        v.dead = v.morttempeffect * p.population[t, r] * 1e6 / 100000.

        # Cost
        v.deadcost[t, r] = p.vsl[t, r] * v.dead[t, r] / 1000000000.0

      end
    end

end
