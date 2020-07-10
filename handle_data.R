setwd('/Users/jmrt/Documents/Internship/Embassy_HateCrimes/hate_groups')

library(leaflet)
library(rgdal)
library(dplyr)
library(colorspace)
library(htmltools)
library(tidyverse)

## Download Shapes and Data ##
shapes <- readOGR( "data/shapes/tl_2017_us_state.shp")
hg <-read.csv('data/splc-hate-groups.csv')
agg_hc <-read.csv('data/agg_hc.csv') #use aggregated data from python code
pop <-read.csv('data/population.csv')
agg_hg<-read.csv('data/agg_hg.csv')

## Aggregate Hate Groups Data ##
all_hg <-hg %>%
  group_by(State, Year) %>%
  summarise(all=n())
categories = c("Anti-Immigrant", "Anti-Muslim", "White Nationalist", 
                  "Neo-Nazi")
for(cat in categories){
  df = filter(hg, hg['Ideology'] == cat) %>% 
    group_by(State, Year) %>% 
    summarize(cat= n())
  colnames(df)<-c('State', 'Year', cat)
  all_hg<-merge(all_hg, df, by=c('State', 'Year'), all=TRUE)
}
#Include population estimates
all_hg = merge(filter(all_hg, all_hg$Year > 2009), pop, by=c('State', 'Year'), all=TRUE)

#Remove DC
all_hg = filter(all_hg, all_hg['State'] != 'District of Columbia')
all_states = tibble(unique(all_hg$State))
colnames(all_states) <-c('State')

all_hg = merge(all_hg, all_states, by='State', all=TRUE)

#Normalize number of hate groups per million people
all_hg$all[is.na(all_hg$all)] <- 0
all_hg$all_n = all_hg[cat]/all_hg$population*1000000
for (cat in categories){
  all_hg[cat][is.na(all_hg[cat])] <- 0
  all_hg[paste(cat, '_n', sep='')]= all_hg[cat]/all_hg$population*1000000
}
all_hg['Other'] = all_hg$all - rowSums(all_hg[categories], na.rm=TRUE)

## Merge with Hate Crimes Data ##
hdata = merge(all_hg, agg_hc, by=c('State', 'Year'), all=TRUE)
hdata$race[is.na(hdata$race)] <- 0#Replace NA with 0
hdata$latino[is.na(hdata$latino)] <- 0
hdata['race_n'] = hdata$race / hdata$population * 1000000
hdata['latino_n'] = hdata$latino / hdata$population * 1000000

## Melt and Merge Functions ##
#melted = melt(hdata, id.vars = c('State', 'Year'), measure.vars=colnames(hdata)[3:11])
year=2019
df = filter(hdata, hdata['Year'] == year)
shapes_toplot = merge(shapes, hdata, 
                      by.x='NAME', by.y='State', all=TRUE)

## Merge all aggregated data with Shapes and PLOT##
map_plot<-function(var_toplot, title, color="PuBu", bins=4){
  pal = colorBin(color, shapes_toplot[[var_toplot]], bins=bins)
  labels = paste("<p>", shapes_toplot$NAME, "</p>",
                 "<p>", title, "</p>",
                 round(shapes_toplot[[var_toplot]], digits=1), "</p>", sep="")
  
  m <-leaflet() %>%
    setView(-96, 37.8, 5) %>%
    addProviderTiles(providers$OpenStreetMap.Mapnik) %>%
    addPolygons(data=shapes_toplot, weight=1, smoothFactor = 0.5,color='grey', 
                fillOpacity = 0.8,
                fillColor = pal(shapes_toplot[[var_toplot]]), 
                #Highlight neighbourhoods 
                highlight = highlightOptions(weight=5, color='transparent', 
                                             bringToFront = TRUE, fillOpacity = 0.7),
                layerId = shapes_toplot$GEOID,
                label = lapply(labels, HTML),
                labelOptions = labelOptions(
                  style = list("font-weight" = "normal", padding = "2px 5px"),
                  textsize = "8px",
                  direction = "auto"))
  #%>% addLegend(values=shapes_toplot$[[var_toplot]],pal=pal,title=title)
  return(m)
}
  
#map_plot('all', 'Number of Hate Groups:', color='Reds')
#map_plot('Anti-Immigrant', 'Number of Hate Groups:', color='Reds')
#map_plot('race', 'Number of Race Motivated Hate Crimes per Million:', color='Oranges')
#map_plot('latino', 'Number of Anti-Latino Motivated Hate Crimes per Million:', color='BuPu')