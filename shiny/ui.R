ui = fluidPage(
  sidebarLayout(
    sidebarPanel(
      h3("Gerrymandering Vizualization"),
      h5("View the results of MCMC redistricting simulations on common shapes and states"),
      selectInput("ojb", "Object of Interest",
                  choices=list(
                    "5 x 5 grid"=1,
                    "Colorado"=2, 
                    "Maryland"=3, 
                    "Ohio"=4),
                  selected=1), 
      numericInput("n_districts", "Number of districts:", min = 1, value = 5),
      numericInput("n_simulations", "Number of simulations", min=1, value=100),
      #wellPanel(uiOutput("district_buttons")),
      
      
      actionButton("redistrict", label = "Redistrict randomly"),
      actionButton("advanced", label = "Show advanced features"),
      
      # Advanced Features
      conditionalPanel(
        condition = "true",
        numericInput("n_thin", "Markov Chain Thining", min=1,value=1), 
        sliderInput("e_prob", "Probability of keeping an edge connected", min=0, max=1, value=0.05), 
        numericInput("lambda", "Lambda (number of swaps per step = Poi(lambda) + 1)", min=0,value=0),
        sliderInput("population_deviation", "Maximum Population Deviation (%)", min = 1, max = 100, value = 15), 
        selectInput("constraint", "Type of constraints", 
                    choices=list("None"=1, 
                                 "compact"=2, 
                                 "population"=3), 
                    selected=1), 
        selectInput("contiguity_method", "Definition for contiguity", choices=list("Rook"=1, "Queen"=2), selected=1
                    
        ), 
      )
      
    ),
    
    mainPanel(
      h3("Select Grid"),
      plotOutput("map"),
      selectModUI("selectmap")
    )
  )
)