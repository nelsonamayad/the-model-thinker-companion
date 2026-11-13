# Lognormal distribution: multiplicative versus additive shocks.
years <- 40
shock <- 0.12 # sd of each year's shock, as a share of the starting 100
people <- 5000
set.seed(8)

mult <- replicate(people, 100 * prod(pmax(0.01, 1 + rnorm(years, 0, shock))))
add <- replicate(people, 100 + sum(100 * rnorm(years, 0, shock)))

top1 <- function(v) {
  s <- sort(v, decreasing = TRUE)
  sum(s[seq_len(length(v) / 100)]) / sum(v)
}
cat(sprintf(
  "Multiplicative: median %.0f, mean %.0f, top 1%% share %.1f%%\n",
  median(mult), mean(mult), 100 * top1(mult)
))
cat(sprintf(
  "Additive:       median %.0f, mean %.0f, top 1%% share %.1f%%\n",
  median(add), mean(add), 100 * top1(add)
))

hist(mult[mult < quantile(mult, 0.99)],
  breaks = 60, col = "#148a91",
  border = "white", main = "", xlab = "Income after multiplicative shocks"
)
abline(v = c(median(mult), mean(mult)), lty = c(2, 1))
