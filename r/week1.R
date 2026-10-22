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
  rain <- "Writing it down: P( event | condition )"
  conv1 <- "Writing it down: 0 to 1"
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

# ---- The mayor poll, worked by hand (appendix) -----------------------------------
# The worked demo after the poll widgets. Every belief is a Beta(a, b) distribution, so
# each update is exact: add the "mayor" answers to a and the rest to b. Best guess is
# the mean, the range is the middle 90%, and "more than half" is the share of the
# belief above 50%, as on the Step 3 widget.
POLL_PRIOR <- c(20, 13) # a supporter: about 60%, as in the last election
POLL_SKEPTIC <- c(10, 23) # a skeptic: about 30%, and just as sure
POLL_SURVEYS <- list(c(k = 4, n = 20), c(k = 7, n = 20))
POLL_BIG_SURVEY <- c(k = 148, n = 360)

beta_update <- function(ab, survey) ab + c(survey[["k"]], survey[["n"]] - survey[["k"]])

# One row per belief: the prior, then the posterior after each survey in turn
poll_sequence <- function(prior = POLL_PRIOR, surveys = POLL_SURVEYS) {
  steps <- Reduce(beta_update, surveys, accumulate = TRUE, init = prior)
  tibble(
    step = c("Prior", paste("After survey", seq_along(surveys))),
    a = map_dbl(steps, 1),
    b = map_dbl(steps, 2),
    guess = a / (a + b),
    range = paste0(round(100 * qbeta(0.05, a, b)), "–", pct(qbeta(0.95, a, b))),
    majority = 1 - pbeta(0.5, a, b)
  )
}

# Bayes' theorem at a few values of θ, as numbers to multiply by hand. The prior is
# its height on the Step 1 scale (peak = 100); the product uses the rounded height, so
# the slide's arithmetic checks out.
poll_by_hand <- function(prior = POLL_PRIOR, survey = POLL_SURVEYS[[1]],
                         thetas = c(0.2, 0.4, 0.6)) {
  peak <- dbeta((prior[1] - 1) / (sum(prior) - 2), prior[1], prior[2])
  height <- round(100 * dbeta(thetas, prior[1], prior[2]) / peak)
  lik <- dbinom(survey[["k"]], survey[["n"]], thetas)
  tibble(
    theta = pct(thetas),
    prior = as.character(height),
    likelihood = formatC(lik, digits = 2, format = "fg"),
    product = formatC(height * lik, digits = 2, format = "f")
  )
}

# A Beta belief as a curve over θ
beta_curve <- function(a, b, label, theta = seq(0, 1, length.out = 401)) {
  tibble(label = label, theta = theta, density = dbeta(theta, a, b))
}

poll_axis <- function() {
  list(
    scale_x_continuous(labels = scales::percent, breaks = seq(0, 1, 0.2)),
    scale_y_continuous(expand = expansion(mult = c(0, 0.15))),
    labs(x = "θ, the mayor's share of the vote", y = NULL),
    theme(axis.text.y = element_blank(), panel.grid.major.y = element_blank(),
          panel.grid.minor = element_blank())
  )
}

# One update: the prior, the survey's likelihood (rescaled to the same area) and the
# posterior, with dotted guides at the values of θ worked by hand
poll_update_plot <- function(prior = POLL_PRIOR, survey = POLL_SURVEYS[[1]],
                             marks = c(0.2, 0.4, 0.6)) {
  k <- survey[["k"]]
  n <- survey[["n"]]
  post <- beta_update(prior, survey)
  curves <- bind_rows(
    beta_curve(prior[1], prior[2], "Prior"),
    beta_curve(k + 1, n - k + 1, "Likelihood"),
    beta_curve(post[1], post[2], "Posterior")
  )
  peaks <- curves |> group_by(label) |> slice_max(density, n = 1) |> ungroup()
  colors <- c(Prior = RED, Likelihood = BLUE, Posterior = GREEN)

  ggplot(curves, aes(theta, density, color = label)) +
    geom_vline(xintercept = marks, color = GRAY, linetype = "dotted", linewidth = 1) +
    geom_area(data = curves[curves$label == "Posterior", ], fill = tint(GREEN, 0.12),
              color = NA) +
    geom_line(aes(linetype = label), linewidth = 1.6) +
    geom_text(data = peaks, aes(label = label), vjust = -0.6, size = 6.5, fontface = "bold") +
    scale_color_manual(values = colors, guide = "none") +
    scale_linetype_manual(values = c(Prior = "solid", Likelihood = "dashed",
                                     Posterior = "solid"), guide = "none") +
    poll_axis()
}

