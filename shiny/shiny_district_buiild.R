library(mapview)
library(mapedit)
library(sf)
library(shiny)
library(redist)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)


nytimes = expand.grid(x = 1:5, y = 1:5) %>%
  as.matrix() %>% 
  st_multipoint() %>%
  st_sfc() %>%
  st_cast("POINT") %>%
  st_make_grid(n = 5,5) %>%
  st_sf() %>% 
  mutate(
    id = 1:n(),
    district = rep(1:5, rep(5,5))
  )


ui = fluidPage(
  sidebarLayout(
    sidebarPanel(
      numericInput("n_districts", "Number of districts:", min = 1, value = 5),
      wellPanel(
        uiOutput("district_buttons")
      )
    ),
    mainPanel(
      h3("Select Grid"),
      plotOutput("map"),
      selectModUI("selectmap")
    )
  )
)

server = function(input, output, session) {
  
  state = reactiveValues(
    buttons = list(),
    observers = list(),
    geom = nytimes,
    cur_selected = c()
  )
  
  selector = callModule(
    selectMod,
    "selectmap",
    leaflet() %>%
      #addTiles() %>%
      addFeatures(state$geom, layerId = ~state$geom$id)
  )
  
  observeEvent(selector(), {
    print(selector())
    state$cur_selected = selector()$id[as.logical(selector()$selected)] 
  })
  
  observeEvent(input$n_districts, {
    
    n = input$n_districts
    stopifnot(n >= 1)
    
    # Kill the old buttons
    if (length(state$observers) != 0)
      map(state$observers, ~ .$destroy())
    
    ids = paste0("add_dist_", 1:n)
    labels = paste("Add to distrinct", 1:n)
    
    state$buttons = map2(ids, labels, actionButton)
    
    state$observers = map2(
      ids, 1:n,
      function(id, i)
      {
        observeEvent(input[[id]], {
          state$geom$district[state$geom$id %in% state$cur_selected] = i
        })
      }
    )
    
    output$district_buttons = renderUI(state$buttons)
  })
  
  
  
  output$map = renderPlot({
    dists = state$geom %>% group_by(district) %>% summarize() 
    
    ggplot() +
      geom_sf(data = dists, aes(fill=as.factor(district))) +
      geom_sf(data = state$geom, color="black", fill=NA) +
      theme_bw() +
      labs(fill="District")
  })
}

shinyApp(ui, server)