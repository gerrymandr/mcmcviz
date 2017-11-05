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
    if(input$inputtype=="Shape") {
      return(input$state)
    } 
    else {
      return(input$grid)
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
      
    print('About to start running a new redistricting simulation with the following parameters')
    print(paste('Current shape file:', geom))
    print(paste('Number of districts:', ndists))
    print(paste('Number of simulations:',nsims))
    print(paste('Thinning rate for MCMC:', nthin))
    print(paste('Number of burnin iterations:', nburn))
    print(paste('Probility of edge swapping:',eprob))
    print(paste('Number of edges to swap = Poi(lambda) + 1:', lambda))
    print(paste('Population contraint percent deviation:', popcons))
    print(paste('Additional contraint types:', constraint))
    
    geom = geom
    iters = redistrict(geom, nsims, nthin, nburn, ndists, popcons)
    maps = gather_maps(geom, iters)
    results_2014 = gather_results(election_2014, iters)
    results_2016 = gather_results(election_2016, iters)
    metrics = gather_metrics(maps, results_2014, results_2016)
    
    updateSliderInput(session, "iter", max = length(iters), value = 1, step=1)
    
    state$geom = geom
    state$iters = iters
    state$maps = maps
    state$results_2014 = results_2014
    state$results_2016 = results_2016
    state$metrics = metrics
    
    state$trace_plot = ggplot(metrics, aes(x=iter,y=value)) + 
      geom_line() + 
      facet_grid(metric~. ,scales="free_y")
    
    state$density_plot = ggplot(metrics, aes(x=value)) + 
      geom_density() +
      facet_wrap(~metric, scales="free", ncol=3) 
    
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
      geom_vline(data=filter(state$metrics, iter==input$iter), aes(xintercept=iter), color="red")
  })
  
  
  output$map = renderPlot({
    if (is.null(state$maps))
      return()
    
    plot(select(state$maps[[input$iter]], district), main="", key.pos=NULL)
    plot(st_geometry(state$geom), add=TRUE, border=adjustcolor("black", alpha.f = 0.1))
  })
}
