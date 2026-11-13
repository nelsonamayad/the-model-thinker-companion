# Lotka-Volterra predator-prey model, solved with deSolve.
# Deterministic: no random numbers.
suppressPackageStartupMessages(library(deSolve))
parms <- c(g = 1, a = 0.1, b = 0.02, d = 0.5)
start <- c(hares = 40, foxes = 9)

lv <- function(t, y, p) {
  with(as.list(c(y, p)), {
    list(c(g * hares - a * foxes * hares, b * foxes * hares - d * foxes))
  })
}
out <- ode(start, times = seq(0, 60, by = 0.05), func = lv, parms = parms)

cat(sprintf(
  "Equilibrium: %.1f hares (d/b), %.1f foxes (g/a)\n",
  parms[["d"]] / parms[["b"]], parms[["g"]] / parms[["a"]]
))
v <- with(as.list(parms), {
  b * out[, "hares"] - d * log(out[, "hares"]) +
    a * out[, "foxes"] - g * log(out[, "foxes"])
})
cat(sprintf("Conserved quantity drifts by %.1e\n", diff(range(v))))

par(mfrow = c(1, 2))
matplot(out[, 1], out[, 2:3],
  type = "l", lty = 1, lwd = 2,
  col = c("#148a91", "#d95f02"), xlab = "Time", ylab = "Population"
)
plot(out[, "hares"], out[, "foxes"],
  type = "l", col = "#7570b3", lwd = 2,
  xlab = "Hares", ylab = "Foxes"
)
points(parms[["d"]] / parms[["b"]], parms[["g"]] / parms[["a"]], pch = 3)
