# Balancing process: add a ball of the opposite colour; urns converge to 1/2.
draws <- 500
set.seed(29)

urn <- function(balancing) {
  w <- 1
  g <- 1
  share <- numeric(draws)
  for (t in 1:draws) {
    white <- runif(1) < w / (w + g)
    if (balancing == white) g <- g + 1 else w <- w + 1
    share[t] <- w / (w + g)
  }
  share
}
bal <- replicate(12, urn(TRUE))
pol <- replicate(12, urn(FALSE))
cat("Final shares, balancing:", round(range(bal[draws, ]), 3), "\n")
cat("Final shares, Polya:    ", round(range(pol[draws, ]), 3), "\n")

matplot(pol,
  type = "l", lty = 1, col = "grey70", ylim = c(0, 1),
  xlab = "Draws", ylab = "Share white"
)
matlines(bal, lty = 1, col = "#148a91")
abline(h = 0.5, lty = 2)
