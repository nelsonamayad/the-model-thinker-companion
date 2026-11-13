# Network robustness: random failure versus targeted attack.
suppressPackageStartupMessages(library(igraph))
n <- 500
set.seed(20)

g <- sample_pa(n, m = 2, directed = FALSE) # hubs
giant <- function(g, removed) {
  h <- delete_vertices(g, removed)
  if (vcount(h) == 0) {
    return(0)
  }
  max(components(h)$csize) / n
}
f <- seq(0, 0.9, by = 0.02)
by_degree <- order(degree(g), decreasing = TRUE)
attack <- sapply(f, function(x) giant(g, by_degree[seq_len(round(x * n))]))
failure <- rowMeans(replicate(5, {
  o <- sample(n)
  sapply(f, function(x) giant(g, o[seq_len(round(x * n))]))
}))
cat(sprintf(
  "At 20%% removed: failure %.0f%%, attack %.0f%%\n",
  100 * failure[f == 0.2], 100 * attack[f == 0.2]
))

plot(f, failure,
  type = "l", lwd = 2, col = "#148a91", ylim = c(0, 1),
  xlab = "Share of nodes removed", ylab = "Giant component"
)
lines(f, attack, lwd = 2, col = "#d95f02")
