# Bernoulli urn: counts of gray balls in N draws with replacement.
gray <- 3
white <- 7
n_draws <- 200
set.seed(26)

p <- gray / (gray + white)
draws <- rbinom(n_draws, 1, p)
cat(sprintf(
  "Expected %.1f gray, sd %.1f; this sequence had %d\n",
  n_draws * p, sqrt(n_draws * p * (1 - p)), sum(draws)
))
cat("Longest run of one colour:", max(rle(draws)$lengths), "\n")

counts <- rbinom(3000, n_draws, p)
cat(sprintf(
  "Within 2 sd in 3000 repetitions: %.0f%%\n",
  100 * mean(abs(counts - n_draws * p) <= 2 * sqrt(n_draws * p * (1 - p)))
))

running <- cumsum(draws) / seq_len(n_draws)
plot(running,
  type = "l", lwd = 2, col = "#148a91", ylim = c(0, 1),
  xlab = "Draws", ylab = "Share gray"
)
band <- 2 * sqrt(p * (1 - p) / seq_len(n_draws))
lines(p + band, lty = 3)
lines(p - band, lty = 3)
abline(h = p, lty = 2)
