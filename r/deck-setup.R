# Shared setup for the slide decks. Each deck's setup chunk is just:
#   source("r/deck-setup.R")
# plus any packages and data that deck alone needs.

library(tidyverse)
source("r/rlib.R")
source("r/data.R")

knitr::opts_chunk$set(
  echo = FALSE,
  warning = FALSE,
  message = FALSE,
  fig.width = 12,
  fig.height = 6.5,
  dpi = 150,
  dev.args = list(bg = "transparent") # let the slide background show through
)

theme_set(
  theme_minimal(base_size = 22) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", color = INK),
      legend.position = "top"
    )
)
