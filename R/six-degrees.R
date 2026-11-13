# Six degrees of separation: people reachable with clique and random friends.
# Deterministic: no random numbers.
clique <- 100 # clique friends, all friends with each other
random <- 20 # random friends, who share no friends with you

a <- clique # paths ending in a clique step
b <- random # paths ending in a random step
reach <- numeric(8)
for (n in 1:8) {
  reach[n] <- a + b
  new_a <- clique * b # no two clique steps in a row
  b <- random * (a + b)
  a <- new_a
}
print(data.frame(steps = 1:8, people = reach, total = cumsum(reach)))
cat(
  "Steps needed to pass 8 billion:", which(cumsum(reach) >= 8e9)[1],
  "\n"
)

barplot(reach,
  names.arg = 1:8, log = "y", col = "#148a91",
  xlab = "Steps", ylab = "People reachable"
)
abline(h = 8e9, lty = 2)
