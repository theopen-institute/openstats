# Dataset loaders shared by the decks. Each deck adds its own derived columns.

# !Kung San adults (Nancy Howell's census, via McElreath's Statistical Rethinking)
load_howell <- function() {
  read_csv("datasets/kungsan.csv") |>
    select(-1) |>
    filter(age >= 18)
}

# UC Berkeley graduate admissions, 1973: one row per applicant (dept, sex, admitted)
load_berkeley <- function() {
  read_csv("datasets/berkeley.csv")
}

# Ames, Iowa house sales 2006-2010 (De Cock 2011, via modeldata::ames)
load_houses <- function() {
  read_csv("datasets/ames.csv")
}

# World Bank indicators for 2022: one row per country (`code`), one column per
# requested series code, e.g. load_wb(c("SP.DYN.TFRT.IN", "IT.CEL.SETS.P2")).
load_wb <- function(codes) {
  read_csv(
    "datasets/wb2022.csv",
    na = c("", "..", "NA"),
    col_types = cols(.default = "c"),
    locale = locale(encoding = "latin1")
  ) |>
    select(code = `Country Code`, series = `Series Code`, value = `2022 [YR2022]`) |>
    filter(series %in% codes) |>
    distinct(code, series, .keep_all = TRUE) |>
    mutate(value = as.numeric(value)) |>
    pivot_wider(names_from = series, values_from = value)
}

# Country metadata (region, income group) for the World Bank data
load_wb_countries <- function() {
  read_csv("datasets/wb_country.csv")
}
