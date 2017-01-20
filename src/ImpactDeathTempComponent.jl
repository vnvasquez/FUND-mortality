using Mimi

@defcomp impactdeathtemp begin
    regions = Index()

    #Parameters
    populationin1  = Parameter(index=[time,regions])
    population     = Parameter(index=[time,regions])
    area           = Parameter(index=[time,regions])
    temp           = Parameter(index=[time,regions])

    betaconstant   = Parameter()

    gammagdppc1    = Parameter()
    gammapopop1    = Parameter()
    gammameantemp1 = Parameter()

    gammagdppc2    = Parameter()
    gammapopop2    = Parameter()
    gammameantemp2 = Parameter()

    #Variables
    popop           = Variable(index=[time,regions])
    morttempeffect1 = Variable(index=[time,regions])
    morttempeffect2 = Variable(index=[time,regions])
    morttemp        = Variable(index=[time,regions])

    dead            = Variable(index=[time,regions])
    deadcost        = Variable(index=[time,regions])

end


function run_timestep(s::impactdeathtemp, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    if t>1
      for r in d.regions

        # Question: why is ypc calculated separately in so many different components rather than just calculated once in socioeconomic?
        v.ypc = p.income[t, r] / p.population[t, r] * 1000.0

        v.popop = p.populationin1[t, r] / p.area[t, r]

        v.morttempeffect1 = p.betaconstant * exp(p.gammagdppc1 * p.ypc[r, t] + p.gammapopop1 * v.popop + p.gammameantemp1 * p.temp[r, t - 7])

        v.morttempeffect2 = p.betaconstant * exp(p.gammagdppc2 * p.ypc[r, t] + p.gammapopop2 * v.popop + p.gammameantemp2 * p.temp[r, t - 7])

        # Using CIL data, this amounts to the change in mortality rate from a baseline of 2001-2010
        v.dead = (v.morttempeffect1 * p.temp[t, r] + v.morttempeffect2 * p.temp[t, r]^2) * p.population[t, r] * 1e6 / 100000.

        v.deadcost[t, r] = p.vsl[t, r] * v.dead[t, r] / 1000000000.0

      end
    end

end
