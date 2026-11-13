# Network statistics and a Monte Carlo test against random networks.
suppressPackageStartupMessages(library(igraph))
n <- 60
k <- 4 # mean degree
beta <- 0.1 # rewiring probability of the small world
set.seed(16)

g <- sample_smallworld(1, n, k / 2, beta) # Watts-Strogatz
stats <- function(x) {
  c(
    path_length = mean_distance(x),
    clustering = transitivity(x, type = "average")
  )
}
observed <- stats(g)
cat(sprintf(
  "Mean degree %.1f, max betweenness %.0f\n", mean(degree(g)),
  max(betweenness(g))
))
print(round(observed, 3))

# 100 random networks with the same numbers of nodes and edges.
random <- t(replicate(100, stats(sample_gnm(n, ecount(g)))))
print(round(colMeans(random), 3))
z <- (observed["clustering"] - mean(random[, "clustering"])) /
  sd(random[, "clustering"])
cat(sprintf("Clustering is %.0f sd above random networks'\n", z))

plot(random,
  pch = 19, col = "grey70", xlab = "Average path length",
  ylab = "Clustering", ylim = range(c(random[, 2], observed[2]))
)
points(observed[1], observed[2], pch = 19, col = "#d95f02", cex = 2)
