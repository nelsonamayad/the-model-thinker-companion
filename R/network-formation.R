# Quality and degree network formation.
suppressPackageStartupMessages(library(igraph))
n <- 300
d <- 2 # links made by each new node
mean_q <- 1
spread_q <- 0.2 # lognormal sd of quality
set.seed(17)

draw_q <- function() mean_q * exp(rnorm(1, -spread_q^2 / 2, spread_q))
deg <- rep(0, d)
q <- replicate(d, draw_q())
edges <- c()
for (t in (d + 1):n) {
  chosen <- sample.int(t - 1, d, prob = deg + q) # degree plus quality
  deg[chosen] <- deg[chosen] + 1
  deg <- c(deg, d)
  q <- c(q, draw_q())
  edges <- c(edges, rbind(t, chosen))
}
g <- make_graph(edges, n = n, directed = FALSE)

cat(sprintf(
  "Largest degree %d; cor(degree, earliness) %.2f; cor(degree, log q) %.2f\n",
  max(degree(g)), cor(degree(g), -(1:n)), cor(degree(g), log(q))
))
plot(1:n, degree(g),
  log = "y", pch = 19,
  col = hcl.colors(10)[cut(log(q), 10)], xlab = "Arrival order",
  ylab = "Final degree"
)
