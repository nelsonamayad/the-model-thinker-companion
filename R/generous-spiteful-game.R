# The generous/spiteful game: individual versus social learning.
n <- 20
periods <- 300
start <- 0.5
set.seed(53)

pay <- function(generous, n_g) if (generous) 1 + 2 * n_g else 2 + 2 * n_g

# Individual reinforcement learning, aspiration = own average payoff.
w <- matrix(50, n, 2) # columns: weight on G, weight on S
total <- numeric(n)
share_rl <- numeric(periods)
for (t in 1:periods) {
  g <- runif(n) < w[, 1] / rowSums(w)
  n_g <- sum(g)
  share_rl[t] <- n_g / n
  for (i in 1:n) {
    p <- pay(g[i], n_g)
    aspiration <- if (t == 1) p else total[i] / (t - 1)
    col <- if (g[i]) 1 else 2
    w[i, col] <- max(1, w[i, col] + p - aspiration)
    total[i] <- total[i] + p
  }
}
# Social learning: replicator dynamics on the share generous.
x <- numeric(periods)
x[1] <- start
for (t in 2:periods) {
  n_g <- x[t - 1] * n
  pg <- pay(TRUE, n_g)
  ps <- pay(FALSE, n_g)
  x[t] <- x[t - 1] * pg / (x[t - 1] * pg + (1 - x[t - 1]) * ps)
}
cat(sprintf(
  "Share generous after %d periods: individual %.2f, social %.2f\n",
  periods, share_rl[periods], x[periods]
))

plot(share_rl,
  type = "l", lwd = 2, col = "#148a91", ylim = c(0, 1),
  xlab = "Period", ylab = "Share generous"
)
lines(x, lwd = 2, col = "#d95f02")
