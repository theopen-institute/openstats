# app.R
library(shiny)
library(bslib)
library(networkD3)
library(tibble)

sankeyHeight <- 600
sankeyWidth <- 1000

ui <- page_sidebar(
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
    open = "always",
    width = 400,
    tags$h2("The Base Rate Paradox"),
    p(
      "Statistical tests help us evaluate the accuracy of prediction models. We often use tests to identify individuals with certain conditions or characteristics prevalent in our population."
    ),
    tags$div(
      tags$div(
        "Rate of Prevalence: P( condition+ )",
        style = "font-weight: bold;"
      ),
      tags$p(
        "Probability that a randomly selected individual has the condition.",
        style = "font-style: italic;"
      ),
      sliderInput(
        inputId = "prevalence_pct",
        label = NULL,
        min = 0,
        max = 10,
        value = 0.1,
        step = 0.1,
        post = "%"
      )
    ),
    tags$hr(style = "margin: 1px 0"),
    tags$div(
      tags$p(
        "Statistical tests are always imperfect. Their accuracy is usually summarized by two conditional rates:"
      ),
      tags$div(
        "Sensitivity: P( test+ | condition+ )",
        style = "font-weight: bold;"
      ),
      tags$p(
        "Probability of a positive test among those with the condition (true positive rate)",
        style = "font-style: italic;"
      ),
      sliderInput(
        inputId = "sensitivity_pct",
        label = NULL,
        min = 0,
        max = 100,
        value = 99,
        step = 1,
        post = "%"
      ),
      tags$div(
        "Specificity: P( test– | condition– )",
        style = "font-weight: bold;"
      ),
      tags$p(
        "Probability of a negative test among those without the condition (true negative rate)",
        style = "font-style: italic;"
      ),
      sliderInput(
        inputId = "specificity_pct",
        label = NULL,
        min = 0,
        max = 100,
        value = 92,
        step = 1,
        post = "%"
      )
    )
  ),
  mainPanel(
    width = 12,
    tags$p(
      "Sensitivity and specificity are important, but they can be misleading. They don't tell the whole story.",
      tags$br(),
      "Often, the kind of accuracy we are actually interested in understanding has the opposite conditional dependency."
    ),
    tags$div(
      tags$div(
        tags$div(
          "Positive Predictive Value: P( condition+ | test+ )",
          style = "font-weight: bold;"
        ),
        tags$p(
          "Probability of a condition among those with a positive test",
          style = "font-style: italic; margin-bottom: 0;"
        )
      ),
      tags$div(
        textOutput("ppv_text"),
        style = "font-size: 200%; font-weight: bold;"
      ),
      style = "display: flex; gap: 40px; align-items: end;"
    ),
    tags$hr(),
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
        "present",
        "absent",
        "true",
        "false",
        "true",
        "false"
      )
    ) |>
      as.data.frame()
  })

  links_reactive <- reactive({
    population <- 100000
    prevalence <- as.numeric(input$prevalence_pct) / 100
    sensitivity <- as.numeric(input$sensitivity_pct) / 100
    specificity <- as.numeric(input$specificity_pct) / 100

    links <- tribble(
      ~source , ~target , ~value                                            , ~title              ,
            0 ,       1 , population * prevalence                           , "Condition Present" ,
            0 ,       2 , population * (1 - prevalence)                     , "Condition Absent"  ,
            2 ,       5 , population * (1 - prevalence) * specificity       , "True Negative"     ,
            1 ,       6 , population * prevalence * (1 - sensitivity)       , "False Negative"    ,
            1 ,       3 , population * prevalence * sensitivity             , "True Positive"     ,
            2 ,       4 , population * (1 - prevalence) * (1 - specificity) , "False Positive"
    ) |>
      as.data.frame()

    # LinkGroup: inherit the source node's group -> links match/blend with node colors
    node_groups <- nodes_reactive()$group
    links$group <- node_groups[links$source + 1]

    links
  })

  output$ppv_text <- renderText({
    ppv <- ppv_reactive()
    if (is.na(ppv)) "Undefined" else sprintf("%.2f%%", 100 * ppv)
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

      # ---- link colors: CRAN networkD3 supports LinkGroup (not linkColourMode) ----
      LinkGroup = "group",

      fontSize = 14,
      nodeWidth = 30,
      iterations = 0,
      margin = list(top = 5, right = 0, bottom = 5, left = 5),
      sinksRight = TRUE,

      # Use semi-transparent RGBA so links blend nicely with nodes
      # (Nodes remain effectively opaque because they're solid rect fills)
      colourScale = JS(
        'd3.scaleOrdinal()
          .domain(["population", "absent", "present", "true", "false"])
          .range([
            "#2f6088ff",  // population
            "#a5c5e2ff",  // absent
            "#468ec9ff",   // present (slightly stronger)
            "#3E5915",  // true
            "#A60F37"   // false
          ])'
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
    .style('stroke-opacity', 0.55)  // optional: strengthen link visibility
    .on('mouseover.tooltip', function(d) {
      showTip(d.source.name + ' \\u2192 ' + d.target.name, d.value);
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
