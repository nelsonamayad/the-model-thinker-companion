# Revenue equivalence: three auction formats, same expected revenue.
n <- 4 # bidders
reps <- 3000
set.seed(48)

revenue <- t(replicate(reps, {
  v <- sort(runif(n), decreasing = TRUE)
  c(
    ascending = v[2], # price stops at the second-highest value
    second_price = v[2], # winner pays the second-highest bid
    first_price = (n - 1) / n * v[1] # winner pays own shaded bid
  )
}))
print(round(rbind(mean = colMeans(revenue), sd = apply(revenue, 2, sd)), 3))
cat(sprintf("Theory: (N - 1)/(N + 1) = %.3f\n", (n - 1) / (n + 1)))

boxplot(revenue, col = "#148a91", ylab = "Seller's revenue")
abline(h = (n - 1) / (n + 1), lty = 2)
