library(mapview)
library(mapedit)
library(sf)
library(shiny)
library(redist)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)

source('shiny_district_ui.R')
source('shiny_district_server.R')

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

shinyApp(ui, server)
