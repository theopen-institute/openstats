# Plots and data for the week 4 deck. Sourced by its setup chunk, after
# r/deck-setup.R.

# ---- Everyone vs. split into groups ------------------------------------------
# Each building block is shown twice: the pattern across everyone, then within
# groups. These draw the two halves; the deck adds the labels.

# Everyone: gray points and one regression line
pooled_plot <- function(data, x, y, alpha = 0.6, size = 2) {
  ggplot(data, aes({{ x }}, {{ y }})) +
    geom_point(color = GRAY, alpha = alpha, size = size) +
    geom_smooth(method = "lm", se = FALSE, color = INK, linewidth = 1.5)
}

# Split: points and a regression line per group, colored by `group`
split_plot <- function(data, x, y, group, colors, alpha = 0.6, size = 2) {
  ggplot(data, aes({{ x }}, {{ y }}, color = {{ group }})) +
    geom_point(alpha = alpha, size = size) +
    geom_smooth(method = "lm", se = FALSE, linewidth = 1.5) +
    scale_color_manual(values = colors, name = NULL)
}

# ---- The fork ------------------------------------------------------------------

# "Do mobile phones lower birth rates?": World Bank 2022, one row per country
load_phones <- function() {
  load_wb_countries() |>
    select(code = Code, income = `Income group`) |>
    inner_join(load_wb(c("IT.CEL.SETS.P2", "SP.DYN.TFRT.IN")), by = "code") |>
    transmute(
      phones = IT.CEL.SETS.P2,
      fertility = SP.DYN.TFRT.IN,
      income = factor(
        income,
        levels = c("Low income", "Lower middle income", "Upper middle income", "High income")
      )
    ) |>
    drop_na()
}

# The same countries, a line per income group
phones_by_income_plot <- function(phones) {
  split_plot(phones, phones, fertility, income, c(RED, ORANGE, TEAL, BLUE), alpha = 0.7, size = 2.5) +
    guides(color = guide_legend(nrow = 2)) +
    labs(
      x = "Mobile subscriptions per 100 people",
      y = "Births per woman",
      title = "Within income groups"
    ) +
    theme(legend.text = element_text(size = 14))
}

# "In development data, wealth is the fork behind everything"
wealth_fork_dag <- function() {
  dag_plot(
    c("W -> P", "W -> S", "W -> B", "W -> H", "W -> C", "S -> B"),
    list(
      W = c(2.6, 1.4), P = c(0, 0), S = c(1.3, 0), B = c(2.6, 0), H = c(3.9, 0), C = c(5.2, 0)
    ),
    labels = c(
      W = "Wealth / SES", P = "Phones", S = "Schooling", B = "Births",
      H = "Health", C = "Clean water"
    ),
    above = "W",
    exposure = "S",
    outcome = "B",
    highlight = c("W -> S", "W -> B")
  )
}

# ---- The pipe ------------------------------------------------------------------

# "Does the anti-fungal treatment work?": average growth for all plants, and
# within each fungus status
fungus_plot <- function(plants) {
  growth_all <- plants |>
    group_by(treated) |>
    summarise(growth = mean(growth)) |>
    mutate(group = "All plants")

  growth_split <- plants |>
    mutate(group = if_else(fungus == 1, "With fungus", "No fungus")) |>
    group_by(group, treated) |>
    summarise(growth = mean(growth), .groups = "drop")

  bind_rows(growth_all, growth_split) |>
    mutate(
      group = factor(group, levels = c("All plants", "No fungus", "With fungus")),
      treated = factor(treated, levels = c("Untreated", "Treated"))
    ) |>
    ggplot(aes(treated, growth, fill = treated)) +
    geom_col(width = 0.7) +
    facet_wrap(~group) +
    scale_fill_manual(values = c(Untreated = GRAY, Treated = BLUE), guide = "none") +
    labs(x = NULL, y = "Average growth (cm)") +
    theme(strip.text = element_text(size = 16), axis.text.x = element_text(size = 14))
}

# Berkeley admissions: the share admitted and number of applicants by sex,
# overall (dept "All") and in each department
berkeley_rates <- function(berkeley) {
  bind_rows(
    berkeley |>
      group_by(sex) |>
      summarise(rate = mean(admitted), applicants = n()) |>
      mutate(dept = "All"),
    berkeley |>
      group_by(dept, sex) |>
      summarise(rate = mean(admitted), applicants = n(), .groups = "drop")
  )
}

