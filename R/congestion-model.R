# Congestion model: equilibrium use is twice the social optimum.
# Deterministic: no random numbers.
b <- 100 # maximal benefit
theta <- 1 # congestion parameter

total <- function(m) m * (b - theta * m)
optimum <- optimize(total, c(0, b / theta), maximum = TRUE)$maximum
equilibrium <- b / theta # users join until utility reaches zero
cat(sprintf(
  "Optimum %.0f users, each %.1f; equilibrium %.0f users, each %.1f\n",
  optimum, b - theta * optimum, equilibrium, b - theta * equilibrium
))

# Two parks: M in park 1 (utility N - M), N - M in park 2 (utility 3M).
n <- 100
park_total <- function(m) m * (n - m) + (n - m) * 3 * m
cat(sprintf(
  "Parks: optimum M = %.0f (total %.0f); equilibrium M = %.0f (total %.0f)\n",
  optimize(park_total, c(0, n), maximum = TRUE)$maximum, park_total(n / 2),
  n / 4, park_total(n / 4)
))

m <- seq(0, 1.2 * b / theta, length.out = 200)
plot(m, total(m),
  type = "l", lwd = 2, col = "#d95f02", xlab = "Users",
  ylab = "Total utility"
)
abline(v = c(optimum, equilibrium), lty = c(2, 1))
