# Schelling's segregation model: how segregated does the grid end up, and how
# long does it take, as agents' tolerance threshold rises?
# NetLogo model: abm/schelling-segregation.nlogo. Output:
# data/schelling-segregation.csv (one row per threshold and seed).
source("abm/_nlrx.R")

nl <- nl_model("schelling-segregation")
nl@experiment <- experiment(
  expname = "threshold_sweep",
  outpath = tempdir(),
  repetition = 1,
  tickmetrics = "false", # measure once, when the run stops
  idsetup = "setup",
  idgo = "go",
  runtime = 300, # cap; runs stop earlier when everyone is content
  metrics = c("percent-similar", "percent-unhappy"),
  variables = list(
    "threshold" = list(values = c(10, 20, 25, 30, 40, 50, 60, 70, 75, 80))
  ),
  constants = list("density" = 80, "spread" = 0)
)
set.seed(19) # makes nlrx draw the same NetLogo seeds every time
nl@simdesign <- simdesign_ff(nl, nseeds = 8)

results <- run_experiment(nl)
save_results(results, "schelling-segregation",
  keep = c(
    "threshold", "random_seed", "step", "percent_similar",
    "percent_unhappy"
  )
)
