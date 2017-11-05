ui = fluidPage(
    titlePanel("Redistricting Vizualization"),
    h3("Redistricting from the perspective of an MCMC simulator"),
    fluidRow(
        column(3,
            h3("Redistricting Vizualization"), 
            h5("View the process of redistricting through the eyes of a Markov Chain Monte Carlo method"), 
            selectInput("inputtype", "Select input type", choices=c("Grid", "State"), selected="Grid"), 
            conditionalPanel(
                condition="input.inputtype=='State'", 
                selectInput("statefile", "Select a state", choices=c("Maryland", "North Carolina"))
            ), 
            numericInput("ndistricts", "Number of districts", min=2, value=6), 
            numericInput("nsimulations", "Number of simulatoins", min=1, value=100), 
            actionButton("redistrict", label="Run redistricting simulation"),
            selectInput("advanced", "Show advanced MCMC parameters", c(hide="Hide",show="Show"), selected="Hide"), 
            conditionalPanel(
                condition="input.advanced=='Show'",
                numericInput("n_thin", "Markov Chain Thining", min=1,value=1), 
                sliderInput("e_prob", "Probability of keeping an edge connected", 
                            min=0, max=1, value=0.05), 
                numericInput("lambda", "Lambda (number of swaps per step = Poi(lambda) + 1)", 
                             min=0,value=0),
                sliderInput("population_deviation", "Maximum Population Deviation (%)", 
                            min = 0, max = 1, value = 0.15), 
                selectInput("constraint", "Type of constraints", 
                            choices=list("None"=1, 
                                         "compact"=2, 
                                         "population"=3), 
                            selected=1), 
                selectInput("contiguity_method", "Definition for contiguity", 
                            choices=list("Rook"=1, "Queen"=2), selected=1),
                numericInput("n_burnin", "Number of burnin iterations", min=0, value=0)
            )
        ),
        column(8, offset=1,  
            h3("Redistricting Process:"),
            plotOutput("map"),
            sliderInput("iteration", "Select an iteration to display", min=1, max=length(maps), value=1, 
            animate=animationOptions(3000,TRUE), width=600),
            fluidRow(
                column(8, 
                    plotOutput("trace_plot", width=400, height=600), 
                    plotOutput("density_plot", width=600, height=600)
                )
            )
        ) 
    ) 
)
