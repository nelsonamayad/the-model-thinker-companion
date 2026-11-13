# Categorization models: model error = categorization + valuation error.
n_cat <- 6 # number of equal-width categories
noise <- 120 # month-to-month noise in spending (sd)
households <- 300
set.seed(3)

x <- runif(households)
mu <- 400 + 300 * x + 150 * sin(3 * pi * x)
last_month <- mu + rnorm(households, 0, noise) # used to value categories
this_month <- mu + rnorm(households, 0, noise) # what we predict

decompose <- function(n) {
  cat_id <- pmin(n, floor(x * n) + 1)
  m_i <- tapply(last_month, factor(cat_id, levels = 1:n), mean)
  m_i[is.na(m_i)] <- mean(last_month)
  v_bar <- ave(this_month, cat_id)
  cat_err <- sum((this_month - v_bar)^2)
  val_err <- sum((m_i[cat_id] - v_bar)^2)
  total <- sum((this_month - mean(this_month))^2)
  c(cat_err = cat_err, val_err = val_err, r2 = 1 - (cat_err + val_err) / total)
}

res <- t(sapply(1:60, decompose))
model_err <- res[, "cat_err"] + res[, "val_err"]
cat(sprintf(
  "%d categories: R2 = %.2f; best is %d categories (R2 = %.2f)\n",
  n_cat, res[n_cat, "r2"], which.min(model_err),
  res[which.min(model_err), "r2"]
))

matplot(1:60, cbind(res[, 1:2], model_err) / 1e6,
  type = "l", lty = 1, lwd = 2, col = c("#7570b3", "#d95f02", "#148a91"),
  xlab = "Number of categories", ylab = "Squared error (millions)"
)
abline(v = n_cat, lty = 2)
