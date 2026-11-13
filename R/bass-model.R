# The Bass model: adoption by broadcast plus word of mouth.
# Deterministic: no random numbers.
p_broad <- 0.01 # chance per period of hearing from the source
p_diffuse <- 0.4 # chance per period of adopting from an adopter
n_pop <- 1e6 # relevant population
periods <- 40

adopted <- numeric(periods + 1) # adopted[t + 1] is I_t; I_0 = 0
broad <- numeric(periods + 1)
word <- numeric(periods + 1)
for (t in 1:periods) {
  susceptible <- n_pop - adopted[t]
  broad[t + 1] <- p_broad * susceptible
  word[t + 1] <- p_diffuse * (adopted[t] / n_pop) * susceptible
  adopted[t + 1] <- adopted[t] + broad[t + 1] + word[t + 1]
}

new <- broad + word
peak <- which.max(new) - 1
half <- which(adopted >= n_pop / 2)[1] - 1
cat("New adoptions peak in period", peak, "\n")
cat("Half the population has adopted by period", half, "\n")
cat(sprintf(
  "Word of mouth accounts for %.0f%% of adoptions\n",
  100 * sum(word) / adopted[periods + 1]
))

barplot(rbind(broad, word)[, -1] / n_pop,
  names.arg = 1:periods, col = c("#148a91", "#d95f02"),
  border = NA, xlab = "Period", ylab = "New adopters (share)",
  legend.text = c("Broadcast", "Word of mouth")
)
