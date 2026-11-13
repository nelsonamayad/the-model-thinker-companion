# Prospect theory: the gain and loss frames of the same choice.
# Deterministic: no random numbers.
alpha <- 0.88 # curvature for gains and losses
lambda <- 2.25 # loss aversion
gamma <- 0.61 # probability weighting
sure <- 400 # sure gain in the gain frame

v <- function(x) ifelse(x >= 0, abs(x)^alpha, -lambda * abs(x)^alpha)
w <- function(p) p^gamma / (p^gamma + (1 - p)^gamma)^(1 / gamma)

gain <- c(sure = v(sure), gamble = w(0.5) * v(1000))
loss <- c(sure = v(-(1000 - sure)), gamble = w(0.5) * v(-1000))
cat("Gain frame values:", round(gain, 1), "-> choose", names(which.max(gain)))
cat("\nLoss frame values:", round(loss, 1), "-> choose", names(which.max(loss)))
cat("\n")

x <- seq(-1000, 1000, length.out = 401)
plot(x, v(x),
  type = "l", lwd = 2, col = "#148a91",
  xlab = "Outcome relative to reference point", ylab = "Value v(x)"
)
abline(h = 0, v = 0, col = "grey60")
