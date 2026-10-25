# Plots, data and helpers for the week 2 deck. Sourced by its setup chunk, after
# r/deck-setup.R.

# The small belief curves beside the photo: {r name, opts.label = "belief"}
knitr::opts_template$set(belief = list(fig.width = 6, fig.height = 2.8))

# ---- Data for the widgets ----------------------------------------------------------
# The canvas widgets (js/sample-mean.js, conditional.js, model-builder.js) read their
# data from a JSON block on the page, written here so the numbers come from the same
# R as the plots. One line in the deck: a chunk calling kung_widget_data() or
# house_models_data().

# `data` as a <script type="application/json" id="id"> block in the slide
json_script <- function(id, data) {
  json <- jsonlite::toJSON(data, auto_unbox = TRUE, digits = 4)
  knitr::asis_output(paste0(
    "\n```{=html}\n<script type=\"application/json\" id=\"", id, "\">",
    json,
    "</script>\n```\n"
  ))
}

# The !Kung adults for the sampling and "moving distribution" widgets, with the
# lines they draw: weight on height, and weight on sex and height
kung_widget_data <- function(howell) {
  line <- coef(lm(weight ~ height, howell))
  both <- coef(lm(weight ~ male + height, howell))
  json_script("kung-data", list(
    height = round(howell$height, 1),
    weight = round(howell$weight, 1),
    male = howell$male,
    line = list(intercept = line[["(Intercept)"]], slope = line[["height"]]),
    sex_line = list(
      intercept = both[["(Intercept)"]],
      male = both[["male"]],
      slope = both[["height"]]
    ),
    sex_gap = coef(lm(weight ~ male, howell))[["male"]]
  ))
}

# The predictors in the house-price model builder, in the order it lists them
HOUSE_FEATURES <- c(
  bedrooms = "Bedrooms",
  area_m2 = "Living area",
  bathrooms = "Bathrooms",
  year_built = "Year built",
  garage_cars = "Garage size",
  lot_m2 = "Lot area"
)

# Every combination of the house features (2^6 = 64 models), each fit to standardized
# data: coefficients with 90% intervals, and the typical miss (residual SD) in dollars.
# The model builder looks its models up by their features joined with "+", in the
# order of HOUSE_FEATURES ("none" for no features).
house_models <- function(houses) {
  keys <- names(HOUSE_FEATURES)
  z <- houses |> mutate(across(all_of(c("price", keys)), standardize))
  subsets <- unlist(
    lapply(0:length(keys), function(k) combn(keys, k, simplify = FALSE)),
    recursive = FALSE
  )

  models <- lapply(subsets, function(features) {
    formula <- reformulate(if (length(features)) features else "1", "price")
    fit <- lm(formula, z)
    ci <- confint(fit, level = 0.9)
    list(
      beta = lapply(set_names(features), function(f) {
        c(coef(fit)[[f]], ci[f, 1], ci[f, 2])
      }),
      sigma = sigma(fit) * sd(houses$price)
    )
  })
  names(models) <- vapply(subsets, paste, "", collapse = "+")
  names(models)[names(models) == ""] <- "none"
  models
}

house_models_data <- function(houses) {
  json_script("house-models", list(
    features = map2(names(HOUSE_FEATURES), unname(HOUSE_FEATURES), ~ list(key = .x, label = .y)),
    models = house_models(houses)
  ))
}

# ---- Part 1: population distributions ----------------------------------------------

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

# "Center, spread, shape": height, with the mean and a band 1 SD either side
height_hist_plot <- function(howell) {
  h_mean <- mean(howell$height)
  h_sd <- sd(howell$height)

  ggplot(howell, aes(height)) +
    annotate(
      "rect",
      xmin = h_mean - h_sd,
      xmax = h_mean + h_sd,
      ymin = -Inf,
      ymax = Inf,
      fill = BLUE,
      alpha = 0.12
    ) +
    geom_histogram(binwidth = 2, fill = GRAY, color = "white") +
    value_marker(h_mean, paste0("mean = ", fmt(h_mean), " cm"), RED) +
    value_marker(h_mean + h_sd, paste0("± 1 SD = ", fmt(h_sd), " cm"), BLUE, vjust = 4, line = FALSE) +
    labs(x = "Height (cm)", y = "Number of adults")
}

