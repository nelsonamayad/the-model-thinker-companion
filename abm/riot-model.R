# Granovetter's riot model: how does the final size of a riot depend on the
# spread of thresholds, holding the average threshold fixed?
# NetLogo model: abm/riot-model.nlogo. Output: data/riot-model.csv (one row
# per threshold spread and seed).
source("abm/_nlrx.R")

nl <- nl_model("riot-model")
nl@experiment <- experiment(
  expname = "spread_sweep",
  outpath = tempdir(),
  repetition = 1,
  tickmetrics = "false", # measure once, when nobody new joins
  idsetup = "setup",
  idgo = "go",
  runtime = 200, # cap; runs stop when the riot stops growing
  metrics = c("rioters", "riot-share"),
  variables = list(
    "sd-threshold" = list(values = seq(0, 24, by = 2))
  ),
  constants = list("population" = 100, "mean-threshold" = 25)
)
set.seed(19) # makes nlrx draw the same NetLogo seeds every time
nl@simdesign <- simdesign_ff(nl, nseeds = 12)

results <- run_experiment(nl)
save_results(results, "riot-model",
  keep = c("sd_threshold", "random_seed", "step", "rioters", "riot_share")
)
