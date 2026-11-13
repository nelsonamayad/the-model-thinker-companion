# Multi-armed bandits: sample-then-greedy versus Thompson sampling.
p <- c(0.55, 0.50, 0.40) # unknown success rates of three pitches
calls <- 1000
m <- 30 # trials per pitch before going greedy
set.seed(54)

run <- function(strategy) {
  s <- c(0, 0, 0)
  n <- c(0, 0, 0)
  regret <- 0
  for (t in 1:calls) {
    a <- if (strategy == "sample_greedy") {
      if (t <= 3 * m) (t - 1) %% 3 + 1 else which.max(s / n)
    } else {
      which.max(rbeta(3, 1 + s, 1 + n - s)) # Thompson sampling
    }
    n[a] <- n[a] + 1
    s[a] <- s[a] + rbinom(1, 1, p[a])
    regret <- regret + max(p) - p[a]
  }
  regret
}
regret <- sapply(c("sample_greedy", "thompson"), function(k) {
  mean(replicate(200, run(k)))
})
print(round(regret, 1))

# Page's Gittins example: try A first over ten periods.
cat("Expected reward when trying A first:", 0.5 * 540 +
  0.5 * mean(c(1160, 780, 720)), "\n")

barplot(regret, col = c("#d95f02", "#148a91"), ylab = "Successes lost")
