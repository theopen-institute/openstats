# Plots and helpers for the week 2 deck. Sourced by its setup chunk, after
# r/deck-setup.R.

# The small belief curves beside the photo: {r name, opts.label = "belief"}
knitr::opts_template$set(belief = list(fig.width = 6, fig.height = 2.8))

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
    geom_point(color = BLUE, alpha = 0.6, size = 2) +
    facet_wrap(~panel, scales = "free") +
    labs(x = NULL, y = NULL) +
    theme(axis.text = element_blank())
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

# ---- Part 1: describing patterns -----------------------------------------------

# "Describing a distribution": height, with the mean and a band 1 SD either side
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
    geom_point(color = BLUE, alpha = 0.6, size = 1.8) +
    facet_wrap(~panel, nrow = 1) +
    coord_equal() +
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

# "β is a parameter": the posterior of β from 20 random adults, and from everyone
beta_posterior_plot <- function(howell) {
  set.seed(7)
  small <- slice_sample(howell, n = 20)

  bind_rows(
    beta_posterior(small) |> mutate(data = "20 adults"),
    beta_posterior(howell) |> mutate(data = paste(nrow(howell), "adults"))
  ) |>
    ggplot(aes(beta, post, color = data)) +
    geom_line(linewidth = 1.5) +
    scale_color_manual(values = c(RED, BLUE), name = NULL) +
    labs(x = "β (SD of weight per SD of height)", y = "Plausibility") +
    theme(axis.text.y = element_blank())
}

# ---- Part 2: when patterns mislead -----------------------------------------------

# "The confounder: temperature": ice cream and drownings within temperature bands
icecream_strata_plot <- function(beach) {
  beach_bands <- beach |>
    mutate(
      band = cut(
        temp,
        c(-Inf, 14, 22, Inf),
        labels = c(
          "Cool days (< 14°C)",
          "Mild days (14–22°C)",
          "Hot days (> 22°C)"
        )
      )
    ) |>
    group_by(band) |>
    mutate(band = paste0(band, ":  r = ", fmt(cor(ice_cream, drownings), 2))) |>
    ungroup() |>
    arrange(temp) |>
    mutate(band = fct_inorder(band))

  ggplot(beach_bands, aes(ice_cream, drownings)) +
    geom_jitter(color = BLUE, alpha = 0.6, size = 2, width = 0, height = 0.15) +
    geom_smooth(method = "lm", se = FALSE, color = RED, linewidth = 1.5) +
    facet_wrap(~band, scales = "free_x") +
    labs(x = "Ice cream sales", y = "Drownings") +
    theme(strip.text = element_text(size = 18))
}

# "Small samples and many comparisons": r for every pair of unrelated variables,
# with 20 cases (`r_small`, from the deck) and with 500
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
    scale_fill_manual(values = c(RED, BLUE), name = NULL) +
    coord_cartesian(xlim = c(-0.8, 0.8)) +
    labs(
      x = paste("r for all", choose(n_vars, 2), "pairs of unrelated variables"),
      y = NULL
    ) +
    theme(axis.text.y = element_blank())
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

# "Step 3": price against living area, with the `unusual` houses marked A and B
price_area_plot <- function(houses, unusual) {
  ggplot(houses, aes(area_m2, price)) +
    geom_point(color = BLUE, alpha = 0.3, size = 1.8) +
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

# "Step 4: The correlations": each feature's correlation with price
price_cor_plot <- function(houses) {
  features <- c(
    area_m2 = "Living area",
    garage_cars = "Garage size",
    year_built = "Year built",
    bathrooms = "Bathrooms",
    lot_m2 = "Lot area",
    bedrooms = "Bedrooms"
  )

  houses |>
    summarise(across(all_of(names(features)), ~ cor(.x, price))) |>
    pivot_longer(everything(), names_to = "feature", values_to = "r") |>
    mutate(feature = fct_reorder(features[feature], r)) |>
    ggplot(aes(r, feature)) +
    geom_col(fill = BLUE, width = 0.7) +
    geom_text(aes(label = fmt(r, 2)), hjust = -0.2, size = 8) +
    scale_x_continuous(limits = c(0, 1)) +
    labs(x = "Correlation with sale price (r)", y = NULL)
}

# "A puzzle: bedrooms": median price by number of bedrooms, within thirds of
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
    geom_line(color = BLUE, linewidth = 1.5) +
    geom_point(color = BLUE, size = 4) +
    facet_wrap(~size) +
    scale_y_continuous(labels = scales::label_dollar()) +
    labs(x = "Bedrooms", y = "Median sale price")
}
