# The effort game: equilibrium effort, checked by best-response dynamics.
prize <- 1000
n <- 5
set.seed(42)

each <- function(k) (k - 1) * prize / k^2
cat(sprintf(
  "Equilibrium: %.0f each, %.0f in total\n",
  each(n), n * each(n)
))

effort <- runif(n, 0, prize / 2)
for (k in 1:200) {
  for (i in 1:n) {
    others <- sum(effort[-i])
    effort[i] <- max(0, sqrt(prize * others) - others) # best response
  }
}
cat("Best-response dynamics settle at:", round(effort), "\n")

sizes <- 2:50
plot(sizes, each(sizes),
  type = "l", lwd = 2, col = "#148a91",
  ylim = c(0, prize), xlab = "Contestants", ylab = "Effort"
)
lines(sizes, sizes * each(sizes), lwd = 2, col = "#d95f02")
abline(h = prize, lty = 2)
