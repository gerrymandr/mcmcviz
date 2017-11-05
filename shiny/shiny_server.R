################################################################################
# shiny_server.R                                                               #
################################################################################
# shiny_server.R function runs all the server side operations to actually do   #
# the work required to plot things on the screen, render the map, and run the  #
# functions required to transform button input into action                     #
################################################################################
################################################################################

server = function(input, output, session) {
  
  observe({
    if(input$redistrict > 0) {
      if(input$inputtype=="Shape") {
        geom = input$state
      } 
      else {
        geom = input$grid
      }
      ndists = input$ndistricts
      nsims = input$nsimulations
      nthin = input$nthin
      nburnin = input$nburnin
      eprob = input$eprob
      lambda = input$lambda
      popcons = input$popcons
      constraint = input$constraint
      
      print('About to start running a new redistricting simulation with the following parameters')
      print(paste('Current shape file:', geom))
      print(paste('Number of districts:', ndistricts))
      print(paste('Number of simulations:',nsimulations))
      print(paste('Thinning rate for MCMC:', nthin))
      print(paste('Number of burnin iterations:', nburnin))
      print(paste('Probility of edge swapping:',eprob))
      print(paste('Number of edges to swap = Poi(lambda) + 1:', lambda))
      print(paste('Population contraint percent deviation:', popcons))
      print(paste('Additional contraint types:', constraint))

      iter = redistrict(geom, nsims, nthin, nburnin, ndists, popcons)
      maps = gather_maps(geom, iters)
      metrics = gather_metrics(iters, maps)
      
    }
  })
  
  output$trace_plot=renderPlot({
    if (input$showplots == 'No') {
      return()
    }
    
    ggplot(metrics, aes(x=iter,y=value)) + 
      geom_line() + 
      facet_grid(metric~. ,scales="free_y") +
      geom_vline(data=filter(metrics, iter==input$iteration), aes(xintercept=iter), color="red")
  })
  output$density_plot=renderPlot({
    if (input$showplots == 'No') {
      return()
    }
    
    metrics=gather_metrics()
    
    ggplot(metrics, aes(x=value)) + 
      geom_line() +
      facet_grid(metric~., scales="free", ncol=4) +
      geom_vline(data=filter(metrics, iter=input$iteration), aes(xintercept=iter), color=red)
  })
  
  
  output$map = renderPlot({
    plot(select(maps[[input$iter]], district), main="", key.pos=NULL)
    plot(st_geometry(geom), add=TRUE, border=adjustcolor("black", alpha.f = 0.1))
  })
}
