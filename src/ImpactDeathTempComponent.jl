using Mimi

@defcomp impactdeathtemp begin
    regions = Index()

    #Variables
    logypc             = Variable(index=[time,regions])
    logpopop           = Variable(index=[time,regions])
    morttempeffect     = Variable(index=[time,regions])
    gcpdead            = Variable(index=[time,regions])
    dead               = Variable(index=[time,regions])
    deadcost           = Variable(index=[time,regions])

    #Parameters
    vsl            = Parameter(index=[time,regions])
    populationin1  = Parameter(index=[time,regions])
    population     = Parameter(index=[time,regions])
    income         = Parameter(index=[time,regions])
    area           = Parameter(index=[time,regions])
    temp           = Parameter(index=[time,regions])
    funddead       = Parameter(index=[time,regions])

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

    if t>7

      for r in d.regions

        v.logypc[t, r] = log(p.income[t, r] / p.population[t, r] * 1000.0)

        v.logpopop[t, r] = log(p.populationin1[t, r] / p.area[t, r])

        # Using CIL data, this amounts to the change in mortality rate from a baseline of 2001-2010
        v.morttempeffect[t, r] = (p.gammatemp1[r] * p.temp[t - 7, r]) + (p.gammatemp2[r] * (p.temp[t - 7, r])^2) +
                                (p.gammagdppc1[r] * p.temp[t - 7, r] * v.logypc[t, r]) + (p.gammagdppc2[r] * (p.temp[t - 7, r])^2 * v.logypc[t, r]) +
                                (p.gammapopop1[r] * (p.temp[t - 7, r]) * v.logpopop[t, r]) + (p.gammapopop2[r] * (p.temp[t - 7, r])^2 * v.logpopop[t, r])

        # Calculate number dead
        v.gcpdead[t, r] = v.morttempeffect[t,r] * p.population[t, r]

        if t>=8

          for r in d.regions

            v.dead[t, r] = (v.gcpdead[t, r] - v.gcpdead[8, r]) + p.funddead[8, r]

          end

        # Cost
        v.deadcost[t, r] = p.vsl[t, r] * v.dead[t, r] / 1000000000.0

      end

    end

  end

end
