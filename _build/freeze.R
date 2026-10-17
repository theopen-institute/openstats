# Keep _freeze/ in step with the files the pages use.
#
#   Rscript _build/freeze.R          re-render every page whose inputs changed
#   Rscript _build/freeze.R --check  only list them, and fail if there are any (CI)
#
# `freeze: auto` re-runs a page's R code only when the page's own .qmd changes. A
# page also uses other files when its code runs: the R it sources, the Stan models
# and datasets it reads, the files it includes (Shiny apps, _includes/), and the
# palette in css/deck.scss. Edit one of those, and a full `quarto render` (or CI)
# keeps publishing the old frozen output.
#
# This script follows those references from each frozen page and records a hash of
# every input in _build/frozen-inputs.tsv. A page whose inputs no longer match the
# record is stale: by default it is re-rendered on its own (`quarto render page.qmd`,
# which always runs the code) and its record updated. Commit the record with _freeze/.
#
# What counts as an input: an existing .R, .stan, .csv, .scss, .md or .qmd file named
# in quotes or in an {{< include >}} in a page, or, recursively, in an R file or
# include it uses (comments don't count).
# Not inputs: notes/ (read by _build/notes.lua at render time, not frozen), and
# everything in css/deck.scss except the `$brand-` palette lines that R reads.

record_file <- "_build/frozen-inputs.tsv"
check_only <- "--check" %in% commandArgs(trailingOnly = TRUE)
root <- paste0(normalizePath("."), "/")

# Pages with frozen results (student projects are managed separately)
frozen_pages <- function() {
  results <- list.files("_freeze", "^html\\.json$", recursive = TRUE)
  results <- results[basename(dirname(results)) == "execute-results"]
  pages <- paste0(dirname(dirname(results)), ".qmd")
  pages <- pages[!startsWith(pages, "projects/") & file.exists(pages)]
  sort(pages)
}

# Files referenced by `file`, resolved from the project root or from its directory
referenced_files <- function(file) {
  lines <- readLines(file, warn = FALSE)
  lines <- sub("(^|\\s)#.*$", "", lines) # R comments (and markdown headings)
  text <- gsub("<!--.*?-->", "", paste(lines, collapse = "\n")) # HTML comments
  path <- "[A-Za-z0-9_./-]+\\.(R|stan|csv|scss|md|qmd)"
  quoted <- regmatches(text, gregexpr(paste0("[\"']", path, "[\"']"), text))[[1]]
  included <- regmatches(text, gregexpr(paste0("\\{\\{< include ", path), text))[[1]]
  paths <- c(gsub("[\"']", "", quoted), sub("^\\{\\{< include ", "", included))
  found <- character()
  for (p in unique(paths)) {
    for (candidate in c(p, file.path(dirname(file), p))) {
      if (!file.exists(candidate) || dir.exists(candidate)) next
      candidate <- normalizePath(candidate)
      if (startsWith(candidate, root)) { # skip files outside the project
        found <- c(found, substring(candidate, nchar(root) + 1))
        break
      }
    }
  }
  found <- found[!startsWith(found, "notes/") & found != file]
  unique(found)
}

# Every input of a page, following references through R files and includes
page_inputs <- function(page) {
  seen <- character()
  queue <- referenced_files(page)
  while (length(queue)) {
    f <- queue[1]
    queue <- queue[-1]
    if (f %in% seen || f == page) next
    seen <- c(seen, f)
    if (grepl("\\.(R|md|qmd)$", f)) queue <- c(queue, referenced_files(f))
  }
  sort(seen)
}

# Hash of one input; for the theme, only the palette lines R reads
input_hash <- function(f) {
  if (f == "css/deck.scss") {
    lines <- grep("^\\$brand-", readLines(f, warn = FALSE), value = TRUE)
    tmp <- tempfile()
    writeLines(lines, tmp)
    on.exit(unlink(tmp))
    f <- tmp
  }
  unname(tools::md5sum(f))
}

current_inputs <- function(page) {
  inputs <- page_inputs(page)
  data.frame(
    page = rep(page, length(inputs)),
    input = inputs,
    md5 = vapply(inputs, input_hash, ""),
    row.names = NULL
  )
}

read_record <- function() {
  if (!file.exists(record_file)) {
    return(data.frame(page = character(), input = character(), md5 = character()))
  }
  read.delim(record_file, colClasses = "character", comment.char = "#")
}

write_record <- function(record) {
  record <- record[order(record$page, record$input), ]
  writeLines(
    c(
      "# Inputs of each frozen page when it was last rendered. Written by _build/freeze.R;",
      "# don't edit by hand. Commit it together with _freeze/.",
      "page\tinput\tmd5",
      paste(record$page, record$input, record$md5, sep = "\t")
    ),
    record_file
  )
}

# How the recorded inputs of `page` differ from the current ones (empty if fresh)
differences <- function(page, recorded, current) {
  old <- recorded[recorded$page == page, ]
  if (!nrow(old)) return("never recorded")
  old_md5 <- setNames(old$md5, old$input)
  new_md5 <- setNames(current$md5, current$input)
  inputs <- union(names(old_md5), names(new_md5))
  inputs[is.na(old_md5[inputs]) | is.na(new_md5[inputs]) | old_md5[inputs] != new_md5[inputs]]
}

record <- read_record()
pages <- frozen_pages()
record <- record[record$page %in% pages, ] # forget pages that no longer exist
stale <- character()

for (page in pages) {
  current <- current_inputs(page)
  changed <- differences(page, record, current)
  if (!length(changed)) next
  stale <- c(stale, page)
  cat(sprintf("%s is stale: %s\n", page, paste(changed, collapse = ", ")))
  if (check_only) next

  status <- system2("quarto", c("render", shQuote(page)))
  if (status != 0) stop("quarto render ", page, " failed", call. = FALSE)
  record <- rbind(record[record$page != page, ], current)
  write_record(record)
}

if (check_only && length(stale)) {
  cat("\nRun `Rscript _build/freeze.R` to re-render these, then commit _freeze/ and",
      record_file, "\n")
  quit(status = 1)
}
if (!length(stale)) cat("All frozen pages are up to date.\n")
