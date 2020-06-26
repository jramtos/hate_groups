# Identifying Anti-immigration movements: Mapping Hate Crimes and Groups in the US

We use U.S. public data to identify hate groups and hate crimes towards immigrants or hispanic/Latino groups.

## 1. Data
In the folder [data](/data), we have three data sets:  
* splc-hate-groups.csv: refers to the identified hate groups since 2000 by the [Southern Poverty Law Center](https://www.splcenter.org/hate-map)
* ucr_hatecrimes.csv: refers to all the reported hate crimes in the US by [the Uniform Crime Reporting (UCR)](https://crime-data-explorer.fr.cloud.gov/downloads-and-docs) from FBI
* extremism_incidents.csv: refers to all the identified hate-related incidents since 2002 by the [ADL (Anti-Defamation League)](https://www.adl.org/adl-hate-crime-map)

Complementary Data:  
* population.csv: Population Estimates of US States from [US Census Bureau](https://www2.census.gov/programs-surveys/popest/tables/2010-2019/state/totals/)
* [shapes](/data/shapes): folder with the geometries of US States and Territories.

## 2. Brief Analysis of Data

Before building an interactive dashboard to map us-hate crimes and hate groups towards immigrant communities, we developed a brief analysis of the data, particularly focusing on Latin and Hispanic communities. 
The overall analysis is in [report.pdf](report.pdf)

## 3. Building Dashboard Framework