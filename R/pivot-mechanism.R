# The pivot mechanism versus majority vote with equal cost shares.
# Deterministic: no random numbers.
pivot <- function(v, cost) {
  build <- sum(v) >= cost
  others <- sum(v) - v
  tax <- ifelse(build & others < cost, cost - others, 0)
  list(build = build, tax = tax, collected = sum(tax))
}
# Page's example: (60, 120, 150), cost 300.
print(pivot(c(60, 120, 150), 300))

v <- c(10, 30, 60, 120, 150)
cost <- 300
p <- pivot(v, cost)
share <- cost / length(v)
majority <- sum(v >= share) > length(v) / 2
cat(sprintf(
  "Should build: %s; pivot builds: %s (taxes %.0f); majority builds: %s\n",
  sum(v) > cost, p$build, p$collected, majority
))

barplot(rbind(v, p$tax, if (majority) share else 0),
  beside = TRUE,
  col = c("grey60", "#148a91", "#d95f02"), names.arg = paste0("R", 1:5),
  legend.text = c("Value", "Pivot tax", "Majority share")
)
