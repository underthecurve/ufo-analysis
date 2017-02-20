# UFO sightings analysis: Data and code supporting the analysis of reported UFO sightings

```
       o                |
                 .     -O-    
      .                 |        *      .     -0-
             *  o     .    '       *      .        o
                    .         .        |      *
         *             *              -O-          .
               .             *         |     ,
                      .           o
              .---.
        =   _/__~0_\_     .  *            o       ' 
       = = (_________)             .            
                       .                        *
       jgs   *               - ) -       *      
                    .               .
```

## Data

The data folder contains the following data:

* `ufo.csv`: UFO sightings data, from the [National UFO Reporting Center (NUFORC)](http://www.nuforc.org/webreports.html).

* `nst-est2016-alldata.csv`: state population (2010 Census figures, with estimates for later years), from the [Census National Population Totals dataset](http://www.census.gov/data/datasets/2016/demo/popest/nation-total.html).

* `PctUrbanRural_State.csv` and `PctUrbanRural_County.txt`: state and county urban/rural population in 2010, from the [2010 Census](https://www.census.gov/geo/reference/ua/ualists_layout.html).

* `ACS_15_5YR_B01003_with_ann_countypop.csv`: county population, from the [2015 American Community Survey 5-year estimate](https://factfinder.census.gov/) (Table B01003). 

* `ACS_15_5YR_B19013_with_ann.csv`: county median household income in the past 12 months (in 2015 INFLATION-adjusted dollars), from the [2015 American Community Survey 5-year estimate](https://factfinder.census.gov/) (Table B19013).

* `US_County_Level_Presidential_Results_12-16.csv`: county presidential results, from The Guardian and Townhall via [this GitHub repository](https://github.com/tonmcg/County_Level_Election_Results_12-16), also referenced [here](https://simonrogers.net/2016/11/16/us-election-2016-how-to-download-county-level-results-data/).

* `airports.txt`: list of airports, from [Open Flights](http://openflights.org/data.html).

* `All NPIAS Airports-Table 1.csv`: list of U.S. airports, classified by size of hub, from the [Federal Aviation Administration](https://www.faa.gov/airports/planning_capacity/npias/reports/).

* The data are cleaned, merged, and processed in [`cleandata.R`](https://github.com/underthecurve/ufo-analysis/blob/master/01_cleandata.R), which creates `.R` data files `ufo.RDS`, `ufo_2016.RDS`, `countypop.RDS`, and `countyincome.RDS` and should be run prior to loading the Jupyter notebooks.

## Analyses

The analyses are saved in two Jupyter notebooks:

* `mass_reports_analysis.ipynb`: analysis of mass reports of UFO sightings

* `demogaphic_analysis,ipynb`: analysis of county-level demographics and 2016 UFO sightings










