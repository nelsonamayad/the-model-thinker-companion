# Solow growth model: capital alone levels off; innovation sustains growth.
# Deterministic: no random numbers.
s <- 0.2 # savings rate
d <- 0.1 # depreciation rate
g <- 0.015 # annual technology growth (second economy)
years <- 100
labour <- 100

run <- function(g_a) {
  k <- 10
  a <- 1
  out <- numeric(years + 1)
  for (t in 0:years) {
    o <- a * sqrt(labour) * sqrt(k)
    out[t + 1] <- o
    k <- k + s * o - d * k
    a <- a * (1 + g_a)
  }
  out
}
flat <- run(0)
innov <- run(g)
o_star <- labour * s / d # A = 1

cat(sprintf("Equilibrium output O* = A^2 L s / d = %.0f\n", o_star))
cat(sprintf(
  "Year %d: capital only %.0f (growth %.2f%%), with innovation %.0f\n",
  years, flat[years + 1], 100 * (flat[years + 1] / flat[years] - 1),
  innov[years + 1]
))

plot(0:years, innov,
  type = "l", lwd = 2, col = "#d95f02",
  xlab = "Year", ylab = "Output"
)
lines(0:years, flat, lwd = 2, col = "#148a91")
abline(h = o_star, lty = 2)
