library(shiny)
library(shinyjs)
library(bslib)
library(jsonlite)
library(dplyr)
library(purrr)
library(ggplot2)
library(DT)
library(munsell)

TOTAL_STONES <- 9L
CONJECTURE <- map_chr(0:TOTAL_STONES, \(x) {
  paste0(strrep("🔵", x), strrep("⚪️", TOTAL_STONES - x))
})

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
APPROX_HANDLER <- JS(
  "
    function(data, type) {
      if (type !== 'display') return data;
      var x = Number(data);
      if (!isFinite(x)) return '';
      if (x > 0 && x < 0.01) return '&lt;0.01';
      if (x < 1 && x > 0.995) return '&gt;0.99';
      return x.toFixed(2);
    }
  "
)

format2 <- function(x, max_digits = 40L) {
  x_chr_fixed <- format(
    x,
    scientific = FALSE,
    trim = TRUE,
    digits = 22 # enough for typical doubles; adjust if needed
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

ui <- page_sidebar(
  sidebar = sidebar(
    shinyjs::useShinyjs(),
    tags$script(SHIFT_HANDLER),
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
          "⚪️⚪️⚪️⚪️⚪️⚪️⚪️⚪️⚪️" = 0,
          "🔵⚪️⚪️⚪️⚪️⚪️⚪️⚪️⚪️" = 1,
          "🔵🔵⚪️⚪️⚪️⚪️⚪️⚪️⚪️" = 2,
          "🔵🔵🔵⚪️⚪️⚪️⚪️⚪️⚪️" = 3,
          "🔵🔵🔵🔵⚪️⚪️⚪️⚪️⚪️" = 4,
          "🔵🔵🔵🔵🔵⚪️⚪️⚪️⚪️" = 5,
          "🔵🔵🔵🔵🔵🔵⚪️⚪️⚪️" = 6,
          "🔵🔵🔵🔵🔵🔵🔵⚪️⚪️" = 7,
          "🔵🔵🔵🔵🔵🔵🔵🔵⚪️" = 8,
          "🔵🔵🔵🔵🔵🔵🔵🔵🔵" = 9
        )
      )
    ),

    p("Draw a stone:"),
    div(
      style = "display: flex; gap: 10px;",
      actionButton("drawBlue", "🔵"),
      actionButton("drawWhite", "⚪️"),
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
    DTOutput("resultTable"),
    plotOutput("likelihoodPlot")
  )
)

