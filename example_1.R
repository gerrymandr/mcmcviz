library(sf)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)
library(redist)


nc <- st_read("data/AnneArundelN.shp")
adj_mat2 = st_touches(nc, sparse = TRUE)
adj_mat2
popvect = nc$Population
numsims = 1000
numdists = 4
out = redist.mcmc(adjobj=adj_mat2,popvect,numsims,ndists=8,popcons=.05)

