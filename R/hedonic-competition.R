# Hedonic regression: recover implicit prices of house attributes.
per_sqft <- 100
per_bed <- 20000
per_min <- -2000 # per minute of daily commute
noise <- 25000
set.seed(39)

n <- 200
beds <- sample(1:5, n, replace = TRUE)
sqft <- 600 + 350 * beds + rnorm(n, 0, 250)
commute <- runif(n, 5, 60)
price <- 50000 + per_sqft * sqft + per_bed * beds + per_min * commute +
  rnorm(n, 0, noise)

fit <- lm(price ~ sqft + beds + commute)
print(round(coef(summary(fit)), 1))
cat(sprintf(
  "Implied value of an hour of commuting: $%.0f\n",
  -coef(fit)["commute"] / (4000 / 60)
))

plot(fitted(fit), price,
  pch = 19, col = "grey60", xlab = "Predicted price",
  ylab = "Sale price"
)
abline(0, 1, col = "#148a91", lwd = 2)
