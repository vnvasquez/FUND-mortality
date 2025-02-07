﻿using Mimi

@defcomp impactdeathmorbidity begin
    regions = Index()

    dead = Variable(index=[time,regions])
    yll = Variable(index=[time,regions])
    yld = Variable(index=[time,regions])
    deadcost = Variable(index=[time,regions])
    # added March 2017
    deadrate = Variable(index=[time,regions])
    #morbcost = Variable(index=[time,regions])
    vsl = Parameter(index=[time,regions])
    #vmorb = Parameter(index=[time,regions])

    d2ld = Parameter(index=[regions])
    d2ls = Parameter(index=[regions])
    d2lm = Parameter(index=[regions])
    d2lc = Parameter(index=[regions])
    d2lr = Parameter(index=[regions])
    d2dd = Parameter(index=[regions])
    d2ds = Parameter(index=[regions])
    d2dm = Parameter(index=[regions])
    d2dc = Parameter(index=[regions])
    d2dr = Parameter(index=[regions])

    dengue = Parameter(index=[time,regions])
    schisto = Parameter(index=[time,regions])
    malaria = Parameter(index=[time,regions])
    cardheat = Parameter(index=[time,regions])
    cardcold = Parameter(index=[time,regions])
    resp = Parameter(index=[time,regions])
    diadead = Parameter(index=[time,regions])
    hurrdead = Parameter(index=[time,regions])
    extratropicalstormsdead = Parameter(index=[time,regions])
    population = Parameter(index=[time,regions])
    diasick = Parameter(index=[time,regions])

    # Other sources of death (GCPdead connected here; does not include additional metrics)
    dead_other = Parameter(index=[time,regions])

    # Other sources of sickness
    sick_other = Parameter(index=[time,regions])
end

function run_timestep(s::impactdeathmorbidity, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    if t>1
        for r in d.regions
            v.dead[t, r] = p.dengue[t, r] + p.schisto[t, r] + p.malaria[t, r] + p.cardheat[t, r] + p.cardcold[t, r] + p.resp[t, r] + p.diadead[t, r] + p.hurrdead[t, r] + p.extratropicalstormsdead[t, r] + p.dead_other[t, r]
            if v.dead[t, r] > (p.population[t, r] * 1_000_000.0)

              # CORRECTED: Formerly divided; edited to multiply per J. Rising 3-8-17
               v.dead[t, r] = p.population[t, r] * 1_000_000.0
            end

            v.yll[t, r] = p.d2ld[r] * p.dengue[t, r] + p.d2ls[r] * p.schisto[t, r] + p.d2lm[r] * p.malaria[t, r] + p.d2lc[r] * p.cardheat[t, r] + p.d2lc[r] * p.cardcold[t, r] + p.d2lr[r] * p.resp[t, r]

            v.yld[t, r] = p.d2dd[r] * p.dengue[t, r] + p.d2ds[r] * p.schisto[t, r] + p.d2dm[r] * p.malaria[t, r] + p.d2dc[r] * p.cardheat[t, r] + p.d2dc[r] * p.cardcold[t, r] + p.d2dr[r] * p.resp[t, r] + p.diasick[t, r] + p.sick_other[t,r]

            # Divide by 1 billion to have units of $B
            v.deadcost[t, r] = (p.vsl[t, r] * v.dead[t, r]) / 1_000_000_000.0

            # ADDED: deadrate; nb that multiply population by 1M to accord with units for dead (makes this same as populationin1)
            v.deadrate[t, r] = v.dead[t, r]/ (p.population[t, r] * 1_000_000.0)

            # deadcost:= vyll*ypc*yll/1000000000
            # v.morbcost[t, r] = p.vmorb[t, r] * v.yld[t, r] / 1000000000.0
        end
    end
end
