################################################################################
# shiny_server.R                                                               #
################################################################################
# shiny_server.R function runs all the server side operations to actually do   #
# the work required to plot things on the screen, render the map, and run the  #
# functions required to transform button input into action                     #
################################################################################
################################################################################

server = function(input, output, session) {
  
  shinyjs::hide("iter")
  
  shp_name = reactive({
    if (input$inputtype=="State") {
      return(input$state)
    } 
    else if (input$inputtype=="Grid"){
      print("there")
      return(input$grid)
    } else {
      stop()
    }
  })
  
  state = reactiveValues()
  
  observeEvent(input$redistrict, {
    
    shp_file = paste0("data/",shp_name(),".shp")
    
    geom = st_read(shp_file, quiet = TRUE)
    
    names(geom) = tolower(names(geom))
    
    election_2014 = geom %>%
      as.data.frame() %>%
      select(id, population, contains("2014")) %>%
      mutate(
        R_votes = population * (e2014_r / 100),
        D_votes = population * (e2014_d / 100)
      )
    
    election_2016 = geom %>%
      as.data.frame() %>%
      select(id, population, contains("2016")) %>%
      mutate(
        R_votes = population * (e2016_r / 100),
        D_votes = population * (e2016_d / 100)
      )
    
    ndists = input$ndistricts
    nsims = input$nsimulations
    nthin = input$nthin
    nburn = input$nburnin
    eprob = input$eprob
    lambda = input$lambda
    popcons = input$popcons
    constraint = input$constraint
      
    #print('About to start running a new redistricting simulation with the following parameters')
    #print(paste('Number of districts:', ndists))
    #print(paste('Number of simulations:',nsims))
    #print(paste('Thinning rate for MCMC:', nthin))
    #print(paste('Number of burnin iterations:', nburn))
    #print(paste('Probility of edge swapping:',eprob))
    #print(paste('Number of edges to swap = Poi(lambda) + 1:', lambda))
    #print(paste('Population contraint percent deviation:', popcons))
    #print(paste('Additional contraint types:', constraint))

    geom = geom
    iters = redistrict(geom, nsims, nthin, nburn, ndists, popcons, eprob, lambda)
    maps = gather_maps(geom, iters)
    results_2014 = gather_results(election_2014, iters)
    results_2016 = gather_results(election_2016, iters)
    metrics = gather_metrics(maps, results_2014, results_2016)
    
    updateSliderInput(session, "iter", max = length(iters), value = 1, step=1)
    
    state$type = input$inputtype
    state$geom = geom
    state$iters = iters
    state$maps = maps
    state$results_2014 = results_2014
    state$results_2016 = results_2016
    state$metrics = metrics
    
    # state$trace_plot = ggplot(metrics, aes(x=iter,y=value)) + 
    #   geom_line() + 
    #   facet_grid(metric~. ,scales="free_y") +
    #   theme_bw()
    state$trace_plot = ggplot(metrics, aes(x=iter,y=value)) + 
      geom_line() + 
      facet_wrap(~metric ,scales="free_y",ncol=2) +
      theme_bw()

    # state$trace_plot1 = ggplot(metrics1, aes(x=iter,y=value)) +
    #   geom_line() +
    #   facet_grid(metric~. ,scales="free_y") +
    #   theme_bw()
    # 
    # state$trace_plot2 = ggplot(metrics2, aes(x=iter,y=value)) +
    #   geom_line() +
    #   facet_grid(metric~. ,scales="free_y") +
    #   theme_bw()
    # 
    # state$trace_plot3 = ggplot(metrics3, aes(x=iter,y=value)) +
    #   geom_line() +
    #   facet_grid(metric~. ,scales="free_y") +
    #   theme_bw()

    state$density_plot = ggplot(metrics, aes(x=value)) + 
      geom_density() +
      facet_wrap(~metric, scales="free", ncol=2) +
      theme_bw()
    
    
    state$order_plot_2014 = results_2014 %>% ordered_prop() %>% plot_ordered_prop()
    state$order_plot_2016 = results_2016 %>% ordered_prop() %>% plot_ordered_prop()
    
    state$factpal = colorFactor(topo.colors(ndists), as.character(seq_len(ndists)-1))
    
    shinyjs::show("iter")
  })
  
  output$trace_plot=renderPlot({
    if (is.null(state$metrics))
      return()
    
    state$trace_plot +
      geom_vline(data=filter(state$metrics, iter==input$iter), aes(xintercept=iter), color="red")
  })
  output$density_plot=renderPlot({
    if (is.null(state$metrics))
      return()

    state$density_plot +
      geom_vline(data=filter(state$metrics, iter==input$iter), aes(xintercept=value), color="red")
  })
  
  output$order_plot=renderPlot({
    
    party = "D"
    
    prop = state$results_2014[[input$iter]] %>% vote_props() %>% pluck(party)
    
    cur = data_frame(
      district = (1:length(prop))-1,
      value = prop
    ) %>%
      arrange(value) %>%
      mutate(order = 1:n())
    
    prop2 = state$results_2016[[input$iter]] %>% vote_props() %>% pluck(party)
    
    cur2 = data_frame(
      district = (1:length(prop)) - 1,
      value = prop
    ) %>%
      arrange(value) %>%
      mutate(order = 1:n())
    
    g1=state$order_plot_2014 + 
      labs(title = paste0("2014 Election"), color="district") + 
      geom_point(data = cur, size=5, aes(color=as.character(district)))+ylim(min(min(cur$value),min(cur2$value)),max(max(cur$value),max(cur2$value)))

    
   
    
    g2=state$order_plot_2016 + 
      labs(title = paste0("2016 Election"), color="district") + 
      geom_point(data = cur, size=5, aes(color=as.character(district)))+ylim(min(min(cur$value),min(cur2$value)),max(max(cur$value),max(cur2$value)))
    
    require(gridExtra)
    grid.arrange(g1,g2,ncol=2)
  })
  
  output$order_plot_2014 = renderPlot({
    party = "D"
    
    prop = state$results_2014[[input$iter]] %>% vote_props() %>% pluck(party)
    
    cur = data_frame(
      district = (1:length(prop))-1,
      value = prop
    ) %>%
      arrange(value) %>%
      mutate(order = 1:n())
    
    g1=state$order_plot_2014 + 
      labs(title = paste0("2014 Election"), color="district") + 
      geom_point(data = cur, size=5, aes(color=as.character(district)))
  })
  
  output$order_plot_2016 = renderPlot({
    party = "D"
    
    prop = state$results_2016[[input$iter]] %>% vote_props() %>% pluck(party)
    
    cur = data_frame(
      district = (1:length(prop)) - 1,
      value = prop
    ) %>%
      arrange(value) %>%
      mutate(order = 1:n())
    
    g2=state$order_plot_2016 + 
      labs(title = paste0("2016 Election"), color="district") + 
      geom_point(data = cur, size=5, aes(color=as.character(district)))
  })
  
  output$map = renderLeaflet({
    if (is.null(state$maps))
      return()
    
    l = leaflet()

    if (state$type != "Grid")
      l = l %>% addTiles()
    
    g = state$geom  
    st_geometry(g) = st_transform(st_geometry(g), 4326)
    
    l %>%
      addPolygons(data=g, group="cands", color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 1.0, fillOpacity = 0.5)
  })
  
  observe({
    if (is.null(state$maps))
      return()
    
    mapdata = state$maps[[input$iter]]
    factpal <- colorFactor(topo.colors(4), mapdata$district)

    mapdata$geometry = st_transform(st_geometry(mapdata),4326)
    proxy <- leafletProxy("map", data = mapdata) %>%
      addPolygons(data=mapdata, group="cands", color = "#444444", weight = 1, smoothFactor = 0.5,
                  layerId=~district,
                  opacity = 1.0, fillOpacity = 0.5,
                  fillColor = ~factpal(district),
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE)) 
    
    
  })
  
  
  observeEvent(input$map_shape_click,{
    if (is.null(state$maps))
      return()
    
    click = input$map_shape_click
    
    if (is.null(click))
      return()
    
    pop=numeric()
    dist=click$id
    print(state$maps[[input$iter]])
    for(i in 1:nrow(state$maps[[input$iter]])){
      print(i)
      if(state$maps[[input$iter]]$district[i]==click$id){
        pop = state$maps[[input$iter]]$population[i]
      }
    }
    proxy = leafletProxy("map") 
    
    proxy %>% clearMarkers() %>% clearPopups()
    
    pop = toString(pop)
    poptxt = paste("population =", pop, sep=" ")
    proxy %>% addPopups(click$lng, click$lat,poptxt)
  })
}
