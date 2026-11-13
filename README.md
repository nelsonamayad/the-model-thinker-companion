# The Model Thinker Companion

*The Model Thinker (Page, 2018) companion you didn't know you needed.*

**Every model in Scott E. Page's *The Model Thinker*, with its formulation and an interactive application that runs in your browser.**

**Visit the site: <https://the-model-thinker-companion.netlify.app>**

In *The Model Thinker* (Basic Books, 2018), Page argues that making sense of data and of the world takes many models, not one. This site gives each of the book's 55 models its own page: the formulation (setup, equations or rules, and the main result), a live application, takeaways, uses, related models and sources, with the chapter and pages where the book presents it.

> This is an independent study aid and homage. It is not affiliated with, endorsed by or reviewed by Scott E. Page or Basic Books. The explanations, formulations as typeset here and simulations are ours, and so are any mistakes. Nothing from the book's text or figures is reproduced; the home page shows
> the cover, at small size, to identify the book.

## The right tool for each model

- **Equation-based models** (48): difference and differential equations, closed-form results, Markov chains, games, mechanisms and learning rules, computed live in the browser with [Observable JS](https://quarto.org/docs/interactive/ojs/). Each has a reference implementation in R (`R/`), using deSolve for differential equations, igraph for networks, `lm` for regression and base R otherwise.
- **Agent-based models** (7): El Farol, the forest fire model, local majority, the Game of Life, Granovetter's riots, Schelling's segregation and cooperative action. Each is a [NetLogo 6.4](https://ccl.northwestern.edu/netlogo/) model (`abm/*.nlogo`) run across parameters and seeds by an [nlrx](https://docs.ropensci.org/nlrx/) experiment (`abm/*.R`). The results are committed to `data/` and charted on the page, next to a JavaScript replay of the same rules.

## Building

```bash
quarto render                    # build the site into _site/ (no R or NetLogo needed)
python scripts/check_models.py   # static checks on every entry
python scripts/check_pages.py    # load every page in headless Chrome
python scripts/run_r.py          # run the R reference scripts
python scripts/run_abm.py        # rerun the NetLogo experiments (needs NetLogo 6.4 and nlrx)
```

See [CLAUDE.md](CLAUDE.md) for the project's conventions, including the rules about the book's copyright.

## Credits

Built by [Nelson Amaya D](https://github.com/nelsonamayad) with Claude Opus 5.5
(Anthropic) through Claude Code. The About page on the site describes how.
Modelled on the sibling project, the Andrew Gelman Statistical Lexicon Explorer.
