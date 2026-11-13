# Zero-sum 2x2 games: saddle points or mixed-strategy equilibria.
# Deterministic: no random numbers.
solve_2x2 <- function(m) {
  for (i in 1:2) {
    for (j in 1:2) {
      if (m[i, j] == min(m[i, ]) && m[i, j] == max(m[, j])) {
        return(c(p = 2 - i, q = 2 - j, value = m[i, j])) # pure strategies
      }
    }
  }
  den <- m[1, 1] - m[1, 2] - m[2, 1] + m[2, 2]
  c(
    p = (m[2, 2] - m[2, 1]) / den, q = (m[2, 2] - m[1, 2]) / den,
    value = (m[1, 1] * m[2, 2] - m[1, 2] * m[2, 1]) / den
  )
}
games <- list(
  matching_pennies = matrix(c(1, -1, -1, 1), 2, byrow = TRUE),
  minimize_risk = matrix(c(-10, 0, 10, 0), 2, byrow = TRUE),
  penalty_kick = matrix(c(0.58, 0.95, 0.93, 0.70), 2, byrow = TRUE)
)
print(round(t(sapply(games, solve_2x2)), 3))

m <- games$penalty_kick
p <- seq(0, 1, by = 0.01)
plot(p, p * m[1, 1] + (1 - p) * m[2, 1],
  type = "l", lwd = 2,
  col = "#148a91", ylim = range(m), xlab = "Probability of row 1",
  ylab = "Row player's expected payoff"
)
lines(p, p * m[1, 2] + (1 - p) * m[2, 2], lwd = 2, col = "#d95f02")
