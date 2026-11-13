# Spatial competition: two candidates best-respond and converge to the median.
set.seed(38)
voters <- pmin(10, pmax(0, ifelse(runif(2000) < 0.55,
  rnorm(2000, 3, 1), rnorm(2000, 7.5, 1)
))) # a polarized electorate

share <- function(a, b) {
  if (a == b) {
    return(0.5)
  }
  mean(ifelse(abs(voters - a) < abs(voters - b), 1,
    ifelse(abs(voters - a) == abs(voters - b), 0.5, 0)
  ))
}
grid <- seq(0, 10, by = 0.1)
best <- function(other) grid[which.max(sapply(grid, share, b = other))]

a <- 2
b <- 8.5
cat(sprintf("Starting shares: A %.3f\n", share(a, b)))
for (round in 1:120) { # each best response leapfrogs the rival
  if (round %% 2 == 1) a <- best(b) else b <- best(a)
}
cat(sprintf(
  "After best responses: A at %.1f, B at %.1f; median %.2f\n",
  a, b, median(voters)
))

hist(voters,
  breaks = 50, col = "grey80", border = "white", main = "",
  xlab = "Ideal point"
)
abline(v = c(a, b), col = c("#148a91", "#d95f02"), lwd = 3)
abline(v = median(voters), lty = 2)
