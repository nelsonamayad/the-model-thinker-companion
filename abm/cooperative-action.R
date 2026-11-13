# The cooperative action model: how far does cooperation spread from a few
# seeded cooperators, as the benefit-cost ratio and the network's degree
# change? NetLogo model: abm/cooperative-action.nlogo.
# Output: data/cooperative-action.csv (one row per setting and seed).
source("abm/_nlrx.R")

nl <- nl_model("cooperative-action")
nl@experiment <- experiment(
  expname = "ratio_degree_sweep",
  outpath = tempdir(),
  repetition = 1,
  tickmetrics = "false", # measure once, when the network is filled
  idsetup = "setup",
  idgo = "go",
  runtime = 1000, # cap; runs stop when no empty node touches an occupied one
  metrics = c("coop-share"),
  variables = list(
    "benefit-ratio" = list(values = c(1, 1.5, 2, 3, 4, 6, 8, 10)),
    "mean-degree" = list(values = c(4, 10))
  ),
  constants = list("population" = 500)
)
set.seed(22) # makes nlrx draw the same NetLogo seeds every time
nl@simdesign <- simdesign_ff(nl, nseeds = 6)

results <- run_experiment(nl)
save_results(results, "cooperative-action",
  keep = c("benefit_ratio", "mean_degree", "random_seed", "step", "coop_share")
)
