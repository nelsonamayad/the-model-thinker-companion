# Random walks: square-root spread and power-law return times.
steps <- 500
set.seed(27)

paths <- replicate(8, cumsum(sample(c(-1, 1), steps, replace = TRUE)))
cat(sprintf(
  "sd after %d steps: theory %.1f, across 8 walks %.1f\n",
  steps, sqrt(steps), sd(paths[steps, ])
))

first_return <- function(cap = 10000) {
  v <- 0
  for (t in 1:cap) {
    v <- v + sample(c(-1, 1), 1)
    if (v == 0) {
      return(t)
    }
  }
  NA
}
returns <- replicate(5000, first_return())
cat(sprintf(
  "Returned at step 2: %.1f%%; not back after 10000 steps: %.1f%%\n",
  100 * mean(returns == 2, na.rm = TRUE) * mean(!is.na(returns)),
  100 * mean(is.na(returns))
))
cat("2.5% value at risk over 9 periods of +/- 1000:", 2 * 1000 * sqrt(9), "\n")

matplot(paths,
  type = "l", lty = 1, xlab = "Step", ylab = "Value",
  col = hcl.colors(8)
)
lines(2 * sqrt(1:steps), lty = 2)
lines(-2 * sqrt(1:steps), lty = 2)
