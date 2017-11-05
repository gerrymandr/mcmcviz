################################################################################
# load_libraries.R                                                             #
################################################################################
# load_libraries.R loads various R libraries which are necessary for running   #
# the redistricting shiny app. The following libraries are all open source     #
# and freely available, so please, feel free to duplicate the analysis for     #
# your own education and advocacy!                                             #
#                                                                              # 
# The following libraries are used for the following purposes:                 #
#   - mapview: used to view map files                                          #
#   - mapedit: used to edit maps in real time                                  #
#   - sf: used to read and manipulate shapefiles                               #
#   - shiny: used to build the shiny app interface                             #
#   - redist: used to run mcmc on space of possible districts                  #
#   - magrittr: used for data pipelining                                       #
#   - purrr: used for data manipulation                                        #
#   - dplyr: used for data manipulation                                        #
#   - ggplot2: used to plot general functions                                  #
#   - devtools: used to install developer tools (for geom_sf)                  #
#   - gganimate: used to animate the map results                               #
################################################################################
################################################################################

library(mapview)
library(mapedit)
library(sf)
library(shiny)
library(redist)
library(magrittr)
library(purrr)
library(dplyr)
library(ggplot2)
library(devtools)
library(gganimate)

