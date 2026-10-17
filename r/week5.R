# Plots for the week 5 deck. Sourced by its setup chunk, after r/deck-setup.R.

# ---- 3. How was the data made? -------------------------------------------------

# Observational: people chose X, so everything behind that choice is a back door
observational_dag <- function() {
  fork_dag(
    "X", "U", "Y",
    labels = c(X = "Program", U = "Motivation, wealth, ...", Y = "Outcome"),
    direct = TRUE,
    highlight = c("U -> X", "U -> Y"),
    unobserved = "U"
  )
}

# Randomized: a coin flip chose X, so no arrows from U into X
randomized_dag <- function() {
  dag_plot(
    c("R -> X", "U -> Y", "X -> Y"),
    list(X = c(0, 0), U = c(1, 1.1), Y = c(2, 0), R = c(-0.2, 1.1)),
    labels = c(R = "Coin flip", X = "Program", U = "Motivation, wealth, ...", Y = "Outcome"),
    above = c("U", "R"),
    exposure = "X",
    outcome = "Y",
    unobserved = "U"
  )
}

# ---- Part 2 --------------------------------------------------------------------

# "More data won't save you": a made-up world where early-marriage norms drive both
# girls' schooling and births, and schooling has no effect on births. At each
# sample size, the estimated effect of schooling (with its 95% interval) from the
# model they ran, and from the model that adjusts for the norms nobody measured.
more_data_plot <- function() {
  set.seed(5)

  fit_row <- function(fit, model, n) {
    ci <- confint(fit)["x", ]
    tibble(model = model, n = n, est = coef(fit)[["x"]], lo = ci[[1]], hi = ci[[2]])
  }

  sizes <- c(50, 200, 1000, 5000, 20000)

  more_data <- map_dfr(sizes, function(n) {
    u <- rnorm(n) # early-marriage norms: nobody measured these
    x <- -0.6 * u + rnorm(n) # schooling
    y <- 0.6 * u + rnorm(n) # births; schooling has no effect
    bind_rows(
      fit_row(lm(y ~ x), "What they ran: births ~ schooling", n),
      fit_row(lm(y ~ x + u), "If norms had been measured", n)
    )
  })

  more_data$model <- fct_inorder(more_data$model)

  ggplot(more_data, aes(n, est, color = model)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = INK) +
    annotate("text", x = 2200, y = 0.04, label = "true effect", vjust = 0,
             color = INK, size = 6) +
    geom_pointrange(aes(ymin = lo, ymax = hi), linewidth = 1.2, size = 0.9,
                    position = position_dodge(width = 0.15)) +
    scale_x_log10(breaks = sizes, labels = fmt(sizes, 0)) +
    scale_color_manual(values = c(RED, GRAY), name = NULL) +
    labs(x = "Sample size", y = "Estimated effect\nof schooling")
}

# The running example: schooling and births, across countries
schooling_labels <- c(
  S = "Schooling", B = "Births",
  G = "GDP per capita", C = "Contraceptive use",
  U = "Urbanization", N = "Gender norms",
  M = "Age at marriage", V = "Surveyed at a clinic"
)

# "Their model implies a DAG": the controls as they drew them
implied_dag <- function() {
  dag_plot(
    c("G -> S", "G -> B", "S -> B", "C -> B"),
    list(S = c(0, 0), B = c(3, 0), G = c(1.5, 1.3), C = c(1.5, -1.3)),
    labels = schooling_labels,
    above = "G",
    left = "S",
    right = "B",
    exposure = "S",
    outcome = "B"
  )
}

# "Unobserved forks": common causes the model left out
missing_forks_dag <- function() {
  dag_plot(
    c("G -> S", "G -> B", "S -> B", "U -> S", "U -> B", "N -> S", "N -> B"),
    list(
      S = c(0, 0), B = c(4, 0), G = c(2, 1.3),
      U = c(0.4, -1.6), N = c(3.6, -1.6)
    ),
    labels = replace(schooling_labels, "G", "GDP"),
    above = "G",
    left = "S",
    right = "B",
    exposure = "S",
    outcome = "B",
    unobserved = c("U", "N"),
    highlight = c("U -> S", "U -> B", "N -> S", "N -> B")
  )
}

# "Hidden pipes": channels schooling works through
mediators_dag <- function() {
  dag_plot(
    c("S -> M", "M -> B", "S -> C", "C -> B", "S -> B"),
    list(S = c(0, 0), B = c(3, 0), M = c(1.5, 1.3), C = c(1.5, -1.3)),
    labels = schooling_labels,
    above = "M",
    left = "S",
    right = "B",
    exposure = "S",
    outcome = "B",
    highlight = c("S -> M", "M -> B", "S -> C", "C -> B")
  )
}

# "Unobserved colliders": who ends up in a clinic survey
clinic_collider_dag <- function() {
  dag_plot(
    c("S -> V", "B -> V", "S -> B"),
    list(S = c(0, 0), B = c(3, 0), V = c(1.5, -1.3)),
    labels = schooling_labels,
    left = "S",
    right = "B",
    exposure = "S",
    outcome = "B",
    unobserved = "V",
    highlight = c("S -> V", "B -> V")
  )
}
