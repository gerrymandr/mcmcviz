library(sf)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)
library(redist)
library(leaflet)
library(rgdal)

aa <- readOGR("data/AnneArundelN.shp",
                  layer = "AnneArundelN", GDAL1_integer64_policy = TRUE)
ncwgs84 <- st_read("data/AnneArundelN.shp")
binpal <- colorBin("Blues", ncwgs84$Population, 6, pretty = FALSE)
binpal
m <- leaflet(ncwgs84) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  #addFeatures(st_transform(nc$geom,4326), layerId = nc$geom$id, fillColor = ~binpal(Population))
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~binpal,
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))
m
adj_mat2 = st_touches(nc, sparse = TRUE)
adj_mat2
popvect = nc$Population
numsims = 1000
numdists = 4
out = redist.mcmc(adjobj=adj_mat2,popvect,numsims,ndists=8,popcons=.05)



