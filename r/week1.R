# Plots for the week 1 deck. Sourced by its setup chunk, after r/deck-setup.R.

# "Counting the ways a thing could happen": the garden of forking paths for n coin
# flips, with the paths that end in exactly `target` heads drawn in blue.
# Ring k holds the 2^k ways the first k flips could go. Node j on ring k sits at
# angle pi * (1 - (j + 0.5) / 2^k), which puts each node midway between its children.
garden_plot <- function(n = 4, target = 2) {
  nodes <- do.call(
    rbind,
    lapply(0:n, function(k) {
      j <- 0:(2^k - 1)
      heads <- if (k == 0) {
        0
      } else {
        vapply(j, function(x) sum(bitwAnd(x, 2^(0:(k - 1))) == 0), numeric(1))
      }
      data.frame(
        k = k,
        j = j,
        flip = if (k == 0) "" else ifelse(bitwAnd(j, 1) == 0, "H", "T"),
        heads = heads,
        theta = pi * (1 - (j + 0.5) / 2^k)
      )
    })
  )
  nodes$x <- nodes$k * cos(nodes$theta)
  nodes$y <- -nodes$k * sin(nodes$theta) # start at the top, fanning down
  # on a path that can still end in exactly `target` heads
  nodes$live <- nodes$heads <= target & nodes$heads + (n - nodes$k) >= target

  kids <- nodes[nodes$k > 0, ]
  parent <- match(paste(kids$k - 1, kids$j %/% 2), paste(nodes$k, nodes$j))
  edges <- data.frame(
    x = nodes$x[parent],
    y = nodes$y[parent],
    xend = kids$x,
    yend = kids$y,
    live = kids$live
  )
  leaves <- nodes[nodes$k == n, ]
  label_r <- n + 0.68 # radius of the head counts, just outside the last ring

  rings <- do.call(
    rbind,
    lapply(1:n, function(k) {
      t <- seq(0, pi, length.out = 200)
      data.frame(k = k, x = k * cos(t), y = -k * sin(t))
    })
  )

  ggplot() +
    geom_path(
      data = rings,
      aes(x, y, group = k),
      color = tint(INK, 0.1),
      linewidth = 0.8,
      linetype = "dashed"
    ) +
    geom_segment(
      data = edges[!edges$live, ],
      aes(x, y, xend = xend, yend = yend),
      color = tint(INK, 0.16),
      linewidth = 1.2
    ) +
    geom_segment(
      data = edges[edges$live, ],
      aes(x, y, xend = xend, yend = yend),
      color = BLUE,
      linewidth = 1.8
    ) +
    geom_point(data = nodes[nodes$k == 0, ], aes(x, y), size = 4, color = INK) +
    geom_point(
      data = nodes[nodes$k > 0, ],
      aes(x, y, fill = flip, alpha = live),
      shape = 21,
      size = 12,
      color = INK,
      stroke = 1.2
    ) +
    geom_text(
      data = nodes[nodes$k > 0, ],
      aes(x, y, label = flip, color = flip, alpha = live),
      size = 5.6,
      fontface = "bold"
    ) +
    geom_text(
      data = leaves,
      aes(label_r * cos(theta), -label_r * sin(theta), label = heads),
      color = ifelse(leaves$heads == target, BLUE, tint(INK, 0.32)),
      fontface = ifelse(leaves$heads == target, "bold", "plain"),
      size = 8.5
    ) +
    annotate(
      "text",
      x = -(1:n),
      y = 0.38,
      label = c("1st", "2nd", "3rd", "4th", paste0(5:12, "th"))[1:n],
      color = GRAY,
      size = 6.5
    ) +
    annotate("text", x = label_r, y = 0.38, label = "heads", color = GRAY, size = 6.5) +
    scale_fill_manual(values = c(H = INK, T = "white"), guide = "none") +
    scale_color_manual(values = c(H = "white", T = INK), guide = "none") +
    scale_alpha_manual(values = c(`TRUE` = 1, `FALSE` = 0.3), guide = "none") +
    coord_fixed(
      xlim = c(-n - 1.2, n + 1.2),
      ylim = c(-n - 1.05, 0.65),
      expand = FALSE
    ) +
    theme_void()
}

# "Step 2: The likelihood": P( k of n | θ ) for every θ, with a few values marked
likelihood_plot <- function(n, k, marks) {
  ggplot() +
    stat_function(
      fun = function(x) dbinom(k, n, x),
      xlim = c(0, 1),
      n = 501,
      color = BLUE,
      linewidth = 1.5
    ) +
    annotate(
      "segment",
      x = marks,
      xend = marks,
      y = 0,
      yend = dbinom(k, n, marks),
      linetype = "dashed",
      color = GRAY
    ) +
    annotate("point", x = marks, y = dbinom(k, n, marks), color = BLUE, size = 4) +
    scale_x_continuous(labels = scales::label_percent()) +
    labs(
      x = "θ (share voting for the mayor)",
      y = paste0("P( ", k, " of ", n, " | θ )")
    )
}
