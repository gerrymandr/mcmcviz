################################################################################
# shiny_ui.R                                                                   #
################################################################################
# shiny_ui.R specifies the design and layout of the web application run by the #
# shinyApp() and shiny_server.R functions. this file is the one to modify if   #
# anyone wants to add in more parameters and options for the user to tune in   #
# the actual web app                                                           #
################################################################################
################################################################################

grid_choices=c(
  "10x5 Grid"="simple_grid_wgs84",
  "5x5 Grid"="simple_grid",
  "10x10 Grid"="BigGrid2"
)

state_choices=c(
  "Maryland"="AnneArundelN"
)

ui = fluidPage(
  useShinyjs(),
  titlePanel("Redistricting Vizualization"),
  h3("Redistricting from the perspective of an MCMC simulator"),
  fluidRow(
    column(3,
           h3("Redistricting Vizualization"), 
           h5("View the process of redistricting through the eyes of a Markov Chain Monte Carlo method"), 

           actionButton("gerrymander", label="Click for gerrymandered state"),
           selectInput("inputtype", "Select input type", choices=c("Grid", "State"), selected="Grid"), 
           conditionalPanel(
             condition="input.inputtype=='State'", 
             selectInput("state", "Select a state", choices=state_choices)
           ), 
           conditionalPanel(
             condition="input.inputtype!='State'",
             selectInput("grid", "Select an example", choices=grid_choices)
           ),
           sliderInput("ndistricts", "Number of districts", min=2, value=3, max=6), 
           numericInput("nsimulations", "Number of simulations", min=1, value=100, max=100000),
           actionButton("redistrict", label="Run redistricting simulation", class="btn btn-primary"),
           checkboxInput("advanced", "Show advanced MCMC parameters"), 
           conditionalPanel(
             condition="input.advanced==true",
             numericInput("nburnin", "Number of burnin iterations", min=0, value=0),
             numericInput("nthin", "Markov Chain Thining", min=1,value=1, max=100), 
             sliderInput("eprob", "Probability of keeping an edge connected", 
                         min=0, max=1, value=0.05), 
             numericInput("lambda", "Lambda (number of swaps per step = Poi(lambda) + 1)", 
                          min=0,value=0),
             sliderInput("popcons", "Maximum Population Deviation (%)", 
                         min = 0, max = 1, value = 0.15)
           )
    ),
    column(8, offset=1,
      leafletOutput("map", width=400, height=400),
      #plotOutput("map"),
      sliderInput("iter", "Select an iteration to display", min=1, max=1, value=1, 
                  animate=animationOptions(500,TRUE), width=900),
      tabsetPanel(
        tabPanel("Trace Plots", plotOutput("trace_plot", width=600, height=600)),
        tabPanel("Density Plots", plotOutput("density_plot", width=400, height=400)),
        tabPanel("Order Plots", 
                  plotOutput("order_plot_2014", width=400, height=400),
                  plotOutput("order_plot_2016", width=400, height=400)
        )
      )
    ) 
  ) 
)
