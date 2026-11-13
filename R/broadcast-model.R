# Broadcast model: fit the broadcast probability and market size from two
# periods of sales, then project. Deterministic: no random numbers.
first <- 20000 # sales in period 1 (I_1)
second <- 16000 # new sales in period 2 (I_2 - I_1)

p_broad <- 1 - second / first
n_pop <- first / p_broad
cat(sprintf("P_broad = %.2f, N_POP = %.0f\n", p_broad, n_pop))

informed <- numeric(16) # informed[t + 1] is I_t
for (t in 1:15) {
  informed[t + 1] <- informed[t] + p_broad * (n_pop - informed[t])
}
new_sales <- diff(informed)
cat("Predicted new sales in period 3:", round(new_sales[3]), "\n")

barplot(new_sales,
  names.arg = 1:15, col = c(rep("#d95f02", 2), rep("#148a91", 13)),
  xlab = "Period", ylab = "New buyers"
)
