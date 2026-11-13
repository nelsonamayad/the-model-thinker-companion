# The El Farol model: does attendance self-organize around capacity, and how
# does that depend on how many rules each person holds?
# NetLogo model: abm/el-farol.nlogo. Output: data/el-farol.csv (one row per
# ensemble size and seed).
source("abm/_nlrx.R")

nl <- nl_model("el-farol")
nl@experiment <- experiment(
  expname = "ensemble_sweep",
  outpath = tempdir(),
  repetition = 1,
  tickmetrics = "false", # measure once, at the end of the run
  idsetup = "setup",
  idgo = "go",
  runtime = 100, # weeks; summaries skip the first 20
  metrics = c("mean-attendance", "sd-attendance", "share-crowded"),
  variables = list(
    "ensemble-size" = list(values = c(1, 2, 3, 4, 6, 8, 10, 12))
  ),
  constants = list("capacity" = 60)
)
set.seed(4) # makes nlrx draw the same NetLogo seeds every time
nl@simdesign <- simdesign_ff(nl, nseeds = 8)

results <- run_experiment(nl)
save_results(results, "el-farol",
  keep = c(
    "ensemble_size", "random_seed", "mean_attendance", "sd_attendance",
    "share_crowded"
  )
)
