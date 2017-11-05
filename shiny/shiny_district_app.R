# load all dependencies
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

# load in the ui, functions, and server
wd = getwd()
#source(paste0(wd, "/shiny_district_functions.R"))
source(paste0(wd,'/shiny_district_ui.R'))
source(paste0(wd,'/shiny_district_server.R'))


# actually run the app
shinyApp(ui, server)