# The prior and each posterior as curves: red to green, the last one filled
poll_sequence_plot <- function(steps = poll_sequence()) {
  curves <- bind_rows(lapply(seq_len(nrow(steps)), function(i) {
    beta_curve(steps$a[i], steps$b[i], steps$step[i])
  }))
  curves$label <- factor(curves$label, levels = steps$step)
  colors <- setNames(c(RED, tint(GREEN, 0.45), GREEN), steps$step)
  # Each label beside its peak: the two posteriors overlap, so one goes left, one right
  peaks <- curves |> group_by(label) |> slice_max(density, n = 1) |> ungroup()
  peaks$hjust <- c(0.5, 0, 1)[seq_len(nrow(peaks))]
  peaks$x <- peaks$theta + c(0, 0.05, -0.03)[seq_len(nrow(peaks))]

  ggplot(curves, aes(theta, density, color = label)) +
    geom_area(data = curves[curves$label == last(steps$step), ], fill = tint(GREEN, 0.12),
              color = NA) +
    geom_line(linewidth = 1.6) +
    geom_text(data = peaks, aes(x, label = label, hjust = hjust), vjust = -0.6, size = 6.5,
              fontface = "bold") +
    scale_color_manual(values = colors, guide = "none") +
    poll_axis()
}

# Two people who start far apart see the same surveys: their beliefs before any data,
# after the two small surveys, and after a big one, one panel each
poll_converge <- function(surveys = c(POLL_SURVEYS, list(POLL_BIG_SURVEY))) {
  people <- list(Supporter = POLL_PRIOR, Skeptic = POLL_SKEPTIC)
  # The beliefs to show: before any data, after the small surveys, after all of them
  shown <- c(1, length(surveys), length(surveys) + 1)
  seen <- cumsum(c(0, map_dbl(surveys, ~ .x[["n"]])))[shown]
  stage <- ifelse(seen == 0, "Before any data", paste("After", fmt(seen, 0), "people"))
  bind_rows(lapply(names(people), function(who) {
    steps <- poll_sequence(people[[who]], surveys)[shown, ]
    tibble(who = who, stage = factor(stage, levels = stage), people = seen,
           a = steps$a, b = steps$b, guess = steps$guess)
  }))
}

poll_converge_plot <- function(beliefs = poll_converge()) {
  curves <- bind_rows(lapply(seq_len(nrow(beliefs)), function(i) {
    beta_curve(beliefs$a[i], beliefs$b[i], beliefs$who[i]) |>
      mutate(stage = beliefs$stage[i])
  }))
  first <- levels(beliefs$stage)[1]
  peaks <- curves |> filter(stage == first) |> group_by(label) |>
    slice_max(density, n = 1) |> ungroup()

  ggplot(curves, aes(theta, density, color = label)) +
    geom_line(linewidth = 1.4) +
    geom_text(data = peaks, aes(label = label), vjust = -0.5, size = 5.5, fontface = "bold") +
    facet_wrap(~stage, ncol = 1, scales = "free_y") +
    scale_color_manual(values = c(Supporter = ORANGE, Skeptic = INK), guide = "none") +
    poll_axis() +
    scale_y_continuous(expand = expansion(mult = c(0, 0.35))) +
    theme(strip.text = element_text(hjust = 0, size = 18, color = INK))
}

# The answer to the question: the share of the belief above 50%, shaded
poll_majority_plot <- function(steps = poll_sequence()) {
  last <- steps[nrow(steps), ]
  curve <- beta_curve(last$a, last$b, last$step)
  ggplot(curve, aes(theta, density)) +
    geom_area(fill = tint(GREEN, 0.12)) +
    geom_area(data = curve[curve$theta >= 0.5, ], fill = tint(GREEN, 0.6)) +
    geom_line(color = GREEN, linewidth = 1.6) +
    geom_vline(xintercept = 0.5, color = INK, linetype = "dashed", linewidth = 1) +
    annotate("text", x = 0.52, y = max(curve$density) * 0.9, hjust = 0, size = 6.5,
             color = INK, label = "more than half") +
    poll_axis()
}