# "One hump or two?": the women's and men's heights, overlapping, with everyone's
# outline on top
height_sex_plot <- function(howell) {
  means <- howell |>
    group_by(sex) |>
    summarise(height = mean(height))

  ggplot(howell, aes(height)) +
    geom_histogram(
      aes(fill = sex),
      binwidth = 2,
      boundary = 0,
      position = "identity",
      alpha = 0.55,
      color = "white"
    ) +
    geom_freqpoly(binwidth = 2, boundary = 0, color = INK, linewidth = 1, linetype = "dashed") +
    geom_vline(data = means, aes(xintercept = height, color = sex), linewidth = 1.2) +
    scale_fill_manual(values = c(female = RED, male = BLUE), name = NULL) +
    scale_color_manual(values = c(female = RED, male = BLUE), guide = "none") +
    labs(x = "Height (cm)", y = "Number of adults")
}

# "The Normal distribution": the height histogram with a fitted Normal curve
normal_overlay_plot <- function(howell) {
  ggplot(howell, aes(height)) +
    geom_histogram(
      aes(y = after_stat(density)),
      binwidth = 2,
      fill = GRAY,
      color = "white"
    ) +
    stat_function(
      fun = dnorm,
      args = list(mean = mean(howell$height), sd = sd(howell$height)),
      color = BLUE,
      linewidth = 1.5
    ) +
    labs(x = "Height (cm)", y = "Density")
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

# "Same data, new ruler": the height histogram in cm, or in z-scores (z = TRUE).
# Bins anchored at the mean and a shared x-range, so each bar holds the same people
# in both plots.
height_ruler_plot <- function(howell, z = FALSE) {
  h_mean <- mean(howell$height)
  h_sd <- sd(howell$height)
  z_range <- c(-3, 3.5)

  if (!z) {
    ggplot(howell, aes(height)) +
      geom_histogram(binwidth = 2, boundary = h_mean, fill = GRAY, color = "white") +
      geom_vline(xintercept = h_mean, color = RED, linewidth = 1.2, linetype = "dashed") +
      coord_cartesian(xlim = h_mean + z_range * h_sd) +
      labs(x = "Height (cm)", y = NULL)
  } else {
    ggplot(howell, aes(z_height)) +
      geom_histogram(binwidth = 2 / h_sd, boundary = 0, fill = BLUE, color = "white") +
      geom_vline(xintercept = 0, color = RED, linewidth = 1.2, linetype = "dashed") +
      scale_x_continuous(breaks = -3:3) +
      coord_cartesian(xlim = z_range) +
      labs(x = "Height (z-score, in SDs)", y = NULL)
  }
}

# ---- Part 2: certainty distributions -----------------------------------------------

# "How old is he?": a belief about someone's age, drawn as a small curve beside the
# photo. ymax fixes the top of the y axis so the curves can be compared.
belief_plot <- function(density, ymax = NA) {
  ggplot() +
    stat_function(fun = density, xlim = c(0, 100), n = 501, color = GREEN, linewidth = 1.2) +
    scale_y_continuous(limits = c(0, ymax)) +
    labs(x = "Age", y = "Plausibility") +
    theme_minimal(base_size = 14) +
    theme(panel.grid.minor = element_blank(), axis.text.y = element_blank())
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

# "Two spreads": for each number of adults measured, how far most adults are from the
# average (2 SD), and how far off our estimate of the average could be (2 SD / √n,
# the 95% width of the certainty distribution with a flat prior)
two_spreads <- function(howell, sizes = c(5, 20, 100, nrow(howell))) {
  s <- sd(howell$height)
  tibble(
    n = sizes,
    population = 2 * s,
    certainty = 2 * s / sqrt(sizes)
  )
}

# ---- Part 3: correlative distributions ---------------------------------------------

# "Standardize both variables": height and weight in z-scores, colored by whether
# each person's two z-scores agree in sign
agreement_plot <- function(howell) {
  quad_labels <- tibble(
    x = c(1.9, -1.9, -1.9, 1.9),
    y = c(2.8, -2.8, 2.8, -2.8),
    label = c(
      "taller & heavier  (+)",
      "shorter & lighter  (+)",
      "shorter & heavier  (−)",
      "taller & lighter  (−)"
    ),
    color = c(BLUE, BLUE, RED, RED)
  )

  howell |>
    mutate(agree = if_else(z_height * z_weight > 0, "agree", "disagree")) |>
    ggplot(aes(z_height, z_weight)) +
    geom_hline(yintercept = 0, color = GRAY) +
    geom_vline(xintercept = 0, color = GRAY) +
    geom_point(aes(color = agree), alpha = 0.7, size = 2.5, show.legend = FALSE) +
    geom_text(
      data = quad_labels,
      aes(x, y, label = label),
      color = quad_labels$color,
      size = 7,
      fontface = "bold"
    ) +
    scale_color_manual(values = c(agree = BLUE, disagree = RED)) +
    coord_equal(xlim = c(-3.5, 3.5), ylim = c(-3, 3)) +
    labs(x = "Height (z)", y = "Weight (z)")
}

# "What does r look like?": made-up clouds of points for a range of correlations
cor_gallery_plot <- function(rs = c(-0.8, -0.3, 0, 0.3, 0.6, 0.9)) {
  set.seed(2)
  gallery <- map_dfr(rs, function(r) {
    x <- rnorm(150)
    tibble(r = r, x = x, y = r * x + sqrt(1 - r^2) * rnorm(150))
  }) |>
    mutate(panel = factor(paste0("r = ", r), levels = paste0("r = ", rs)))

  ggplot(gallery, aes(x, y)) +
    geom_point(color = ORANGE, alpha = 0.7, size = 1.8) +
    facet_wrap(~panel, nrow = 1) +
    coord_equal() +
    labs(x = NULL, y = NULL) +
    theme(axis.text = element_blank())
}

# "What correlation misses": three made-up datasets whose r hides what's going on
cor_misses_plot <- function() {
  set.seed(4)
  x1 <- runif(150, -3, 3)
  x2 <- rnorm(30)
  x3a <- rnorm(75, -1.5, 0.5)
  x3b <- rnorm(75, 1.5, 0.5)

  misses <- bind_rows(
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

  ggplot(misses, aes(x, y)) +
    geom_point(color = ORANGE, alpha = 0.7, size = 2) +
    facet_wrap(~panel, scales = "free") +
    labs(x = NULL, y = NULL) +
    theme(axis.text = element_blank())
}

# "Regression: our first coefficient": lines through the z-scores with a few slopes,
# one of them the correlation r
candidate_lines_plot <- function(howell, r) {
  candidates <- tibble(
    beta = c(0, 0.4, round(r, 2), 1.5),
    label = paste0("β = ", beta)
  )

  ggplot(howell, aes(z_height, z_weight)) +
    geom_point(color = GRAY, alpha = 0.6, size = 2) +
    geom_abline(
      data = candidates,
      aes(slope = beta, intercept = 0, color = label),
      linewidth = 1.4
    ) +
    scale_color_manual(values = c(ORANGE, TEAL, BLUE, RED), name = NULL) +
    coord_equal(xlim = c(-3, 3), ylim = c(-3, 3)) +
    labs(x = "Height (z)", y = "Weight (z)") +
    theme(legend.text = element_text(size = 20))
}

# "The best line": the line with slope r, and each person's error from it
residuals_plot <- function(howell, r) {
  howell |>
    mutate(fitted = r * z_height) |>
    ggplot(aes(z_height, z_weight)) +
    geom_segment(aes(xend = z_height, yend = fitted), color = RED, alpha = 0.4) +
    geom_point(color = GRAY, size = 2) +
    geom_abline(slope = r, intercept = 0, color = BLUE, linewidth = 1.5) +
    coord_equal(xlim = c(-3, 3), ylim = c(-3, 3)) +
    labs(x = "Height (z)", y = "Weight (z)")
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

# "How sure are we about β?": the posterior of β from 20 random adults, and from
# everyone. Certainty distributions, so green: lighter for the smaller sample.
beta_posterior_plot <- function(howell) {
  set.seed(7)
  small <- slice_sample(howell, n = 20)
  labels <- c("20 adults", paste(nrow(howell), "adults"))

  bind_rows(
    beta_posterior(small) |> mutate(data = labels[1]),
    beta_posterior(howell) |> mutate(data = labels[2])
  ) |>
    mutate(data = factor(data, levels = labels)) |>
    ggplot(aes(beta, post, color = data, fill = data)) +
    geom_area(alpha = 0.15, position = "identity", linewidth = 1.5) +
    scale_color_manual(values = c(tint(GREEN, 0.45), GREEN), name = NULL) +
    scale_fill_manual(values = c(tint(GREEN, 0.45), GREEN), name = NULL) +
    labs(x = "β (SD of weight per SD of height)", y = "Plausibility") +
    theme(axis.text.y = element_blank())
}

# "How much r varies by chance": r for every pair of unrelated variables, with 20
# cases (`r_small`, from the deck) and with 500
noise_dist_plot <- function(r_small, n_vars) {
  set.seed(4)
  noise_big <- matrix(rnorm(500 * n_vars), nrow = 500)
  r_big <- cor(noise_big)

  null_rs <- bind_rows(
    tibble(r = r_small[upper.tri(r_small)], n = "20 cases"),
    tibble(r = r_big[upper.tri(r_big)], n = "500 cases")
  )

  ggplot(null_rs, aes(r, fill = n)) +
    geom_histogram(
      binwidth = 0.025,
      color = "white",
      position = "identity",
      alpha = 0.8
    ) +
    geom_vline(xintercept = 0, color = INK, linetype = "dashed") +
    scale_fill_manual(values = c(tint(GREEN, 0.45), GREEN), name = NULL) +
    coord_cartesian(xlim = c(-0.8, 0.8)) +
    labs(
      x = paste("r for all", choose(n_vars, 2), "pairs of unrelated variables"),
      y = NULL
    ) +
    theme(axis.text.y = element_blank())
}

# ---- Part 3, the preview: sex, height and weight -----------------------------------

# The coefficients the "Do men weigh more?" slides quote, with 90% intervals: sex on
# its own (total), sex once height is in the model (direct), height's slope in that
# model, and how much taller the men are
sex_weight_fits <- function(howell) {
  alone <- lm(weight ~ male, howell)
  both <- lm(weight ~ male + height, howell)
  ci <- confint(both, level = 0.9)
  list(
    total = coef(alone)[["male"]],
    direct = coef(both)[["male"]],
    direct_lo = ci["male", 1],
    direct_hi = ci["male", 2],
    slope = coef(both)[["height"]],
    height_gap = coef(lm(height ~ male, howell))[["male"]],
    weight_women = mean(howell$weight[howell$male == 0]),
    weight_men = mean(howell$weight[howell$male == 1])
  )
}

# "Do men weigh more?": the women's and men's weights, with each group's average
sex_weight_plot <- function(howell) {
  means <- howell |>
    group_by(sex) |>
    summarise(weight = mean(weight))

  ggplot(howell, aes(weight, fill = sex)) +
    geom_histogram(binwidth = 2, boundary = 0, position = "identity", alpha = 0.55, color = "white") +
    geom_vline(data = means, aes(xintercept = weight, color = sex), linewidth = 1.4) +
    scale_fill_manual(values = c(female = RED, male = BLUE), name = NULL) +
    scale_color_manual(values = c(female = RED, male = BLUE), guide = "none") +
    labs(x = "Weight (kg)", y = "Number of adults")
}

# "Add height, and sex stops predicting weight": sex works on weight through height. The
# direct arrow stays, gray: in these data it carries almost nothing.
sex_path_dag <- function() {
  pipe_dag(
    "S", "H", "W",
    labels = c(S = "Sex", H = "Height", W = "Weight"),
    direct = TRUE,
    highlight = c("S -> H", "H -> W")
  )
}

# ---- Practical work: house prices ------------------------------------------------

# "Step 1": sale prices, with the mean and median
price_hist_plot <- function(houses) {
  p_mean <- mean(houses$price)
  p_median <- median(houses$price)

  ggplot(houses, aes(price)) +
    geom_histogram(binwidth = 10000, fill = GRAY, color = "white") +
    value_marker(p_mean, paste("mean =", dollars(p_mean)), RED) +
    value_marker(p_median, paste("median =", dollars(p_median)), BLUE, vjust = 3.5) +
    scale_x_continuous(labels = scales::label_dollar()) +
    labs(x = "Sale price", y = "Number of houses")
}

# "Step 4": price against living area, with the `unusual` houses marked A and B
price_area_plot <- function(houses, unusual) {
  ggplot(houses, aes(area_m2, price)) +
    geom_point(color = ORANGE, alpha = 0.3, size = 1.8) +
    geom_point(data = unusual, color = RED, size = 5) +
    geom_text(
      data = unusual,
      aes(label = str_sub(house, 1, 1)),
      color = RED,
      size = 8,
      fontface = "bold",
      nudge_x = -25
    ) +
    scale_y_continuous(labels = scales::label_dollar()) +
    labs(x = "Living area (m²)", y = "Sale price")
}

# "Step 3: The correlations": each feature's correlation with price
price_cor_plot <- function(houses) {
  houses |>
    summarise(across(all_of(names(HOUSE_FEATURES)), ~ cor(.x, price))) |>
    pivot_longer(everything(), names_to = "feature", values_to = "r") |>
    mutate(feature = fct_reorder(HOUSE_FEATURES[feature], r)) |>
    ggplot(aes(r, feature)) +
    geom_col(fill = ORANGE, width = 0.7) +
    geom_text(aes(label = fmt(r, 2)), hjust = -0.2, size = 8) +
    scale_x_continuous(limits = c(0, 1)) +
    labs(x = "Correlation with sale price (r)", y = NULL)
}

# "Step 6: A puzzle: bedrooms": median price by number of bedrooms, within thirds of
# living area (groups of at least 20 houses)
bedrooms_puzzle_plot <- function(houses) {
  size_breaks <- quantile(houses$area_m2, c(0, 1 / 3, 2 / 3, 1))
  size_labels <- c(
    paste0("Small (< ", fmt(size_breaks[2], 0), " m²)"),
    paste0("Medium (", fmt(size_breaks[2], 0), "–", fmt(size_breaks[3], 0), " m²)"),
    paste0("Large (> ", fmt(size_breaks[3], 0), " m²)")
  )

  houses |>
    mutate(size = cut(area_m2, size_breaks, labels = size_labels, include.lowest = TRUE)) |>
    group_by(size, bedrooms) |>
    filter(n() >= 20) |>
    summarise(price = median(price), .groups = "drop") |>
    ggplot(aes(bedrooms, price)) +
    geom_line(color = ORANGE, linewidth = 1.5) +
    geom_point(color = ORANGE, size = 4) +
    facet_wrap(~size) +
    scale_y_continuous(labels = scales::label_dollar()) +
    labs(x = "Bedrooms", y = "Median sale price")
}
