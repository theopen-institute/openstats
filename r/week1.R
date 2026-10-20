# Plots for the week 1 deck. Sourced by its setup chunk, after r/deck-setup.R.

# The garden of forking paths: both versions are stacked on one slide, so they
# share a size: {r name, opts.label = "garden"}
knitr::opts_template$set(garden = list(fig.width = 9, fig.height = 5.4, out.width = "100%"))

# "Counting the ways a thing could happen": the garden of forking paths for n coin
# flips, with the paths that end in exactly `target` heads drawn in blue and the
# rest grayed out. target = NULL draws every path the same.
# Ring k holds the 2^k ways the first k flips could go. Node j on ring k sits at
# angle pi * (1 - (j + 0.5) / 2^k), which puts each node midway between its children.
garden_plot <- function(n = 4, target = NULL) {
  nodes <- do.call(
    rbind,
    lapply(0:n, function(k) {
      j <- 0:(2^k - 1)
      heads <- if (k == 0) {
        0
      } else {
        vapply(j, function(x) sum(bitwAnd(x, 2^(0:(k - 1))) == 0), numeric(1))
      }
      data.frame(
        k = k,
        j = j,
        flip = if (k == 0) "" else ifelse(bitwAnd(j, 1) == 0, "H", "T"),
        heads = heads,
        theta = pi * (1 - (j + 0.5) / 2^k)
      )
    })
  )
  nodes$x <- nodes$k * cos(nodes$theta)
  nodes$y <- -nodes$k * sin(nodes$theta) # start at the top, fanning down
  # on a path that can still end in exactly `target` heads (every node, if no target)
  nodes$live <- if (is.null(target)) {
    TRUE
  } else {
    nodes$heads <= target & nodes$heads + (n - nodes$k) >= target
  }
  path_color <- if (is.null(target)) INK else BLUE

  kids <- nodes[nodes$k > 0, ]
  parent <- match(paste(kids$k - 1, kids$j %/% 2), paste(nodes$k, nodes$j))
  edges <- data.frame(
    x = nodes$x[parent],
    y = nodes$y[parent],
    xend = kids$x,
    yend = kids$y,
    live = kids$live
  )
  leaves <- nodes[nodes$k == n, ]
  hit <- if (is.null(target)) rep(FALSE, nrow(leaves)) else leaves$heads == target
  label_r <- n + 0.68 # radius of the head counts, just outside the last ring

  rings <- do.call(
    rbind,
    lapply(1:n, function(k) {
      t <- seq(0, pi, length.out = 200)
      data.frame(k = k, x = k * cos(t), y = -k * sin(t))
    })
  )

  ggplot() +
    geom_path(
      data = rings,
      aes(x, y, group = k),
      color = tint(INK, 0.1),
      linewidth = 0.8,
      linetype = "dashed"
    ) +
    geom_segment(
      data = edges[!edges$live, ],
      aes(x, y, xend = xend, yend = yend),
      color = tint(INK, 0.16),
      linewidth = 1.2
    ) +
    geom_segment(
      data = edges[edges$live, ],
      aes(x, y, xend = xend, yend = yend),
      color = path_color,
      linewidth = 1.8
    ) +
    geom_point(data = nodes[nodes$k == 0, ], aes(x, y), size = 4, color = INK) +
    geom_point(
      data = nodes[nodes$k > 0, ],
      aes(x, y, fill = flip, alpha = live),
      shape = 21,
      size = 12,
      color = INK,
      stroke = 1.2
    ) +
    geom_text(
      data = nodes[nodes$k > 0, ],
      aes(x, y, label = flip, color = flip, alpha = live),
      size = 5.6,
      fontface = "bold"
    ) +
    geom_text(
      data = leaves,
      aes(label_r * cos(theta), -label_r * sin(theta), label = heads),
      color = ifelse(hit, BLUE, tint(INK, 0.32)),
      fontface = ifelse(hit, "bold", "plain"),
      size = 8.5
    ) +
    annotate(
      "text",
      x = -(1:n),
      y = 0.38,
      label = c("1st", "2nd", "3rd", "4th", paste0(5:12, "th"))[1:n],
      color = GRAY,
      size = 6.5
    ) +
    annotate("text", x = label_r, y = 0.38, label = "heads", color = GRAY, size = 6.5) +
    scale_fill_manual(values = c(H = INK, T = "white"), guide = "none") +
    scale_color_manual(values = c(H = "white", T = INK), guide = "none") +
    scale_alpha_manual(values = c(`TRUE` = 1, `FALSE` = 0.3), guide = "none") +
    coord_fixed(
      xlim = c(-n - 1.2, n + 1.2),
      ylim = c(-n - 1.05, 0.65),
      expand = FALSE
    ) +
    theme_void()
}

