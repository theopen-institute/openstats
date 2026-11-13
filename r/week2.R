# Plots, data and helpers for the week 2 deck. Sourced by its setup chunk, after
# r/deck-setup.R.

# The small belief curves beside the photo: {r name, opts.label = "belief"}
knitr::opts_template$set(belief = list(fig.width = 6, fig.height = 2.8))

# ---- Data for the widgets ----------------------------------------------------------
# The canvas widgets (js/sample-mean.js, conditional.js, model-builder.js) read their
# data from a JSON block on the page, written here so the numbers come from the same
# R as the plots. One line in the deck: a chunk calling adults_widget_data() or
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

# The adults for the sampling and "moving distribution" widgets, with the lines they
# draw: weight on height, and weight on sex and height (in kg and cm, the widgets' units)
adults_widget_data <- function(adults) {
  line <- coef(lm(weight ~ height, adults))
  both <- coef(lm(weight ~ male + height, adults))
  json_script("adults-data", list(
    height = round(adults$height, 1),
    weight = round(adults$weight, 1),
    male = adults$male,
    line = list(intercept = line[["(Intercept)"]], slope = line[["height"]]),
    sex_line = list(
      intercept = both[["(Intercept)"]],
      male = both[["male"]],
      slope = both[["height"]]
    ),
    sex_gap = coef(lm(weight ~ male, adults))[["male"]]
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

# ---- The opening puzzle: Nepal's earnings by education ---------------------------

# The opening puzzle's plot size: {r name, opts.label = "puzzle"}
knitr::opts_template$set(puzzle = list(fig.width = 8.5, fig.height = 6.6, out.width = "100%"))


# Rupees at 2025/26 prices per rupee at each survey's prices, from the Nepal Rastra Bank
# index. The 2008 round ran through calendar 2008, half of each of two fiscal years;
# the 2017/18 round matches its fiscal year. The index stops at 2022/23, so 2025/26 is
# chained on from it with each later year's inflation.
nepal_price_factors <- function(cpi = load_nepal_cpi()) {
  index <- set_names(cpi$cpi_index, cpi$fiscal_year)
  later <- cpi$infl_overall[is.na(cpi$cpi_index)]
  now <- index[["2022/23"]] * prod(1 + later / 100)
  c(`2008` = now / mean(index[c("2007/08", "2008/09")]), `2017` = now / index[["2017/18"]])
}

# The ILO's education levels (ISCED codes), lowest first. Grades 11–12 are coded 5
# (short-cycle tertiary) in 2008 and 4 (post-secondary, non-tertiary) in 2017/18.
NLFS_LEVELS <- c(
  "9" = "Not stated", X = "No schooling", "0" = "Pre-primary", "1" = "Primary",
  "2" = "Lower secondary", "3" = "Upper secondary", "5" = "Grades 11–12",
  "4" = "Grades 11–12", "6" = "Bachelor's", "7" = "Master's"
)

# Paid employees of both sexes by education level: year (2017 is 2017/18), level,
# employees (thousands) and average monthly earnings (thousand rupees, 2025/26 prices)
nlfs_levels <- function() {
  price <- nepal_price_factors()
  load_nlfs() |>
    filter(sex == "T", isced != "TOTAL") |>
    transmute(
      year, isced,
      level = factor(NLFS_LEVELS[isced], levels = unique(NLFS_LEVELS)),
      employees = employees_k,
      earnings = earnings_npr * price[as.character(year)] / 1000
    )
}

# Is a level post-secondary? coding "ilo": as the ILO's tables count it, with grades
# 11–12 post-secondary in 2008 and secondary in 2017/18. "same": degrees only, in both
# years.
is_post <- function(isced, year, coding) {
  isced %in% c("6", "7") | (coding == "ilo" & year == 2008 & isced == "5")
}

# Each group's average earnings and share of employees, by year, with the levels'
# averages combined by their employee counts: coding ("ilo", "same", or "all" for
# all employees), group ("secondary", "post", "all"), year, earnings, employees, share
nlfs_groups <- function(levels = nlfs_levels()) {
  grouped <- function(coding) {
    mutate(levels, coding = coding, group = case_when(
      coding == "all" ~ "all",
      is_post(isced, year, coding) ~ "post",
      .default = "secondary"
    ))
  }
  map(c("ilo", "same", "all"), grouped) |>
    list_rbind() |>
    summarize(
      earnings = weighted.mean(earnings, employees),
      employees = sum(employees),
      .by = c(coding, group, year)
    ) |>
    mutate(share = employees / sum(employees), .by = c(coding, year))
}

# 2008 to 2017/18, a row per coding and group: earnings_2008, employees_2017,
# share_2017, ..., and
# change, the real change in average earnings
nlfs_growth <- function(groups = nlfs_groups()) {
  groups |>
    pivot_wider(id_cols = c(coding, group), names_from = year, values_from = c(earnings, employees, share)) |>
    mutate(change = earnings_2017 / earnings_2008 - 1)
}

# One number from nlfs_growth(), for the text: nlfs_stat(edu, "same", "post", "share_2017")
nlfs_stat <- function(growth, coding, group, what = "change") {
  growth[[what]][growth$coding == coding & growth$group == group]
}

# Thousand rupees as rupees, to the nearest ten, the way the slides write them: "Rs 24,180"
rupees <- function(x) paste("Rs", fmt(round(1000 * x, -1), 0))

# The reclassification widget (js/reclass.js): paid employees by education level in 2008
# and 2017/18, with each level's number (thousands), average earnings (thousand rupees,
# 2025/26 prices) and group: "secondary", "post" (degrees), or "movers" (grades 11–12:
# ISCED 5 in 2008, counted as post-secondary; ISCED 4 in 2017/18, counted as secondary,
# which is inferred from those codes appearing in one round each). The tables
# give each level's average, not its spread, so the widget draws each level as a
# log-normal curve with that average and a made-up spread, RECLASS_SDLOG: the shapes
# are hypothetical.
RECLASS_SDLOG <- 0.5

reclass_widget_data <- function(levels = nlfs_levels()) {
  json_script("reclass-data", list(
    sdlog = RECLASS_SDLOG,
    levels = levels |>
      transmute(
        year, isced,
        # precise enough that the widget's averages round to the same rupees as the table
        employees = round(employees, 3),
        earnings = round(earnings, 4),
        group = case_when(
          isced %in% c("4", "5") ~ "movers",
          is_post(isced, year, "same") ~ "post",
          .default = "secondary"
        )
      )
  ))
}

# The reclassification slide's numbers. Each group's average (thousand rupees, rounded to
# the nearest ten rupees as the slides show them) in 2008 as published (y2008), 2017/18
# counted the 2008 way, with grades 11–12 still post-secondary (same), and 2017/18 as
# published (y2017): post[["same"]], secondary[["y2008"]], ... And grades 11–12 in
# 2017/18: movers (thousands of employees), and movers_share of the post-secondary
# group counted the 2008 way.
reclass_numbers <- function(levels = nlfs_levels()) {
  post <- list(y2008 = c(2008, "5", "6", "7"), same = c(2017, "4", "6", "7"), y2017 = c(2017, "6", "7"))
  average <- function(spec, in_post) {
    d <- levels[levels$year == spec[1] & (levels$isced %in% spec[-1]) == in_post, ]
    round(weighted.mean(d$earnings, d$employees), 2)
  }
  y2017 <- levels[levels$year == 2017, ]
  movers <- y2017$employees[y2017$isced == "4"]
  list(
    post = sapply(post, average, in_post = TRUE),
    secondary = sapply(post, average, in_post = FALSE),
    movers = movers,
    movers_share = movers / sum(y2017$employees[y2017$isced %in% c("4", "6", "7")])
  )
}

EDU_COLORS <- c(secondary = INK, post = BLUE, all = GRAY)
EDU_NAMES <- c(secondary = "Secondary\nor less", post = "Post-\nsecondary", all = "Both\ngroups")

# "Income in Nepal, 2008–2018": each group's real change in average earnings, 2008 to
# 2017/18, as bars, each with its average monthly earnings in both years written in it.
# everyone = FALSE leaves out all employees' bar (an empty row, so the plot doesn't
# move when it appears); with it, its change is carried up across the others. Step 2
# (a parked slide): the published bars fade, and arrows run from them to the change
# with grades 11–12 counted the same way in both years.
edu_growth_plot <- function(step, everyone = TRUE, growth = nlfs_growth()) {
  rows <- c(secondary = 3, post = 2, all = 1)
  published <- growth |>
    filter(coding %in% c("ilo", "all")) |>
    mutate(y = rows[group], color = EDU_COLORS[group])
  same <- growth |>
    filter(coding == "same") |>
    mutate(y = rows[group], color = EDU_COLORS[group], was = published$change[match(group, published$group)])
  all_change <- nlfs_stat(growth, "all", "all")
  if (!everyone) published <- filter(published, group != "all")
  label <- function(x) paste0("+", round(100 * x), "%")
  fade <- step >= 2 & published$group != "all"
  names <- EDU_NAMES[names(rows)]
  if (!everyone) names[["all"]] <- ""

  p <- ggplot() +
    geom_rect(
      data = published,
      aes(xmin = 0, xmax = change, ymin = y - 0.3, ymax = y + 0.3,
          fill = I(if_else(fade, tint(color, 0.25), color)))
    ) +
    geom_text(
      data = published, aes(change, y, label = label(change), color = I(if_else(fade, GRAY, color))),
      hjust = -0.15, size = if_else(fade, 7, 9), fontface = "bold"
    ) +
    geom_text(
      data = filter(published, !fade),
      aes(0.015, y, label = paste(rupees(earnings_2008), "→", rupees(earnings_2017))),
      hjust = 0, size = 6.5, fontface = "bold", color = "white"
    )
  if (everyone) {
    p <- p + annotate(
      "segment", x = all_change, xend = all_change, y = 1.3, yend = 3.3,
      color = INK, linetype = "dashed", linewidth = 0.9
    )
  }
  if (step >= 2) {
    p <- p +
      geom_segment(
        data = same, aes(x = was, xend = change, y = y, yend = y, color = I(color)),
        linewidth = 1.4, arrow = arrow(length = unit(0.14, "inches"), type = "closed")
      ) +
      geom_point(data = same, aes(change, y, color = I(color)), size = 6) +
      geom_text(
        data = same, aes(change, y + 0.3, label = label(change), color = I(color)),
        hjust = 0.1, vjust = -0.35, size = 9, fontface = "bold"
      )
  }
  p +
    scale_x_continuous(
      limits = c(0, 0.85), breaks = seq(0, 0.8, 0.2), labels = \(x) paste0(100 * x, "%"),
      expand = expansion(0)
    ) +
    scale_y_continuous(breaks = rows, labels = names, limits = c(0.6, 3.85)) +
    labs(x = "Change in average monthly earnings, after inflation", y = NULL) +
    theme(panel.grid.major.y = element_blank(), panel.grid.minor = element_blank())
}

# ---- Part 1: population distributions ----------------------------------------------

# A dashed vertical line at x, labelled at the top of the plot. line = FALSE gives
# just the label. Smaller vjust puts the label higher; left = TRUE puts it left of the
# line.
value_marker <- function(x, label, color, vjust = 1.5, line = TRUE, left = FALSE) {
  list(
    if (line) geom_vline(xintercept = x, color = color, linewidth = 1.2, linetype = "dashed"),
    annotate(
      "text",
      x = x,
      y = Inf,
      vjust = vjust,
      hjust = if (left) 1.05 else -0.05,
      size = 7,
      color = color,
      label = label
    )
  )
}

# "What does income look like?": monthly incomes in six imagined places, in the style
# of the named shapes (shape_panel(), below), all on one axis and untitled (the deck
# names each place when it describes it). Made up, not data. In row order: three
# countries (typical, then more and less equal), then three places with a story in
# their shape. The share paid exactly the minimum wage is a solid bar, as tall as a bar
# of that share would be in a 2,000-rupee-wide histogram.
income_shape_plots <- function() {
  x <- seq(0, 100, length.out = 501)
  axis <- scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 25))
  panel <- function(y, ...) shape_panel(x, y, NULL, NULL, NULL, axis, ...)
  minimum <- 17 # the floor, in thousand Rs (Nepal's was Rs 17,300 a month in 2023)
  # The countries share their most common income (a log-normal's peak is at
  # exp(meanlog - sdlog^2)) and differ only in spread
  country <- function(spread) dlnorm(x, log(15) + spread^2, spread)

  list(
    panel(country(0.5)), # a typical country
    panel(country(0.25)), # a more equal country
    panel(country(0.8)), # a very unequal country
    panel(dnorm(x, 40, 4)), # one pay scale
    panel(0.6 * dnorm(x, 15, 5) + 0.4 * dnorm(x, 55, 10)), # farms and offices
    panel(
      if_else(x > minimum + 2, 0.8 * dexp(x - minimum - 2, 1 / 12), 0), # a minimum wage
      annotate("rect", xmin = minimum, xmax = minimum + 2, ymin = 0, ymax = 0.2 / 2, fill = BLUE)
    )
  )
}

# Every histogram of the adults' heights has the same bars: 2 cm wide, each from half a
# centimeter below an even one. STEPS measured heights to the whole centimeter, so each
# bar holds two whole centimeters (1 cm bars would show every lump of rounding).
HEIGHT_BIN <- 2
HEIGHT_EDGE <- -0.5 # one bar edge; the others are whole bars away
height_bars <- function(...) {
  geom_histogram(binwidth = HEIGHT_BIN, boundary = HEIGHT_EDGE, color = "white", ...)
}
# The bar an adult falls in, numbered from HEIGHT_EDGE
height_bar <- function(height) floor((height - HEIGHT_EDGE) / HEIGHT_BIN)
# The heights the plots show (leaving out the 9 adults below 129.5 or above 187.5 cm),
# and the count axis of "Describing distributions" (sex_humps_widget_data(),
# js/sex-humps.js)
HEIGHT_XLIM <- c(129.5, 187.5)
height_ylim <- function(adults) c(0, 1.25 * max(table(height_bar(adults$height))))

# "The Normal distribution": each sex's heights in its own panel, women then men, each
# with the Normal of its own mean and SD, its mean dashed, and both numbers in the
# panel's title. bands = TRUE shades each curve within 1 and 2 SD of its mean, with the
# Normal's 68% and 95% above. Both versions share their y range, so the bars don't move
# when the bands appear.
normal_overlay_plot <- function(adults, bands = FALSE) {
  colors <- c(female = RED, male = BLUE)
  sexes <- adults |>
    group_by(sex) |>
    summarize(m = mean(height), s = sd(height)) |>
    mutate(
      peak = dnorm(m, m, s),
      title = paste0(
        if_else(sex == "female", "Women", "Men"),
        ": mean ", fmt(m), " cm, SD ", fmt(s), " cm"
      )
    )
  curves <- expand_grid(sexes, x = seq(HEIGHT_XLIM[1], HEIGHT_XLIM[2], by = 0.05)) |>
    mutate(y = dnorm(x, m, s))
  band <- function(k, alpha) {
    geom_area(
      data = filter(curves, abs(x - m) <= k * s),
      aes(x, y, fill = sex),
      alpha = alpha
    )
  }
  bracket <- function(k, height, label) {
    at <- mutate(sexes, y = height * peak)
    list(
      geom_segment(
        data = at,
        aes(x = m - k * s, xend = m + k * s, y = y, yend = y, color = sex),
        linewidth = 1,
        arrow = arrow(ends = "both", length = unit(0.1, "inches"))
      ),
      geom_label(
        data = at,
        aes(m, y, color = sex),
        label = label, vjust = -0.35, size = 6.5, fill = "white", linewidth = 0
      )
    )
  }

  shading <- if (bands) list(band(2, 0.2), band(1, 0.3))
  brackets <- if (bands) {
    list(bracket(1, 1.12, "68% within 1 SD"), bracket(2, 1.38, "95% within 2 SD"))
  }

  ggplot(adults, aes(height)) +
    height_bars(aes(y = after_stat(density)), fill = tint(GRAY, 0.45)) +
    shading +
    geom_line(data = curves, aes(x, y, color = sex), linewidth = 1.5) +
    geom_vline(data = sexes, aes(xintercept = m, color = sex), linewidth = 1.2, linetype = "dashed") +
    brackets +
    facet_wrap(~sex, labeller = as_labeller(setNames(sexes$title, sexes$sex))) +
    scale_color_manual(values = colors, guide = "none") +
    scale_fill_manual(values = colors, guide = "none") +
    scale_x_continuous(breaks = seq(140, 180, 10)) +
    scale_y_continuous(expand = expansion(mult = c(0, 0))) +
    coord_cartesian(xlim = HEIGHT_XLIM, ylim = c(0, 1.6 * max(sexes$peak))) +
    labs(x = "Height (cm)", y = NULL) +
    theme(axis.text.y = element_blank(), panel.spacing.x = unit(3, "lines"))
}

# The share of one sex's heights (male = 0 or 1) within k SDs of that sex's mean
within_sd <- function(adults, male, k) {
  h <- adults$height[adults$male == male]
  mean(abs(h - mean(h)) < k * sd(h))
}

# "Describing distributions": the adults' heights for js/sex-humps.js, in the same bars
# as the plots: each bar's left edge and its women and men (the bars in view), each
# sex's mean and SD (for its Normal) and number (all of them), and the axes' ranges
sex_humps_widget_data <- function(adults) {
  bar <- height_bar(adults$height)
  bars <- seq(height_bar(HEIGHT_XLIM[1]), height_bar(HEIGHT_XLIM[2]) - 1)
  count <- function(m) as.vector(table(factor(bar[adults$male == m], levels = bars)))
  normal <- function(m) {
    h <- adults$height[adults$male == m]
    list(mean = mean(h), sd = sd(h), n = length(h))
  }
  ylim <- height_ylim(adults)
  json_script("sex-humps-data", list(
    width = HEIGHT_BIN,
    left = HEIGHT_EDGE + bars * HEIGHT_BIN,
    women = count(0),
    men = count(1),
    normals = list(women = normal(0), men = normal(1)),
    xlim = HEIGHT_XLIM,
    ylim = ylim,
    ystep = diff(pretty(ylim))[1] # the count axis's ticks
  ))
}

# "Taller or heavier?" and "Same data, new ruler": the man js/z-compare.js and
# js/z-ruler.js mark (they read the adults themselves, from adults_widget_data())
zscore_widget_data <- function(height, weight) {
  json_script("zscore-data", list(person = list(height = height, weight = weight)))
}

# ---- Part 1, the end: shapes that tell stories -------------------------------------

# Each age's share of a population (%), from load_nepal_ages() or load_japan_ages():
# Nepal's residents only
age_shares <- function(ages) {
  if ("status" %in% names(ages)) ages <- filter(ages, status == "resident")
  ages |>
    count(age, wt = people, name = "people") |>
    mutate(share = 100 * people / sum(people))
}

# The median age: the first age at which age_shares() add up to half the people
median_age <- function(shares) shares$age[which(cumsum(shares$share) >= 50)[1]]

# Ages that collect people who round their age: ages ending in 0 or 5, from 30 on
# (below 30, Nepal's ages ending in 0 and 5 don't stand out)
rounded_age <- function(age) age >= 30 & age %% 5 == 0

# "Nepal, age by age": the share of residents at each age. spikes = TRUE picks out the
# ages ending in 0 or 5.
nepal_age_plot <- function(nepal, spikes = FALSE) {
  d <- age_shares(nepal) |>
    filter(age <= 90) |>
    mutate(fill = case_when(!spikes ~ "age", rounded_age(age) ~ "rounded", TRUE ~ "other"))

  p <- ggplot(d, aes(age, share, fill = fill)) +
    geom_col(width = 0.85, show.legend = FALSE) +
    scale_fill_manual(values = c(age = BLUE, other = tint(BLUE, 0.4), rounded = RED)) +
    scale_x_continuous(breaks = seq(0, 90, 10)) +
    scale_y_continuous(labels = ~ paste0(.x, "%"), expand = expansion(mult = c(0, 0.08))) +
    labs(x = "Age", y = "Share of residents")
  if (spikes) {
    p <- p +
      annotate(
        "text",
        x = 90, y = max(d$share) * 0.95,
        label = "ages ending in 0 or 5",
        color = RED, size = 8, fontface = "bold", hjust = 1
      )
  }
  p
}

# "Two countries, two stories": the share of each country's people at each age, Nepal
# above Japan, with Japan's generations labelled (and 1966, the "fire horse" year). Ages
# run to 90 (Japan's 100 is 100 and over).
age_compare_plot <- function(nepal, japan) {
  countries <- c("Nepal, 2022/23", "Japan, 2022")
  d <- bind_rows(
    age_shares(nepal) |> mutate(country = countries[1]),
    age_shares(japan) |> mutate(country = countries[2])
  ) |>
    filter(age <= 90) |>
    mutate(country = factor(country, levels = countries))
  # Japan's generations, by the age they were on 1 July 2022
  japan_notes <- tibble(
    country = factor(countries[2], levels = countries),
    age = c(48.5, 73.5, 55.5),
    label = c("second baby boom\n(born 1971–74)", "baby boom\n(born 1947–49)", "1966"),
    y = c(2.25, 2.25, 1.6)
  )

  ggplot(d, aes(age, share)) +
    geom_col(fill = BLUE, width = 0.85) +
    geom_text(
      data = japan_notes,
      aes(y = y, label = label),
      color = INK,
      size = 6,
      lineheight = 0.9,
      vjust = 0
    ) +
    facet_wrap(~country, ncol = 1) +
    scale_x_continuous(breaks = seq(0, 90, 10)) +
    scale_y_continuous(labels = ~ paste0(.x, "%"), breaks = c(0, 1, 2)) +
    coord_cartesian(ylim = c(0, 2.9)) +
    labs(x = "Age", y = "Share of people") +
    theme(strip.text = element_text(hjust = 0))
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

# ---- Part 2, the named shapes ------------------------------------------------------
# Each named-shapes slide is a grid of small plots, one per family, laid out by the
# chunk: {r name, opts.label = "shapes"} with the option line #| layout-ncol: 3
knitr::opts_template$set(shapes = list(fig.width = 5, fig.height = 3))

# One small plot of a named distribution: its curve (or bars, for a count) over x, a
# title and subtitle, and what x measures. `...` adds layers (an x scale).
shape_panel <- function(x, y, title, subtitle, xlab, ..., color = BLUE, discrete = FALSE) {
  shape <- if (discrete) {
    geom_col(fill = color, width = 0.7)
  } else {
    geom_area(fill = tint(color, 0.3), color = color, linewidth = 1.2)
  }

  ggplot(tibble(x, y), aes(x, y)) +
    shape +
    list(...) +
    labs(title = title, subtitle = subtitle, x = xlab, y = NULL) +
    theme(
      axis.text.y = element_blank(),
      panel.grid.major.y = element_blank(),
      plot.subtitle = element_text(color = INK, margin = margin(b = 10))
    )
}

# "Every named distribution is a story": six families, each drawn for an everyday
# example. Population distributions, so blue. The heights use the adults' mean and
# SD; the other knobs are made up (the earnings use the opening's log-normal spread,
# RECLASS_SDLOG).
named_shape_plots <- function(adults) {
  h_mean <- mean(adults$height)
  h_sd <- sd(adults$height)
  heights <- seq(h_mean - 3.5 * h_sd, h_mean + 3.5 * h_sd, length.out = 301)
  earnings <- seq(0, 50, length.out = 301)
  minutes <- seq(0, 40, length.out = 301)
  shares <- seq(0, 1, length.out = 301)

  list(
    shape_panel(
      heights, dnorm(heights, h_mean, h_sd),
      "Normal", "small pushes, added up", "Height of an adult (cm)"
    ),
    shape_panel(
      earnings, dlnorm(earnings, log(15), RECLASS_SDLOG),
      "Log-normal", "small pushes, multiplied", "Monthly earnings (thousand Rs)"
    ),
    shape_panel(
      minutes, dexp(minutes, 1 / 10),
      "Exponential", "waiting for it to happen", "Minutes until the next bus"
    ),
    shape_panel(
      0:20, dbinom(0:20, 20, 0.3),
      "Binomial", "yeses out of n tries", "Of 20 asked, how many say \"mayor\"",
      discrete = TRUE
    ),
    shape_panel(
      0:12, dpois(0:12, 3),
      "Poisson", "counting, with no maximum", "Births in a day at a health post",
      discrete = TRUE, scale_x_continuous(breaks = seq(0, 12, 3))
    ),
    shape_panel(
      shares, dbeta(shares, 8, 4),
      "Beta", "a share, between 0 and 1", "Share of adults who can read",
      scale_x_continuous(labels = scales::label_percent())
    )
  )
}

# "The same shapes, for certainty": a prior for each kind of unknown, in green. β and σ
# are the priors behind beta_posterior() in Part 3. Each subtitle gives the 95% range.
certainty_shape_plots <- function() {
  shares <- seq(0, 1, length.out = 301)
  betas <- seq(-3.5, 3.5, length.out = 301)
  sigmas <- seq(0, 5, length.out = 301)
  share_range <- qbeta(c(0.025, 0.975), 3, 7)

  list(
    shape_panel(
      shares, dbeta(shares, 3, 7),
      "θ ~ Beta(3, 7)", paste0("a share: ", pct(share_range[1]), " to ", pct(share_range[2])),
      "The mayor's vote share",
      color = GREEN, scale_x_continuous(labels = scales::label_percent())
    ),
    shape_panel(
      betas, dnorm(betas, 0, 1),
      "β ~ Normal(0, 1)", "a coefficient: within ±2", "β (SD per SD)",
      color = GREEN
    ),
    shape_panel(
      sigmas, dexp(sigmas, 1),
      "σ ~ Exponential(1)", paste("a spread: below", fmt(qexp(0.95, 1), 0)),
      "σ (in SDs)",
      color = GREEN
    )
  )
}

# ---- Part 3: correlative distributions ---------------------------------------------

# "Standardize both variables": height and weight in z-scores, colored by whether
# each person's two z-scores agree in sign
# The z-score scatterplots' axes: z-scores on the bottom and left, labeled as such, and
# the same scales back in centimeters (top) and kilograms (right), in gray
z_axes <- function(adults) {
  h <- c(mean(adults$height), sd(adults$height))
  w <- c(mean(adults$weight), sd(adults$weight))
  list(
    scale_x_continuous(
      "Height (z-score)",
      breaks = -3:3,
      sec.axis = sec_axis(~ h[1] + .x * h[2], name = "cm", breaks = seq(130, 190, 10))
    ),
    scale_y_continuous(
      "Weight (z-score)",
      breaks = -3:3,
      sec.axis = sec_axis(~ w[1] + .x * w[2], name = "kg", breaks = seq(30, 90, 10))
    ),
    theme(
      axis.title.x.top = element_text(color = GRAY),
      axis.text.x.top = element_text(color = GRAY),
      axis.title.y.right = element_text(color = GRAY),
      axis.text.y.right = element_text(color = GRAY)
    )
  )
}

agreement_plot <- function(adults) {
  quad_labels <- tibble(
    x = c(3.4, -3.4, -3.4, 3.4),
    y = c(2.6, -2.6, 2.6, -2.6),
    hjust = c(1, 0, 0, 1), # each label in its own quadrant's outer corner
    label = c(
      "taller &\nheavier (+)",
      "shorter &\nlighter (+)",
      "shorter &\nheavier (−)",
      "taller &\nlighter (−)"
    ),
    color = c(BLUE, BLUE, RED, RED)
  )

  adults |>
    mutate(agree = if_else(z_height * z_weight > 0, "agree", "disagree")) |>
    ggplot(aes(z_height, z_weight)) +
    geom_hline(yintercept = 0, color = GRAY) +
    geom_vline(xintercept = 0, color = GRAY) +
    geom_point(aes(color = agree), alpha = 0.3, size = 1.3, show.legend = FALSE) +
    geom_label(
      data = quad_labels,
      aes(x, y, label = label, hjust = hjust),
      color = quad_labels$color,
      size = 6,
      fontface = "bold",
      lineheight = 0.9,
      fill = "white",
      linewidth = 0
    ) +
    scale_color_manual(values = c(agree = BLUE, disagree = RED)) +
    z_axes(adults) +
    coord_equal(xlim = c(-3.5, 3.5), ylim = c(-3, 3))
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
# one of them the correlation r (blue, as in the next slide)
candidate_lines_plot <- function(adults, r) {
  candidates <- tibble(
    beta = c(0, round(r, 2), 1, 1.5),
    label = paste0("β = ", beta),
    color = c(ORANGE, BLUE, TEAL, RED)
  )

  ggplot(adults, aes(z_height, z_weight)) +
    geom_point(color = GRAY, alpha = 0.25, size = 1.2) +
    geom_abline(
      data = candidates,
      aes(slope = beta, intercept = 0, color = label),
      linewidth = 1.4
    ) +
    scale_color_manual(values = set_names(candidates$color, candidates$label), name = NULL) +
    z_axes(adults) +
    coord_equal(xlim = c(-3, 3), ylim = c(-3, 3)) +
    theme(legend.text = element_text(size = 20))
}

# "The best line": the line with slope r, and the misses from it of a random `n`
# adults (all of them would be a wall of red), over everyone, faint
residuals_plot <- function(adults, r, n = 200) {
  set.seed(5)
  some <- slice_sample(adults, n = n) |> mutate(fitted = r * z_height)
  ggplot(adults, aes(z_height, z_weight)) +
    geom_point(color = GRAY, alpha = 0.15, size = 1.2) +
    geom_segment(data = some, aes(xend = z_height, yend = fitted), color = RED, alpha = 0.6) +
    geom_point(data = some, color = INK, size = 1.8) +
    geom_abline(slope = r, intercept = 0, color = BLUE, linewidth = 1.5) +
    z_axes(adults) +
    coord_equal(xlim = c(-3, 3), ylim = c(-3, 3))
}

# Posterior of beta in z_weight ~ Normal(beta * z_height, sigma), by grid
# approximation over (beta, sigma) with sigma then summed out. Priors:
# beta ~ Normal(0, 1), sigma ~ Exponential(1). The likelihood needs only three sums
# (the data's sufficient statistics), so the grid can be fine enough for thousands of
# adults, whose posterior is narrow.
beta_posterior <- function(d) {
  n <- nrow(d)
  sxx <- sum(d$z_height^2)
  sxy <- sum(d$z_height * d$z_weight)
  syy <- sum(d$z_weight^2)
  expand_grid(
    beta = seq(-0.5, 1.5, by = 0.001),
    sigma = seq(0.2, 1.5, by = 0.001)
  ) |>
    mutate(
      misses = syy - 2 * beta * sxy + beta^2 * sxx, # sum of squared misses
      log_post = -n * log(sigma) - misses / (2 * sigma^2) +
        dnorm(beta, 0, 1, log = TRUE) +
        dexp(sigma, 1, log = TRUE),
      post = exp(log_post - max(log_post))
    ) |>
    group_by(beta) |>
    summarise(post = sum(post)) |>
    mutate(post = post / sum(post) / (beta[2] - beta[1]))
}

# "How sure are we about β?": the posterior of β from 20 random adults, and from
# everyone, in SDs (bottom) and back in kg per cm (top). Certainty distributions, so
# green: lighter for the smaller sample. Each curve is scaled to the same peak: at
# their true heights, everyone's would be a spike and the 20 adults' a flat line.
beta_posterior_plot <- function(adults) {
  set.seed(7)
  small <- slice_sample(adults, n = 20)
  labels <- c("20 adults", paste(fmt(nrow(adults), 0), "adults"))
  per_cm <- sd(adults$weight) / sd(adults$height)

  bind_rows(
    beta_posterior(small) |> mutate(data = labels[1]),
    beta_posterior(adults) |> mutate(data = labels[2])
  ) |>
    group_by(data) |>
    mutate(post = post / max(post)) |>
    ungroup() |>
    mutate(data = factor(data, levels = labels)) |>
    ggplot(aes(beta, post, color = data, fill = data)) +
    geom_area(alpha = 0.15, position = "identity", linewidth = 1.5) +
    scale_color_manual(values = c(tint(GREEN, 0.45), GREEN), name = NULL) +
    scale_fill_manual(values = c(tint(GREEN, 0.45), GREEN), name = NULL) +
    scale_x_continuous(
      "β (SDs of weight per SD of height)",
      breaks = seq(-0.5, 1.5, 0.25),
      sec.axis = sec_axis(~ .x * per_cm, name = "kg per cm", breaks = seq(-0.5, 2, 0.25))
    ) +
    labs(y = "Plausibility") +
    theme(
      axis.text.y = element_blank(),
      axis.title.x.top = element_text(color = GRAY),
      axis.text.x.top = element_text(color = GRAY)
    )
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

# The coefficients the "Do men weigh more?" slides quote, fit in z-scores (weight and
# height standardized, sex 0 for women and 1 for men), with 90% intervals: sex on its
# own (total), sex once height is in the model (direct), height's slope in that model,
# and how much taller the men are, all in SDs. `kg` has the same numbers back in kg and
# cm. (total = height_gap × slope + direct, in either units.)
sex_weight_fits <- function(adults) {
  w_sd <- sd(adults$weight)
  h_sd <- sd(adults$height)
  z <- mutate(adults, z_weight = standardize(weight), z_height = standardize(height))
  alone <- lm(z_weight ~ male, z)
  both <- lm(z_weight ~ male + z_height, z)
  ci <- confint(both, level = 0.9)
  fits <- list(
    total = coef(alone)[["male"]],
    direct = coef(both)[["male"]],
    direct_lo = ci["male", 1],
    direct_hi = ci["male", 2],
    slope = coef(both)[["z_height"]],
    height_gap = coef(lm(z_height ~ male, z))[["male"]]
  )
  c(fits, list(
    kg = list(
      total = fits$total * w_sd,
      direct = fits$direct * w_sd,
      direct_lo = fits$direct_lo * w_sd,
      direct_hi = fits$direct_hi * w_sd,
      slope = fits$slope * w_sd / h_sd, # kg per cm
      height_gap = fits$height_gap * h_sd, # cm
      through_height = fits$height_gap * fits$slope * w_sd
    ),
    weight_women = mean(adults$weight[adults$male == 0]),
    weight_men = mean(adults$weight[adults$male == 1])
  ))
}

# "Do men weigh more?": the women's and men's weights, with each group's average
sex_weight_plot <- function(adults) {
  means <- adults |>
    group_by(sex) |>
    summarise(weight = mean(weight))

  ggplot(adults, aes(weight, fill = sex)) +
    geom_histogram(binwidth = 2, boundary = 0, position = "identity", alpha = 0.55, color = "white") +
    geom_vline(data = means, aes(xintercept = weight, color = sex), linewidth = 1.4) +
    scale_fill_manual(values = c(female = RED, male = BLUE), name = NULL) +
    scale_color_manual(values = c(female = RED, male = BLUE), guide = "none") +
    coord_cartesian(xlim = c(25, 110)) +
    labs(x = "Weight (kg)", y = "Number of adults")
}

# "Add height, and sex shrinks": sex works on weight mostly through height. The direct
# arrow carries a little, too.
sex_path_dag <- function() {
  pipe_dag(
    "S", "H", "W",
    labels = c(S = "Sex", H = "Height", W = "Weight"),
    direct = TRUE,
    highlight = c("S -> H", "H -> W", "S -> W")
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
