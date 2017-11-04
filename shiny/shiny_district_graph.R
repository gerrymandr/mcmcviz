library(mapview)
library(mapedit)
library(sf)
library(shiny)
library(redist)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)

files = list.files("../data", "*.shp", full.names = TRUE)
names(files) = basename(files)

polsby_popper = function(sf) {
  P = st_geometry(sf) %>% map(st_length) %>% map_dbl(sum)
  A = st_area(st_geometry(sf))
  
  attr(A, "class") = NULL
  attr(A, "units") = NULL
  
  4 * pi * A / P^2
}


ui = fluidPage(
  selectInput("file_path", "Which data source:", choices = files),
  actionButton("load", "Load data"),
  fluidRow(
    column(width = 6,
      plotOutput("map", width=600, height=600)
    ),
    column(width = 2,
      tableOutput("compactness")
    )
  )
)



server = function(input, output, session) {
  
  observeEvent(input$load, {
    if (file.exists(input$file_path)) {
      geom$precincts = st_read(input$file_path, quiet = TRUE)
      geom$districts = geom$precincts %>% group_by(DISTRICT) %>% summarize() 
      
      
    } else {
      message("File does not exist")    
    }
  })
  
  geom = reactiveValues(
    precincts = NULL,
    districts = NULL
  )
  
  output$compactness = renderTable({
    if (is.null(geom$districts))
      return()
    
    geom$districts %>%
      as.data.frame() %>%
      select(-geometry)
  })
  
  output$map = renderPlot({
    if (is.null(geom$districts))
      return()
    
    ggplot() +
      geom_sf(data = geom$districts, aes(fill=as.factor(DISTRICT))) +
      geom_sf(data = geom$precincts, color="black", fill=NA) +
      theme_bw() +
      labs(fill="District")
  })
}

shinyApp(ui, server)