# The overall admission rate for one sex
overall_rate <- function(rates, sex) {
  rates$rate[rates$dept == "All" & rates$sex == sex]
}

# The number of departments that admitted women at a higher rate than men
women_higher <- function(rates) {
  rates |>
    filter(dept != "All") |>
    select(dept, sex, rate) |>
    pivot_wider(names_from = sex, values_from = rate) |>
    summarise(n = sum(female > male)) |>
    pull(n)
}

# Admission rates for women and men, overall and by department. Dot size: applicants.
berkeley_plot <- function(rates) {
  rates |>
    mutate(dept = fct_relevel(factor(dept), "All")) |>
    ggplot(aes(rate, fct_rev(dept), color = sex)) +
    geom_line(aes(group = dept), color = GRAY, linewidth = 1) +
    geom_point(aes(size = applicants), alpha = 0.9) +
    scale_color_manual(values = c(female = RED, male = BLUE), name = NULL) +
    scale_size_area(max_size = 10, guide = "none") +
    scale_x_continuous(labels = scales::label_percent()) +
    labs(x = "Admission rate", y = "Department")
}

# ---- The collider --------------------------------------------------------------

# "Are rich kids lazy?": only the people with prestigious jobs (on the axes of the
# whole population, so the two plots compare)
hired_plot <- function(jobs) {
  jobs |>
    filter(job) |>
    ggplot(aes(wealth, work)) +
    geom_point(color = BLUE, alpha = 0.7, size = 2) +
    geom_smooth(method = "lm", se = FALSE, color = BLUE, linewidth = 1.5) +
    coord_cartesian(xlim = range(jobs$wealth), ylim = range(jobs$work)) +
    labs(x = "Family wealth", y = "Hard work", title = "People with prestigious jobs")
}

# Everyone, with the people who got the job in blue
everyone_jobs_plot <- function(jobs) {
  ggplot(jobs, aes(wealth, work)) +
    geom_point(aes(color = status), alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", se = FALSE, color = INK, linewidth = 1.5) +
    scale_color_manual(
      values = c("Prestigious job" = BLUE, "No prestigious job" = GRAY),
      name = NULL
    ) +
    labs(x = "Family wealth", y = "Hard work", title = "Everyone")
}

# "Why is published science so often wrong?": all proposals, with a line through
# the funded ones
grants_plot <- function(grants) {
  ggplot(grants, aes(newsworthy, trustworthy, color = funded)) +
    geom_point(size = 3, alpha = 0.8) +
    geom_smooth(
      data = filter(grants, funded),
      method = "lm", se = FALSE, color = BLUE, linewidth = 1.5
    ) +
    scale_color_manual(values = c(`TRUE` = BLUE, `FALSE` = GRAY), guide = "none") +
    labs(x = "Newsworthiness", y = "Trustworthiness")
}

# ---- Descendants ---------------------------------------------------------------

# A proxy for a confounder: income group, a descendant of wealth
proxy_dag <- function() {
  dag_plot(
    c("Z -> X", "Z -> Y", "Z -> D"),
    list(X = c(0, 0), Z = c(1, 1.1), Y = c(2, 0), D = c(1, -0.4)),
    labels = c(X = "Phones", Z = "Wealth", Y = "Births", D = "Income group"),
    above = "Z",
    exposure = "X",
    outcome = "Y",
    unobserved = "Z",
    highlight = "Z -> D"
  )
}

# A consequence of a collider: salary, a descendant of having the job
salary_dag <- function() {
  dag_plot(
    c("X -> Z", "Y -> Z", "Z -> D"),
    list(X = c(0, 1.1), Z = c(1, 0.3), Y = c(2, 1.1), D = c(2, -0.6)),
    labels = c(X = "Wealth", Z = "Job", Y = "Hard work", D = "Salary"),
    above = c("X", "Y"),
    exposure = "X",
    outcome = "Y",
    highlight = "Z -> D"
  )
}

# "A paradox inside a paradox": Berkeley with applicants' unmeasured ability
berkeley_ability_dag <- function() {
  dag_plot(
    c("S -> D", "D -> A", "S -> A", "U -> D", "U -> A"),
    list(S = c(0, 0), D = c(1, 1.1), A = c(2, 0), U = c(2, 1.1)),
    labels = c(S = "Sex", D = "Department", A = "Admitted", U = "Ability"),
    above = c("D", "U"),
    exposure = "S",
    outcome = "A",
    unobserved = "U",
    highlight = c("S -> D", "U -> D", "U -> A")
  )
}
