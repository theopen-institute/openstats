# Plots and helpers for the week 2 deck. Sourced by its setup chunk, after
# r/deck-setup.R.

# "Probability distributions": a belief about someone's age, drawn as a small curve
# beside the photo. ymax fixes the top of the y axis so the curves can be compared.
belief_plot <- function(density, ymax = NA) {
  ggplot() +
    stat_function(fun = density, xlim = c(0, 100), n = 501, color = RED, linewidth = 1.2) +
    scale_y_continuous(limits = c(0, ymax)) +
    labs(x = "Age", y = "Density") +
    theme_minimal(base_size = 14) +
    theme(panel.grid.minor = element_blank())
}

# A flat-topped density: equally plausible across `plateau` years around `center`,
# tapering smoothly to zero over `taper` years on each side
plateau_density <- function(center = 40, plateau = 20, taper = 15) {
  shape <- function(x) {
    y <- numeric(length(x))
    left <- center - plateau / 2
    right <- center + plateau / 2
    i <- x >= left - taper & x < left
    y[i] <- 0.5 * (1 - cos(pi * (x[i] - (left - taper)) / taper))
    y[x >= left & x <= right] <- 1
    i <- x > right & x <= right + taper
    y[i] <- 0.5 * (1 + cos(pi * (x[i] - right) / taper))
    y
  }
  area <- integrate(shape, 0, 100)$value
  function(x) shape(x) / area
}

# A dashed vertical line at x, labelled at the top of the plot. line = FALSE gives
# just the label. Smaller vjust puts the label higher.
value_marker <- function(x, label, color, vjust = 1.5, line = TRUE) {
  list(
    if (line) geom_vline(xintercept = x, color = color, linewidth = 1.2, linetype = "dashed"),
    annotate(
      "text",
      x = x,
      y = Inf,
      vjust = vjust,
      hjust = -0.05,
      size = 7,
      color = color,
      label = label
    )
  )
}

# "The 68-95-99.7 rule": the standard Normal with 1, 2 and 3 SD bands shaded
normal_rule_plot <- function() {
  bands <- tibble(k = c(3, 2, 1), fill = c(tint(BLUE, 0.18), tint(BLUE, 0.5), BLUE))
  shading <- lapply(seq_len(nrow(bands)), function(i) {
    stat_function(
      fun = dnorm,
      geom = "area",
      xlim = c(-bands$k[i], bands$k[i]),
      fill = bands$fill[i]
    )
  })

  ggplot() +
    xlim(-4, 4) +
    shading +
    stat_function(fun = dnorm, linewidth = 1.2, color = INK) +
    annotate(
      "text",
      x = 0,
      y = 0.18,
      label = "68%",
      size = 10,
      color = "white",
      fontface = "bold"
    ) +
    annotate("text", x = 1.5, y = 0.04, label = "95%", size = 8, color = INK) +
    annotate("text", x = 2.5, y = 0.015, label = "99.7%", size = 7, color = INK) +
    scale_x_continuous(
      breaks = -3:3,
      labels = c("-3 SD", "-2 SD", "-1 SD", "mean", "+1 SD", "+2 SD", "+3 SD")
    ) +
    labs(x = NULL, y = NULL) +
    theme(axis.text.y = element_blank())
}

# "What correlation misses": three made-up datasets whose r hides what's going on
correlation_misses_data <- function() {
  set.seed(4)
  x1 <- runif(150, -3, 3)
  x2 <- rnorm(30)
  x3a <- rnorm(75, -1.5, 0.5)
  x3b <- rnorm(75, 1.5, 0.5)

  bind_rows(
    tibble(panel = "A curve", x = x1, y = x1^2 + rnorm(150, 0, 0.8)),
    tibble(panel = "One extreme point", x = c(x2, 8), y = c(rnorm(30), 8)),
    tibble(
      panel = "Two groups",
      x = c(x3a, x3b),
      y = c(
        -0.8 * x3a - 2 + rnorm(75, 0, 0.4),
        -0.8 * x3b + 2 + rnorm(75, 0, 0.4)
      )
    )
  ) |>
    group_by(panel) |>
    mutate(panel = paste0(panel, ":  r = ", fmt(cor(x, y), 2))) |>
    ungroup()
}

# Posterior of beta in z_weight ~ Normal(beta * z_height, sigma), by grid
# approximation over (beta, sigma) with sigma then summed out. Priors:
# beta ~ Normal(0, 1), sigma ~ Exponential(1).
beta_posterior <- function(d) {
  grid <- expand_grid(
    beta = seq(0, 1.5, length.out = 301),
    sigma = seq(0.2, 1.5, length.out = 131)
  ) |>
    mutate(
      log_post = map2_dbl(beta, sigma, function(b, s) {
        sum(dnorm(d$z_weight, b * d$z_height, s, log = TRUE))
      }) +
        dnorm(beta, 0, 1, log = TRUE) +
        dexp(sigma, 1, log = TRUE),
      post = exp(log_post - max(log_post))
    )
  grid |>
    group_by(beta) |>
    summarise(post = sum(post)) |>
    mutate(post = post / sum(post) / (beta[2] - beta[1]))
}
