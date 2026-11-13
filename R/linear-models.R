# Linear models: an omitted variable biases a simple regression.
effect <- 2 # true effect of an hour of study
income_effect <- 5 # effect of a one-sd difference in family income
rho <- 0.6 # correlation between study hours and income
n <- 200
set.seed(12)

income <- rnorm(n)
hours <- 5 + 2 * (rho * income + sqrt(1 - rho^2) * rnorm(n))
score <- 50 + effect * hours + income_effect * income + rnorm(n, 0, 8)

simple <- lm(score ~ hours)
multiple <- lm(score ~ hours + income)
print(summary(simple)$coefficients["hours", ])
print(summary(multiple)$coefficients["hours", ])
cat(sprintf(
  "Hours only: %.2f points per hour; holding income fixed: %.2f (true %g)\n",
  coef(simple)["hours"], coef(multiple)["hours"], effect
))

plot(hours, score, pch = 19, col = "grey70", xlab = "Hours of study")
abline(simple, col = "#d95f02", lwd = 2)
abline(
  a = mean(score) - coef(multiple)["hours"] * mean(hours),
  b = coef(multiple)["hours"], col = "#148a91", lwd = 2
)
