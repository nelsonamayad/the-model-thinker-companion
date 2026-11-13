# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**The Model Thinker Companion**: a Quarto website with one page for each model in Scott E. Page's *The Model Thinker: What You Need to Know to Make Data Work for You* (Basic Books, 2018; paperback with a new chapter 29, 2021). Each page states the model's **formulation** (assumptions, variables, equations, main result) and then gives an **interactive application** that runs in the browser. It is an homage and study aid, modelled on the sibling project `../gelman-lexicon` (the Andrew Gelman Statistical Lexicon Explorer), and it is independent: not affiliated with or endorsed by Scott E. Page or his publisher. The footer and the About page say so.

The site does not exist to replace the book. It points readers to the chapter and pages for each model and adds what a printed book cannot: sliders, runs and parameter sweeps.

The site was renamed from "Model Thinker Explorer" to **The Model Thinker Companion** on 13 November 2026, before its first release; use the new name everywhere.

## Repository and deployment

- Repository: `github.com/nelsonamayad/model-thinker` (public), branch `main`. `_quarto.yml` sets `repo-url` and `repo-actions: [edit, issue]`, so every page has "Edit this page" and "Report an issue" links, and the navbar and footer link to the repo.
- Site: <https://the-model-thinker-companion.netlify.app>, a Netlify site that Nelson created, recorded in the committed `_publish.yml` (site id `81ef47c9-…`). `_publish.yml` belongs to the deployment: never overwrite it or create another Netlify site (`quarto publish netlify` without a target would create one with a random name). To deploy: `quarto render`, run the checks, then `quarto publish netlify --no-render --no-prompt --no-browser`, which updates the site in `_publish.yml` using the Netlify account Quarto stores locally (in `%LOCALAPPDATA%/quarto/publish/accounts/netlify`).
- There is no GitHub Actions workflow yet. Deploys are manual, from this machine. If one is added, follow `../gelman-lexicon/.github/workflows/publish.yml` (checks, render, `quarto publish netlify` with a `NETLIFY_AUTH_TOKEN` secret).
- Releases: the home page shows `[Version X.Y, date.]{.site-version}` at the end of the hero. When releasing, bump it, commit, tag `vX.Y` (annotated), push `main` and the tag, and deploy.
- Before committing, make sure `git status` shows no EPUB and no `_site/`: both are gitignored.

## The book is copyrighted: rules

`tmt_page.epub` (the paperback edition, © 2018, 2021 Scott E. Page) is the source for checking each entry. It is **never** committed, published, copied into the site or quoted at length.

- `.gitignore` excludes `*.epub`. `project.render` is limited to `**/*.qmd` and `resources` lists only our own files, so the EPUB never reaches `_site/`. Keep it that way.
- Write every explanation in our own words. Do not paste or lightly reword the book's prose, boxes, examples or figures. A quotation, if any, is one sentence at most, in quotation marks, with its page number.
- Equations are standard mathematics and may follow the book's notation (for example $I_{t+1} = I_t + P_{\text{broad}} S_t$), typeset by us in LaTeX. Never embed the book's images (`OEBPS/images/*`), with one exception: the cover. `assets/book-cover.jpg` is a 360 × 540 thumbnail of the expanded edition's cover (taken from the EPUB's `images/9780465094639.jpg`), shown only on the home page to identify the book, with its credit line (cover design by Chin-Yee Lai; cover © 2021 Hachette Book Group). Don't replace it with a larger version or reuse it elsewhere (social cards, favicons, entry pages).
- Every entry cites the chapter and print pages (`chapter`, `pages` in the front matter; the EPUB carries `page-N` anchors). Original references come from the book's bibliography (`OEBPS/appendix002.xhtml`) or the Crossref API, never from memory.
- To read the book, extract the EPUB into the session scratchpad, not into this folder, and read it with `python -I`. Its model boxes are `<div class="sidebar">` elements with `<h1 class="sidebar-title">`; many equations inside them are small JPEG images.

## The right tool for the right model

