# Lyapunov functions: the race to the bottom must reach zero.
players <- 20
set.seed(32)

props <- sample(0:49, players, replace = TRUE)
highest <- max(props)
while (max(props) > 0) {
  target <- floor(2 / 3 * mean(props)) - 1 # at least 1 below 2/3 of mean
  props <- pmax(0, target - sample(0:2, players, replace = TRUE))
  highest <- c(highest, max(props))
}
cat(
  "Highest proposal by period:", highest, "\n",
  "Reached zero in", length(highest) - 1, "periods; bound",
  highest[1], "\n"
)
stopifnot(all(diff(highest) <= -1)) # falls by at least 1 each period

plot(seq_along(highest) - 1, highest,
  type = "b", pch = 19,
  col = "#d95f02", xlab = "Period", ylab = "Highest proposal F"
)
abline(a = highest[1], b = -1, lty = 2)
