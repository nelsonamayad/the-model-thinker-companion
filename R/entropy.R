# Information entropy and block entropies of binary sequences.
q <- 0.85 # stickiness: chance of repeating the last symbol
len <- 2000
set.seed(25)

entropy2 <- function(p) -sum(p[p > 0] * log2(p[p > 0]))
block_entropy <- function(x, k) {
  blocks <- sapply(1:(length(x) - k + 1), function(j) {
    paste(x[j:(j + k - 1)], collapse = "")
  })
  entropy2(table(blocks) / length(blocks))
}

sticky <- numeric(len)
sticky[1] <- rbinom(1, 1, 0.5)
for (i in 2:len) {
  sticky[i] <- if (runif(1) < q) sticky[i - 1] else 1 - sticky[i - 1]
}
sources <- list(
  random = rbinom(len, 1, 0.5),
  sticky = sticky,
  periodic = rep(c(0, 1, 1), length.out = len),
  elections = as.integer(strsplit(chartr(
    "RD", "10",
    "RRRRDRDRRRRDDRRRDDDDDRRDDRRDRRRDDRRDDR"
  ), "")[[1]])
)
h <- sapply(sources, function(x) sapply(1:8, function(k) block_entropy(x, k)))
print(round(h, 2))

matplot(1:8, h,
  type = "b", pch = 19, lty = 1,
  col = c("grey50", "#148a91", "#d95f02", "#7570b3"),
  xlab = "Block length k", ylab = "Block entropy (bits)"
)
abline(0, 1, lty = 2)
