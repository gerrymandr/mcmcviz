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


geom = st_read("data/AnneArundelN.shp", quiet = TRUE)

names(geom) = tolower(names(geom))

election_2014 = geom %>%
  as.data.frame() %>%
  select(id, population, contains("2014")) %>%
  mutate(
    R_votes = population * (e2014_r / 100),
    D_votes = population * (e2014_d / 100)
  )

election_2016 = geom %>%
  as.data.frame() %>%
  select(id, population, contains("2016")) %>%
  mutate(
    R_votes = population * (e2016_r / 100),
    D_votes = population * (e2016_d / 100)
  )

