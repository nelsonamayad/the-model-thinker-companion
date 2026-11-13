# The forest fire model: how do tree density and the distribution of fire
# sizes change as lightning becomes rarer (g closer to 1)?
# NetLogo model: abm/forest-fire-model.nlogo. Output:
# data/forest-fire-model.csv (one row per g, seed and fire-size bin).
source("abm/_nlrx.R")

nl <- nl_model("forest-fire-model")
nl@experiment <- experiment(
  expname = "growth_sweep",
  outpath = tempdir(),
  repetition = 1,
  tickmetrics = "false", # measure once, at the end of the run
  idsetup = "setup",
  idgo = "go",
  runtime = 250, # ticks; each tick is one step per site
  metrics = c("mean-density", "largest-fire", "fires-recorded", "fire-bins"),
  variables = list(
    "g" = list(values = c(0.9, 0.95, 0.98, 0.99, 0.995, 0.998))
  ),
  constants = list("burn-in" = 50)
)
set.seed(6) # makes nlrx draw the same NetLogo seeds every time
nl@simdesign <- simdesign_ff(nl, nseeds = 6)

results <- as.data.frame(run_experiment(nl))

# fire-bins arrives as a NetLogo list in a string, "[a b c ...]": expand it
# to one row per bin. Bin b holds fires of 2^b to 2^(b + 1) - 1 trees.
bins <- lapply(strsplit(gsub("\\[|\\]", "", results[["fire-bins"]]), " "),
  as.numeric)
long <- do.call(rbind, lapply(seq_along(bins), function(i) {
  data.frame(
    g = results$g[i], random_seed = results[["random-seed"]][i],
    mean_density = results[["mean-density"]][i],
    largest_fire = results[["largest-fire"]][i],
    fires = results[["fires-recorded"]][i],
    bin = seq_along(bins[[i]]) - 1, count = bins[[i]]
  )
}))
long <- long[long$count > 0 | long$bin <= 12, ]
save_results(long, "forest-fire-model",
  keep = c(
    "g", "random_seed", "mean_density", "largest_fire", "fires", "bin",
    "count"
  )
)
