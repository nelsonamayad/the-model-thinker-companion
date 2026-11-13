# Public good provision: social optimum versus equilibrium.
# Deterministic: no random numbers.
n <- 100
alpha <- 0.1 # weight on others' utility

welfare <- function(g) n * 2 * sqrt(g) - g # total utility net of incomes
# Check the closed forms numerically.
opt <- optimize(welfare, c(0, 4 * n^2), maximum = TRUE)$maximum
own <- function(g) 2 * sqrt(g) - g # one person's view, others' fixed at 0
eq <- optimize(own, c(0, 10), maximum = TRUE)$maximum
cat(sprintf(
  "Social optimum %.0f (N^2 = %d); equilibrium %.2f (= 1)\n",
  opt, n^2, eq
))
cat(sprintf(
  "With altruism %.2f: %.0f in total\n", alpha,
  (1 - alpha + alpha * n)^2
))

sizes <- 2:1000
plot(sizes, sizes^2,
  log = "xy", type = "l", lwd = 2, col = "#148a91",
  xlab = "Group size", ylab = "Public good provided"
)
lines(sizes, (1 - alpha + alpha * sizes)^2, lwd = 2, col = "#7570b3")
abline(h = 1, lwd = 2, col = "#d95f02")
