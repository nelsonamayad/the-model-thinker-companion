# Renewable resource extraction: sustainable harvest and collapse.
# Deterministic: no random numbers.
g <- 0.05 # growth rate
harvest <- 50 # harvest per year
years <- 100
r0 <- 1000

stock <- numeric(years + 1)
stock[1] <- r0
for (t in 1:years) {
  stock[t + 1] <- max(0, (1 + g) * (stock[t] - min(stock[t], harvest)))
}
cat(sprintf("Sustainable harvest g/(1+g) R = %.1f\n", g / (1 + g) * r0))
cat("Year of collapse:", which(stock == 0)[1] - 1, "\n")

plot(0:years, stock,
  type = "l", lwd = 2, col = "#148a91", xlab = "Year",
  ylab = "Stock"
)
abline(h = r0, lty = 2)
