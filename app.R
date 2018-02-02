library(here)
source(here("R", "load_libraries.R"))
source(here("R", "load_functions.R"))

source(here("shiny", "shiny_ui.R"))
source(here("shiny", "shiny_server.R"))

shinyApp(ui, server)
