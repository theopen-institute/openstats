# app.R
library(shiny)
library(networkD3)
library(tibble)

ui <- fluidPage(
  titlePanel("HIV Test Outcomes Sankey"),
  sidebarLayout(
    sidebarPanel(
      numericInput(
        inputId = "population",
        label = "Population",
        value = 100000,
        min = 1,
        step = 1000
      ),

      sliderInput(
        inputId = "prevalence_pct",
        label = "Prevalence (%)",
        min = 0,
        max = 5,
        value = 0.2,
        step = 0.01
      ),

      sliderInput(
        inputId = "sensitivity_pct",
        label = "Sensitivity (%)",
        min = 0,
        max = 100,
        value = 99,
        step = 1
      ),
      sliderInput(
        inputId = "specificity_pct",
        label = "Specificity (%)",
        min = 0,
        max = 100,
        value = 92,
        step = 1
      ),

      tags$hr(),
      strong("Positive Predictive Value (PPV):"),
      textOutput("ppv_text")
    ),
    mainPanel(
      sankeyNetworkOutput("sankey", height = "600px")
    )
  )
)

server <- function(input, output, session) {
  colourScale <- JS(
    'd3.scaleOrdinal()
       .domain(["population", "negative", "positive", "true", "false"])
       .range([
         "#c7dceb",
         "#6baed6",
         "#3182bd",
         "#74c476",
         "#f28e8c"
       ])'
  )

  nodes_reactive <- reactive({
    tibble(
      id = 0:6,
      name = c(
        "Population",
        "HIV-",
        "HIV+",
        "True Negative",
        "False Negative",
        "True Positive",
        "False Positive"
      ),
      group = c(
        "population",
        "negative",
        "positive",
        "true",
        "false",
        "true",
        "false"
      )
    )
  })

  ppv_reactive <- reactive({
    prevalence <- input$prevalence_pct / 100
    sensitivity <- input$sensitivity_pct / 100
    specificity <- input$specificity_pct / 100

    tp <- prevalence * sensitivity
    fp <- (1 - prevalence) * (1 - specificity)

    if ((tp + fp) == 0) NA_real_ else tp / (tp + fp)
  })

  output$ppv_text <- renderText({
    ppv <- ppv_reactive()
    if (is.na(ppv)) {
      "Undefined"
    } else {
      sprintf("%.2f%%", 100 * ppv)
    }
  })

  links_reactive <- reactive({
    population <- as.numeric(input$population)
    prevalence <- as.numeric(input$prevalence_pct) / 100
    sensitivity <- as.numeric(input$sensitivity_pct) / 100
    specificity <- as.numeric(input$specificity_pct) / 100

    tribble(
      ~source , ~target , ~value                                            , ~title           ,
            0 ,       1 , population * (1 - prevalence)                     , "HIV-"           ,
            0 ,       2 , population * prevalence                           , "HIV+"           ,
            1 ,       3 , population * (1 - prevalence) * specificity       , "True Negative"  ,
            2 ,       4 , population * prevalence * (1 - sensitivity)       , "False Negative" ,
            2 ,       5 , population * prevalence * sensitivity             , "True Positive"  ,
            1 ,       6 , population * (1 - prevalence) * (1 - specificity) , "False Positive"
    )
  })

  output$sankey <- renderSankeyNetwork({
    sankeyNetwork(
      Links = links_reactive(),
      Nodes = nodes_reactive(),
      Source = "source",
      Target = "target",
      Value = "value",
      NodeID = "name",
      NodeGroup = "group",
      fontSize = 14,
      nodeWidth = 30,
      iterations = 0,
      colourScale = colourScale
    )
  })
}

shinyApp(ui, server)
