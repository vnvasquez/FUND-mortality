using Mimi

@defcomp vslvmorb begin
    regions = Index()

    vsl             = Variable(index=[time,regions])
    vmorb           = Variable(index=[time,regions])
    ypc             = Variable(index=[time,regions])

    population      = Parameter(index=[time,regions])
    income          = Parameter(index=[time,regions])

    vslbm           = Parameter()
    vslypc0         = Parameter()
    #vslel          = Parameter()
    vslel_highest   = Parameter()
    vslel_high      = Parameter()
    vslel_mid       = Parameter()
    vslel_low       = Parameter()

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

            # Calculate ypc quartiles using World Bank thresholds
            # Note that GNP used as rough approximation for GDP
            # Y17 values in 2015USD, * 0.64 to convert to 1995USD. Source: https://www.bls.gov/data/inflation_calculator.htm
            # GNP caculated in nominal dollars using Atlas conversion method
            # Source: https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups
            low = 1_025.00 * 0.64
            lowermiddle1 = 1_026.00 * 0.64
            lowermiddle2 = 4_035.00 * 0.64
            uppermiddle1 = 4_036.00 * 0.64
            uppermiddle2 = 12_475.00 * 0.64
            high = 12_475 * 0.64

            # Assign VSL elasticity values of 0.5, 1.0, 1.5, 2.0 per Miguel et al.
            if v.ypc[t,r] <= low
              v.vsl[t, r] = p.vslbm * (v.ypc[t,r] / p.vslypc0)^p.vslel_highest

            elseif v.ypc[t,r] > lowermiddle1 && v.ypc[t,r] < lowermiddle2
              v.vsl[t, r] = p.vslbm * (v.ypc[t,r] / p.vslypc0)^p.vslel_high

            elseif v.ypc[t,r] > uppermiddle1 && v.ypc[t,r] < uppermiddle2
              v.vsl[t, r] = p.vslbm * (v.ypc[t,r] / p.vslypc0)^p.vslel_mid

            else v.ypc[t,r] > high
              v.vsl[t, r] = p.vslbm * (v.ypc[t,r] / p.vslypc0)^p.vslel_low

            end
            #v.vmorb[t, r] = p.vmorbbm * (ypc / p.vmorbypc0)^p.vmorbel
        end
    end
end

# ADDITIONAL INFORMATION ON GROUPINGS AND THRESHOLDS
# http://www.worldbank.org/en/topic/poverty/brief/global-poverty-line-faq
# 1.90 USD per person per day in PPP: 1.90 * p.populationin1 * 365 * conversion to 1995 MER dollars
# NB current estimate of 1.90 is in 2011 PPP dollars
# Most up to date information from the Commision on Global Poverty, and World Bank response:
# https://openknowledge.worldbank.org/bitstream/handle/10986/25141/9781464809613.pdf
# http://pubdocs.worldbank.org/en/733161476724983858/MonitoringGlobalPovertyCoverNote.pdf
# http://data.worldbank.org/products/wdi-maps
