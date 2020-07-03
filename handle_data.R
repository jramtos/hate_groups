setwd('/Users/jmrt/Documents/Internship/Embassy_HateCrimes/hate_groups')

library(leaflet)
library(rgdal)
library(dplyr)
library(colorspace)
library(htmltools)
library(stringr)
library(stringi)
library(tidyverse)
## Download Shapes and Data ##
shapes <- readOGR( "data/shapes/tl_2017_us_state.shp")
hg <-read.csv('data/splc-hate-groups.csv')
agg_hc <-read.csv('data/agg_hc.csv') #use aggregated data from python code
pop <-read.csv('data/population.csv')

## Aggregate Hate Groups Data ##
all_hg <-hg %>%
  group_by(State, Year) %>%
  summarise(count_hg=n())

only_immigrant = filter(hg, hg['Ideology'] == 'Anti-Immigrant') %>% 
  group_by(State, Year) %>% 
  summarize(count_hg_i= n())

hg_counts = merge(all_hg, only_immigrant, by=c('State', 'Year'), all=TRUE)

#Include population estimates
hg_counts = merge(hg_counts, pop, by=c('State', 'Year'), all=TRUE)

#Normalize number of hate groups per million people
hg_counts$count_hg[is.na(hg_counts$count_hg)] <- 0
hg_counts$count_hg_i[is.na(hg_counts$count_hg_i)] <- 0
hg_counts['count_hg_n'] = hg_counts$count_hg / hg_counts$population * 1000000
hg_counts['count_hg_i_n'] = hg_counts$count_hg_i / hg_counts$population * 1000000
#Filter
hg_counts = filter(hg_counts, hg_counts['State'] != 'District of Columbia')
all_states = tibble(unique(hg_counts$State))
colnames(all_states) <-c('State')

## Merge with Hate Crimes Data ##
colnames(agg_hc)
hdata = merge(hg_counts, agg_hc, by=c('State', 'Year'), all=TRUE)
hdata$race[is.na(hdata$race)] <- 0#Replace NA with 0
hdata$latino[is.na(hdata$latino)] <- 0
hdata['race_n'] = hdata$race / hdata$population * 1000000
hdata['latino_n'] = hdata$latino / hdata$population * 1000000

## Melt Data

## Merge all aggregated data with Shapes ##
select_year = 2016
df_year = filter(hdata, hdata['Year'] == select_year)
df_year =  merge(df_year, all_states, by='State', all=TRUE)
df_year[is.na(df_year)] <- 0

shapes_toplot = merge(shapes, df_year, 
               by.x='NAME', by.y='State', all=FALSE)
#pal2_df = data.frame(rainbow_hcl(50))

map_plot<-function(shapes_toplot, var_toplot, title, color="PuBu", bins=4){
  pal = colorBin(color, shapes_toplot[[var_toplot]], bins=bins)
  labels = paste("<p>", shapes_toplot$NAME, "</p>",
                 "<p>", title, "</p>",
                 round(shapes_toplot[[var_toplot]], digits=1), "</p>", sep="")
  m <-leaflet() %>%
    setView(-96, 37.8, 3.3)%>%
    addProviderTiles(providers$OpenStreetMap.Mapnik) %>%
    addPolygons(data=shapes_toplot, weight=1, smoothFactor = 0.5,color='grey', 
                fillOpacity = 0.8,
                fillColor = pal(shapes_toplot[[var_toplot]]), 
                #Highlight neighbourhoods 
                highlight = highlightOptions(weight=5, color='transparent', 
                                             bringToFront = TRUE, fillOpacity = 0.7),
                label = lapply(labels, HTML),
                labelOptions = labelOptions(
                  style = list("font-weight" = "normal", padding = "2px 5px"),
                  textsize = "8px",
                  direction = "auto"))
  #%>% addLegend(values=shapes_toplot$[[var_toplot]],pal=pal,title=title)
  return(m)
}

map_plot(shapes_toplot, 'count_hg_n', 'Number of Hate Groups:', color='Reds')
map_plot(shapes_toplot, 'count_hg_i_n', 'Number of Anti-Immigrant Groups:')
map_plot(shapes_toplot, 'race_n', 'Number of Race Motivated Hate Crimes per Million:', color='Oranges')
map_plot(shapes_toplot, 'latino_n', 'Number of Anti-Latino Motivated Hate Crimes per Million:', 
         color='BuPu')

