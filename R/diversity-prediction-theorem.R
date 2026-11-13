# Diversity prediction theorem: crowd error = average error - diversity.
n_models <- 12
spread <- 12 # sd of each model's own error
bias <- 3 # error shared by every model
truth <- 100
set.seed(11)

m <- truth + bias + rnorm(n_models, 0, spread)
m_bar <- mean(m)
crowd <- (m_bar - truth)^2
avg_err <- mean((m - truth)^2)
diversity <- mean((m - m_bar)^2)

cat(sprintf("Average prediction: %.1f (truth %d)\n", m_bar, truth))
cat(sprintf(
  "Crowd error %.1f = average error %.1f - diversity %.1f\n",
  crowd, avg_err, diversity
))
cat("Models that beat the average:", sum((m - truth)^2 < crowd), "\n")

barplot(c(avg_err, diversity, crowd),
  names.arg = c("Average error", "Diversity", "Crowd error"),
  col = c("grey60", "#d95f02", "#148a91"), ylab = "Squared error"
)
