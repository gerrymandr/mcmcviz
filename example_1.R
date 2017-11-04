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

pop_vec = runif(25, 150000, 350000)
num_sim = 1000
num_dis = 7

out = redist.mcmc(adj_mat, pop_vec, num_sim, ndist=num_dis)
if (FALSE) {
nc <- st_read("data/AnneArundelN.shp")
adj_mat2 = st_touches(nc, sparse = TRUE)
adj_mat2
popvect = nc$Population
numsims = 1000
numdists = 4
out = redist.mcmc(adjobj=adj_mat2,popvect,numsims,ndists=8,popcons=.05)
}
