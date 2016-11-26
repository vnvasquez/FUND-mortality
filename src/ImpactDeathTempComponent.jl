using Mimi

@defcomp impactdeathtemp begin
    regions = Index()

    #Parameters
    populationin1  = Parameter(index=[time,regions])
    population     = Parameter(index=[time,regions])
    area           = Parameter(index=[time,regions])
    temp           = Parameter(index=[time,regions])

    betaconstant1  = Parameter()
    gammagdppc1    = Parameter()
    gammapopop1    = Parameter()
    gammameantemp1 = Parameter()

    betaconstant2  = Parameter()
    gammagdppc2    = Parameter()
    gammapopop2    = Parameter()
    gammameantemp2 = Parameter()

    #Variables
    popop           = Variable(index=[time,regions])
    morttempeffect1 = Variable(index=[time,regions])
    morttempeffect2 = Variable(index=[time,regions])
    morttemp        = Variable(index=[time,regions])
end


function run_timestep(s::impactdeathtemp, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    if t>1
      for r in d.regions
        v.popop = p.populationin1[t, r] / p.area[t, r]

        v.morttempeffect1 = p.betaconstant1 * exp(p.gammagdppc1 * p.ypc[r, t] + p.gammapopop1 * v.popop + p.gammameantemp1 * p.temp[r, t - 7])

        v.morttempeffect2 = p.betaconstant2 * exp(p.gammagdppc2 * p.ypc[r, t] + p.gammapopop2 * v.popop + p.gammameantemp2 * p.temp[r, t - 7])

        v.morttemp = (v.morttempeffect1 * p.temp[t, r] + v.morttempeffect2 * p.temp[t, r]^2) * p.population[t, r] * 1e6 / 100000.
      end
    end
    
end