Each model is built with the tool that suits its class. The class is recorded in the front matter (`engine`, `tool`, `reference`).

| Class | Examples | Live on the page | Offline reference |
|---|---|---|---|
| **Agent-based** (`engine: "Agent-based"`) | El Farol, forest fire, local majority, Game of Life, Schelling segregation, Granovetter riots, cooperative action | A JavaScript port of the same rules that readers can step through and play (`player()` in `js/models.js`), plus an explorer of the NetLogo results | **NetLogo 6.4** model `abm/<slug>.nlogo`, run across parameters and seeds by an **nlrx** experiment `abm/<slug>.R`, which writes `data/<slug>.csv` |
| **Equation-based** (`engine: "Equation-based"`) | Difference and differential equations, closed-form theorems, Markov chains, games, mechanisms, learning rules | Observable JS computes the model live as sliders move (iteration, `rk4()`, matrix algebra, exact formulas) | R script `R/<slug>.R` with the package suited to the class: **deSolve** for differential equations, **igraph** for networks, `stats::lm` for regression, base R matrices for Markov chains, base R otherwise |

Agent-based means many heterogeneous agents following local rules, with outcomes that emerge from their interaction and vary from run to run, so one run proves little and the right tool is a proper ABM platform plus a designed experiment. Don't hand-roll an ABM sweep in JavaScript when it belongs in NetLogo, and don't move a closed-form or equation model into NetLogo. When a model could go either way (for example Pólya urns or preferential attachment), it is equation-based if one state variable or an urn describes it, and agent-based if agents, space or a network do.

### NetLogo and nlrx

- NetLogo **6.4.0**, in `%LOCALAPPDATA%/Programs/NetLogo 6.4.0` on this machine. winget's download link for 6.4.0 is dead (404), so it was installed from the GitHub release MSI (`github.com/NetLogo/NetLogo/releases/download/v6.4.0/NetLogo-6.4.0-64.msi`, SHA-256 checked against winget's manifest) with an administrative extract (`msiexec /a ... TARGETDIR=...`), which needs no admin rights. nlrx 0.4.6 supports NetLogo 6.x; NetLogo 7 changed the model format (`.nlogox`) and is not supported, so models stay in the 6.x `.nlogo` format.
- The Windows NetLogo bundle's Java runtime has no `java.exe`, which the `netlogo-headless.bat` that nlrx calls expects. NetLogo's own Windows headless launcher is `NetLogo_Console.exe --headless`, so `abm/_nlrx.R` gives nlrx a generated folder whose `netlogo-headless.bat` forwards to it. No separate Java install is needed. On Linux or macOS the shim is skipped.
- `abm/_nlrx.R` holds the shared setup: `netlogo_home()` finds NetLogo (`NETLOGO_HOME` overrides), `nl_model()` builds the `nl` object, `run_experiment()` runs the design in parallel (`future::multisession`) and `save_results()` tidies the column names (`[step]` becomes `step`, `percent-similar` becomes `percent_similar`) and writes the CSV. Each `abm/<slug>.R` sources it and defines only the experiment: metrics, variables, constants, design (`simdesign_ff` with `nseeds`), runtime and evaluation ticks. A metric that is a NetLogo list arrives as a string such as `"[3 0 7]"`; parse it in the experiment script (see `abm/forest-fire-model.R`). An empty `constants = list()` is fine.
- Run one experiment with `Rscript abm/<slug>.R` (from the project root), all of them with `python scripts/run_abm.py`. Runs are slow (a JVM per run), so keep designs small: about 5–10 parameter values times 5–10 seeds, and keep each `data/<slug>.csv` under 300 KB. Commit the CSV: the site never runs NetLogo or R at render time.
- Call `set.seed()` before the `simdesign_*()` call, so nlrx draws the same NetLogo seeds on every run and the CSV is reproducible.
- Each `.nlogo` file must have `setup` and `go`, reporters for every metric the experiment collects, globals or sliders for every variable it varies, and `random-seed` handled by nlrx (never set the seed inside `setup`). Keep the interface tab minimal (sliders for the experiment variables, a view, and buttons) so the model also opens and runs in the NetLogo GUI.
- The JavaScript replay and the NetLogo model must implement the **same rules with the same defaults**. If you change one, change the other, rerun the experiment and recheck the page. The page says which numbers come from NetLogo.

