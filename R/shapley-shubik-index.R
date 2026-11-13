# Shapley-Shubik index: share of orderings in which a member is pivotal.
# Deterministic: enumerates every ordering.
votes <- c(A = 40, B = 39, C = 11, D = 11) # Page's example
quota <- 51

perms <- function(v) {
  if (length(v) <= 1) {
    return(list(v))
  }
  out <- list()
  for (i in seq_along(v)) {
    for (p in perms(v[-i])) out[[length(out) + 1]] <- c(v[i], p)
  }
  out
}
pivots <- setNames(numeric(length(votes)), names(votes))
orders <- perms(names(votes))
for (o in orders) {
  running <- cumsum(votes[o])
  pivots[o[which(running >= quota)[1]]] <- pivots[o[which(running >=
    quota)[1]]] + 1
}
power <- pivots / length(orders)
print(round(rbind(vote_share = votes / sum(votes), power = power), 3))

barplot(rbind(votes / sum(votes), power),
  beside = TRUE,
  col = c("grey60", "#148a91"), ylim = c(0, 1),
  legend.text = c("Share of votes", "Power index")
)
