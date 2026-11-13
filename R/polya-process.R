# Polya process: self-reinforcing urns settle at random limits.
white0 <- 1
gray0 <- 1
draws <- 500
set.seed(28)

polya <- function() {
  w <- white0
  g <- gray0
  share <- numeric(draws)
  for (t in 1:draws) {
    if (runif(1) < w / (w + g)) w <- w + 1 else g <- g + 1
    share[t] <- w / (w + g)
  }
  share
}
paths <- replicate(12, polya())
finals <- replicate(3000, tail(polya(), 1))
cat("Final shares of 3000 urns by decile (uniform if flat):\n")
print(round(quantile(finals, seq(0, 1, 0.1)), 2))
cat(sprintf(
  "Correlation of share after 20 draws with final share: %.2f\n",
  cor(paths[20, ], paths[draws, ])
))

par(mfrow = c(1, 2))
matplot(paths,
  type = "l", lty = 1, ylim = c(0, 1), xlab = "Draws",
  ylab = "Share white", col = hcl.colors(12)
)
hist(finals,
  breaks = 20, col = "#148a91", border = "white", main = "",
  xlab = "Final share white"
)
