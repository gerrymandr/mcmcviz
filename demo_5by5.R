library(sf)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)
library(redist)
library(shiny)
library(tidyr)
library(forcats)
library(parallel)
library(leaflet)

geom =  st_read("data/simple_grid_wgs84.shp")

election_2014 = geom %>%
  as.data.frame() %>%
  select(id, population = Population, contains("2014")) %>%
  mutate(
    R_votes = population * (E2014_R / 100),
    D_votes = population * (E2014_D / 100)
  )

election_2016 = geom %>%
  as.data.frame() %>%
  select(id, population = Population, contains("2016")) %>%
  mutate(
    R_votes = population * (E2016_R / 100),
    D_votes = population * (E2016_D / 100)
  )

#geom = geom %>% select(id, district = DISTRICT, population = Population)



nsims = 100
nthin = 1
nburnin = 0
ndists = 4
popcons = 0.20

source("utility.R")

adj_obj = st_relate(geom, pattern = "****1****")

mcmc = redist.mcmc(
  adj_obj, geom$population, 
  nsims = nsims+nburnin, ndists = ndists, 
  popcons = popcons
  #constraint = "compact", ssdmat = centroid_dist(geom)^2, beta=1 #FIXME
)

iters = mcmc$partitions %>% thin(nsims, nburnin, nthin=nthin) %>% as.data.frame() %>% as.list()

create_election_results = function(df, districts)
{
  mutate(df, district = as.character(districts)) %>% 
    group_by(district) %>% 
    summarize(
      population = sum(population), 
      R_votes = sum(R_votes),
      D_votes = sum(D_votes)
    ) 
}

create_district_map = function(geom, districts)
{
  mutate(geom, district = as.character(districts)) %>% 
    group_by(district) %>% 
    summarize(
      population = sum(population), 
      geometry = st_union(geometry)
    ) 
}

maps = mclapply(iters,  create_district_map, geom = geom, mc.cores = detectCores())

results_2014 = mclapply(iters, create_election_results, df = election_2014, mc.cores = detectCores())
results_2016 = mclapply(iters, create_election_results, df = election_2016, mc.cores = detectCores())

#save(maps, mcmc, file="aa_example.Rdata")

seats_2014 = map_df(results_2014, seats)
seats_2016 = map_df(results_2016, seats)

eff_gap_2014 = map_df(results_2014, efficiency_gap)
eff_gap_2016 = map_df(results_2016, efficiency_gap)

pop_diff = map_dbl(maps, pop_rmsd)
polsby = map(maps, polsby_popper)

metrics = data_frame(
  iter = seq_along(iters),
  polsby_min = map_dbl(polsby, min),
  polsby_avg = map_dbl(polsby, mean),
  pop_dff = pop_diff,
  D_seats_2014 = pull(seats_2014, D),
  D_seats_2016 = pull(seats_2016, D)
  #D_eff_gap_2014 = pull(eff_gap_2014, D),
  #D_eff_gap_2016 = pull(eff_gap_2016, D)
) %>% gather(metric, value, -iter)


trace = ggplot(metrics, aes(x=iter,y=value)) + 
  geom_line() + 
  facet_grid(as_factor(metric)~., scales="free_y") +
  theme_bw()

density = ggplot(metrics, aes(x=value)) + 
  geom_density() + 
  facet_wrap(~as_factor(metric), scales="free", ncol = 3) +
  theme_bw()

shinyApp(
  ui = fluidPage(
    fluidRow(
      column(width=4, leafletOutput("map", width = 400, height = 400)),
      column(width=4, plotOutput("trace_plot", width=400, height=600)),
      column(width=4, plotOutput("density_plot", width=600, height=600))
    ),
    fluidRow(
      column(width=4,
             sliderInput("iter","Iteration", min = 1, max=length(maps), value=1, animate=animationOptions(1000,TRUE), width = 600)
      )
    )
  ),
  server = function(input, output, session)
  {
    output$density_plot = renderPlot({
      density + geom_vline(data=filter(metrics, iter==input$iter), aes(xintercept=value), color="red")
    })
    
    output$trace_plot = renderPlot({
      trace + geom_vline(data=filter(metrics, iter==input$iter), aes(xintercept=iter), color="red")
    })
    
    output$map = renderLeaflet({
      nc <- st_read("data/simple_grid_wgs84.shp")
      factpal <- colorFactor(topo.colors(5), nc$District)
      leaflet() %>%
        addTiles() %>%
        addPolygons(data=nc, group="cands", color = "#444444", weight = 1, smoothFactor = 0.5,
                    opacity = 1.0, fillOpacity = 0.5,
                    fillColor = ~factpal(District),
                    highlightOptions = highlightOptions(color = "white", weight = 2,
                                                        bringToFront = TRUE))
    })
    
    observe({
      mapdata = maps[[input$iter]]
      factpal <- colorFactor(topo.colors(5), mapdata$district)
      print("helloworld")
      mapdata$geometry = st_transform(mapdata$geometry,4326)
      proxy <- leafletProxy("map", data = mapdata) %>%
        addPolygons(data=mapdata, group="cands", color = "#444444", weight = 1, smoothFactor = 0.5,
                    opacity = 1.0, fillOpacity = 0.5,
                    fillColor = ~factpal(district),
                    highlightOptions = highlightOptions(color = "white", weight = 2,
                                                        bringToFront = TRUE))
      
      
    })
  }
)


