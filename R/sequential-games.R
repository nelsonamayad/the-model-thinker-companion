# Sequential games: backward induction in the Market Entry Game.
# Deterministic: no random numbers.
payoffs <- list(
  exit = c(entrant = 0, firm = 5),
  accept = c(entrant = 2, firm = 2),
  compete = c(entrant = -1, firm = 0)
)

# Step 1: the firm's choice after entry.
firm_choice <- if (payoffs$accept["firm"] >= payoffs$compete["firm"]) {
  "accept"
} else {
  "compete"
}
# Step 2: the entrant anticipates it.
entrant_choice <- if (payoffs[[firm_choice]]["entrant"] >
  payoffs$exit["entrant"]) {
  "enter"
} else {
  "exit"
}
cat("Subgame perfect equilibrium:", entrant_choice, "and", firm_choice, "\n")

# Chain store with 20 markets: accommodate all, or fight k entrants and
# (if reputation works) keep the rest out.
markets <- 20
fights <- 0:markets
reputation <- fights * payoffs$compete["firm"] +
  (markets - fights) * payoffs$exit["firm"]
cat("Accommodate all:", markets * payoffs$accept["firm"], "\n")
cat("Fight first 2, then deter:", reputation[3], "\n")

plot(fights, reputation,
  type = "b", pch = 19, col = "#d95f02",
  xlab = "Entrants fought before deterrence works", ylab = "Firm's profit"
)
abline(h = markets * payoffs$accept["firm"], lty = 2)
