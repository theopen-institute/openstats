# TODO: consider merging root_ values and _val variables
# TODO: implement sex differentiation
# TODO: update model definition based on units and sex differentiation
# TODO: make generate buttons do something

library(shiny)
library(bslib)
library(shinyjs)
library(ggplot2)
library(tibble)
library(ggiraph)
library(htmlwidgets)
library(uuid)
library(munsell)

INITIAL_ALPHA <- -40
INITIAL_BETA <- 0.6
INITIAL_SIGMA <- 5

CSS <- "
  .plot-wrap {
    position: relative;
    width: 100%;
    padding-left: 25px;
    padding-bottom: 25px;
  }

  .height-units-inline {
    position: absolute;
    left: 50%;
    bottom: 0;
    transform: translateX(-50%);
    width: 360px;
    z-index: 10;
  }

  .weight-units-inline {
    position: absolute;
    left: 0;
    bottom: 0;
    transform: translateY(-50%) rotate(-90deg);
    transform-origin: left top;
    width: 45%;
    z-index: 10;
  }

  .height-units-inline .shiny-input-container {
    margin-bottom: 0;
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .weight-units-inline .shiny-input-container {
    margin-bottom: 0;
    display: flex;
    align-items: center;
    gap: 0.5rem;
    justify-content: center;
    width: 100%;
  }

  .height-units-inline label,
  .weight-units-inline label {
    margin-bottom: 0;
    font-weight: 600;
    white-space: nowrap;
  }

  .height-units-inline .form-select,
  .weight-units-inline .form-select,
  .height-units-inline select,
  .weight-units-inline select {
    flex: 1;
    min-width: 0;
  }
  .height-units-inline .selectize-control,
  .weight-units-inline .selectize-control {
    width: 200px;
  }
  "

ui <- page_sidebar(
  tags$head(
    tags$style(HTML(CSS))
  ),
  sidebar = sidebar(
    open = "always",
    width = 400,
    withMathJax(),
    tags$h2("Generative Models"),
    checkboxInput("include_sex", "Include sex?", value = FALSE),
    tags$div(uiOutput("modelDef")),
    tags$hr(),
    tags$h3("Parameters"),
    tags$div(
      class = "d-flex flex-nowrap gap-2 align-items-end",
      numericInput(
        "alpha",
        "⍺ (intercept)",
        value = INITIAL_ALPHA,
        width = "100%"
      ),
      tags$div(
        class = "d-flex flex-column justify-content-end",
        actionButton(
          "generate-alpha",
          "↺",
          class = "btn-primary",
          style = "margin-bottom: 1rem;"
        )
      )
    ),
    tags$div(
      class = "d-flex flex-nowrap gap-2 align-items-end",
      numericInput(
        "beta",
        "𝛽 (coefficient)",
        value = INITIAL_BETA,
        width = "100%"
      ),
      tags$div(
        class = "d-flex flex-column justify-content-end",
        actionButton(
          "generate-beta",
          "↺",
          class = "btn-primary",
          style = "margin-bottom: 1rem;"
        )
      )
    ),
    tags$div(
      class = "d-flex flex-nowrap gap-2 align-items-end",
      sliderInput(
        "sigma",
        "𝜎 (residual deviation)",
        min = 0,
        max = 100,
        value = INITIAL_SIGMA,
        width = "100%"
      ),
      tags$div(
        class = "d-flex flex-column justify-content-end",
        actionButton(
          "generate-sigma",
          "↺",
          class = "btn-primary",
          style = "margin-bottom: 1.5rem;"
        )
      )
    )
  ),
  tags$p("What are we doing here?"),
  tags$ul(
    tags$li(
      "When fitting a statistical model, we use observed data to infer the values of unknown parameters."
    ),
    tags$li(
      "When simulating from a generative model, we do the opposite: we choose parameter values and generate synthetic data from them to see what kinds of observations the model would make."
    )
  ),
  div(
    class = "plot-wrap",
    div(
      class = "weight-units-inline",
      selectInput(
        "weight_units",
        "Weight",
        choices = c("Kilograms", "Pounds"),
        selected = "Kilograms"
      )
    ),
    girafeOutput("generatedPlot"),
    div(
      class = "height-units-inline",
      selectInput(
        "height_units",
        "Height",
        choices = c("Centimeters", "Inches", "Standardized Units"),
        selected = "Centimeters"
      )
    )
  )
)

server <- function(input, output, session) {
  # base in cm
  HEIGHT_MEAN <- 155
  HEIGHT_SD <- 25
  # weight base in kg (for default parameters)
  WEIGHT_MEAN <- 49

  heights <- rnorm(200, 0, 1)
  residev <- rnorm(200, 0, 1)
  sex <- rbinom(200, 1, 0.5)

  root_alpha <- reactiveVal(INITIAL_ALPHA) # kg ~ cm intercept
  root_beta <- reactiveVal(INITIAL_BETA) # kg per cm
  root_sigma <- reactiveVal(INITIAL_SIGMA) # kg

  alpha_val <- reactiveVal(INITIAL_ALPHA)
  beta_val <- reactiveVal(INITIAL_BETA)
  sigma_val <- reactiveVal(INITIAL_SIGMA)

  # --- scales/shifts ---
  alphaScale <- reactive({
    switch(input$weight_units, "Kilograms" = 1, "Pounds" = 2.20462, 1)
  })

  alphaShift <- reactive({
    switch(
      input$height_units,
      "Centimeters" = 0,
      "Inches" = 0,
      "Standardized Units" = HEIGHT_MEAN * root_beta(),
      0
    )
  })

  betaScale <- reactive({
    h <- switch(
      input$height_units,
      "Centimeters" = 1,
      "Inches" = 2.54,
      "Standardized Units" = HEIGHT_SD,
      1
    )
    w <- switch(input$weight_units, "Kilograms" = 1, "Pounds" = 2.20462, 1)
    h * w
  })

  sigmaScale <- reactive({
    switch(input$weight_units, "Kilograms" = 1, "Pounds" = 2.20462, 1)
  })

  # --- user edits: displayed units -> root units ---
  observeEvent(
    input$alpha,
    {
      req(!is.na(input$alpha))
      root_alpha((as.numeric(input$alpha) / alphaScale()) - alphaShift())
      alpha_val(as.numeric(input$alpha))
    },
    ignoreInit = TRUE
  )

  observeEvent(
    input$beta,
    {
      req(!is.na(input$beta))
      root_beta(as.numeric(input$beta) / betaScale())
      beta_val(as.numeric(input$beta))
    },
    ignoreInit = TRUE
  )

  observeEvent(
    input$sigma,
    {
      req(!is.na(input$sigma))
      root_sigma(as.numeric(input$sigma) / sigmaScale())
      sigma_val(as.numeric(input$sigma))
    },
    ignoreInit = TRUE
  )

  # --- unit changes: root units -> displayed units ---
  sync_from_root <- function() {
    new_alpha <- (root_alpha() + alphaShift()) * alphaScale()
    new_beta <- root_beta() * betaScale()
    new_sigma <- root_sigma() * sigmaScale()

    alpha_val(new_alpha)
    beta_val(new_beta)
    sigma_val(new_sigma)

    updateNumericInput(session, "alpha", value = new_alpha)
    updateNumericInput(session, "beta", value = new_beta)
    updateSliderInput(session, "sigma", value = new_sigma)
  }

  observeEvent(
    list(input$height_units, input$weight_units),
    {
      sync_from_root()
    },
    ignoreInit = TRUE
  )

  heightScale <- reactive({
    switch(
      input$height_units,
      "Centimeters" = HEIGHT_SD,
      "Inches" = HEIGHT_SD / 2.54,
      "Standardized Units" = 1,
      1
    )
  })
  heightShift <- reactive({
    switch(
      input$height_units,
      "Centimeters" = HEIGHT_MEAN,
      "Inches" = HEIGHT_MEAN / 2.54,
      "Standardized Units" = 0,
      0
    )
  })
  weightScale <- reactive({
    switch(
      input$weight_units,
      "Kilograms" = 1,
      "Pounds" = 2.20462,
      1
    )
  })

  observeEvent(
    input$height_units,
    {
      new_alpha <- (root_alpha() + alphaShift()) * alphaScale()
      alpha_val(new_alpha)
      updateNumericInput(session, "alpha", value = new_alpha)

      new_beta <- root_beta() * betaScale()
      beta_val(new_beta)
      updateNumericInput(session, "beta", value = new_beta)
    },
    ignoreInit = TRUE
  )

  # convert parameters when units change
  observeEvent(
    input$weight_units,
    {
      new_alpha <- (root_alpha() + alphaShift()) * alphaScale()
      alpha_val(new_alpha)
      updateNumericInput(session, "alpha", value = new_alpha)

      new_beta <- root_beta() * betaScale()
      beta_val(new_beta)
      updateNumericInput(session, "beta", value = new_beta)

      new_sigma <- root_sigma() * sigmaScale()
      sigma_val(new_sigma)
      updateNumericInput(session, "sigma", value = new_sigma)
    },
    ignoreInit = TRUE
  )

  output$generatedPlot <- renderGirafe({
    req(
      !is.na(alpha_val()),
      !is.na(beta_val()),
      !is.na(sigma_val()),
      sigma_val() >= 0
    )

    df <- tibble(
      height = heights * heightScale() + heightShift(),
      weight_pred = height * beta_val() + alpha_val(),
      weight = weight_pred + (sigma_val() * residev)
    )

    plot <- ggplot(df, aes(x = height, y = weight)) +
      geom_point_interactive(aes(
        tooltip = paste0(
          "Height: ",
          round(height, 1),
          "<br>Weight: ",
          round(weight, 1)
        ),
        data_id = seq_len(nrow(df))
      )) +
      annotate_interactive(
        "segment",
        tooltip = paste0(
          "Alpha: ",
          round(alpha_val(), 1),
          "<br>Beta: ",
          round(beta_val(), 1)
        ),
        x = min(df$height),
        y = min(df$height) * beta_val() + alpha_val(),
        xend = max(df$height),
        yend = max(df$height) * beta_val() + alpha_val(),
        color = "purple",
        linewidth = 1,
        alpha = 0.7
      ) +
      labs(x = "", y = "") +
      coord_cartesian(
        xlim = c(
          heightShift() - 4 * heightScale(),
          heightShift() + 4 * heightScale()
        ),
        ylim = c(0, weightScale() * 120),
        clip = "off"
      )

    girafe(
      ggobj = plot,
      width_svg = 12,
      height_svg = 6,
      options = list(
        opts_hover(css = "fill:orange;r:4px;"),
        opts_toolbar(saveaspng = TRUE)
      )
    )
  })

  output$modelDef <- renderUI({
    withMathJax(HTML(paste0(
      r"{
        $$
        \begin{array}{@{} r @{\qquad} l @{}}
        \textbf{Likelihood:} &
          \begin{aligned}[t]
          {\text{weight}_i} &\sim \text{Normal}({\mu_i}, {\sigma})
          \end{aligned}
          \\[6pt]

        \textbf{Predictor:} &
          \begin{aligned}[t]
          {\mu_i} &= {\alpha} + {\beta} \times {\text{height}_i}
          \end{aligned}
          \\[6pt]

        \textbf{Priors:} &
          \begin{aligned}[t]
          {\alpha} &\sim \text{Normal}(60, 10) \\
          {\beta} &\sim \text{Normal}(0, 5) \\
          {\sigma} &\sim \text{Normal}(0, 10), \quad {\sigma} > 0
          \end{aligned}
        \end{array}
        $$
      }"
    )))
  })
}

shinyApp(ui, server)
