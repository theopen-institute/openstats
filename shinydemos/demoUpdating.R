library(shiny)
library(bslib)
library(shinyjs)
library(uuid)
library(ggplot2)
library(ggiraph)
library(htmlwidgets)
library(munsell) # https://github.com/r-wasm/webr/issues/537

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
  h1 { margin-bottom: 0; }
  p { font-size: 90%; }

  /* Prevent table from graying out during recalculation */
  #resultTable.recalculating { opacity: 1 !important; }
  #resultTable.shiny-output-error,
  #resultTable.shiny-output-error-validation { color: inherit; }
  /* Shiny adds .shiny-recalculating to the output element while updating */
  #resultTable.shiny-recalculating { opacity: 1 !important; }
  #resultTable.shiny-recalculating:before { display: none !important; }

  #resultTable table {
    width: 100%;
    table-layout: fixed;
  }

  #resultTable th:nth-child(1),
  #resultTable td:nth-child(1) { width: 220px; }

  #resultTable th:nth-child(3),
  #resultTable td:nth-child(3) { width: 160px; direction: rtl }

  #resultTable th:nth-child(4),
  #resultTable td:nth-child(4) { width: 80px; }

  /* --- Stop Shiny from dimming the table while recalculating --- */
  /* Shiny uses .recalculating (not always .shiny-recalculating) */
  #resultTable.recalculating,
  #resultTable.shiny-recalculating {
    opacity: 1 !important;
  }

  /* If opacity is applied in a way that affects children, force children too */
  #resultTable.recalculating *,
  #resultTable.shiny-recalculating * {
    opacity: 1 !important;
  }s

  /* Shiny adds a spinner/overlay via pseudo-elements */
  #resultTable.recalculating:before,
  #resultTable.recalculating:after,
  #resultTable.shiny-recalculating:before,
  #resultTable.shiny-recalculating:after {
    display: none !important;
    content: none !important;
  }

  /* ---- full-height main panel + plot fills remaining space ---- */
  html, body { height: 100%; }
  .bslib-page-sidebar { height: 100vh; }

  .bslib-page-sidebar .main {
    height: 100%;
    display: flex;
    flex-direction: column;
    min-height: 0;
  }

  #likelihoodPlot_wrap {
    flex: 1 1 auto;
    min-height: 0;
    width: 100%;
  }

  /* Ensure the htmlwidget + ggiraph wrappers and SVG fill the wrapper */
  #likelihoodPlot_wrap .html-widget,
  #likelihoodPlot_wrap .girafe_container,
  #likelihoodPlot_wrap svg {
    width: 100% !important;
    height: 100% !important;
  }
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
  tags$script(SHIFT_HANDLER),
  tags$style(STYLE),
  shinyjs::useShinyjs(),

  sidebar = sidebar(
    open = "open",
    width = 400,

    h1("Bayesian Updating"),
    p(
      "Imagine you have a bag of 9 stones. Each stone is either blue or black, but you don't know how many of each color you have."
    ),
    p(
      "You can draw stones from the bag one at a time, noting down its color and then placing it back in the bag. The more you repeat this process, the more you can infer about the contents of the bag."
    ),
    p(
      "This graph represents a",
      tags$b("probability distribution", .noWS = c("after")),
      ". From limited observations, we can never be absolutely certain of the contents of the bag, but we can say that some possibilities are more likely than others."
    ),

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

    div("Draw a stone:"),
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
    div(
      id = "likelihoodPlot_wrap",
      ggiraph::girafeOutput("likelihoodPlot")
    )
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

  observeEvent(input$drawBlue, draws(c(draws(), "🔵")))
  observeEvent(input$drawWhite, draws(c(draws(), "⚫️")))

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

    log_paths <- vapply(factors, function(f) sum(log(f)), numeric(1))

    m <- max(log_paths)
    paths_scaled <- exp(log_paths - m)
    likelihood <- paths_scaled / sum(paths_scaled)

    paths <- vapply(factors, prod, numeric(1))

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
    width = "100%",
    align = "llrr",
    sanitize.text.function = function(x) x
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

  make_plot_data <- function(df, h) {
    x <- 0:TOTAL_STONES

    cur <- data.frame(
      x = x,
      y = df$likelihood,
      conjecture = df$conjecture,
      stringsAsFactors = FALSE
    )

    ghost_df <- NULL
    if (length(h) > 1) {
      ghosts <- h[-length(h)]
      n_ghosts <- length(ghosts)

      gray_vals_full <- as.integer(round(seq(240, 120, length.out = max_hist)))
      gray_vals <- tail(gray_vals_full, n_ghosts)
      ghost_cols <- rgb(gray_vals, gray_vals, gray_vals, maxColorValue = 255)

      ghost_df <- do.call(
        rbind,
        lapply(seq_along(ghosts), function(i) {
          data.frame(
            step = i,
            x = x,
            y = ghosts[[i]],
            col = ghost_cols[i],
            stringsAsFactors = FALSE
          )
        })
      )
    }

    list(cur = cur, ghost = ghost_df)
  }

  output$likelihoodPlot <- ggiraph::renderGirafe({
    df <- table_state()$df
    h <- lik_hist()

    pd <- make_plot_data(df, h)
    cur <- pd$cur
    ghost <- pd$ghost

    cur$point_id <- paste0("curpt-", cur$x)

    # Tooltip changes:
    # - emoji line first (conjecture)
    # - likelihood formatted like the table
    cur$tooltip <- sprintf(
      "%s\nBlue stones: %d\nLikelihood: %s",
      cur$conjecture,
      cur$x,
      vapply(cur$y, format_likelihood, character(1))
    )

    p <- ggplot()

    # ghosts
    if (!is.null(ghost) && nrow(ghost) > 0) {
      p <- p +
        geom_line(
          data = ghost,
          aes(x = x, y = y, group = step, color = col),
          linewidth = 0.7
        ) +
        scale_color_identity()
    }

    # current: points only (line is drawn + animated in JS)
    p <- p +
      ggiraph::geom_point_interactive(
        data = cur,
        aes(x = x, y = y, tooltip = tooltip, data_id = point_id),
        size = 2.6,
        color = "black"
      ) +
      scale_x_continuous(breaks = 0:TOTAL_STONES, limits = c(0, TOTAL_STONES)) +
      scale_y_continuous(
        limits = c(-0.05, 1.05),
        expand = expansion(mult = c(0, 0.02))
      ) +
      labs(x = "Number of blue stones", y = "Likelihood") +
      theme_minimal(base_size = 13) +
      theme(panel.grid.minor = element_blank(), legend.position = "none")

    g <- ggiraph::girafe(
      ggobj = p,
      width_svg = 12,
      height_svg = 4,
      options = list(
        ggiraph::opts_sizing(rescale = FALSE),
        ggiraph::opts_hover(css = "fill:black; r:5px;"),
        ggiraph::opts_tooltip(
          css = "background-color: white; border: 1px solid #999; padding: 6px; border-radius: 4px;"
        )
      )
    )

    g$x$step <- length(draws())

    htmlwidgets::onRender(
      g,
      "
function(el, x) {
  var svg = el.querySelector('svg');
  if (!svg) return;

  // Let SVG stretch to match the available rectangle
  svg.setAttribute('preserveAspectRatio', 'none');
  svg.setAttribute('width', '100%');
  svg.setAttribute('height', '100%');

  // Hide immediately to prevent flash of new final coordinates
  svg.style.visibility = 'hidden';

  var step = x.step;

  function getPoints() {
    var pts = Array.prototype.slice.call(svg.querySelectorAll('[data-id^=\"curpt-\"]'));
    var arr = pts.map(function(pt) {
      var id = pt.getAttribute('data-id');
      var idx = parseInt(id.replace('curpt-', ''), 10);
      return {
        id: id,
        idx: idx,
        el: pt,
        cx: parseFloat(pt.getAttribute('cx')),
        cy: parseFloat(pt.getAttribute('cy'))
      };
    }).filter(function(d) {
      return isFinite(d.idx) && isFinite(d.cx) && isFinite(d.cy);
    });
    arr.sort(function(a,b){ return a.idx - b.idx; });
    return arr;
  }

  function ensureLine() {
    var line = svg.querySelector('#curline-js');
    if (!line) {
      line = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      line.setAttribute('id', 'curline-js');
      line.setAttribute('fill', 'none');
      line.setAttribute('stroke', 'black');
      line.setAttribute('stroke-width', '2.2');
      line.setAttribute('stroke-linecap', 'round');
      line.setAttribute('stroke-linejoin', 'round');
      svg.appendChild(line);
    }
    return line;
  }

  function pathFromXY(xy) {
    if (!xy || xy.length === 0) return '';
    var d = 'M ' + xy[0].cx + ' ' + xy[0].cy;
    for (var i=1; i<xy.length; i++) d += ' L ' + xy[i].cx + ' ' + xy[i].cy;
    return d;
  }

  function ease(u) {
    return u < 0.5 ? 4*u*u*u : 1 - Math.pow(-2*u + 2, 3)/2;
  }

  function setToPts(ptsArr, pts, line) {
    for (var i=0; i<ptsArr.length; i++) {
      ptsArr[i].el.setAttribute('cx', pts[i].cx);
      ptsArr[i].el.setAttribute('cy', pts[i].cy);
      ptsArr[i].el.removeAttribute('transform');
    }
    line.setAttribute('d', pathFromXY(pts));
  }

  // More responsive feel:
  // - shorter debounce before starting animation
  // - slightly shorter duration
  var DEBOUNCE_MS = 55;  // was 100
  var DURATION_MS = 360; // was 450

  function animateFromTo(ptsArr, startPts, endPts, line, durationMs, onDone) {
    if (el.__animCancel) el.__animCancel();

    var t0 = null;
    var cancelled = false;
    el.__animCancel = function(){ cancelled = true; };

    el.__animating = true;
    el.__animTargetPts = endPts;

    // Put at start before showing
    setToPts(ptsArr, startPts, line);

    // Show once start state is in place
    svg.style.visibility = 'visible';

    ptsArr.forEach(function(d){ d.el.style.pointerEvents = 'none'; });

    function frame(ts) {
      if (cancelled) return;
      if (t0 === null) t0 = ts;

      var u = Math.min(1, (ts - t0) / durationMs);
      var e = ease(u);

      var interp = new Array(endPts.length);
      for (var i=0; i<endPts.length; i++) {
        var a = startPts[i], b = endPts[i];
        interp[i] = {
          cx: a.cx + (b.cx - a.cx) * e,
          cy: a.cy + (b.cy - a.cy) * e
        };
      }

      el.__curLinePts = interp;

      for (var j=0; j<ptsArr.length; j++) {
        ptsArr[j].el.setAttribute('cx', interp[j].cx);
        ptsArr[j].el.setAttribute('cy', interp[j].cy);
      }
      line.setAttribute('d', pathFromXY(interp));

      if (u < 1) {
        requestAnimationFrame(frame);
      } else {
        setToPts(ptsArr, endPts, line);
        ptsArr.forEach(function(d){ d.el.style.pointerEvents = ''; });

        el.__animating = false;
        el.__animCancel = null;
        el.__curLinePts = endPts;

        if (typeof onDone === 'function') onDone();
      }
    }

    requestAnimationFrame(frame);
  }

  function finishAnimationNow(ptsArr, line) {
    if (el.__animating && el.__animTargetPts && el.__prevLinePts) {
      if (el.__animCancel) el.__animCancel();
      setToPts(ptsArr, el.__animTargetPts, line);
      ptsArr.forEach(function(d){ d.el.style.pointerEvents = ''; });

      el.__animating = false;
      el.__animCancel = null;

      el.__prevLinePts = el.__animTargetPts;
      el.__curLinePts = el.__animTargetPts;
    }
  }

  // Read new rendered final positions (but hidden)
  var ptsArr = getPoints();
  var nextPts = ptsArr.map(function(d){ return { cx: d.cx, cy: d.cy }; });
  var line = ensureLine();

  // First render: snap and show
  if (el.__lastStep === undefined || el.__prevLinePts === undefined) {
    el.__lastStep = step;
    el.__prevLinePts = nextPts;
    el.__curLinePts = nextPts;
    setToPts(ptsArr, nextPts, line);
    svg.style.visibility = 'visible';
    return;
  }

  // No new draw: keep synced and show
  if (step === el.__lastStep) {
    el.__prevLinePts = nextPts;
    el.__curLinePts = nextPts;
    setToPts(ptsArr, nextPts, line);
    svg.style.visibility = 'visible';
    return;
  }

  // Defensive: mismatch => snap and show
  if (el.__prevLinePts.length !== nextPts.length || nextPts.length === 0) {
    el.__lastStep = step;
    el.__prevLinePts = nextPts;
    el.__curLinePts = nextPts;
    setToPts(ptsArr, nextPts, line);
    svg.style.visibility = 'visible';
    return;
  }

  // Coalesce rapid updates
  finishAnimationNow(ptsArr, line);

  el.__pendingStep = step;
  el.__pendingNextPts = nextPts;

  if (el.__debounceTimer) clearTimeout(el.__debounceTimer);
  el.__debounceTimer = setTimeout(function() {
    if (!el.__pendingNextPts) return;

    var targetPts = el.__pendingNextPts;
    var targetStep = el.__pendingStep;

    el.__pendingNextPts = null;
    el.__pendingStep = null;

    var startPts = el.__prevLinePts;

    animateFromTo(ptsArr, startPts, targetPts, line, DURATION_MS, function() {
      el.__lastStep = targetStep;
      el.__prevLinePts = targetPts;
      el.__curLinePts = targetPts;
    });
  }, DEBOUNCE_MS);

  // While we wait for debounce, show the baseline (current) state, not the new final state
  setToPts(ptsArr, el.__prevLinePts, line);
  svg.style.visibility = 'visible';
}
"
    )
  })
}

shinyApp(ui, server)
