# Reinforcement learning with an aspiration equal to the average reward.
rewards <- c(apple = 20, banana = 10) # Page's pancake example
gamma <- 1
periods <- 300
learners <- 200
set.seed(51)

prob_best <- numeric(periods)
for (l in 1:learners) {
  w <- c(50, 50)
  total <- 0
  for (t in 1:periods) {
    prob_best[t] <- prob_best[t] + w[1] / sum(w) / learners
    k <- sample(seq_along(w), 1, prob = w)
    aspiration <- if (t == 1) 5 else total / (t - 1)
    w[k] <- max(1, w[k] + gamma * (rewards[k] - aspiration))
    total <- total + rewards[k]
  }
}
cat(sprintf(
  "P(best) after 10, 50, 300 periods: %.2f %.2f %.2f\n",
  prob_best[10], prob_best[50], prob_best[300]
))

plot(prob_best,
  type = "l", lwd = 2, col = "#148a91", ylim = c(0, 1),
  xlab = "Period", ylab = "Probability of choosing the best"
)
abline(h = 0.5, lty = 2)
