[![Build Status](https://travis-ci.org/davidanthoff/fund.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/fund.jl)

# FUND-mortality

This iteration of FUND in Julia has been cloned for the purpose of experimenting with the mortality, morbidity, and VSL components. All code manipulation efforts stem from my understanding of the structure of the sector-specific empirical response functions that are being developed by the Climate Impact Lab and the Global Policy Lab, where I completed my DS421-required internship in the summer of 2016 working in the climate-driven migration sector. That summer internship furnished the foundation for the work I have added to this github repo: please see the "ImpactDeathTempComponent.jl" file. 

##### Please note: The text featured below has been included from the original repository for explanatory purposes. #####

# Fund.jl

This is an implementation of FUND in Julia. Everything is experimental at this point and this is not the official FUND code. We have not finished to cross check this code with the official C# implementation, so it might still have bugs. Please do not use this code for any publication at this point. This code will also migrate to a different github repository once it is finalized.

## Requirements

The minimum requirement to run FUND is [Julia](http://julialang.org/) and the [Mimi](https://github.com/davidanthoff/Mimi.jl) package. To run the example IJulia notebook file you need to install [IJulia](https://github.com/JuliaLang/IJulia.jl).

### Installing Julia

You can download Julia from [http://julialang.org/downloads/](http://julialang.org/downloads/). You should use the v0.4.x version and install it.

### Installing the Mimi package

Start Julia and enter the following command on the Julia prompt:

````jl
Pkg.add("Mimi")
````

### Keeping requirements up-to-date (optional)

Many of these requirements are regularily updated. To make sure you have the latest versions, periodically execute the following command on the Julia prompt:

````jl
Pkg.update()
````
## Acknowledgements

This work is partially supported by the National Science Foundation through the Network for Sustainable Climate Risk Management ([SCRiM](http://scrimhub.org/)) under NSF cooperative agreement GEO-1240507.
