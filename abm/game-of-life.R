# The Game of Life: how does the share of live cells evolve from random
# starting densities? NetLogo model: abm/game-of-life.nlogo.
# Output: data/game-of-life.csv (one row per initial density, seed and
# sampled tick).
source("abm/_nlrx.R")

nl <- nl_model("game-of-life")
nl@experiment <- experiment(
  expname = "density_sweep",
  outpath = tempdir(),
  repetition = 1,
  tickmetrics = "true", # record the trajectory
  evalticks = seq(0, 400, by = 10),
  idsetup = "setup",
  idgo = "go",
  runtime = 400,
  metrics = c("density", "changed"),
  variables = list(
    "initial-density" = list(values = c(5, 10, 20, 35, 50, 65, 80))
  ),
  constants = list()
)
set.seed(31) # makes nlrx draw the same NetLogo seeds every time
nl@simdesign <- simdesign_ff(nl, nseeds = 5)

results <- run_experiment(nl)
save_results(results, "game-of-life",
  keep = c("initial_density", "random_seed", "step", "density", "changed")
)
