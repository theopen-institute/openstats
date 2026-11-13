# Step 4 of the violence deck: a simulated Nepal. Sourced by r/violence.R; the deck
# shows this file on a slide.

# Women from two kinds of group (hill origin and plains origin) living in villages,
# interviewed by teams. Every arrow in the DAGs is an argument, so each world is one
# call. Effects are in log-odds.
#
# segregation: how unevenly the two kinds of group are spread over villages. 0: every
#   village has the same mix; 1: every village is all one or all the other. (It's the
#   variance of villages' plains-origin share, as a fraction of the most it could be.)
# Interviewers come in teams of three, and each team works villages next to each other
# in a list ordered by the village's plains-origin share, the way real teams work one
# region. So a team's villages are alike, and within a village each woman gets one of
# the team's interviewers at random.
simulate_violence <- function(
  n_villages = 476,
  women_per_village = 9,
  plains_share = 0.25, # share of women from plains-origin groups
  segregation = 0.9, # about as in the DHS villages
  caste_effect = 0, # C -> V: a plains-origin woman vs a hill-origin one in the same village
  place_effect = 0, # P -> V: an all-plains village vs an all-hill one
  village_sd = 0.3, # P -> V: other differences between villages
  drunk_rate = c(0.08, 0.04), # C -> D: share of husbands often drunk, hill and plains
  drunk_effect = 2, # D -> V: husband often drunk
  report_effect = 0, # I -> R: interviewers in all-plains areas vs all-hill areas
  interviewer_sd = 0.2, # I -> R: other differences between interviewers
  baseline = 0.12, # violence for a hill woman in an all-hill village, sober husband
  villages_per_team = 24
) {
  # P: each village's plains-origin share
  share <- if (segregation >= 1) {
    rbinom(n_villages, 1, plains_share)
  } else if (segregation <= 0) {
    rep(plains_share, n_villages)
  } else {
    k <- 1 / segregation - 1
    rbeta(n_villages, plains_share * k, (1 - plains_share) * k)
  }
  village_effect <- place_effect * share + rnorm(n_villages, 0, village_sd)

  # teams work neighboring villages; their interviewers record differently
  # (centred, so the average interviewer records violence as it is)
  team <- ceiling(rank(share, ties.method = "random") / villages_per_team)
  team_share <- rep(tapply(share, team, mean), each = 3)
  interviewer_effect <- report_effect * (team_share - mean(team_share)) +
    rnorm(length(team_share), 0, interviewer_sd)

  tibble(village = rep(seq_len(n_villages), each = women_per_village)) |>
    mutate(
      share = share[village],
      plains = rbinom(n(), 1, share), # C
      group = factor(if_else(plains == 1, "Plains origin", "Hill origin")),
      mix = ave(plains, village), # the plains-origin share among the women interviewed
      drunk = rbinom(n(), 1, drunk_rate[plains + 1]), # C -> D
      interviewer = 3 * (team[village] - 1) + sample.int(3, n(), replace = TRUE),
      # V: true violence, on the log-odds scale
      place_lo = qlogis(baseline) + village_effect[village],
      true_lo = place_lo + drunk_effect * drunk,
      # ... and the chance of it if she were from either kind of group, in the same
      # village, with a typical interviewer, and with a husband as likely to be often
      # drunk as that group's husbands are
      p_hill = (1 - drunk_rate[1]) * plogis(place_lo) +
        drunk_rate[1] * plogis(place_lo + drunk_effect),
      p_plains = (1 - drunk_rate[2]) * plogis(place_lo + caste_effect) +
        drunk_rate[2] * plogis(place_lo + caste_effect + drunk_effect),
      # R: what the interviewer records
      violence = rbinom(
        n(),
        1,
        plogis(true_lo + caste_effect * plains + interviewer_effect[interviewer])
      )
    ) |>
    select(-place_lo, -true_lo)
}

# The two answers a simulated world has: the raw gap in recorded violence, and the
# true gap among women in the same village (switch each woman's group, keep her
# village and a typical interviewer; her husband drinks as her new group's do)
sim_truths <- function(sim) {
  tibble(
    raw = mean(sim$violence[sim$plains == 1]) - mean(sim$violence[sim$plains == 0]),
    same_village = mean(sim$p_plains - sim$p_hill)
  )
}
