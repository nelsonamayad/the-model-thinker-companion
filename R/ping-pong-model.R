# Ping-pong model: negative feedback with diverse or similar thresholds.
n <- 100
periods <- 80
set.seed(37)

run <- function(range_t) {
  thr <- runif(n, 0, range_t)
  act <- sample(c(-1, 1), n, replace = TRUE)
  s <- 0
  state <- numeric(periods)
  for (t in 1:periods) {
    s <- 0.5 * (sum(act) + s) + sample(c(-1, 1), 1)
    state[t] <- s
    act <- ifelse(abs(s) <= thr, act, -sign(s))
  }
  state
}
narrow <- run(10)
wide <- run(100)
cat(sprintf(
  "Mean |S| after period 20: range 10 -> %.1f, range 100 -> %.1f\n",
  mean(abs(narrow[21:periods])), mean(abs(wide[21:periods]))
))

plot(narrow,
  type = "l", lwd = 2, col = "#148a91", xlab = "Period",
  ylab = "State S"
)
lines(wide, lwd = 2, col = "grey60")
abline(h = 0)
