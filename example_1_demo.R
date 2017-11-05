
popvect = nc$Population

nsims = 100000
nthin = 100
nburnin = 100000
ndists = 3
popcons = 0.20


mcmc = redist.mcmc(adjobj=st_relate(nc, pattern = "****1****"), nc$Population, nsims = nsims+nburnin, ndists=ndists, popcons=popcons, constraint = "compact", ssdmat = centroid_dist(nc)^2, beta=0.1)

iters = mcmc$partitions %>% thin(nsims, nburn, nthin=100) %>% as.data.frame() %>% as.list()

create_districts = function(districts)
{
  mutate(nc, DISTRICT = as.character(districts)) %>% 
    group_by(DISTRICT) %>% 
    summarize(Population = sum(Population), geometry = st_union(geometry)) 
}
maps = mclapply(iters,  create_districts, mc.cores = 4)
#save(maps, mcmc, file="aa_example.Rdata")


polsby = map(maps, polsby_popper)


shinyApp(
  ui = fluidPage(
    plotOutput("plot"),
    sliderInput("iter","Iteration", min = 1, max=length(maps), value=1, animate=TRUE)
  ),
  server = function(input, output, session)
  {
    output$plot = renderPlot({
      plot(maps[[input$iter]][,"DISTRICT"])
      plot(st_geometry(nc), add=TRUE, border=adjustcolor("black", alpha.f = 0.1))
    })
  }
)

