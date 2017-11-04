library(sf)
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
  mutate(
    id = 1:n(),
    district = rep(1:5, rep(5,5))
  )

adj_mat = st_touches(nytimes, sparse = FALSE) * 1 
