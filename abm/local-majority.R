# The local majority model: how does the initial mix shape the frozen
# configuration? Does the majority take over, and how patchy is the result?
# NetLogo model: abm/local-majority.nlogo. Output: data/local-majority.csv
# (one row per initial share and seed).
source("abm/_nlrx.R")

nl <- nl_model("local-majority")
nl@experiment <- experiment(
  expname = "share_sweep",
  outpath = tempdir(),
  repetition = 1,
  tickmetrics = "false", # measure once, when the grid has frozen
  idsetup = "setup",
  idgo = "go",
  runtime = 100, # cap; runs stop when no cell would switch
  metrics = c("initial-on", "final-on", "boundary-share"),
  variables = list(
    "share-on" = list(values = c(20, 30, 40, 45, 50, 55, 60, 70, 80))
  ),
  constants = list()
)
set.seed(15) # makes nlrx draw the same NetLogo seeds every time
nl@simdesign <- simdesign_ff(nl, nseeds = 6)

results <- run_experiment(nl)
save_results(results, "local-majority",
  keep = c(
    "share_on", "random_seed", "step", "initial_on", "final_on",
    "boundary_share"
  )
)
