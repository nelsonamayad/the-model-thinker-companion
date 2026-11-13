# Replicator dynamics: the best alternative takes over from a rare start.
# Deterministic: no random numbers.
rewards <- c(best = 11, second = 9, third = 8, fourth = 7)
start <- 0.01 # initial share of the best alternative
periods <- 100

p <- c(start, rep((1 - start) / 3, 3))
shares <- matrix(NA, periods + 1, 4, dimnames = list(NULL, names(rewards)))
shares[1, ] <- p
for (t in 1:periods) {
  p <- p * rewards / sum(p * rewards) # P(K) * pi(K) / average pi
  shares[t + 1, ] <- p
}
majority <- which(shares[, 1] > 0.5)[1] - 1
cat("Best alternative is a majority from period", majority, "\n")
cat(sprintf(
  "Share after %d periods: %.3f\n", periods,
  shares[periods + 1, 1]
))

matplot(0:periods, shares,
  type = "l", lty = 1, lwd = 2,
  col = c("#148a91", "#d95f02", "#7570b3", "grey60"),
  xlab = "Period", ylab = "Share of population"
)
