# Markov models: the statistical equilibrium is the left eigenvector of P
# with eigenvalue 1. Deterministic: no random numbers.
freedom <- matrix(
  c(
    0.95, 0.05, 0.00,
    0.10, 0.80, 0.10,
    0.05, 0.15, 0.80
  ),
  nrow = 3, byrow = TRUE,
  dimnames = list(
    c("free", "partly", "not_free"),
    c("free", "partly", "not_free")
  )
)
equilibrium <- function(P) {
  v <- Re(eigen(t(P))$vectors[, 1])
  v / sum(v)
}
print(round(equilibrium(freedom), 3)) # 0.625, 0.25, 0.125

# Convergence from two different starting points.
x_a <- c(1, 0, 0)
x_b <- c(0, 0, 1)
for (t in 1:40) {
  x_a <- x_a %*% freedom
  x_b <- x_b %*% freedom
}
print(round(rbind(x_a, x_b), 3))

# Sales-durability paradox: linoleum outsells tile 3:1 but wears out faster.
share_lin <- 3 / 4
floors <- matrix(
  c(
    1 - share_lin / 60, share_lin / 60,
    (1 - share_lin) / 10, 1 - (1 - share_lin) / 10
  ),
  nrow = 2, byrow = TRUE
)
cat("Tile, linoleum floors in equilibrium:", round(equilibrium(floors), 3))
cat("\n")

barplot(equilibrium(freedom),
  names.arg = colnames(freedom),
  col = c("#148a91", "#d95f02", "#7570b3"), ylab = "Long-run share"
)
