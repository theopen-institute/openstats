# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`openstats` is a Quarto website project holding the "Data Lunch" statistics course for
The Open Institute For Social Science. It produces two kinds of output from the same
`.qmd` sources:

- **RevealJS slide decks** — the weekly lectures (`week1.qmd` … `week4.qmd`, plus
  `workflow.qmd`, `tester.qmd`, `wb-vars.qmd`).
- **HTML pages** — student project writeups under `projects/`.

The pedagogy is Bayesian (McElreath-style *Statistical Rethinking*): models are written
in Stan, fit with `cmdstanr`, and summarized/plotted with the tidybayes/bayesplot stack.
Several slides embed live, browser-run Shiny apps via `shinylive`.

## Committing

Never commit code unless explicitly instructed to. The maintainer commits manually.
Make and leave changes in the working tree; do not run `git commit` on your own.

## Commands

```bash
quarto render                    # render the whole site to .output/
quarto render week1.qmd          # render a single deck/page
quarto preview week1.qmd         # live-reload preview while editing
quarto preview                   # preview the whole site
```

There is no test suite, linter, or build step beyond `quarto render`. The knitr engine
executes the embedded R, so rendering *is* the build and the correctness check.

Publishing is automatic: pushing to `main` triggers `.github/workflows/publish.yml`,
which renders on CI and deploys to the `gh-pages` branch. The CI job also installs
CmdStan and all R packages fresh, so a deck that renders locally can still fail on CI if
it depends on an uncommitted package or extension.

## Rendering model (important)

- **Engine is `knitr`** (set globally in `_quarto.yml`, reaffirmed in each `.qmd`
  header). R code chunks run at render time.
- **Output dir is `.output/`** — gitignored, never edit by hand. So are `.quarto/`,
  `_extensions/`, and `.stancache/`.
- **Quarto extensions are NOT committed** (`_extensions/` is gitignored). CI runs
  `quarto add quarto-ext/shinylive` and `quarto add quarto-ext/include-code-files`.
  Locally they must already be installed or renders of Shiny/embedded-code slides fail.
- **Stan models are cached** in `.stancache/` keyed by model; first render compiles with
  CmdStan (slow), later renders reuse the cache.

Three Quarto filters run on every render (`_quarto.yml`):
- `shinylive` — turns ```` ```{shinylive-r} ```` chunks into self-contained
  browser-run Shiny apps (no server).
- `include-code-files` — enables `{{< include path >}}` to inline files.
- `_build/notes.lua` — custom speaker-notes filter (see below).

## Architecture / things that span files

### Shiny demos (`shiny/*.R`)
Each file is a complete standalone `shinyApp(ui, server)`. They are pulled into slides
with `{{< include shiny/<name>.R >}}` inside a `{shinylive-r}` chunk (see `week1.qmd`),
so they run entirely client-side in the browser. `regression.R` is the most complex:
it keeps parameters in a canonical ("root") unit space and reactively converts to the
chosen display units (cm/in/z, kg/lb), using an `updating_inputs` flag to prevent
feedback loops between programmatic `update*Input` calls and user-driven observers.

### Student projects (`projects/`)
Each `projects/<name>.qmd` is a thin wrapper: it defines a config block (the `variables`
vector mapping short codes → World Bank series codes, a `dag` string, prior
hyperparameters like `ALPHA_SD`/`BETA_SD`) and then `{{< include _base.qmd >}}`.

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
Plain `.stan` files (e.g. `weight1.stan`, `berkeley.stan`, `fertility*.stan`) used by the
week decks (as opposed to the inline-glued models in `projects/`).

### Data (`datasets/*.csv`)
`wb2022.csv` + `wb_country.csv` are the World Bank panel used by all projects (joined and
pivoted long→wide in `_base.qmd`). `berkeley.csv` (admissions / Simpson's paradox),
`kungsan.csv` (!Kung height/weight) back the week decks. Nepal is the recurring reference
case highlighted in project plots.

### Speaker notes (`_build/notes.lua` + `notes/`)
Slides reference external notes with an attribute:
`# Slide Title {notes="notes/week1_notes.md#section-id"}` or a block placeholder
`::: {notes="notes/week1_notes.md#id"} :::`. The Lua filter finds the heading with that
`{#id}` in the markdown file, extracts everything until the next same-or-higher heading,
and injects it as a reveal `<aside class="notes">`. `notes/` is excluded from direct
rendering (`!notes/**` in `_quarto.yml`) — it is a content source, not pages. CI also
builds a separate "speaker bundle" artifact from any `*-speaker.html` files.

### DAGs (`js/dagitty.js`, `js/dag-embed.html`)
Causal diagrams are authored as dagitty strings and rendered client-side. Project pages
pull in `js/dagitty.js` via `include-in-header` and the `_base.qmd`
`<pre class="dagitty">` block renders the `dag` variable; `DAGitty.setup()` runs on
`DOMContentLoaded`.

### Styling (`css/deck.scss`)
Single SCSS theme layered on reveal's `simple` theme. Defines the brand palette
(blue `#1b91ff`), Inter/Space Grotesk fonts, and semantic inline color spans used
throughout the slides as `[text]{.red}`, `.blue`, `.green`, `.gray`.

### `r/rlib.R`
Shared R helpers sourced by decks (e.g. `week3.qmd`). `replace_indexes()` relabels Stan
indexed parameter names like `alpha[2]` with factor levels (`alpha[female]`) for readable
summaries.
