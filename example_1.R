library(sf)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)
library(redist)
library(leaflet)
library(rgdal)


popvect = nc$Population

nsims = 100
nburnin = 10000
ndists = 3
popcons = 0.20

source("utility.R")

mcmc = redist.mcmc(adjobj=st_relate(nc, pattern = "****1****"), nc$Population, nsims = nsims+nburnin, ndists=ndists, popcons=popcons)

iters = mcmc$partitions[,1:nsims + nburnin] %>% as.data.frame() %>% as.list()

maps = map(iters, ~ mutate(nc, DISTRICT = .) %>% group_by(DISTRICT) %>% summarize(Population = sum(Population), geometry = st_union(geometry)) )
save(maps, file="aa_example.Rdata")


polsby = map(maps, polsby_popper)



i=1
plot(maps[[1]][,"DISTRICT"],)
plot(maps[[2]][,"DISTRICT"],)
plot(maps[[3]][,"DISTRICT"],)
plot(maps[[4]][,"DISTRICT"],)



