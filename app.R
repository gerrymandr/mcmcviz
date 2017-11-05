# load some default values into the system so that nothing breaks
nsims = 100000
nthin = 100
nburnin = 100000
ndists = 5
popcons = 0.10

geom = expand.grid(x = 1:5, y = 1:5) %>%
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

geom$population = runif(25, 150000, 350000)

# actually run the application
wd = getwd()
source(paste0(wd,'/src/load_libraries.R'))
#source(paste0(wd,'/src/load_data.R'))
source(paste0(wd,'/src/load_functions.R'))
source(paste0(wd,'/src/load_mcmc.R'))
source(paste0(wd,'/shiny/shiny_ui.R'))
source(paste0(wd,'/shiny/shiny_server.R'))
shinyApp(ui, server)
