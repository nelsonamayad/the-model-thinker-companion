# Repeated Prisoners' Dilemma: a round-robin tournament with mistakes.
pay <- c(T = 5, R = 3, P = 1, S = 0)
delta <- 0.95 # continuation probability
noise <- 0.05 # chance an intended move is flipped
set.seed(43)

payoff <- function(a, b) {
  if (a == "C") {
    if (b == "C") pay[["R"]] else pay[["S"]]
  } else {
    if (b == "C") pay[["T"]] else pay[["P"]]
  }
}
strategies <- list(
  all_c = function(me, them) "C",
  all_d = function(me, them) "D",
  tit_for_tat = function(me, them) if (length(them)) tail(them, 1) else "C",
  grim = function(me, them) if ("D" %in% them) "D" else "C",
  wsls = function(me, them) {
    if (!length(me)) {
      return("C")
    }
    won <- payoff(tail(me, 1), tail(them, 1)) >= pay[["R"]]
    if (won) tail(me, 1) else setdiff(c("C", "D"), tail(me, 1))
  }
)
flip <- function(m) if (runif(1) < noise) setdiff(c("C", "D"), m) else m
play <- function(f, g) {
  a <- c()
  b <- c()
  repeat {
    x <- flip(f(a, b))
    y <- flip(g(b, a))
    a <- c(a, x)
    b <- c(b, y)
    if (runif(1) > delta) break
  }
  mean(mapply(payoff, a, b))
}
scores <- sapply(strategies, function(f) {
  mean(sapply(strategies, function(g) mean(replicate(20, play(f, g)))))
})
print(round(sort(scores, decreasing = TRUE), 2))
cat(sprintf(
  "Grim Trigger needs delta >= %.2f\n",
  (pay[["T"]] - pay[["R"]]) / (pay[["T"]] - pay[["P"]])
))

barplot(sort(scores), horiz = TRUE, las = 1, col = "#148a91")
