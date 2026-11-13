# Preferential attachment: entity sizes follow a power law.
arrivals <- 20000
p <- 0.05 # chance an arrival founds a new entity
set.seed(9)

grow <- function(preferential) {
  owner <- integer(arrivals)
  owner[1] <- 1
  sizes <- 1
  for (t in 2:arrivals) {
    if (runif(1) < p) {
      e <- length(sizes) + 1
      sizes[e] <- 0
    } else if (preferential) {
      e <- owner[sample.int(t - 1, 1)] # a random member's entity
    } else {
      e <- sample.int(length(sizes), 1) # any entity, ignoring size
    }
    sizes[e] <- sizes[e] + 1
    owner[t] <- e
  }
  sort(sizes, decreasing = TRUE)
}

pref <- grow(TRUE)
unif <- grow(FALSE)
top <- 5:min(500, length(pref)) # skip the noisy very top
slope <- coef(lm(log(pref[top]) ~ log(top)))[2]
cat(sprintf(
  "%d entities; largest holds %.1f%%; rank-size slope %.2f (theory %.2f)\n",
  length(pref), 100 * pref[1] / arrivals, slope, -(1 - p)
))

plot(seq_along(pref), pref,
  log = "xy", type = "l", lwd = 2, col = "#148a91",
  xlab = "Rank", ylab = "Size"
)
lines(seq_along(unif), unif, lwd = 2, col = "grey60")
