source("src/load_libraries.R")

# load some default values into the system so that nothing breaks
nsims = 100
nthin = 10
nburn = 100
ndists = 5
popcons = 0.10


# actually run the application
source("src/load_data.R")
source("src/load_functions.R")
source("src/load_mcmc.R")
source("shiny/shiny_ui.R")
source("shiny/shiny_server.R")

shinyApp(ui, server)