server <- function(input, output, session) {
  bag_blue <- reactiveVal(NULL) # integer: number of blue stones in bag (hidden mode only)
  draws <- reactiveVal(character()) # vector of "🔵"/"⚪️"
  busy <- reactiveVal(FALSE)

  # likelihood curve history for ghost lines
  lik_hist <- reactiveVal(list())
  max_hist <- 10L

  # UI events
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
    draws(c(draws(), "⚪️"))
  })
  observeEvent(
    input$drawRandom_n,
    {
      req(!is.null(bag_blue()))
      n_draws <- as.integer(input$drawRandom_n)
      pool <- c(rep("🔵", bag_blue()), rep("⚪️", TOTAL_STONES - bag_blue()))
      draws(c(draws(), sample(pool, n_draws, replace = TRUE)))
    },
    ignoreInit = TRUE
  )
  observeEvent(input$reset, {
    draws(character())
    bag_blue(sample(0:TOTAL_STONES, 1))
    lik_hist(list())
  })

  # Disable bag contents after first draw; enable reset only when there is history
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

  # Update tooltip for select control
  observe({
    req(!is.null(bag_blue()))
    tip <- sprintf("blue stones = %d (out of %d)", bag_blue(), TOTAL_STONES)
    shinyjs::runjs(sprintf(
      "$('#bagContents_wrap .selectize-control').attr('title', %s);",
      jsonlite::toJSON(tip, auto_unbox = TRUE)
    ))
  })

  # Core calculation: returns df + header text
  table_state <- reactive({
    d <- draws()
    n <- length(d)

    header <- if (n == 0) {
      "Draw Results"
    } else if (n <= 20) {
      paste(d, collapse = "\u00A0")
    } else {
      tibble(val = d) |>
        count(val) |>
        arrange(desc(n)) |>
        transmute(label = paste(val, "×", n)) |>
        pull(label) |>
        paste(collapse = ", ")
    }

    # Explicit n==0 handling for nicer display
    if (n == 0) {
      df <- tibble(
        conjecture = CONJECTURE,
        `possible paths` = "",
        total = "1",
        likelihood = rep(1 / (TOTAL_STONES + 1), TOTAL_STONES + 1)
      )
      return(list(df = df, header = header))
    }

    # For each conjecture x, each blue draw contributes x ways; each white contributes (TOTAL_STONES - x) ways
    factors <- map(0:TOTAL_STONES, \(bx) {
      ifelse(d == "🔵", bx, TOTAL_STONES - bx)
    })

    # Pretty formulas
    formula <- map_chr(factors, \(f) {
      if (n <= 20) {
        paste0(f, collapse = " × ")
      } else {
        tibble(val = f) |>
          count(val) |>
          arrange(desc(n)) |>
          transmute(label = paste0(val, "<sup>", n, "</sup>")) |>
          pull(label) |>
          paste(collapse = " × ")
      }
    })

    # Safer numeric computation (log space) for likelihood
    log_paths <- map_dbl(factors, \(f) sum(log(f)))
    m <- max(log_paths)
    paths_scaled <- exp(log_paths - m)
    likelihood <- paths_scaled / sum(paths_scaled)

    # If you still want integer-looking totals, use scaled paths (relative) or raw prod.
    # Here we preserve the original intent (counts) where feasible:
    paths <- map_dbl(factors, prod)
    df <- tibble(
      conjecture = CONJECTURE,
      `possible paths` = formula,
      total = format2(round(paths, 0)),
      likelihood = likelihood
    )

    list(df = df, header = header)
  })

  output$dynamicHeader <- renderUI({
    h4(HTML(sprintf(
      "<span style='letter-spacing:0.15em;'>%s</span>",
      table_state()$header
    )))
  })

  output$resultTable <- renderDT(
    {
      df <- table_state()$df
      DT::datatable(
        df,
        escape = c(1, 3, 4),
        rownames = FALSE,
        width = "100%",
        options = list(
          dom = "t",
          ordering = FALSE,
          autoWidth = FALSE,
          columnDefs = list(
            list(targets = 0, className = "dt-left", width = "180px"),
            list(targets = 2, className = "dt-right", width = "120px"),
            list(
              targets = 3,
              className = "dt-right",
              width = "80px",
              render = APPROX_HANDLER
            )
          )
        )
      )
    },
    server = FALSE
  )

  # Lighter-weight reactive for likelihood only
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

    ghost_df <- NULL
    if (length(h) > 1) {
      ghost_df <- purrr::imap_dfr(
        h[-length(h)],
        \(y, i) tibble(x = x, likelihood = y, id = i)
      )
    }

    p <- ggplot()

    if (!is.null(ghost_df) && nrow(ghost_df) > 0) {
      p <- p +
        geom_line(
          data = ghost_df,
          aes(x = x, y = likelihood, group = id),
          linewidth = 0.8,
          alpha = 0.15
        )
    }

    p +
      geom_line(
        data = df,
        aes(x = x, y = likelihood, group = 1),
        linewidth = 1.2,
        color = "black"
      ) +
      geom_point(
        data = df,
        aes(x = x, y = likelihood),
        size = 2,
        color = "black"
      ) +
      scale_y_continuous(limits = c(0, 1)) +
      scale_x_continuous(breaks = 0:TOTAL_STONES, labels = 0:TOTAL_STONES) +
      labs(x = "Number of blue stones", y = "Likelihood") +
      theme_minimal(base_size = 12) +
      theme(panel.grid.minor = element_blank())
  })
}

shinyApp(ui, server)