## Commands

```bash
quarto preview                          # live-reloading dev server
quarto render                           # full build into _site/
quarto render models/<slug>.qmd         # re-render one page
python scripts/build_site.py            # regenerate family pages, cards, sidebar, callouts, code blocks
python scripts/check_models.py          # static checks on every entry (run before committing)
python scripts/check_pages.py           # load every built page in headless Chrome (after quarto render)
python scripts/check_pages.py _site models/<slug>.html --readouts   # one page, with its readout text
python scripts/run_r.py [slug ...]      # run the R reference scripts in R/
python scripts/run_abm.py [slug ...]    # run the nlrx experiments in abm/ (needs NetLogo 6.4)
```

R is at `C:/Program Files/R/R-4.6.0/bin/Rscript.exe` and is not on the PATH; the Python runners find it (set `RSCRIPT` to override). R packages used: nlrx, deSolve, igraph (all in the user library).

Run `scripts/build_site.py` after adding an entry, after changing any entry's front matter, its OJS cells, its `R/` script or its `abm/` files. It regenerates `families/*.qmd`, `agent-based.qmd`, `_family-cards.md` and `_sidebar.yml`, keeps each entry's `categories` in sync (`[family, engine]`), rewrites the source callout at the top of each entry, and rewrites the generated "Show model code" block (tabs: Observable JS from the page's cells; R from `R/<slug>.R`, or for agent-based models NetLogo from `abm/<slug>.nlogo` and the nlrx experiment from `abm/<slug>.R`). Don't edit generated files or blocks by hand.

`quarto render` only checks OJS syntax. Runtime errors (a misspelled helper, a bad Plot option, a missing CSV) show up only in a browser, which is what `scripts/check_pages.py` is for: it serves `_site/`, loads each page in headless Chrome and fails on any `observablehq--error` box or on a model page without a labelled chart (an `svg` or `canvas` with `aria-label`).

## Structure

- `_quarto.yml`: site structure, navbar (Browse all, Families menu, Agent-based models, Many-model thinking, Random model, About), search, footer, MathJax pinned. `metadata-files: [_sidebar.yml]`; the generated sidebar groups models by family in book order.
- `_brand.yml`: colors (light and dark values, which gives the dark-mode toggle) and fonts (IBM Plex Sans for text, IBM Plex Serif for headings, IBM Plex Mono for code). `styles.css` adds the formulation box, readouts, player control and home-page cards.
- Authors are Nelson Amaya D (github.com/nelsonamayad) and Claude Opus 5.5, following the convention of `../gelman-lexicon`. They are credited only on the About page (its `author` field, its opening "What is this?" sentence and its "How this site was built" section, which is the project history) and in one line at the end of `README.md`; not on the home page, entry pages or footer. Keep "How this site was built" factual: say what each author did, and don't claim reviews that haven't happened. Every page has `date` (published) and `date-modified: last-modified` (set site-wide). New pages need a `date:` line. There is no license file yet; don't add license claims until the authors choose one.
- `index.qmd` (hero with the book's cover beside the welcome text, `.hero-wrap` in `styles.css`; family cards from `_family-cards.md`; table of every model sorted by `order`), `many-models.qmd` (Page's case for many-model thinking and the seven uses of models, REDCAPE), `agent-based.qmd` (generated listing), `families/*.qmd` (generated listings), `about.qmd` (disclaimer, how the site was built, credits), `random.qmd`, `404.qmd`.
- `models/<slug>.qmd`: one file per model. `models/_metadata.yml` turns off code echo; the generated block shows the code once.
- `_template.qmd`: the required structure of an entry (not rendered).
- `js/models.js`: shared helpers, imported on every page with `import {...} from "../js/models.js"`. Seeded RNG (`rng(seed)` with `.normal`, `.binomial`, `.pick`, `.shuffle` and others), summaries, `pnorm`/`qnorm`, `lm`/`ols`, `dbinom`, `entropy`, `rk4` (ODEs) and `iterate` (difference equations), Markov helpers (`stationary`), network generators and statistics (`graphRandom`, `graphSmallWorld`, `graphPrefAttach`, `graphStats`, `layoutForce`), grid helpers (`torus8`, `drawGrid`, which draws a labelled canvas), the `player()` control for stepping through a run, the chart palette `C`, and `fmt`/`pct`. Add a helper here rather than copying it into pages. The RNG and statistics are adapted from `../gelman-lexicon/js/stats.js` (same author, MIT).
- `abm/`: NetLogo models and nlrx experiments, `abm/_nlrx.R` shared setup. `data/`: nlrx results (CSV), read on the page with `FileAttachment("../data/<slug>.csv").csv({typed: true})`.
- `R/<slug>.R`: reference implementation of each equation-based model in R, with the controls as variables at the top, a seed where there is randomness, printed results and a base-graphics chart. Lines of at most 80 characters; tidyverse style (`<-`, snake_case, spaces around operators); single-letter mathematical names (`N`, `K`, `P`) may keep their case to match the formulas; never use `T`, `F` or `C` as names.
- `scripts/`: `build_site.py`, `check_models.py`, `check_pages.py`, `run_r.py`, `run_abm.py`.
- `project.render` is `**/*.qmd`, so `README.md`, `CLAUDE.md`, the EPUB and the R and NetLogo sources are never rendered as pages. `resources` publishes `js/`, `data/` and `assets/`.

## Which models get an entry

One entry per model the book defines in a box (`sidebar-title`), in book order (`order`, 1-based). Boxes that define a variant of the same model share its entry: the rule of 72 and half-lives go with exponential growth; the simple growth model with Solow; R0 and superspreaders with SIR; maximum-entropy distributions with entropy; Markov decision models with Markov models; the party model with Schelling; majority-vote equal sharing with the pivot mechanism; discrete and continuous signals share one entry; Bernoulli and Bayesian bandits (and the Gittins index) share one; group selection goes with cooperative action. Boxes that are applications or essays (REDCAPE, the Lucas critique, algorithmic riots, presidential elections, patents, "many models of value") are not models and get no entry; their ideas may appear in "Uses" or on `many-models.qmd`. Chapter 29 (opioids, COVID-19, inequality) applies earlier models; it may get entries later, each marked as an application.

## Families

Exactly one per entry, in this order (keep `FAMILIES` in `scripts/build_site.py`, the navbar and `_template.qmd` in sync):

1. Many models and prediction (ch. 3)
2. Modeling people (ch. 4)
3. Distributions (ch. 5, 6, 12)
4. Linear and nonlinear models (ch. 7, 8)
5. Value and power (ch. 9, 24, 25)
6. Networks and contagion (ch. 10, 11)
7. Processes and dynamics (ch. 13–19)
8. Games and cooperation (ch. 20–23)
9. Learning and search (ch. 26–28)

## Page conventions

Front matter: `title`, `date` (published), `description` (one sentence in our words: what the model says), `order`, `chapter`, `chapter-title`, `pages`, `family`, `engine` (`"Agent-based"` or `"Equation-based"`), `tool` (what runs live, for example `"Observable JS: difference equation"` or `"NetLogo 6.4 + nlrx; JavaScript replay"`), `reference` (the R package or NetLogo), `uses` (a list from Reason, Explain, Design, Communicate, Act, Predict, Explore), `categories` (kept in sync by the build script) and `verified` (`true` once the formulation has been checked against the book's box and text, with an optional `source-note`).

Body sections, in order:

1. Source callout (generated).
2. **The idea**: one or two short paragraphs, plain language, our own example where possible.
3. **Formulation**: a `::: {.model-box}` block with **Setup** (agents, states, parameters with their symbols), **Rules** or **Equations** (LaTeX display math), and **Result** (the theorem, equilibrium or regularity the model produces). Use the book's symbols unless there is a reason not to, and say where we depart from them. Add a short derivation or reading of the equations under the box when it helps.
4. **Interactive model**: one sentence on what the application shows and what to try, then OJS cells in this order: imports (`//| echo: false`), `viewof` controls (with a "Random seed" slider whenever there are random draws; deterministic models have none), pure computation, one or two `Plot.plot` charts (or `drawGrid` canvases), and a readout `html\`<div class="sim-readout">${md\`...\`}</div>\`` cell that states the result in words. Agent-based pages add a **NetLogo experiment** subsection that loads `data/<slug>.csv` and charts the sweep, with its own readout. The default settings must visibly show the model's point.
5. **Takeaways**: `::: takeaways` with three bullets.
6. **Uses**: two to four bullets, each starting with a bold REDCAPE use (**Explain.**, **Predict.**, ...) and a concrete application.
7. **Related models**: links to other entries (`[Title](slug.qmd)`) with a few words on how they complement or contrast; many-model thinking is the point of the book.
8. **Sources**: the book (chapter, pages), then original works from the bibliography.

## OJS and chart rules (learned in the sibling project)

- Never name a cell `window`, `width`, `document` or another browser or Observable global. A cell cannot reference itself.
- Every `Plot.plot({...})` starts with `ariaLabel:` (model name plus chart name) and `ariaDescription:`; `drawGrid` takes the same two options. `check_models.py` enforces it.
- Use `"currentColor"` for reference lines and text. Use the palette `C` from `js/models.js` (teal `#148a91`, orange `#d95f02`, purple `#7570b3`, gray `#8a8a8a`, gold `#b8860b`, green `#1a9850`, red `#d6604d`): each passes 3:1 contrast on the light and dark backgrounds.
- Animations never autoplay: `player()` starts paused, at the step that best shows the result, so headless checks and screenshots are deterministic.
- Wrap slow simulations' controls in `debounce()`. Keep each page's live computation under about half a second.
- When scripting edits that touch LaTeX, use raw strings (`\t` and `\f` in `\theta` and `\frac` otherwise become control characters).
- Quotation marks are for words someone actually said or wrote. Hypothetical lines go in italics.
- Readouts must only claim what the numbers show. Make comparative sentences conditional on the computed values (several readouts say "close to the theory" only when it is), and check every readout with `check_pages.py --readouts` after changing defaults.
- A literal `*` in a readout (for example `O*`) must be escaped as `\\*` inside the JavaScript template, or Markdown turns it into emphasis.
- Pick default seeds that show a typical run, not a lucky one. For stochastic pages, scan seeds with Node (copy `js/models.js` to a scratch `.mjs` file and rerun the page's computation) and choose one near the median outcome.
- Inputs.form returns an object, so a `viewof params = cond ? Inputs.form(...) : Inputs.form(...)` cell can change shape with another control (see `markov-models.qmd`). Grouped bars use `fx` for the group and `x` for the series.
- In a website project, rendering several files in one `quarto render a.qmd b.qmd` call failed with a Pandoc error during this build; render one file per call, or the whole site.

## Where the book and our pages differ

When the book's box and its worked example disagree, or a printed number is off, follow the version that is internally consistent, compute the numbers ourselves, and record the choice in the entry's `source-note` (which the callout shows). Current cases: the riot model's joining rule (≤, as in the text's examples, not the box's <), the ping-pong model's state equation (the text's worked example), the six-degrees counts from four steps on (15.36 million, not 17.36 million), the two-park congestion total (3N²/4, not 9N²/16), the category-size weight in the model error decomposition, and the book's "SIR" box, which returns the recovered to the susceptible pool (the page offers both versions). The broadcast model's period-3 prediction is 12,800, which the book rounds to 13,000.
