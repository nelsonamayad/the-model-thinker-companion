# Rational-actor model: Cobb-Douglas consumer, U = C^(1 - a) * H^a.
# Deterministic: no random numbers.
income <- 6000
price <- 20 # price of housing per square metre
a <- 1 / 3 # housing exponent (the book's value)

# Numerical maximization, to check the closed form p * H = a * I.
utility <- function(h) (income - price * h)^(1 - a) * h^a
best <- optimize(utility, c(0, income / price), maximum = TRUE)$maximum
cat(sprintf(
  "Optimal housing: %.1f m2 (closed form %.1f)\n",
  best, a * income / price
))
cat(sprintf("Share of income on housing: %.3f\n", price * best / income))

# The share does not depend on the price.
prices <- c(10, 20, 40)
h_star <- sapply(prices, function(p) {
  optimize(function(h) (income - p * h)^(1 - a) * h^a,
    c(0, income / p),
    maximum = TRUE
  )$maximum
})
print(data.frame(price = prices, housing = h_star, share = prices * h_star /
  income))

h <- seq(1, income / price, length.out = 200)
plot(h, income - price * h,
  type = "l", lwd = 2, col = "#d95f02",
  xlab = "Housing H", ylab = "Other consumption C"
)
u_star <- utility(best)
lines(h, (u_star / h^a)^(1 / (1 - a)), col = "grey50")
points(best, income - price * best, pch = 19, col = "#148a91")
