# Plots, DAGs and model fits for the week 3 deck. Sourced by its setup chunk,
# after r/deck-setup.R and r/stan.R.

# Posterior of (male - female) from a model with alpha[sex]
sex_difference <- function(fit) {
  fit$draws("alpha", format = "df") |>
    as_tibble() |>
    transmute(difference = `alpha[2]` - `alpha[1]`)
}

# The !Kung DAG: sex, height, weight and age. `highlight` picks the path to show.
howell_dag <- function(highlight = NULL) {
  dag_plot(
    c("S -> H", "S -> W", "H -> W", "A -> H", "A -> W"),
    list(S = c(0, 1), H = c(1, 0), W = c(2, 1), A = c(3, 0)),
    labels = c(S = "Sex", H = "Height", W = "Weight", A = "Age"),
    above = c("S", "W"),
    highlight = highlight,
    exposure = "S",
    outcome = "W"
  )
}

# Height against weight, colored by sex (the !Kung adults, or a simulation of them)
sex_scatter <- function(data, alpha = 0.7, size = 2.5) {
  ggplot(data, aes(height, weight, color = sex)) +
    geom_point(alpha = alpha, size = size) +
    scale_color_manual(values = c(female = RED, male = BLUE), name = NULL) +
    labs(x = "Height (cm)", y = "Weight (kg)")
}

# "Does sex affect weight?": Model A (weight ~ sex) and Model B (weight ~ sex +
# height) fit to `data`, as draws of the male - female difference under each
weight_model_draws <- function(data) {
  fit_a <- fit_stan("models/weight_sex.stan", compose_data(select(data, weight, sex)))
  fit_b <- fit_stan(
    "models/weight_sex_height.stan",
    compose_data(select(data, weight, height_std, sex))
  )
  bind_rows(
    sex_difference(fit_a) |> mutate(model = "A: weight ~ sex"),
    sex_difference(fit_b) |> mutate(model = "B: weight ~ sex + height")
  )
}

# "Bedrooms: two models": the coefficient on bedrooms, without and with living area
bedroom_model_draws <- function(houses) {
  house_fit <- function(predictors) {
    fit_stan(
      "models/linear.stan",
      list(
        n = nrow(houses),
        k = length(predictors),
        X = as.matrix(houses[predictors]),
        y = houses$z_price
      )
    )
  }

  bind_rows(
    param_draws(house_fit("z_bedrooms"), "beta[1]", "price ~ bedrooms", "beta_bedrooms"),
    param_draws(
      house_fit(c("z_bedrooms", "z_area")),
      "beta[1]",
      "price ~ bedrooms + area",
      "beta_bedrooms"
    )
  )
}

# World Bank 2022, one row per country: births per woman, women's college enrollment
# (% gross) and infant mortality, with the last two also standardized for the models
load_fertility_countries <- function() {
  load_wb(c("SP.DYN.TFRT.IN", "SE.TER.ENRR.FE", "SP.DYN.IMRT.IN")) |>
    transmute(
      code,
      fertility_rate = SP.DYN.TFRT.IN,
      college = SE.TER.ENRR.FE,
      mortality = SP.DYN.IMRT.IN
    ) |>
    drop_na() |>
    mutate(
      women_in_college = standardize(college),
      infant_mortality = standardize(mortality)
    )
}

# "Worked example: education and birth rates"
fertility_scatter <- function(countries) {
  ggplot(countries, aes(college, fertility_rate)) +
    geom_point(color = BLUE, alpha = 0.7, size = 3) +
    geom_smooth(method = "lm", se = FALSE, color = INK) +
    labs(
      x = "Women's college enrollment (% gross)",
      y = "Births per woman"
    )
}

fertility_labels <- c(
  C = "Women in college",
  M = "Infant mortality",
  F = "Births per woman",
  D = "Development"
)

# DAG 1, development first: development drives both college and infant mortality
development_dag <- function() {
  dag_plot(
    c("D -> C", "D -> M", "C -> F", "M -> F"),
    pos = list(D = c(0.4, 1.4), C = c(0, 0), M = c(2.6, 1.4), F = c(3, 0)),
    labels = fertility_labels,
    above = c("D", "M"),
    highlight = c("D -> C", "D -> M", "M -> F"),
    exposure = "C",
    outcome = "F",
    unobserved = "D"
  )
}

# DAG 2, education first: college lowers infant mortality, which lowers births
education_dag <- function() {
  dag_plot(
    c("C -> M", "C -> F", "M -> F"),
    pos = list(C = c(0, 0), M = c(1.5, 1.2), F = c(3, 0)),
    labels = fertility_labels,
    above = "M",
    highlight = c("C -> M", "M -> F"),
    exposure = "C",
    outcome = "F"
  )
}

# "Same data, different science": the coefficient on college under each DAG
fertility_model_draws <- function(countries) {
  fit_1 <- fit_stan(
    "models/fertility_college.stan",
    compose_data(select(countries, fertility_rate, women_in_college))
  )
  fit_2 <- fit_stan(
    "models/fertility_college_mortality.stan",
    compose_data(select(countries, fertility_rate, women_in_college, infant_mortality))
  )
  bind_rows(
    param_draws(fit_1, "beta", "DAG 2: births ~ college", "beta_college"),
    param_draws(fit_2, "beta_college", "DAG 1: births ~ college + mortality")
  )
}
