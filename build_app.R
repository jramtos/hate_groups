source('handle_data.R')
##Build App ##
library(shiny)

ui <- navbarPage(title="Anti-immigration sentiment through hate data",
                 tabPanel(title='Hate Groups',
                          leafletOutput("map_g", width='1000', height='500')),
      tabPanel(title='Hate Crimes',
         leafletOutput("map_c", width='1000', height='500'))
)

server <- function(input, output, session) {
  
  output$map_g <- renderLeaflet({map_plot(shapes_toplot, 
                                          'count_hg_n', 
                                          'Number of Hate Groups:', 
                                          color='Reds')})
  output$map_c <- renderLeaflet({map_plot(shapes_toplot, 
                                          'race_n', 
                                          'Number of Race related Hate Crimes:', 
                                          color='PuBu')})
}

shinyApp(ui, server)
