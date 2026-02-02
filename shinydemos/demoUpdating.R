library(shiny)
library(shinyjs)
library(bslib)

TOTAL_STONES <- 9L

CONJECTURE <- vapply(
  0:TOTAL_STONES,
  function(x) paste0(strrep("🔵", x), strrep("⚫️", TOTAL_STONES - x)),
  character(1)
)

SHIFT_HANDLER <- HTML(
  "
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Shift') {
        const btn = document.getElementById('drawRandom');
        if (btn) btn.innerText = 'Random × 10';
      }
    });

    document.addEventListener('keyup', function(e) {
      if (e.key === 'Shift') {
        const btn = document.getElementById('drawRandom');
        if (btn) btn.innerText = 'Random';
      }
    });
  "
)

STYLE <- HTML(
  "
  #resultTable table {
    width: 100%;
    table-layout: fixed;
  }

  #resultTable th:nth-child(1),
  #resultTable td:nth-child(1) { width: 220px; }

  #resultTable th:nth-child(3),
  #resultTable td:nth-child(3) { width: 380px; }

  #resultTable th:nth-child(4),
  #resultTable td:nth-child(4) { width: 80px; }
"
)

format2 <- function(x, max_digits = 40L) {
  x_chr_fixed <- format(
    x,
    scientific = FALSE,
    trim = TRUE,
    digits = 22
  )

  digit_count <- nchar(gsub("[^0-9]", "", x_chr_fixed))

  ifelse(
    is.na(x),
    NA_character_,
    ifelse(
      digit_count > max_digits,
      format(x, scientific = TRUE, trim = TRUE),
      x_chr_fixed
    )
  )
}

format_likelihood <- function(x) {
  if (is.na(x) || !is.finite(x)) {
    return("")
  }
  if (x > 0 && x < 0.01) {
    return("<0.01")
  }
  if (x < 1 && x > 0.995) {
    return(">0.99")
  }
  sprintf("%.2f", x)
}

ui <- page_sidebar(
  sidebar = sidebar(
    shinyjs::useShinyjs(),
    tags$script(SHIFT_HANDLER),
    tags$style(STYLE),
    open = "open",
    width = 400,

    h1("Bayesian Updating"),
    div(
      id = "bagContents_wrap",
      selectizeInput(
        "bagContents",
        "Contents of the bag:",
        choices = c(
          "Hidden" = "hidden",
          "⚫️⚫️⚫️⚫️⚫️⚫️⚫️⚫️⚫️" = 0,
          "🔵⚫️⚫️⚫️⚫️⚫️⚫️⚫️⚫️" = 1,
          "🔵🔵⚫️⚫️⚫️⚫️⚫️⚫️⚫️" = 2,
          "🔵🔵🔵⚫️⚫️⚫️⚫️⚫️⚫️" = 3,
          "🔵🔵🔵🔵⚫️⚫️⚫️⚫️⚫️" = 4,
          "🔵🔵🔵🔵🔵⚫️⚫️⚫️⚫️" = 5,
          "🔵🔵🔵🔵🔵🔵⚫️⚫️⚫️" = 6,
          "🔵🔵🔵🔵🔵🔵🔵⚫️⚫️" = 7,
          "🔵🔵🔵🔵🔵🔵🔵🔵⚫️" = 8,
          "🔵🔵🔵🔵🔵🔵🔵🔵🔵" = 9
        )
      )
    ),

    p("Draw a stone:"),
    div(
      style = "display: flex; gap: 10px;",
      actionButton("drawWhite", "⚫️"),
      actionButton("drawBlue", "🔵"),
      actionButton(
        "drawRandom",
        "Random",
        style = "flex: 1;",
        onclick = "
          Shiny.setInputValue(
            'drawRandom_n',
            event.shiftKey ? 10 : 1,
            {priority: 'event'}
          );
        "
      )
    ),
    actionButton("reset", "Reset", class = "btn-danger")
  ),

  mainPanel(
    width = 12,
    uiOutput("dynamicHeader"),
    tableOutput("resultTable"),
    plotOutput("likelihoodPlot")
  )
)

