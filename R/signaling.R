# Discrete signaling: pooling, separating or partial pooling.
# Deterministic: no random numbers.
signal_outcome <- function(strong, benefit, c_strong, c_weak, n = 100) {
  if (c_weak < benefit / n) {
    return("pooling")
  }
  if (benefit / (strong + 1) < c_weak) {
    return(if (c_strong < benefit / strong) "separating" else "no signaling")
  }
  sprintf(
    "partial pooling (%d weak signal)",
    floor(benefit / c_weak - strong)
  )
}
for (cw in c(5, 30, 60)) {
  cat("Weak cost", cw, "->", signal_outcome(20, 1000, 10, cw), "\n")
}
# Continuous signal that separates, and whether strong types want it.
strong <- 20
weak <- 80
cat(sprintf("Separating signal M >= B/(S C) = %.2f\n", 1000 / (strong * 30)))
cat("All strong types separate (C W >= c N):", 30 * weak >= 10 * 100, "\n")

n_sig <- 1:100
plot(n_sig, 1000 / n_sig,
  log = "y", type = "l", lwd = 2, col = "#7570b3",
  xlab = "Number who signal", ylab = "Share of benefit"
)
abline(h = c(10, 30), col = c("#148a91", "#d95f02"), lwd = 2)
