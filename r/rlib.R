library(rlang)

replace_indexes <- function(tbl, data, ...) {
  specs <- rlang::enquos(...)
  factor_levels <- lapply(data, levels)

  parse_spec <- function(q) {
    expr <- rlang::get_expr(q)

    if (rlang::is_symbol(expr)) {
      return(list(var = rlang::as_string(expr), dims = NULL))
    }

    if (rlang::is_call(expr, "[")) {
      var <- rlang::as_string(expr[[2]])
      dims <- vapply(as.list(expr)[-c(1, 2)], rlang::as_string, character(1))
      return(list(var = var, dims = dims))
    }

    stop("Invalid specification")
  }

  parsed <- lapply(specs, parse_spec)
  out <- tbl

  for (p in parsed) {
    var <- p$var
    dims <- p$dims
    if (is.null(dims)) {
      next
    }

    idx_pattern <- paste(rep("(\\d+)", length(dims)), collapse = ",")
    full_pattern <- paste0("^", var, "\\[", idx_pattern, "\\]$")

    out$variable <- vapply(
      out$variable,
      function(v) {
        if (!grepl(paste0("^", var, "\\["), v)) {
          return(v)
        }

        m <- stringr::str_match(v, full_pattern)
        if (all(is.na(m))) {
          return(v)
        }

        idx <- as.integer(m[1, -1])

        labels <- Map(
          function(dim, i) {
            lvls <- factor_levels[[dim]]
            if (is.null(lvls) || i > length(lvls)) {
              return(NA_character_)
            }
            lvls[i]
          },
          dims,
          idx
        )

        paste0(var, "[", paste(unlist(labels), collapse = ","), "]")
      },
      character(1)
    )
  }

  out
}

# Draw a DAG as a ggplot: a circle per variable, an arrow per direct cause.
#   edges:      c("S -> H", "H -> W")
#   pos:        list(S = c(0, 0), H = c(1, 1), W = c(2, 0))
#   labels:     full names drawn beside each node, e.g. c(S = "Sex")
#   above:      nodes whose label goes above the circle instead of below
#   left, right: nodes whose label goes beside the circle instead
#   highlight:  edges to draw in red (e.g. one path); the rest fade to gray
#   exposure, outcome, unobserved: node names to style
dag_plot <- function(
  edges,
  pos,
  labels = NULL,
  above = NULL,
  left = NULL,
  right = NULL,
  highlight = NULL,
  exposure = NULL,
  outcome = NULL,
  unobserved = NULL,
  r = 0.3,
  text_size = 9
) {
  ink <- "#16314d"
  blue <- "#1b91ff"
  red <- "#ff2c2d"
  gray <- "#999999"

  nodes <- tibble::tibble(
    name = names(pos),
    x = vapply(pos, `[`, numeric(1), 1),
    y = vapply(pos, `[`, numeric(1), 2)
  )
  nodes$fill <- ifelse(
    nodes$name %in% exposure,
    blue,
    ifelse(nodes$name %in% outcome, ink, "white")
  )
  nodes$text <- ifelse(nodes$fill == "white", ink, "white")
  nodes$linetype <- ifelse(nodes$name %in% unobserved, "dashed", "solid")
  nodes$label <- if (is.null(labels)) "" else unname(labels[nodes$name])
  nodes$label[is.na(nodes$label)] <- ""
  nodes$label_y <- ifelse(nodes$name %in% above, nodes$y + r + 0.12, nodes$y - r - 0.12)
  nodes$vjust <- ifelse(nodes$name %in% above, 0, 1)
  nodes$label_x <- nodes$x
  nodes$hjust <- 0.5
  side <- nodes$name %in% left
  nodes$label_x[side] <- nodes$x[side] - r - 0.12
  nodes$hjust[side] <- 1
  side <- nodes$name %in% right
  nodes$label_x[side] <- nodes$x[side] + r + 0.12
  nodes$hjust[side] <- 0
  side <- nodes$name %in% c(left, right)
  nodes$label_y[side] <- nodes$y[side]
  nodes$vjust[side] <- 0.5

  circles <- do.call(rbind, lapply(seq_len(nrow(nodes)), function(i) {
    t <- seq(0, 2 * pi, length.out = 61)
    data.frame(
      name = nodes$name[i],
      x = nodes$x[i] + r * cos(t),
      y = nodes$y[i] + r * sin(t),
      fill = nodes$fill[i],
      linetype = nodes$linetype[i]
    )
  }))

  # Arrows run between circle edges, not centers
  ends <- strsplit(gsub("\\s", "", edges), "->")
  from <- vapply(ends, `[`, character(1), 1)
  to <- vapply(ends, `[`, character(1), 2)
  x0 <- nodes$x[match(from, nodes$name)]
  y0 <- nodes$y[match(from, nodes$name)]
  x1 <- nodes$x[match(to, nodes$name)]
  y1 <- nodes$y[match(to, nodes$name)]
  len <- sqrt((x1 - x0)^2 + (y1 - y0)^2)
  gap <- r + 0.04
  arrows <- data.frame(
    x = x0 + (x1 - x0) * gap / len,
    y = y0 + (y1 - y0) * gap / len,
    xend = x1 - (x1 - x0) * gap / len,
    yend = y1 - (y1 - y0) * gap / len,
    color = if (is.null(highlight)) {
      ink
    } else {
      ifelse(paste0(from, "->", to) %in% gsub("\\s", "", highlight), red, gray)
    }
  )

  ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = arrows,
      ggplot2::aes(x, y, xend = xend, yend = yend, color = I(color)),
      linewidth = 1.6,
      arrow = ggplot2::arrow(length = ggplot2::unit(0.18, "inches"), type = "closed")
    ) +
    ggplot2::geom_polygon(
      data = circles,
      ggplot2::aes(x, y, group = name, fill = I(fill), linetype = I(linetype)),
      color = ink,
      linewidth = 1.2
    ) +
    ggplot2::geom_text(
      data = nodes,
      ggplot2::aes(x, y, label = name, color = I(text)),
      size = text_size,
      fontface = "bold"
    ) +
    ggplot2::geom_text(
      data = nodes,
      ggplot2::aes(label_x, label_y, label = label, hjust = hjust, vjust = vjust),
      color = ink,
      size = text_size * 0.75
    ) +
    ggplot2::coord_equal(clip = "off") +
    ggplot2::scale_x_continuous(
      expand = ggplot2::expansion(add = c(
        if (is.null(left)) 0.6 else 1.8,
        if (is.null(right)) 0.6 else 1.8
      ))
    ) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(add = 0.6)) +
    ggplot2::theme_void()
}
