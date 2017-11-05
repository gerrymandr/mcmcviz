################################################################################
# load_data.R                                                                  #
################################################################################
# load_data.R calls various R functions to load data files for demo into a     #
# global environement. currenlty the script loads the following data sources   #
#   - nytimes: a sample 5x5 grid that is connected in the traditional sense    #
#   - aa84: data from AnneArundelN85.shp which encodes information for         #
#     anne arundel county in maryland (home of baltimore)                      #
#   - col: data from colorado                                                  #
################################################################################
################################################################################


geom <- st_read("data/AnneArundelN.shp")

election_2014 = geom %>%
  as.data.frame() %>%
  select(id, population = Population, contains("2014")) %>%
  mutate(
    R_votes = population * (E2014_R / 100),
    D_votes = population * (E2014_D / 100)
  )

election_2016 = geom %>%
  as.data.frame() %>%
  select(id, population = Population, contains("2016")) %>%
  mutate(
    R_votes = population * (E2016_R / 100),
    D_votes = population * (E2016_D / 100)
  )

geom = geom %>% select(id, district = DISTRICT, population = Population)



aa <- geom


if (FALSE) {

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
load("data/aa_example.Rdata")

}
################################################################################
################################################################################
# This is where colorado data should be loaded in the future                   #
################################################################################
################################################################################

