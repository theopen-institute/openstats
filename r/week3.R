# Helpers for the week 3 deck. Sourced by its setup chunk, after r/deck-setup.R
# and r/stan.R.

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

# The surgeon example: case difficulty decides who operates, and how it goes
surgeon_dag <- function(...) {
  fork_dag(
    "S", "C", "O",
    labels = c(S = "Surgeon", C = "Case difficulty", O = "Outcome"),
    direct = TRUE,
    ...
  )
}
