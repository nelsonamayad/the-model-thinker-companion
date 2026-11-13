# Central limit theorem: sums of N skewed draws look normal.
n_draws <- 20 # draws added up
reps <- 4000
set.seed(5)

sums <- replicate(reps, sum(rexp(n_draws, rate = 1))) # mean 1, sd 1
center <- n_draws * 1
spread <- 1 * sqrt(n_draws) # square-root rule

cat(sprintf(
  "Predicted sd %.2f, simulated sd %.2f\n",
  spread, sd(sums)
))
cat(sprintf(
  "Within 1 sd: %.0f%%; within 2 sd: %.0f%%\n",
  100 * mean(abs(sums - center) <= spread),
  100 * mean(abs(sums - center) <= 2 * spread)
))

hist(sums,
  breaks = 50, freq = FALSE, col = "grey80", border = "white",
  main = "", xlab = paste("Sum of", n_draws, "exponential draws")
)
curve(dnorm(x, center, spread), add = TRUE, lwd = 2, col = "#148a91")
