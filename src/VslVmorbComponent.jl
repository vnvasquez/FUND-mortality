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
    #vslel_low   = Parameter()

    #vmorbbm     = Parameter()
    #vmorbel     = Parameter()
    #vmorbypc0   = Parameter()

end

function run_timestep(s::vslvmorb, t::Int)
    v = s.Variables
    p = s.Parameters
    d = s.Dimensions

    #if t>1
        for r in d.regions

            # CORRECTED: For discussion, but added ".v" ahead of ypc, and included as variable above.
            v.ypc[t,r] = p.income[t, r] / p.population[t, r] * 1000.0

            # Explicit VSL values of 1.0 and 1.5.
            # Q: include VSL of 0.5 too? Miguel et al. - would be p.vslel_low. If so, what value for GDP indicator to trigger low?
            if v.ypc[t, r] < p.vslypc0
              v.vsl[t, r] = p.vslbm * (v.ypc[t,r] / p.vslypc0)^p.vslel_high
            else
              v.vsl[t, r] = p.vslbm * (v.ypc[t,r] / p.vslypc0)^p.vslel_mid
            end

            #v.vmorb[t, r] = p.vmorbbm * (ypc / p.vmorbypc0)^p.vmorbel
        end
    #end
end
