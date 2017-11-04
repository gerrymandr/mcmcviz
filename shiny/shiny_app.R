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
  mutate(district = rep(1:5, rep(5,5)))


ui = fluidPage(
  sidebarLayout(
    sidebarPanel(
      wellPanel(
        uiOutput("district_buttons")
      ),
      actionButton("add_district",label = "Add another district")
    ),
    mainPanel(
      h3("Select Grid"),
      plotOutput("map"),
      selectModUI("selectmap")
    )
  )
)

geom = nytimes

server = function(input, output, session) {

  state = reactiveValues(
    n_districts = length(unique(geom$district)),
    buttons = list(),
    observers = list()
  )
  
  selected = callModule(
    selectMod,
    "selectmap",
    leaflet() %>%
      #addTiles() %>%
      addFeatures(geom, layerId = ~seq_len(nrow(geom)))
  )
  
  observe({
    n = state$n_districts
    
    # Kill the old buttons
    if (length(state$observers) != 0)
      map(state$observers, ~ .$destory())
    
    
    ids = paste0("add_dist_", 1:n)
    labels = paste("Add to distrinct", 1:n)
    
    state$buttons = map2(ids, labels, actionButton)
    
    #state$observers = map2(
    #  ids, 1:n,
    #  function(id, i)
    #  {
    #    observeEvent(input[[id]], {
    #      print(selected())
    #    })
    #  }
    #)
    
    output$district_buttons = renderUI(state$buttons)
  })
  
  observeEvent(input$add_district, {
    state$n_districts = state$n_districts + 1
  })
  
  #rv = reactiveValues(intersect=NULL, selectgrid=NULL)
  #
  #observe({
  #  # the select module returns a reactive
  #  #   so let's use it to find the intersection
  #  #   of selected grid with quakes points
  #  gs = g_sel()
  #  rv$selectgrid = st_sf(
  #    grd[as.numeric(gs[which(gs$selected==TRUE),"id"])]
  #  )
  #  if(length(rv$selectgrid) > 0) {
  #    rv$intersect = st_intersection(rv$selectgrid, qk_sf)
  #  } else {
  #    rv$intersect = NULL
  #  }
  #})
  #
  #output$selectplot = renderPlot({
  #  plot(qk_mp, col="gray")
  #  if(!is.null(rv$intersect)) {
  #    plot(rv$intersect, pch=19, col="black", add=TRUE)      
  #  }
  #  plot(st_union(rv$selectgrid), add=TRUE)
  #})
  
  output$map = renderPlot({
    dists = geom %>% group_by(district) %>% summarize() 
    
    ggplot() +
      geom_sf(data = dists, aes(fill=as.factor(district))) +
      geom_sf(data = geom, color="black", fill=NA) +
      theme_bw() +
      labs(fill="District")
  })
}

shinyApp(ui, server)