# The base rate, drawn: n cases as a grid of squares, the ones that are truly positive
# (have HIV, are true ideas) in blue. results = TRUE shows what the test reports: the
# true positives it catches (blue), the false positives (red), with everything else
# faded. Used by "The base rate paradox" and "So why is most published research wrong?".
knitr::opts_template$set(base_rate = list(fig.width = 7, fig.height = 4.6, out.width = "100%"))

base_rate_plot <- function(n_true, true_positives, false_positives, results = FALSE,
                           n = 1000, per_row = 40) {
  set.seed(1) # which negatives come up positive
  cases <- tibble(
    id = seq_len(n),
    x = (id - 1) %% per_row,
    y = -((id - 1) %/% per_row),
    true = id <= n_true,
    positive = id <= true_positives | id %in% (n_true + sample(n - n_true, false_positives))
  )
  cases$color <- if (!results) {
    ifelse(cases$true, BLUE, tint(INK, 0.18))
  } else {
    ifelse(
      cases$positive,
      ifelse(cases$true, BLUE, RED),
      ifelse(cases$true, tint(BLUE, 0.3), tint(INK, 0.07))
    )
  }

  ggplot(cases, aes(x, y)) +
    geom_point(aes(color = I(color)), shape = 15, size = 4.6) +
    coord_equal() +
    theme_void()
}

# ---- Numbers the slides state as plain text --------------------------------------
# The base-rate slides type their numbers out so they read as plain markdown. They
# depend on each other, so this recomputes each one and stops the render if a slide
# and its calculation disagree. If you change a number on a slide, change it here.
check_stated_numbers <- function() {
  # P( true | positive ): the share of positives that are real
  ppv <- function(base, tpr, fpr) base * tpr / (base * tpr + (1 - base) * fpr)

  # `stated` is what the slide says, `digits` the decimals it shows
  expect <- function(slide, value, stated, digits = 0) {
    if (round(value, digits) != stated) {
      stop(
        sprintf('week1.qmd, "%s": the slide says %s, but it works out to %s',
                slide, stated, signif(value, 4)),
        call. = FALSE
      )
    }
  }
  pct <- function(x) 100 * x

  # Kathmandu rain: rainy days over days counted, five years of records
  rain <- "Describing Probability: Convention 3"
  conv1 <- "Describing Probability: Convention 1"
  expect(conv1, 113 / 365, 0.31, 2)
  expect(conv1, 10 / 500, 0.02, 2)
  expect(conv1, 1 / 6, 0.17, 2)
  expect(rain, 565 / (5 * 365), 0.31, 2)
  expect(rain, 35 / (5 * 30), 0.23, 2)
  expect(rain, 5 / (5 * 31), 0.03, 2)
  expect(rain, 126 / (5 * 31), 0.81, 2)
  expect(rain, 8 / (5 * 28), 0.06, 2)

  # HIV test: prevalence 0.1%, sensitivity 99%, specificity 97%, 100,000 people
  hiv <- "Probability for Decision Making (continued)"
  expect(hiv, pct(ppv(0.001, 0.99, 0.03)), 3.2, 1)
  expect(hiv, 1e5 * 0.001 * 0.99, 99)
  expect(hiv, 1e5 * 0.001 * 0.01, 1)
  expect(hiv, 1e5 * 0.999 * 0.03, 2997)
  expect(hiv, 1e5 * 0.999 * 0.97, 96903)
  expect(hiv, pct(ppv(0.001, 0.99, 0.002)), 33) # modern tests: 99.8% specificity

  # The base rate paradox: the HIV test on 1,000 people (drawn with base_rate_plot())
  paradox <- "The base rate paradox"
  expect(paradox, 1000 * 0.001, 1)
  expect(paradox, 1000 * 0.001 * 0.99, 1) # 0.99
  expect(paradox, 999 * 0.03, 30) # 29.97
  expect(paradox, 1 + 30, 31)

  # Research findings: 1% of ideas true, 80% power (beta = 20%), alpha = 5%, drawn
  # as 1,000 ideas with base_rate_plot()
  research <- "So why is most published research wrong?"
  expect(research, 1000 * 0.01, 10)
  expect(research, 1000 * 0.01 * 0.8, 8)
  expect(research, 1000 * 0.99 * 0.05, 50) # 49.5: "about 50"
  expect(research, 8 + 50, 58)
  # The table of study types: true-idea share, sensitivity, specificity -> chance a
  # discovery is true
  trust <- "How far can we trust data?"
  for (row in list(c(0.5, 0.8, 0.95, 94), c(0.5, 0.2, 0.95, 80), c(0.1, 0.8, 0.95, 64),
                   c(0.1, 0.2, 0.95, 31), c(0.01, 0.8, 0.95, 14), c(0.01, 0.2, 0.95, 4),
                   c(0.01, 0.2, 0.8, 1))) {
    expect(trust, pct(ppv(row[1], row[2], 1 - row[3])), row[4])
  }
}
