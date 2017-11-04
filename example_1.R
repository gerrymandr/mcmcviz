library(sf)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)
library(redist)


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

adj_mat = st_touches(nytimes, sparse = TRUE)

popvect <- runif(25, 1.0, 10000)
numsims = 100
numdists = 4
out = redist.mcmc(adjobj=adj_mat,popvect,numsims,ndists=4)
