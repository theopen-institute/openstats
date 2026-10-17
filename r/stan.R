# Fitting Stan models in the decks, and plotting their posteriors. Sourced by a
# deck's setup chunk, after r/deck-setup.R.

library(cmdstanr)
library(tidybayes)

# Fit a Stan model quietly. Compiled models are cached in .stancache.
fit_stan <- function(file, data) {
  cmdstan_model(file, dir = ".stancache")$sample(
    data = data,
    seed = 1,
    refresh = 0,
    show_messages = FALSE,
    show_exceptions = FALSE
  )
}

# Draws of one parameter as a tibble with a `model` column and a column `name`, for
# plot_posteriors(). Bind several: bind_rows(param_draws(fit_a, "beta", "A"), ...)
param_draws <- function(fit, variable, model, name = variable) {
  fit$draws(variable, format = "df") |>
    as_tibble() |>
    transmute(model = model, "{name}" := .data[[variable]])
}

# The posterior median of `x` for each model, as a named vector: m[["model name"]]
posterior_medians <- function(draws, x) {
  draws |>
    group_by(model) |>
    summarise(median = median({{ x }})) |>
    deframe()
}

# Posteriors of one quantity under several models, one row per model. `draws` has a
# `model` column and a column of draws named by `x`.
plot_posteriors <- function(draws, x, xlab, colors = c(RED, BLUE)) {
  ggplot(draws, aes(x = {{ x }}, y = model, fill = model)) +
    geom_vline(xintercept = 0, color = GRAY, linetype = "dashed") +
    stat_halfeye(.width = 0.89, point_size = 4, slab_alpha = 0.8, normalize = "groups") +
    scale_fill_manual(values = colors, guide = "none") +
    labs(x = xlab, y = NULL)
}
