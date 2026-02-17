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
