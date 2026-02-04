# app.R
library(shiny)
library(networkD3)
library(tibble)

sankeyHeight <- 600
sankeyWidth <- 1200

ui <- page_sidebar(
  # titlePanel("HIV Test Outcomes Sankey"),
  tags$style(HTML(
    "
      #sankeyWrap svg, 
      #sankeyWrap svg * {
        filter: none !important;
        box-shadow: none !important;
      }
    "
  )),
  sidebar = sidebar(
    open = "open",
    width = 400,
    h1("The Base Rate Paradox"),
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
      value = 0.1,
      step = 0.1
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
    )
  ),
  mainPanel(
    width = 12,
    tags$div(
      span("Positive Predictive Value:"),
      span(
        textOutput("ppv_text"),
        style = "font-size: 200%; font-weight: bold;"
      ),
      style = "display: flex; align-items: baseline; gap: 5px"
    ),
    tags$hr(style = "margin: 0"),
    sankeyNetworkOutput(
      "sankey",
      width = paste0(sankeyWidth, "px"),
      height = paste0(sankeyHeight, "px")
    )
  )
)


server <- function(input, output, session) {
  ppv_reactive <- reactive({
    prevalence <- input$prevalence_pct / 100
    sensitivity <- input$sensitivity_pct / 100
    specificity <- input$specificity_pct / 100

    tp <- prevalence * sensitivity
    fp <- (1 - prevalence) * (1 - specificity)

    if ((tp + fp) == 0) NA_real_ else tp / (tp + fp)
  })

  nodes_reactive <- reactive({
    tibble(
      id = 0:6,
      name = c(
        "Population",
        "Condition Present",
        "Condition Absent",
        "True Positive",
        "False Positive",
        "True Negative",
        "False Negative"
      ),
      group = c(
        "population",
        "positive",
        "negative",
        "true",
        "false",
        "true",
        "false"
      )
    ) |>
      as.data.frame()
  })
  links_reactive <- reactive({
    population <- as.numeric(input$population)
    prevalence <- as.numeric(input$prevalence_pct) / 100
    sensitivity <- as.numeric(input$sensitivity_pct) / 100
    specificity <- as.numeric(input$specificity_pct) / 100

    tribble(
      ~source , ~target , ~value                                            , ~title              ,
            0 ,       1 , population * prevalence                           , "Condition Present" ,
            0 ,       2 , population * (1 - prevalence)                     , "Condition Absent"  ,
            2 ,       5 , population * (1 - prevalence) * specificity       , "True Negative"     ,
            1 ,       6 , population * prevalence * (1 - sensitivity)       , "False Negative"    ,
            1 ,       3 , population * prevalence * sensitivity             , "True Positive"     ,
            2 ,       4 , population * (1 - prevalence) * (1 - specificity) , "False Positive"
    ) |>
      as.data.frame()
  })

  output$ppv_text <- renderText({
    ppv <- ppv_reactive()
    if (is.na(ppv)) {
      "Undefined"
    } else {
      sprintf("%.2f%%", 100 * ppv)
    }
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
      sinksRight = FALSE,
      colourScale = JS(
        'd3.scaleOrdinal()
       .domain(["population", "negative", "positive", "true", "false"])
       .range([
         "#c7dceb",
         "#6baed6",
         "#3182bd",
         "#74c476",
         "#f28e8c"
       ])'
      ),
      height = sankeyHeight,
      width = sankeyWidth
    )
  })
}

shinyApp(ui, server)
