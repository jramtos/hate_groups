library(leaflet)
library(rgdal)
library(dplyr)
library(colorspace)
library(htmltools)
library(tidyverse)
library(shiny)
agg_hg<-read_csv('data/agg_hg.csv')
agg_hc<-read_csv('data/agg_hc.csv')
shapes<-readOGR( "data/shapes/tl_2017_us_state.shp")

##Build App ##
## USER INTERFACE ###
top=140
left=20

hategroups_choices <-absolutePanel(
  top = top + 50, left = left, fixed = T, 
  width = "20%", style = "z-index:500; min-width: 100px;",
  selectInput(inputId = "year_hg",label = strong("Select Year"),
              choices = c(2019:2010)),
  checkboxGroupInput(inputId = "category",
                     label = strong("Ideology"),
                     choices = c("Anti-Immigrant", "Anti-Muslim", "White Nationalist", 
                                    "Neo-Nazi", "Other Idelogies"),
                     selected = c("Anti-Immigrant")))

hatecrimes_choices <-absolutePanel(
  top = top + 90, left = left, fixed = T, 
  width = "20%", style = "z-index:500; min-width: 100px;",
  selectInput(inputId = "year_hc",label = strong("Select Year"),
              choices = c(2018:2010)),
  checkboxGroupInput(inputId = "bias",
                     label = strong("Motivated Bias (Race based)"),
                     choiceNames = c('Anti-Latino', 'Anti-Asian', 'Anti-Arab', 'Anti-Native',
                                     'Anti-Black', 'Other Race'),
                     choiceValues = c('latino', 'asian', 'arab', 'native', 'black', 'other'))
)

ui <- navbarPage(title="Anti-immigration sentiment through hate data",
                 tabPanel(title='Hate Groups',
                          absolutePanel(style = "opacity: 0.65; z-index: 10;",
                                        fixed = T,
                                        top=top, left=left, right='auto', bottom = 'auto',
                                        width = 600, height = 30,
                                        h2('Hate Groups per Million People')),
                          leafletOutput("map_g", width='1300', height='600'), 
                          hategroups_choices
                          ),
                 tabPanel(title='Hate Crimes',
                          absolutePanel(style = "opacity: 0.65; z-index: 10;",fixed=T,
                             top=top, left=left, right='auto', bottom = 'auto',
                             width = 600, height = 30,
                             h2('Hate Crimes (Race biased) per Million People')),
                          leafletOutput("map_c", width='1300', height='600'),
                          hatecrimes_choices
         )
)

initial_map <-leaflet() %>%
  setView(-100, 39, 4)%>%
  addProviderTiles(providers$OpenStreetMap.Mapnik) 

## SERVER ##
server <- function(input, output, session) {
  #Hate Groups Data
  fgdata = reactive({
    selected_cols = input$category
    selected_year =  as.numeric(input$year_hg)
    df_filtered<-agg_hg%>%mutate(total= rowSums(agg_hg%>% select(selected_cols),na.rm=TRUE)) %>% filter(Year == selected_year)
    mdf<- merge(shapes, df_filtered,
              by.x='NAME', by.y='State', all=FALSE)
    mdf})
  
  #Hate Crimes Data
  fcdata = reactive({
    selected_cols = input$bias
    selected_year =  as.numeric(input$year_hc)
    df_filtered<-agg_hc%>%mutate(total= rowSums(agg_hc%>% select(selected_cols),na.rm=TRUE)) %>% filter(Year == selected_year)
    mdf<- merge(shapes, df_filtered,
                by.x='NAME', by.y='State', all=FALSE)
    mdf})
  
  #Hate Groups Map
  pal = colorBin('BuPu', domain=NULL, bins=4)
  output$map_g <- renderLeaflet({
    initial_map
    })
  
  #Hate Crimes  Map
  pal2 = colorBin('Reds', domain=NULL, bins=4)
  output$map_c <- renderLeaflet({
    initial_map
  })
  
  
  #Interactive Update
  observe({
    #Update for Hate Groups Map
      leafletProxy("map_g", data = fgdata()) %>%
        addTiles() %>% 
        clearShapes() %>%
        addPolygons(data = fgdata(), fillColor = pal(fgdata()$total), 
                    weight=1, smoothFactor = 0.5,color='grey', 
                    fillOpacity = 0.8, 
                    highlight = highlightOptions(weight=5, color='transparent', 
                                                 bringToFront = TRUE, fillOpacity = 0.7),
                    label = lapply(paste("<p>", fgdata()$NAME,
                                         "<p>", 'Hate Groups per Million:',
                                         fgdata()$total), HTML),
                    labelOptions = labelOptions(
                      style = list("font-weight" = "normal", padding = "2px 5px"),
                      textsize = "8px", direction = "auto"))
    })
  observe({
    #Update for Hate Crimes Map
    leafletProxy("map_c", data = fcdata()) %>%
      clearShapes() %>% 
      addPolygons(data=fcdata(), 
                  weight=1, smoothFactor = 0.5,color='grey', 
                  fillOpacity = 0.8,fillColor = pal2(fcdata()$total),
                  #Highlight neighbourhoods
                  highlight = highlightOptions(weight=5, color='transparent',
                                               bringToFront = TRUE, fillOpacity = 0.7),
                  label =lapply(paste("<p>", fcdata()$NAME,
                                      "<p>", 'Hate Crimes per Million:',
                                      fcdata()$total), HTML),
                  labelOptions = labelOptions(style = list("font-weight" = "normal", 
                                                           padding = "2px 5px"),
                                              textsize = "8px", direction = "auto"))
  })
  
  #  observeEvent(input$category, 
  #               {print(input$category)})
  #  observeEvent(input$bias, 
  #               {print(input$bias)})
}

shinyApp(ui, server)
