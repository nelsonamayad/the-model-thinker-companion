# NK model: count local peaks and run hill climbs on a rugged landscape.
n <- 12 # bits
k <- 3 # interactions per bit
set.seed(55)

partners <- lapply(1:n, function(i) sample(setdiff(1:n, i), k))
tables <- lapply(1:n, function(i) runif(2^(k + 1)))
bits <- function(s) as.integer(intToBits(s))[1:n]
value <- function(s) {
  b <- bits(s)
  mean(sapply(1:n, function(i) {
    idx <- sum(c(b[i], b[partners[[i]]]) * 2^(0:k)) + 1
    tables[[i]][idx]
  }))
}
v <- sapply(0:(2^n - 1), value)
flip <- function(s, i) bitwXor(s, 2^(i - 1))
is_peak <- sapply(0:(2^n - 1), function(s) {
  all(v[s + 1] >= v[sapply(1:n, function(i) flip(s, i)) + 1])
})
cat("Local peaks:", sum(is_peak), "of", 2^n, "strings\n")

climb <- function() {
  s <- sample(0:(2^n - 1), 1)
  repeat {
    nbrs <- sapply(sample(1:n), function(i) flip(s, i))
    better <- nbrs[v[nbrs + 1] > v[s + 1]]
    if (!length(better)) {
      return(v[s + 1])
    }
    s <- better[1]
  }
}
reached <- replicate(300, climb())
cat(sprintf("Hill climbs reaching the global peak: %.0f%%\n", 100 *
  mean(reached >= max(v) - 1e-12)))

hist(reached,
  breaks = 30, col = "#148a91", border = "white", main = "",
  xlab = "Value of the peak reached"
)
abline(v = max(v), lty = 2)
