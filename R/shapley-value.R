# Shapley value of a three-player cooperative game, over all orderings.
# Deterministic: no random numbers.
v <- c(
  A = 10, B = 0, C = 0, AB = 60, AC = 40, BC = 10, ABC = 100
)
value <- function(players) {
  if (length(players) == 0) {
    return(0)
  }
  v[[paste(sort(players), collapse = "")]]
}

orders <- list(
  c("A", "B", "C"), c("A", "C", "B"), c("B", "A", "C"),
  c("B", "C", "A"), c("C", "A", "B"), c("C", "B", "A")
)
added <- t(sapply(orders, function(o) {
  out <- c(A = 0, B = 0, C = 0)
  for (k in seq_along(o)) {
    out[o[k]] <- value(o[1:k]) - value(o[seq_len(k - 1)])
  }
  out
}))
rownames(added) <- sapply(orders, paste, collapse = "")
print(added)
phi <- colMeans(added)
cat("Shapley values:", round(phi, 2), " total:", sum(phi), "\n")

barplot(phi, col = "#148a91", ylab = "Shapley value")
abline(h = v[["ABC"]] / 3, lty = 2)
