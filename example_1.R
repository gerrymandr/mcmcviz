library(sf)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)
library(redist)
library(leaflet)
library(rgdal)


aa84 <- readOGR("data/AnneArundelN84.shp",
                  layer = "AnneArundelN84", GDAL1_integer64_policy = TRUE)
aa <- st_read("data/AnneArundelN.shp")
binpal <- colorBin("Blues", aa84$Population, 6, pretty = TRUE)
binpal
m <- leaflet(aa84) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  #addFeatures(st_transform(nc$geom,4326), layerId = nc$geom$id, fillColor = ~binpal(Population))
  addPolygons(group="cands", color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~binpal(Population),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))

m
m %>% clearGroup("cands")

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



adj_mat2 = st_touches(aa, sparse = TRUE)
adj_mat2
popvect = nc$Population
numsims = 1000
numdists = 4
out = redist.mcmc(adjobj=adj_mat2,popvect,numsims,ndists=8,popcons=.05)



