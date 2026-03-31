library(shiny)
library(bslib)
library(ggplot2)
library(tibble)
library(ggiraph)

INITIAL_ALPHA_FEMALE <- -40
INITIAL_ALPHA_MALE <- -32
INITIAL_BETA <- 0.6
INITIAL_SIGMA <- 5

N_POINTS <- 200
HEIGHT_MEAN_CM <- 155
HEIGHT_SD_CM <- 25
KG_TO_LB <- 2.20462
CM_PER_IN <- 2.54

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

  .height-units-inline .shiny-input-container,
  .weight-units-inline .shiny-input-container {
    margin-bottom: 0;
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .weight-units-inline .shiny-input-container {
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

param_row <- function(input_ui, button_id, button_margin = "1rem") {
  tags$div(
    class = "d-flex flex-nowrap gap-2 align-items-end",
    input_ui,
    tags$div(
      class = "d-flex flex-column justify-content-end",
      actionButton(
        button_id,
        "↺",
        class = "btn-primary",
        style = paste0("margin-bottom: ", button_margin, ";")
      )
    )
  )
}

ui <- page_sidebar(
  tags$head(tags$style(HTML(CSS))),
  sidebar = sidebar(
    open = "always",
    width = 430,
    style = "gap: 10px",
    withMathJax(),
    tags$h2("Generative Models"),
    checkboxInput("include_sex", "Include sex?", value = FALSE),
    tags$div(uiOutput("modelDef")),
    tags$hr(),
    tags$h3("Parameters"),

    uiOutput("alpha_ui"),

    param_row(
      numericInput(
        "beta",
        "𝛽 (coefficient)",
        value = INITIAL_BETA,
        width = "100%"
      ),
      "generate_beta"
    ),

    param_row(
      sliderInput(
        "sigma",
        "𝜎 (residual deviation)",
        min = 0,
        max = 100,
        value = INITIAL_SIGMA,
        width = "100%"
      ),
      "generate_sigma",
      button_margin = "1.5rem"
    ),

    # tags$hr(),
    # actionButton(
    #   "generate_data",
    #   "Generate new data",
    #   class = "btn-secondary w-100"
    # )
  ),

  tags$p("What are we doing here?"),
  tags$ul(
    tags$li(
      "When fitting a statistical model, we use observed data to infer the values of unknown parameters."
    ),
    tags$li(
      "When simulating from a generative model, we do the opposite: we choose parameter values and generate synthetic data from them to see what kinds of predictions the model would make."
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
  root_alpha_female <- reactiveVal(INITIAL_ALPHA_FEMALE)
  root_alpha_male <- reactiveVal(INITIAL_ALPHA_MALE)
  root_beta <- reactiveVal(INITIAL_BETA)
  root_sigma <- reactiveVal(INITIAL_SIGMA)

  updating_inputs <- reactiveVal(FALSE)

  weight_scale <- reactive({
    switch(
      input$weight_units,
      "Kilograms" = 1,
      "Pounds" = KG_TO_LB,
      1
    )
  })

  alpha_shift_root <- reactive({
    switch(
      input$height_units,
      "Centimeters" = 0,
      "Inches" = 0,
      "Standardized Units" = HEIGHT_MEAN_CM * root_beta(),
      0
    )
  })

  beta_display_scale <- reactive({
    switch(
      input$height_units,
      "Centimeters" = 1,
      "Inches" = CM_PER_IN,
      "Standardized Units" = HEIGHT_SD_CM,
      1
    ) *
      weight_scale()
  })

  display_alpha_female <- reactive({
    (root_alpha_female() + alpha_shift_root()) * weight_scale()
  })

  display_alpha_male <- reactive({
    (root_alpha_male() + alpha_shift_root()) * weight_scale()
  })

  display_alpha <- reactive({
    (root_alpha_female() + alpha_shift_root()) * weight_scale()
  })

  display_beta <- reactive({
    root_beta() * beta_display_scale()
  })

  display_sigma <- reactive({
    root_sigma() * weight_scale()
  })

  height_unit_label <- reactive({
    switch(
      input$height_units,
      "Centimeters" = "cm",
      "Inches" = "in",
      "Standardized Units" = "z",
      ""
    )
  })

  weight_unit_label <- reactive({
    switch(
      input$weight_units,
      "Kilograms" = "kg",
      "Pounds" = "lb",
      ""
    )
  })

  canonical_to_display_height <- function(height_cm, units) {
    switch(
      units,
      "Centimeters" = height_cm,
      "Inches" = height_cm / CM_PER_IN,
      "Standardized Units" = (height_cm - HEIGHT_MEAN_CM) / HEIGHT_SD_CM,
      height_cm
    )
  }

  canonical_to_display_weight <- function(weight_kg, units) {
    switch(
      units,
      "Kilograms" = weight_kg,
      "Pounds" = weight_kg * KG_TO_LB,
      weight_kg
    )
  }

  set_root_alpha_from_display <- function(
    alpha_display,
    which = c("female", "male"),
    beta_root = root_beta()
  ) {
    which <- match.arg(which)

    shift <- switch(
      input$height_units,
      "Centimeters" = 0,
      "Inches" = 0,
      "Standardized Units" = HEIGHT_MEAN_CM * beta_root,
      0
    )

    alpha_root <- (alpha_display / weight_scale()) - shift

    if (which == "female") {
      root_alpha_female(alpha_root)
    } else {
      root_alpha_male(alpha_root)
    }
  }

  sync_inputs_from_root <- function() {
    vals <- isolate(list(
      include_sex = isTRUE(input$include_sex),
      alpha = round(display_alpha(), 3),
      alpha_female = round(display_alpha_female(), 3),
      alpha_male = round(display_alpha_male(), 3),
      beta = round(display_beta(), 3),
      sigma = min(max(display_sigma(), 0), 100)
    ))

    updating_inputs(TRUE)
    on.exit(updating_inputs(FALSE), add = TRUE)

    freezeReactiveValue(input, "alpha")
    freezeReactiveValue(input, "alpha_female")
    freezeReactiveValue(input, "alpha_male")
    freezeReactiveValue(input, "beta")
    freezeReactiveValue(input, "sigma")

    if (vals$include_sex) {
      updateNumericInput(session, "alpha_female", value = vals$alpha_female)
      updateNumericInput(session, "alpha_male", value = vals$alpha_male)
    } else {
      updateNumericInput(session, "alpha", value = vals$alpha)
    }

    updateNumericInput(session, "beta", value = vals$beta)
    updateSliderInput(session, "sigma", value = vals$sigma)
  }

  sim_data <- reactiveVal(NULL)

  regenerate_data <- function() {
    sim_data(list(
      height_z = rnorm(N_POINTS, 0, 1),
      resid_z = rnorm(N_POINTS, 0, 1),
      sex = rbinom(N_POINTS, 1, 0.5)
    ))
  }

  regenerate_data()

  observeEvent(input$generate_data, {
    regenerate_data()
  })

  observeEvent(input$generate_alpha, {
    if (isTRUE(input$include_sex)) {
      root_alpha_female(rnorm(1, mean = 60, sd = 10))
      root_alpha_male(rnorm(1, mean = 60, sd = 10))
    } else {
      root_alpha_female(rnorm(1, mean = 60, sd = 10))
      root_alpha_male(root_alpha_female())
    }
    sync_inputs_from_root()
  })

  observeEvent(input$generate_alpha_female, {
    root_alpha_female(rnorm(1, mean = 60, sd = 10))
    sync_inputs_from_root()
  })

  observeEvent(input$generate_alpha_male, {
    root_alpha_male(rnorm(1, mean = 60, sd = 10))
    sync_inputs_from_root()
  })

  observeEvent(input$generate_beta, {
    new_root_beta <- rnorm(1, mean = 0, sd = 5)

    if (identical(input$height_units, "Standardized Units")) {
      if (isTRUE(input$include_sex)) {
        alpha_female_disp <- isolate(as.numeric(input$alpha_female))
        alpha_male_disp <- isolate(as.numeric(input$alpha_male))

        root_beta(new_root_beta)
        set_root_alpha_from_display(
          alpha_female_disp,
          "female",
          beta_root = new_root_beta
        )
        set_root_alpha_from_display(
          alpha_male_disp,
          "male",
          beta_root = new_root_beta
        )

        updating_inputs(TRUE)
        on.exit(updating_inputs(FALSE), add = TRUE)
        freezeReactiveValue(input, "alpha_female")
        freezeReactiveValue(input, "alpha_male")
        freezeReactiveValue(input, "beta")
        updateNumericInput(
          session,
          "alpha_female",
          value = round(alpha_female_disp, 3)
        )
        updateNumericInput(
          session,
          "alpha_male",
          value = round(alpha_male_disp, 3)
        )
        updateNumericInput(
          session,
          "beta",
          value = round(new_root_beta * beta_display_scale(), 3)
        )
      } else {
        alpha_disp <- isolate(as.numeric(input$alpha))
        root_beta(new_root_beta)
        set_root_alpha_from_display(
          alpha_disp,
          "female",
          beta_root = new_root_beta
        )
        root_alpha_male(root_alpha_female())

        updating_inputs(TRUE)
        on.exit(updating_inputs(FALSE), add = TRUE)
        freezeReactiveValue(input, "alpha")
        freezeReactiveValue(input, "beta")
        updateNumericInput(session, "alpha", value = round(alpha_disp, 3))
        updateNumericInput(
          session,
          "beta",
          value = round(new_root_beta * beta_display_scale(), 3)
        )
      }
    } else {
      root_beta(new_root_beta)
      sync_inputs_from_root()
    }
  })

  observeEvent(input$generate_sigma, {
    root_sigma(abs(rnorm(1, mean = 0, sd = 10)))
    sync_inputs_from_root()
  })

  observeEvent(
    input$alpha,
    {
      req(!updating_inputs(), !is.na(input$alpha))
      set_root_alpha_from_display(as.numeric(input$alpha), "female")
      root_alpha_male(root_alpha_female())
    },
    ignoreInit = TRUE
  )

  observeEvent(
    input$alpha_female,
    {
      req(!updating_inputs(), !is.na(input$alpha_female))
      set_root_alpha_from_display(as.numeric(input$alpha_female), "female")
    },
    ignoreInit = TRUE
  )

  observeEvent(
    input$alpha_male,
    {
      req(!updating_inputs(), !is.na(input$alpha_male))
      set_root_alpha_from_display(as.numeric(input$alpha_male), "male")
    },
    ignoreInit = TRUE
  )

  observeEvent(
    input$beta,
    {
      req(!updating_inputs(), !is.na(input$beta))

      new_root_beta <- as.numeric(input$beta) / beta_display_scale()

      if (identical(input$height_units, "Standardized Units")) {
        if (isTRUE(input$include_sex)) {
          alpha_female_disp <- isolate(as.numeric(input$alpha_female))
          alpha_male_disp <- isolate(as.numeric(input$alpha_male))

          root_beta(new_root_beta)
          set_root_alpha_from_display(
            alpha_female_disp,
            "female",
            beta_root = new_root_beta
          )
          set_root_alpha_from_display(
            alpha_male_disp,
            "male",
            beta_root = new_root_beta
          )

          updating_inputs(TRUE)
          on.exit(updating_inputs(FALSE), add = TRUE)
          freezeReactiveValue(input, "alpha_female")
          freezeReactiveValue(input, "alpha_male")
          updateNumericInput(
            session,
            "alpha_female",
            value = round(alpha_female_disp, 3)
          )
          updateNumericInput(
            session,
            "alpha_male",
            value = round(alpha_male_disp, 3)
          )
        } else {
          alpha_disp <- isolate(as.numeric(input$alpha))
          root_beta(new_root_beta)
          set_root_alpha_from_display(
            alpha_disp,
            "female",
            beta_root = new_root_beta
          )
          root_alpha_male(root_alpha_female())

          updating_inputs(TRUE)
          on.exit(updating_inputs(FALSE), add = TRUE)
          freezeReactiveValue(input, "alpha")
          updateNumericInput(session, "alpha", value = round(alpha_disp, 3))
        }
      } else {
        root_beta(new_root_beta)
      }
    },
    ignoreInit = TRUE
  )

  observeEvent(
    input$sigma,
    {
      req(!updating_inputs(), !is.na(input$sigma))
      root_sigma(as.numeric(input$sigma) / weight_scale())
    },
    ignoreInit = TRUE
  )

  observeEvent(
    input$include_sex,
    {
      if (isTRUE(input$include_sex)) {
        root_alpha_male(root_alpha_male())
      } else {
        root_alpha_male(root_alpha_female())
      }

      session$onFlushed(
        function() {
          sync_inputs_from_root()
        },
        once = TRUE
      )
    },
    ignoreInit = TRUE
  )

  observeEvent(
    list(input$height_units, input$weight_units),
    {
      sync_inputs_from_root()
    },
    ignoreInit = TRUE
  )

  output$alpha_ui <- renderUI({
    if (isTRUE(input$include_sex)) {
      tagList(
        param_row(
          numericInput(
            "alpha_female",
            "⍺[female] (intercept)",
            value = NA_real_,
            width = "100%"
          ),
          "generate_alpha_female"
        ),
        param_row(
          numericInput(
            "alpha_male",
            "⍺[male] (intercept)",
            value = NA_real_,
            width = "100%"
          ),
          "generate_alpha_male"
        )
      )
    } else {
      param_row(
        numericInput(
          "alpha",
          "⍺ (intercept)",
          value = NA_real_,
          width = "100%"
        ),
        "generate_alpha"
      )
    }
  })

  plot_data <- reactive({
    s <- sim_data()
    req(!is.null(s), !is.na(root_sigma()), root_sigma() >= 0)

    height_cm <- HEIGHT_MEAN_CM + HEIGHT_SD_CM * s$height_z

    alpha_by_sex <- if (isTRUE(input$include_sex)) {
      ifelse(s$sex == 1, root_alpha_male(), root_alpha_female())
    } else {
      rep(root_alpha_female(), length(s$sex))
    }

    weight_kg_pred <- alpha_by_sex + root_beta() * height_cm
    weight_kg <- weight_kg_pred + root_sigma() * s$resid_z

    tibble(
      height_cm = height_cm,
      height = canonical_to_display_height(height_cm, input$height_units),
      weight = canonical_to_display_weight(weight_kg, input$weight_units),
      sex = s$sex,
      sex_label = ifelse(s$sex == 1, "Male", "Female")
    )
  })

  line_data <- reactive({
    if (isTRUE(input$include_sex)) {
      tibble(
        sex = c(0, 1),
        sex_label = c("Female", "Male"),
        intercept = c(display_alpha_female(), display_alpha_male()),
        slope = c(display_beta(), display_beta())
      )
    } else {
      tibble(
        sex = 0,
        sex_label = "Data",
        intercept = display_alpha(),
        slope = display_beta()
      )
    }
  })

  output$generatedPlot <- renderGirafe({
    df <- plot_data()
    lines <- line_data()

    x_min <- switch(
      input$height_units,
      "Centimeters" = HEIGHT_MEAN_CM - 4 * HEIGHT_SD_CM,
      "Inches" = (HEIGHT_MEAN_CM - 4 * HEIGHT_SD_CM) / CM_PER_IN,
      "Standardized Units" = -4,
      HEIGHT_MEAN_CM - 4 * HEIGHT_SD_CM
    )

    x_max <- switch(
      input$height_units,
      "Centimeters" = HEIGHT_MEAN_CM + 4 * HEIGHT_SD_CM,
      "Inches" = (HEIGHT_MEAN_CM + 4 * HEIGHT_SD_CM) / CM_PER_IN,
      "Standardized Units" = 4,
      HEIGHT_MEAN_CM + 4 * HEIGHT_SD_CM
    )

    y_max <- switch(
      input$weight_units,
      "Kilograms" = 120,
      "Pounds" = 120 * KG_TO_LB,
      120
    )

    p <- ggplot(df, aes(x = height, y = weight)) +
      geom_point_interactive(
        aes(
          tooltip = paste0(
            "Height: ",
            round(height, 1),
            " ",
            height_unit_label(),
            "<br>Weight: ",
            round(weight, 1),
            " ",
            weight_unit_label(),
            if (isTRUE(input$include_sex)) {
              paste0("<br>Sex: ", sex_label)
            } else {
              ""
            }
          ),
          data_id = seq_len(nrow(df)),
          colour = if (isTRUE(input$include_sex)) sex_label else "Data"
        ),
        alpha = 0.8
      ) +
      geom_abline(
        data = lines,
        aes(intercept = intercept, slope = slope, colour = sex_label),
        linewidth = 1,
        alpha = 0.8,
        show.legend = isTRUE(input$include_sex)
      ) +
      labs(x = "", y = "", colour = NULL) +
      coord_cartesian(
        xlim = c(x_min, x_max),
        ylim = c(0, y_max),
        clip = "off"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        legend.position = if (isTRUE(input$include_sex)) "top" else "none"
      )

    girafe(
      ggobj = p,
      width_svg = 12,
      height_svg = 6,
      options = list(
        opts_hover(css = "fill:orange;r:4px;"),
        opts_toolbar(saveaspng = TRUE)
      )
    )
  })

  output$modelDef <- renderUI({
    if (isTRUE(input$include_sex)) {
      withMathJax(HTML(
        paste0(
          "$$",
          "\\begin{array}{@{} r @{\\qquad} l @{}}
          \\textbf{Likelihood:} &
            \\begin{aligned}[t]
            \\text{weight}_i &\\sim \\text{Normal}(\\mu_i, \\sigma)
            \\end{aligned}
            \\\\[6pt]

          \\textbf{Predictor:} &
            \\begin{aligned}[t]
            \\mu_i &= \\alpha_{\\text{sex}[i]} + \\beta \\times \\text{height}_i
            \\end{aligned}
            \\\\[6pt]

          \\textbf{Priors:} &
            \\begin{aligned}[t]
            \\alpha_{\\text{female}} &\\sim \\text{Normal}(60, 10) \\\\
            \\alpha_{\\text{male}} &\\sim \\text{Normal}(60, 10) \\\\
            \\beta &\\sim \\text{Normal}(0, 20) \\\\
            \\sigma &\\sim \\text{Normal}(10) \\quad {\\sigma} > 0
            \\end{aligned}
          \\end{array}",
          "$$"
        )
      ))
    } else {
      withMathJax(HTML(
        paste0(
          "$$",
          "\\begin{array}{@{} r @{\\qquad} l @{}}
          \\textbf{Likelihood:} &
            \\begin{aligned}[t]
            \\text{weight}_i &\\sim \\text{Normal}(\\mu_i, \\sigma)
            \\end{aligned}
            \\\\[6pt]

          \\textbf{Predictor:} &
            \\begin{aligned}[t]
            \\mu_i &= \\alpha + \\beta \\times \\text{height}_i
            \\end{aligned}
            \\\\[6pt]

          \\textbf{Priors:} &
            \\begin{aligned}[t]
            \\alpha &\\sim \\text{Normal}(60, 10) \\\\
            \\beta &\\sim \\text{Normal}(0, 20) \\\\
            \\sigma &\\sim \\text{Normal}(10) \\quad {\\sigma} > 0
            \\end{aligned}
          \\end{array}",
          "$$"
        )
      ))
    }
  })

  session$onFlushed(
    function() {
      sync_inputs_from_root()
    },
    once = TRUE
  )
}

shinyApp(ui, server)
