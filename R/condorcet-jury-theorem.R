# Condorcet jury theorem: accuracy of a majority vote.
# Deterministic: exact binomial sums, no random numbers.
p <- 0.6 # accuracy of each classifier
n_max <- 101 # largest (odd) group
rho <- 0.3 # chance of copying one shared signal (our extension)

maj <- function(n, q) {
  sum(dbinom(((n + 1) / 2):n, n, q))
}
sizes <- seq(1, n_max, by = 2)
independent <- sapply(sizes, maj, q = p)
correlated <- sapply(sizes, function(n) {
  p * maj(n, rho + (1 - rho) * p) + (1 - p) * maj(n, (1 - rho) * p)
})

cat(sprintf("One classifier: %.0f%% correct\n", 100 * p))
cat(sprintf(
  "Majority of %d independent: %.1f%%; correlated: %.1f%%\n",
  n_max, 100 * tail(independent, 1), 100 * tail(correlated, 1)
))

plot(sizes, independent,
  type = "l", lwd = 2, col = "#148a91",
  ylim = c(0.4, 1), xlab = "Number of classifiers N",
  ylab = "Majority correct"
)
lines(sizes, correlated, lwd = 2, col = "#d95f02")
abline(h = p, lty = 2)
