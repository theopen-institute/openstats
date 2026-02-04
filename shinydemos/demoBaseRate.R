# app.R
library(shiny)
library(networkD3)
library(tibble)

sankeyHeight <- 600
sankeyWidth <- 1000

ui <- page_sidebar(
  # titlePanel("HIV Test Outcomes Sankey"),
  tags$style(HTML(
    "
      p, ul { font-size: 90%; }
      #sankeyWrap svg, 
      #sankeyWrap svg * {
        filter: none !important;
        box-shadow: none !important;
      }
      .sankey-tooltip {
        position: absolute;
        pointer-events: none;
        z-index: 99999;
        opacity: 0;
        transition: opacity 80ms linear;
        padding: 8px 10px;
        border-radius: 6px;
        background: rgba(20, 20, 20, 0.92);
        color: #fff;
        font-size: 12px;
        line-height: 1.25;
        box-shadow: 0 8px 24px rgba(0,0,0,0.25);
        max-width: 280px;
      }
      .sankey-tooltip .label {
        font-weight: 600;
        margin-bottom: 2px;
      }
      .sankey-tooltip .value {
        opacity: 0.9;
      }
    "
  )),
  sidebar = sidebar(
    open = "open",
    width = 400,
    tags$h1("The Base Rate Paradox"),
    # numericInput(
    #   inputId = "population",
    #   label = "Population",
    #   value = 100000,
    #   min = 1,
    #   step = 1000
    # ),

    tags$div(
      tags$p(
        "When we talk about the 'accuracy' of a statistical model, we need to distinguish at least three different things:"
      ),
      tags$ul(
        tags$li(
          "Sensitivity:",
          tags$br(),
          tags$code("P(test positive | condition present)")
        ),
        tags$li(
          "Specificity:",
          tags$br(),
          tags$code("P(test negative | condition absent)"),
        ),
        tags$li(
          "Positive Predictive Value:",
          tags$br(),
          tags$code("P(condition present | test positive)"),
        )
      )
    ),

    sliderInput(
      inputId = "prevalence_pct",
      label = "Condition Prevalence (%)",
      min = 0,
      max = 5,
      value = 0.1,
      step = 0.1
    ),

    sliderInput(
      inputId = "sensitivity_pct",
      label = "Test Sensitivity (%)",
      min = 0,
      max = 100,
      value = 99,
      step = 1
    ),
    sliderInput(
      inputId = "specificity_pct",
      label = "Test Specificity (%)",
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
    population <- 100000 # as.numeric(input$population)
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
       .range(["#c7dceb","#6baed6","#3182bd","#74c476","#f28e8c"])'
      ),
      height = sankeyHeight,
      width = sankeyWidth
    ) |>
      htmlwidgets::onRender(
        "
function(el) {
  // remove native SVG tooltips
  d3.select(el).selectAll('title').remove();

  var fmt = d3.format(',.0f');

  // tooltip div (one per widget)
  var tipId = 'sankey-tooltip-' + el.id;
  d3.select('body').select('#' + tipId).remove();

  var tip = d3.select('body')
    .append('div')
    .attr('id', tipId)
    .attr('class', 'sankey-tooltip')
    .style('position', 'absolute')
    .style('pointer-events', 'none')
    .style('z-index', 99999)
    .style('opacity', 0)
    .style('padding', '8px 10px')
    .style('border-radius', '6px')
    .style('background', 'rgba(20,20,20,0.92)')
    .style('color', '#fff')
    .style('font-size', '12px')
    .style('line-height', '1.25')
    .style('box-shadow', '0 8px 24px rgba(0,0,0,0.25)');

  function moveTip() {
    var e = d3.event;
    tip.style('left', (e.pageX + 12) + 'px')
       .style('top',  (e.pageY + 12) + 'px');
  }

  function showTip(label, value) {
    tip.html(
      '<div style=\"font-weight:600;\">' + label + '</div>' +
      '<div>' + fmt(value) + '</div>'
    ).style('opacity', 1);
    moveTip();
  }

  function hideTip() {
    tip.style('opacity', 0);
  }

  // LINKS: Source -> Target + value
  d3.select(el).selectAll('path.link')
    .on('mouseover.tooltip', function(d) {
      showTip(d.source.name + ' \u2192 ' + d.target.name, d.value);
    })
    .on('mousemove.tooltip', moveTip)
    .on('mouseout.tooltip', hideTip);

  // NODES: Name + value
  d3.select(el).selectAll('.node rect')
    .on('mouseover.tooltip', function(d) {
      showTip(d.name, d.value);
    })
    .on('mousemove.tooltip', moveTip)
    .on('mouseout.tooltip', hideTip);
}
"
      )
  })
}

shinyApp(ui, server)
