# Exponential growth, the rule of 72 and half-lives.
# Deterministic: no random numbers.
rate <- 10 # growth rate, percent per period
periods <- 40
v0 <- 100

t <- 0:periods
v <- v0 * (1 + rate / 100)^t
linear <- v0 + v0 * rate / 100 * t
cat(sprintf(
  "Doubling time: exact %.2f, rule of 72 %.2f periods\n",
  log(2) / log(1 + rate / 100), 72 / rate
))
cat(sprintf(
  "After %d periods: exponential %.0f, linear %.0f\n",
  periods, v[periods + 1], linear[periods + 1]
))

rates <- c(1, 2, 5, 10, 15, 20, 30)
print(data.frame(
  rate = rates, exact = log(2) / log(1 + rates / 100),
  rule_of_72 = 72 / rates
))

h <- 5 # half-life in periods
cat("Share left after 20 periods with a half-life of 5:", 0.5^(20 / h), "\n")

plot(t, v,
  type = "l", lwd = 2, col = "#148a91", xlab = "Period",
  ylab = "Value"
)
lines(t, linear, lty = 2, col = "grey50", lwd = 2)
