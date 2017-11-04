library(sf)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)
library(redist)
library(shiny)

popvect = nc$Population

nsims = 10000
nthin = 100
nburnin = 10000
ndists = 3
popcons = 0.20

source("utility.R")

ssd = nc %>% 
  st_geometry() %>% 
  st_centroid() %>% 
  st_coordinates() %>% 
  dist() %>% 
  as.matrix() %>%
  {.^2}

mcmc = redist.mcmc(adjobj=st_relate(nc, pattern = "****1****"), nc$Population, nsims = nsims+nburnin, ndists=ndists, popcons=popcons, constraint = "compact", ssdmat = ssd, beta=0.1, nthin=1000)

iters = mcmc$partitions[,(1:(nsims/nthin))*nthin + nburnin] %>% as.data.frame() %>% as.list()

maps = map(iters, ~ mutate(nc, DISTRICT = as.character(.)) %>% group_by(DISTRICT) %>% summarize(Population = sum(Population), geometry = st_union(geometry)) )
#save(maps, file="aa_example.Rdata")


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

