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
