# Diffusion model: two apps with different spreading rates and markets.
# Deterministic: no random numbers.
diffuse <- function(p, n_pop, days = 60, i0 = 100) {
  informed <- numeric(days)
  informed[1] <- i0
  for (t in 2:days) {
    i <- informed[t - 1]
    informed[t] <- i + p * (i / n_pop) * (n_pop - i)
  }
  informed
}
app_a <- diffuse(0.4, 1e3) # fast, small market
app_b <- diffuse(0.3, 1e6) # slower, large market

print(round(cbind(day = 1:7, app_a = app_a[1:7], app_b = app_b[1:7])))
cat("App B overtakes A on day", which(app_b > app_a)[1], "\n")

plot(1:60, app_b,
  log = "y", type = "l", lwd = 2, col = "#d95f02",
  xlab = "Day", ylab = "Adopters"
)
lines(1:60, app_a, lwd = 2, col = "#148a91")
