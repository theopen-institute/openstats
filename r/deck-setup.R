# Shared setup for the slide decks. Each deck's setup chunk is:
#   source("r/deck-setup.R")
#   source("r/weekN.R")   # that deck's plot helpers, if it has any
#   source("r/stan.R")    # if it fits Stan models
# plus the data that deck alone needs.

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

# Figure sizes for the usual slide layouts: {r name, opts.label = "half"}
knitr::opts_template$set(
  half = list(fig.width = 7, fig.height = 5.5), # a plot in one of two columns
  dag_half = list(fig.width = 7, fig.height = 4.5), # a DAG in one of two columns
  dag_side = list(fig.width = 6, fig.height = 4.5), # a DAG beside a column of text
  dag_third = list(fig.width = 5, fig.height = 4) # a DAG in one of three columns
)

theme_set(
  theme_minimal(base_size = 22) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", color = INK),
      strip.text = element_text(size = 20, face = "bold"), # facet titles
      legend.position = "top"
    )
)
