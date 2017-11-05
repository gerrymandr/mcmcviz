################################################################################
# load_libraries.R                                                             #
################################################################################
# load_libraries.R loads various R libraries which are necessary for running   #
# the redistricting shiny app. The following libraries are all open source     #
# and freely available, so please, feel free to duplicate the analysis for     #
# your own education and advocacy!                                             #
#                                                                              # 
# The following libraries are used for the following purposes:                 #
#   - shiny: used to build the shiny app interface                             #
#   - magrittr: used for data pipelining                                       #
#   - purrr: used for data manipulation                                        #
#   - dplyr: used for data manipulation                                        #
#   - ggplot2: used to plot general functions                                  #
#   - devtools: used to install developer tools (for geom_sf)                  #
#   - gganimate: used to animate the map results                               #
#   - mapview: used to view map files                                          #
#   - mapedit: used to edit maps in real time                                  #
#   - sf: used to read and manipulate shapefiles                               #
#   - leaflet: used to display annotations etc on shapes via js                #
#   - rgdal: used to interface with GDAL for shape manipulation                #
#   - redist: used to run mcmc on space of possible districts                  #
################################################################################
################################################################################

# webapp/ui tools
library(shiny)

# data pipelining and org. tools
library(magrittr)
library(purrr)
library(dplyr)

# general plotting tools
library(ggplot2)
library(gganimate)

# mapping tools
library(mapview)
library(mapedit)
library(sf)
library(leaflet)
library(rgdal)

# mcmc tools
library(redist)
