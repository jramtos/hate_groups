# Identifying Anti-immigration movements: Mapping Hate Crimes and Groups in the US

We use U.S. public data to identify hate groups and hate crimes towards immigrants or hispanic/Latino groups.

## 1. Data
In the folder [data](/data), we have three data sets:  
* splc-hate-groups.csv: refers to the identified hate groups since 2000 by the [Southern Poverty Law Center](https://www.splcenter.org/hate-map)
* ucr_hatecrimes.csv: refers to all the reported hate crimes in the US by [the Uniform Crime Reporting (UCR)](https://crime-data-explorer.fr.cloud.gov/downloads-and-docs) from FBI
* extremism_incidents.csv: refers to all the identified hate-related incidents since 2002 by the [ADL (Anti-Defamation League)](https://www.adl.org/adl-hate-crime-map)

Complementary Data:  
* US Census Bureau API: we used [American Community Survey (ACS)](https://www.census.gov/programs-surveys/acs/technical-documentation/summary-file-documentation.html). 
    The following demographics were downloaded:  
    * Population estimates of US States from the American Community Survey 5 Year Estimates and 1 Year Estimates. 
    * 1 Year Estimates are stored in population.csv from [US Census Bureau](https://www2.census.gov/programs-surveys/popest/tables/2010-2019/state/totals/)
    * Median Income, Foreign Born Population, Mexican Born Population, and Latin American born Population
    5 year estimates obtained from the American Community Survey.
    
    For information about US Census API using python see:
    * [Census Data python module](https://jtleider.github.io/censusdata/)
    * [Example downloading State data](https://jtleider.github.io/censusdata/example3.html)
    * [Accessing Census Data with Python](https://towardsdatascience.com/accessing-census-data-with-python-3e2f2b56e20d)

* [shapes](/data/shapes): folder with the geometries of US States and Territories.

## 2. Brief Analysis of Data

Before building an interactive dashboard to map us-hate crimes and hate groups towards immigrant communities, we developed a brief analysis of the data, particularly focusing on Latin and Hispanic communities. 
The overall analysis is in [report.pdf](report.pdf) and the code is in [analysis_hate_data.ipynb](analysis_hate_data.ipynb)

## 3. Building Dashboard Framework