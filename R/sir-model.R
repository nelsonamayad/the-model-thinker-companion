# SIR model: the book's discrete-time version, and the continuous-time
# version solved with deSolve. Deterministic: no random numbers.
suppressPackageStartupMessages(library(deSolve))
p_contact <- 0.5
p_spread <- 0.5
p_recover <- 0.1
vacc <- 0 # vaccinated share
n_pop <- 1e6
r0 <- p_contact * p_spread / p_recover
cat(sprintf(
  "R0 = %.2f; herd-immunity threshold 1 - 1/R0 = %.0f%%\n",
  r0, 100 * (1 - 1 / r0)
))

# Discrete time, lasting immunity (as on the page).
s <- n_pop * (1 - vacc) - 10
i <- 10
infected <- numeric(250)
for (t in 1:250) {
  new_cases <- min(s, p_contact * p_spread * i / n_pop * s)
  recoveries <- p_recover * i
  s <- s - new_cases
  i <- i + new_cases - recoveries
  infected[t] <- i / n_pop
}
cat(sprintf(
  "Discrete: peak %.1f%% infected in period %d\n",
  100 * max(infected), which.max(infected)
))

# Continuous time with deSolve: dS = -beta S I, dI = beta S I - gamma I.
sir <- function(t, y, parms) {
  with(as.list(c(y, parms)), {
    infect <- beta * s * i
    list(c(s = -infect, i = infect - gamma * i, r = gamma * i))
  })
}
out <- ode(
  y = c(s = 1 - vacc - 1e-5, i = 1e-5, r = vacc), times = 0:250,
  func = sir, parms = c(beta = p_contact * p_spread, gamma = p_recover)
)
cat(sprintf(
  "Continuous: peak %.1f%% at t = %d; %.0f%% ever infected\n",
  100 * max(out[, "i"]), out[which.max(out[, "i"]), "time"],
  100 * (out[251, "r"] - vacc)
))

matplot(out[, "time"], out[, c("s", "i", "r")],
  type = "l", lty = 1, lwd = 2, col = c("#148a91", "#d95f02", "#7570b3"),
  xlab = "Time", ylab = "Share of population"
)
