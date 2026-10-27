# Dataset loaders shared by the decks. Each deck adds its own derived columns.

# !Kung San adults (Nancy Howell's census, via McElreath's Statistical Rethinking).
# adults = FALSE gives everyone she counted, children too.
load_howell <- function(adults = TRUE) {
  read_csv("datasets/kungsan.csv", show_col_types = FALSE) |>
    select(-1) |>
    filter(!adults | age >= 18)
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

# Nepal Labour Force Survey earnings, from the ILO's tabulations of the 2008 and
# 2017/18 rounds (ILOSTAT EAR_EMTA_SEX_EDU_CUR_NB, EES_TEES_SEX_EDU_NB): paid
# employees' average monthly earnings in their main job (rupees of the day) and their
# number (thousands), by sex (T: both, M, F) and ISCED education level (X: none,
# 0 pre-primary ... 7 master's, 9 not stated). year 2017 is the 2017/18 round.
load_nlfs <- function() {
  read_csv("datasets/nlfs_earnings.csv", col_types = "cicdd")
}

# Nepal Rastra Bank consumer price index by fiscal year (mid-July to mid-July), 2014/15
# = 100, and annual inflation (%). From 2023/24 on, inflation only.
load_nepal_cpi <- function() {
  read_csv("datasets/nepal_cpi.csv", col_types = "cdddd")
}

# Nepal's population by single year of age and sex, from the Nepal Living Standards
# Survey IV (2022/23): household roster (S01, question 1.03, age as reported), weighted
# by household weight (hhs_wt). status "resident": household members; "abroad":
# members living abroad, not counted in the residents. people: weighted count; n:
# survey respondents.
load_nepal_ages <- function() {
  read_csv("datasets/nepal_ages.csv", col_types = "iccdi")
}

# Japan's population by single year of age and sex, 1 July 2022 (age 100 is 100 and
# over), from UN World Population Prospects 2024
# (WPP2024_PopulationBySingleAgeSex_Medium_1950-2023)
load_japan_ages <- function() {
  read_csv("datasets/japan_ages.csv", col_types = "icd")
}
