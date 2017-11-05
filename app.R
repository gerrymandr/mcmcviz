source("src/load_libraries.R")
source("src/load_functions.R")

source("shiny/shiny_ui.R")
source("shiny/shiny_server.R")

shinyApp(ui, server)
