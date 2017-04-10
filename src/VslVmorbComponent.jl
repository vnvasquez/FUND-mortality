using Mimi

@defcomp vslvmorb begin
    regions = Index()

    vsl         = Variable(index=[time,regions])
    vmorb       = Variable(index=[time,regions])
    ypc         = Variable(index=[time,regions])

    population  = Parameter(index=[time,regions])
    income      = Parameter(index=[time,regions])

    vslbm       = Parameter()
    vslypc0     = Parameter()
    #vslel       = Parameter()
    vslel_high  = Parameter()
    vslel_mid   = Parameter()
    vslel_low   = Parameter()

    #terciles
    #one_third   = Variable(index=[time])
    #two_third   = Variable(index=[time])

    #vmorbbm     = Parameter()
    #vmorbel     = Parameter()
    #vmorbypc0   = Parameter()

end

function run_timestep(s::vslvmorb, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    if t>1

        for r in d.regions

            # CORRECTED: For discussion, but added ".v" ahead of ypc, and included as variable above.
            # Income in billions, population in millions - multiply by 1_000.0 to even out units
            v.ypc[t,r] = p.income[t, r] / p.population[t, r] * 1_000.0

            # Calculate ypc terciles
            min_ypc, max_ypc = extrema(v.ypc[t,:])
            one_third = quantile([min_ypc, max_ypc], 1/3)
            two_third = quantile([min_ypc, max_ypc], 2/3)

            # Assign VSL elasticity values of 0.5, 1.0, 1.5 per Miguel et al.
            if v.ypc[t,r] <one_third
              v.vsl[t, r] = p.vslbm * (v.ypc[t,r] / p.vslypc0)^p.vslel_high

            elseif v.ypc[t,r] >one_third && v.ypc[t,r] <two_third
              v.vsl[t, r] = p.vslbm * (v.ypc[t,r] / p.vslypc0)^p.vslel_mid

            else v.ypc[t,r]>two_third
              v.vsl[t, r] = p.vslbm * (v.ypc[t,r] / p.vslypc0)^p.vslel_low

            end
            #v.vmorb[t, r] = p.vmorbbm * (ypc / p.vmorbypc0)^p.vmorbel
        end
    end
end
