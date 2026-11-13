# The friendship paradox in a preferential-attachment network.
suppressPackageStartupMessages(library(igraph))
n <- 1000
set.seed(18)

g <- sample_pa(n, m = 3, directed = FALSE)
k <- degree(g)
friends <- sapply(adjacent_vertices(g, V(g)), function(nb) mean(k[nb]))

cat(sprintf("Average person: %.1f friends\n", mean(k)))
cat(sprintf(
  "Average friend: %.1f friends (k + var/k = %.1f)\n",
  sum(k^2) / sum(k), mean(k) + var(k) * (n - 1) / n / mean(k)
))
cat(sprintf(
  "%.0f%% of people have friends with more friends on average\n",
  100 * mean(friends > k)
))

plot(k, friends,
  log = "xy", pch = 19, col = adjustcolor("#d95f02", 0.4),
  xlab = "My friends", ylab = "My friends' average friends"
)
abline(0, 1, lty = 2)