server <- function(input, output, session) {
  bag_blue <- reactiveVal(NULL)
  draws <- reactiveVal(character())

  lik_hist <- reactiveVal(list())
  max_hist <- 10L

  observeEvent(
    input$bagContents,
    {
      if (input$bagContents == "hidden") {
        bag_blue(sample(0:TOTAL_STONES, 1))
      } else {
        bag_blue(as.integer(input$bagContents))
      }
    },
    ignoreInit = FALSE
  )

  observeEvent(input$drawBlue, {
    draws(c(draws(), "🔵"))
  })

  observeEvent(input$drawWhite, {
    draws(c(draws(), "⚫️"))
  })

  observeEvent(
    input$drawRandom_n,
    {
      req(!is.null(bag_blue()))
      n_draws <- as.integer(input$drawRandom_n)
      pool <- c(rep("🔵", bag_blue()), rep("⚫️", TOTAL_STONES - bag_blue()))
      draws(c(draws(), sample(pool, n_draws, replace = TRUE)))
    },
    ignoreInit = TRUE
  )

  observeEvent(input$reset, {
    draws(character())
    bag_blue(sample(0:TOTAL_STONES, 1))
    lik_hist(list())
  })

  observe({
    has_draws <- length(draws()) > 0
    if (has_draws) {
      shinyjs::disable("bagContents")
      shinyjs::enable("reset")
    } else {
      shinyjs::enable("bagContents")
      shinyjs::disable("reset")
    }
  })

  observe({
    req(!is.null(bag_blue()))
    tip <- sprintf("blue stones = %d (out of %d)", bag_blue(), TOTAL_STONES)

    shinyjs::runjs(sprintf(
      "$('#bagContents_wrap .selectize-control').attr('title', %s);",
      shQuote(tip)
    ))
  })

  table_state <- reactive({
    d <- draws()
    n <- length(d)

    header <- if (n == 0) {
      "Draw Results"
    } else if (n <= 20) {
      paste(d, collapse = "\u00A0")
    } else {
      tbl <- sort(table(d), decreasing = TRUE)
      labels <- paste(names(tbl), "×", as.integer(tbl))
      paste(labels, collapse = ", ")
    }

    if (n == 0) {
      df <- data.frame(
        conjecture = CONJECTURE,
        possibilities = "-",
        total = "-",
        likelihood = rep(1 / (TOTAL_STONES + 1), TOTAL_STONES + 1),
        stringsAsFactors = FALSE
      )
      return(list(df = df, header = header))
    }

    factors <- lapply(
      0:TOTAL_STONES,
      function(bx) ifelse(d == "🔵", bx, TOTAL_STONES - bx)
    )

    formula <- vapply(
      factors,
      function(f) {
        if (n <= 20) {
          paste0(f, collapse = " × ")
        } else {
          tbl <- sort(table(f), decreasing = TRUE)
          labels <- paste0(names(tbl), "<sup>", as.integer(tbl), "</sup>")
          paste(labels, collapse = " × ")
        }
      },
      character(1)
    )

    log_paths <- vapply(
      factors,
      function(f) sum(log(f)),
      numeric(1)
    )

    m <- max(log_paths)
    paths_scaled <- exp(log_paths - m)
    likelihood <- paths_scaled / sum(paths_scaled)

    paths <- vapply(
      factors,
      prod,
      numeric(1)
    )

    df <- data.frame(
      conjecture = CONJECTURE,
      possibilities = formula,
      total = format2(round(paths, 0)),
      likelihood = likelihood,
      stringsAsFactors = FALSE
    )

    list(df = df, header = header)
  })

  output$dynamicHeader <- renderUI({
    h4(HTML(sprintf(
      "<span style='letter-spacing:0.15em;'>%s</span>",
      table_state()$header
    )))
  })

  output$resultTable <- renderTable(
    {
      df <- table_state()$df
      df$likelihood <- vapply(df$likelihood, format_likelihood, character(1))
      df
    },
    striped = TRUE,
    hover = TRUE,
    bordered = FALSE,
    spacing = "s",
    rownames = FALSE,
    width = '100%',
    align = 'llrr',
    sanitize.text.function = function(x) x # allow <sup> in possibilities
  )

  likelihood_vector <- reactive(table_state()$df$likelihood)

  observeEvent(
    likelihood_vector(),
    {
      y <- likelihood_vector()
      h <- lik_hist()

      if (length(h) == 0 || !isTRUE(all.equal(h[[length(h)]], y))) {
        h <- c(h, list(y))
        if (length(h) > max_hist) {
          h <- tail(h, max_hist)
        }
        lik_hist(h)
      }
    },
    ignoreInit = TRUE
  )

  output$likelihoodPlot <- renderPlot({
    df <- table_state()$df
    x <- 0:TOTAL_STONES
    h <- lik_hist()

    op <- par(no.readonly = TRUE)
    on.exit(par(op), add = TRUE)

    par(mar = c(4.2, 4.2, 0.8, 0.8))

    plot(
      x,
      df$likelihood,
      type = "n",
      xlab = "Number of blue stones",
      ylab = "Likelihood",
      xaxt = "n",
      ylim = c(0, 1.05)
    )
    axis(1, at = x, labels = x)

    if (length(h) > 1) {
      ghosts <- h[-length(h)]
      n_ghosts <- length(ghosts)

      gray_vals_full <- as.integer(round(seq(240, 120, length.out = max_hist)))
      gray_vals <- tail(gray_vals_full, n_ghosts)

      for (i in seq_along(ghosts)) {
        lines(
          x,
          ghosts[[i]],
          lwd = 1,
          col = rgb(
            gray_vals[i],
            gray_vals[i],
            gray_vals[i],
            maxColorValue = 255
          )
        )
      }
    }

    lines(x, df$likelihood, lwd = 3, col = "black")
    points(x, df$likelihood, pch = 16, cex = 1, col = "black")
  })
}

shinyApp(ui, server)
