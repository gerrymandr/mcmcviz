
aa84 <- readOGR("data/AnneArundelN84.shp",
                layer = "AnneArundelN84", GDAL1_integer64_policy = TRUE)
class(aa84)
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

load("data/aa_example.Rdata")
maps
maps[[1]]$geometry = st_transform(maps[[1]]$geometry,4326)
maps1 = maps[[1]]


binpal <- colorBin("Greens", maps1$Population, 6, pretty = TRUE)
m %>% addPolygons(data=maps1, group="cands", color = "#444444", weight = 1, smoothFactor = 0.5,
                    opacity = 1.0, fillOpacity = 0.5,
                    fillColor = ~binpal(Population),
                    highlightOptions = highlightOptions(color = "white", weight = 2,
                                                        bringToFront = TRUE))
