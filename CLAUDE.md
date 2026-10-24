# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`openstats` is a Quarto website project holding the "Data Lunch" statistics course for
The Open Institute For Social Science. It produces two kinds of output from the same
`.qmd` sources:

- **RevealJS slide decks** — the weekly lectures, `week1.qmd` … `week5.qmd`.
- **HTML pages** — `index.qmd`, `workflow.qmd` (the full Bayesian workflow),
  `wb-vars.qmd` (World Bank series reference), `homework/week*.qmd`, and the student
  project writeups under `projects/`. Each sets `format: html` so it isn't also built as
  a deck. (`homework/week*_key.md` are answer keys: gitignored, because the repo is
  public. They exist only in the maintainer's working copy.)

Files starting with `_` are never rendered: `_removed.qmd` is a parking file for cut
slides (keep the assets it references), `_includes/` holds shared slide snippets.

The pedagogy is Bayesian (McElreath-style *Statistical Rethinking*): models are written
in Stan, fit with `cmdstanr`, and summarized/plotted with the tidybayes/bayesplot stack.
Several slides embed live, browser-run Shiny apps via `shinylive`.

## Committing

Never commit code unless explicitly instructed to. The maintainer commits manually.
Make and leave changes in the working tree; do not run `git commit` on your own.
When asked to commit, don't add `Co-Authored-By` or other Claude attribution lines.

## Commands

```bash
quarto render                    # render the whole site to .output.nosync/
quarto render week1.qmd          # render a single deck/page
quarto preview week1.qmd         # live-reload preview while editing
quarto preview                   # preview the whole site
Rscript _build/freeze.R          # re-render pages whose R/model/data/include inputs changed
Rscript _build/freeze.R --check  # just list them (CI runs this and fails if any)
```

There is no test suite, linter, or build step beyond `quarto render`. The knitr engine
executes the embedded R, so rendering *is* the build and the correctness check.

Publishing is automatic: pushing to `main` triggers `.github/workflows/publish.yml`,
which renders on CI and deploys to the `gh-pages` branch. The CI job also installs
CmdStan and all R packages fresh, so a deck that renders locally can still fail on CI if
it depends on an uncommitted package or extension.

## Rendering model (important)

- **Engine is `knitr`** (set globally in `_quarto.yml`). R code chunks run at render
  time. `freeze: auto` stores results in `_freeze/` (committed): a page only re-runs
  its R code when its source changes, and CI reuses the frozen results.
- **Freeze doesn't see a page's other inputs.** The frozen output also bakes in the R
  files a page sources, the models and datasets it reads, and everything it pulls in
  with `{{< include >}}` (Shiny apps, `_includes/`). Editing those doesn't trigger a
  re-run in a full render. After editing anything under `r/`, `models/`, `datasets/`,
  `shiny/`, `_includes/` or the palette, run `Rscript _build/freeze.R`: it re-renders
  the affected pages and records their inputs' hashes in `_build/frozen-inputs.tsv`
  (commit it with `_freeze/`). CI runs it with `--check` and fails on stale pages.
  (Rendering one file, `quarto render week2.qmd`, always re-runs its code too, but
  doesn't update the record.) `notes/` and the non-palette parts of `deck.scss` are
  applied after execution, so they never go stale.
- **Output dir is `.output.nosync/`** — gitignored, never edit by hand. So are
  `.quarto/`, `_extensions/`, and `.stancache/`.
- **The repo lives in iCloud Drive**, which skips anything named `*.nosync`. The site
  renders straight into `.output.nosync` (a symlinked output dir doesn't last: a full
  render deletes it and recreates a real directory). Locally, `.quarto` and `.stancache`
  are symlinks to `*.nosync` directories (`sh _build/nosync.sh` sets this up; run it
  once per Mac). `_freeze/` is committed and syncs normally. Keep the `resources:` globs
  in `_quarto.yml` anchored with a leading `/` (`/images/`, not `images/`): unanchored
  globs also match inside `.output.nosync`, and every render then copies the output
  into itself one level deeper until paths get too long and renders fail.
- **Quarto extensions are NOT committed** (`_extensions/` is gitignored). The only one
  is shinylive: CI runs `quarto add quarto-ext/shinylive@v0.2.0`, and locally it must
  already be installed or renders of Shiny slides fail.
- **Pinned versions:** CI pins Quarto 1.10.18, shinylive v0.2.0, CmdStan 2.37.0 and
  R 4.5.2 (`.github/workflows/publish.yml`). Bump them together with your local install.
- **Stan models are cached** in `.stancache/` keyed by model; first render compiles with
  CmdStan (slow), later renders reuse the cache.
- **Renders work offline, and Bioconductor is off.** shinylive resolves each app's
  dependencies with pkgdepends/pkgcache, which by default also searches Bioconductor
  and looks up its version online on every render. `_environment` (read by Quarto for
  every render, CI included) turns that off: `PKG_USE_BIOCONDUCTOR=false` keeps the
  apps to CRAN packages, and `R_BIOC_VERSION` stops the version lookup, which pkgcache
  does even with Bioconductor off. Offline builds still need caches from one online
  build: the CRAN package list and shinylive's in-browser package files.
- **`_environment.local`** (gitignored, local only) sets `SHINYLIVE_WASM_PACKAGES=0` for
  faster previews: shinylive skips bundling the apps' R packages, so the Shiny apps in a
  local build download them at runtime and need an internet connection to run. CI never
  sees the file, so the published site still bundles everything. Comment the line out
  before building locally to present offline.

Three Quarto filters run on every render (`_quarto.yml`):
- `shinylive` — turns ```` ```{shinylive-r} ```` chunks into self-contained
  browser-run Shiny apps (no server).
- `_build/notes.lua` — custom speaker-notes filter (see below).
- `_build/list-fragments.lua` — a list item that is only a fragment span,
  `- [text]{.fragment fragment-index=2}`, becomes a fragment `<li>` (bullet and text
  appear together). Use it instead of a raw-HTML `<ul>` when items need their own
  fragment order.

`{{< include path >}}` is built into Quarto. It works inside code blocks too, which is
how `workflow.qmd` shows `models/berkeley.stan` and the decks embed `shiny/*.R`.

## Architecture / things that span files

### Shiny demos (`shiny/*.R`)
Each file is a complete standalone `shinyApp(ui, server)`, and must stay that way: no
`source()`, no shared palette, nothing from elsewhere in this repo. They may use CRAN
packages only (see the Bioconductor note under "Rendering model"). They are pulled into slides
with `{{< include shiny/<name>.R >}}` inside a `{shinylive-r}` chunk (see `week1.qmd`),
so they run entirely client-side in the browser. `regression.R` is the most complex:
it keeps parameters in a canonical ("root") unit space and reactively converts to the
chosen display units (cm/in/z, kg/lb), using an `updating_inputs` flag to prevent
feedback loops between programmatic `update*Input` calls and user-driven observers.

### Student projects (`projects/`)
Each `projects/<name>.qmd` defines a config block (the `variables` vector mapping short
codes → World Bank series codes, a `dag` string, prior hyperparameters like
`ALPHA_SD`/`BETA_SD`), then `{{< include _base.qmd >}}`, then its own two Stan models,
fits and summaries. That second half is currently copied per project, with only names
changed; shared front matter (df-print, the DAGitty scripts) is in
`projects/_metadata.yml`.

**`projects/_base.qmd` is shared machinery, not a standalone doc.** It reads the World
Bank data, builds variable-labelled data frames, renders the DAG, auto-generates
histograms/scatterplots, and defines `plot_param()`. It depends on variables the
including file must define first (`variables`, `dag`, `histograms`, `BETA_SD`, …).
When editing a project, decide whether the change belongs in the per-student config or
in `_base.qmd` (where it affects every project).

**Stan-in-knitr pattern:** project Stan models are written in `{stan eval=FALSE,
output.var=...}` chunks using `<<PLACEHOLDER>>` syntax, then retrieved with
`knitr::knit_code$get(...)`, interpolated via `glue::glue(.open="<<", .close=">>")` with
the R-side hyperparameters, written with `write_stan_file()`, and compiled with
`cmdstan_model()`. This is how priors defined once in R flow into the Stan source.

### Standalone Stan models (`models/*.stan`)
Plain `.stan` files used by the week decks and `workflow.qmd` (as opposed to the
inline-glued models in `projects/`), named for what they fit: `weight_sex.stan`,
`weight_sex_height.stan`, `fertility_college.stan`, `fertility_college_mortality.stan`,
`linear.stan` (any number of standardized predictors), `berkeley.stan`. (`weight1`,
`weight3` and `fertility1b` are only referenced from `_removed.qmd`.)

### Data (`datasets/*.csv`)
`wb2022.csv` + `wb_country.csv` are the World Bank panel used by all projects (joined and
pivoted long→wide in `_base.qmd`). `berkeley.csv` (admissions / Simpson's paradox),
`kungsan.csv` (!Kung height/weight) back the week decks. Nepal is the recurring reference
case highlighted in project plots.

### Speaker notes (`_build/notes.lua` + `notes/`)
Slides reference external notes with an attribute on the slide heading:
`# Slide Title {notes="notes/week1_notes.md#section-id"}`. (The filter also accepts a
block placeholder, `::: {notes="notes/week1_notes.md#id"} :::`, but the decks all use
the heading form.) The Lua filter finds the heading with that
`{#id}` in the markdown file, extracts everything until the next same-or-higher heading,
and injects it as a reveal `<aside class="notes">`. A reference that doesn't resolve
(missing file or `#id`) stops the render. `notes/` is excluded from direct
rendering (`!notes/**` in `_quarto.yml`) — it is a content source, not pages.

### DAGs
- **In decks:** drawn as ggplots with `dag_plot()` from `r/rlib.R`. Any three-node DAG
  (with or without a direct X → Y arrow, `direct = TRUE`) should use the `fork_dag()`,
  `pipe_dag()` or `collider_dag()` building blocks so they look the same everywhere.
  A DAG with its own layout is a named function in `r/weekN.R` (`howell_dag()`,
  `wealth_fork_dag()`); one used by several decks (`surgeon_dag()`, `bedrooms_dag()`)
  is in `rlib.R`. The dagitty.net editor slide is the
  shared include `_includes/dagitty-slide.md`.
- **On project pages and `workflow.qmd`:** authored as dagitty strings and rendered
  client-side by `js/dagitty.js`. `projects/_metadata.yml` loads it (and runs
  `DAGitty.setup()`) for every project page; `_base.qmd`'s `<pre class="dagitty">` block
  renders the `dag` variable.

### Styling (`css/deck.scss`) and the palette
Single SCSS theme layered on reveal's `simple` theme: Inter/Space Grotesk fonts, the
semantic color spans used as `[text]{.red}`, `.blue`, `.green`, `.gray`, and shared
classes for things decks would otherwise style inline (`.source` for small gray source
lines, `.big-statement`, `.small-caption`, the week 1 widgets, week 2's `.kinds` cards, week 3's `.workflow`).
Keep `style=` attributes and `<style>` blocks out of the decks; add a class here.
Footnotes (`[^id]`, with the note defined below the table or paragraph) build in with
the fragment their reference sits in, and the marker is light gray; both come from a
small script in `_build/_reveal.html`. Another script there keeps slide titles on one
line, shrinking a title that would wrap (to no less than 75% of its size).

**The palette is defined once**, as the `$brand-*` lines at the top of `deck.scss`.
The theme re-exports them as CSS variables (`var(--brand-blue)`) for scripts
(`js/palette.js`), and `r/rlib.R` parses those same lines into `BLUE`, `RED`, `INK`,
`GREEN`, `GRAY`, `ORANGE`, `TEAL` for plots, with `tint(color, amount)` for lighter
shades. Change a color there and everything follows; don't hard-code hex values
anywhere else. In MathJax, color with the same classes: `\class{blue}{...}`.

Slides that go deeper into the math than the big picture needs (formulas, derivations,
unit conversions, formal model notation) are marked `## Title {.mechanics}`. This turns
the whole screen into a blueprint (the class is copied onto reveal's background
element): a navy sheet (`$brand-blueprint`) with a faint white grid, white text,
lighter versions of the red/blue/green classes, tables drawn in white lines, plots on
white cards, and a "Mechanics" title block in the top-right corner. The logo and corner
buttons turn white while it shows. The class only works on a slide heading, not on a
heading inside a callout or other div.

### Title slides (YAML, not a heading)
Each deck's title slide comes from YAML: `title:`, `subtitle:`, and optionally
`title-notes: "notes/<file>.md#id"` (speaker notes, pulled in by `_build/notes.lua`) and
`title-footer:` (a footer on the title slide only; set for every deck in `_quarto.yml`). `_build/title-slide.html` overrides
Quarto's title-slide template to add those two; `css/deck.scss` left-aligns and styles it
to match the content slides. Don't add a `# Title` heading slide instead: Positron's Quarto
extension counts any YAML front matter as a title slide, so a heading-based title slide
makes the preview jump one slide ahead after each render. For the same reason, give
callouts their title with `title="..."` rather than a `##` heading inside the callout.

### Keeping the decks content-only
The `weekN.qmd` files should read as slides. Things that aren't content live elsewhere:
- **Plot code longer than a few lines** goes in `r/weekN.R` as a function named for
  what it draws (`garden_plot()`, `normal_rule_plot()`), so the chunk is one line.
  So do data prep and model fitting (`load_phones()`, `weight_model_draws()`).
  Short ggplots, and the small simulations that define a made-up example, stay inline;
  week 4's `pooled_plot()`/`split_plot()` keep its "everyone vs. by group" pairs short.
- **Raw HTML** (widgets, diagrams, auto-animate tables) goes in `_includes/` (shared)
  or `_includes/weekN/` (one deck) and is pulled in with `{{< include ... >}}`. Text
  that appears in more than one place is an include too: the ten workflow steps are
  `_includes/bayesian-workflow.md`, used by `workflow.qmd` and week 1. For a line
  break, end the line with `\` rather than `<br>` (pipe-table cells still need `<br>`).
- **Figure sizes** use the named layouts from `r/deck-setup.R` where one fits:
  `{r name, opts.label = "half"}` (also `half_short`, `half_tall`, `dag_half`,
  `dag_side`, `dag_third`). A layout only one deck uses is set in its `r/weekN.R`
  (week 2's `belief`). One-off sizes stay inline.
- **Numbers typed into the text** that are calculated from each other get a check that
  recomputes them, so the render fails if one is edited and the rest aren't: week 1's
  base-rate numbers are checked by `check_stated_numbers()` in `r/week1.R`, called
  from the setup chunk.
- **Incremental lists:** `_quarto.yml` makes lists build one item at a time. Week 1
  turns that off in its front matter (most of its lists appear at once) and marks the
  few that build with `::: {.incremental}`; the other decks mark the exceptions with
  `.nonincremental`. Incremental only affects lists, so tables never need it.

### Shared R (`r/`)
- **`r/deck-setup.R`** — every deck's setup chunk starts with `source("r/deck-setup.R")`.
  It loads tidyverse, `rlib.R` and `data.R`, sets the knitr chunk options (no echo,
  12×6.5 figures, transparent backgrounds), the named figure layouts and the ggplot
  theme.
- **`r/weekN.R`** — one deck's plots, DAGs, data prep and model fits, sourced by that
  deck after `deck-setup.R` (and `stan.R`, for week 3).
- **`r/stan.R`** — `fit_stan()` (quiet sampling, models cached in `.stancache`),
  `param_draws()` (one parameter's draws, labelled by model), `posterior_medians()`
  and `plot_posteriors()`, for decks that fit Stan models.
- **`r/rlib.R`** — the palette (read from `css/deck.scss`), `fmt()`/`pct()`/`dollars()`
  for inline numbers, `standardize()` for z-scores, `dag_plot()` and the
  fork/pipe/collider helpers, the DAGs shared between decks, and
  `replace_indexes()` (relabels Stan names like `alpha[2]` as `alpha[female]`).
  `workflow.qmd` includes it directly so students can read it.
- **`r/data.R`** — `load_howell()`, `load_houses()`, `load_berkeley()`,
  `load_wb(codes)` (World Bank 2022, one column per series code) and
  `load_wb_countries()`.

### Interactive widgets (`js/`)
Week 1's widgets are one include line each in the deck. Their HTML markup is in
`_includes/week1/`, their behavior in `js/` (`count-demo.js`, `cond-table.js`, and the
ES modules `poll-prior.js` (Step 1: draw the prior), `poll-likelihood.js` (Step 2: set
the survey), `poll-posterior.js` (Step 3), `poll-whatif.js` (the three "What if"
slides, which change one input at a time) and `poll-answer.js` (answering the question
from the class's own posterior). They share the prior and the survey through
`poll-store.js`, and the math through `poll-math.js`; the drawn prior is a smooth
curve through its 21 points (`smooth.js`), on Step 1 and in the math alike; the canvas plots share axes and
styling through `canvas-axes.js`, and their animated transitions through `tween.js`), and their styles in `deck.scss`. jspreadsheet comes from a pinned CDN version via
`_build/jspreadsheet.html`.
