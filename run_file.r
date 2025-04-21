
# run_file.r

args <- commandArgs(trailingOnly = TRUE)
seed <- as.integer(args[1])
set.seed(seed)

df <- read.csv("cleaned_lendingclub_ccf_data.csv")
y <- df$CCF
X <- as.matrix(df[, -which(names(df) == "CCF")])
N <- nrow(X)
P <- ncol(X)

# rmvnorm（Cholesky ）
rmvnorm_manual <- function(n, mean, sigma) {
  L <- chol(sigma)
  z <- matrix(rnorm(length(mean) * n), ncol = length(mean))
  t(L) %*% t(z) + mean
}

# prior
tau2 <- 100  # beta prior var
a <- 0.01    # sigma2's inverse-gamma prior
b <- 0.01

# initialization
beta <- rep(0, P)
sigma2 <- 1

# MCMC 
n_iter <- 3000
burn_in <- 1000

beta_samples <- matrix(0, nrow = n_iter - burn_in, ncol = P)
sigma2_samples <- numeric(n_iter - burn_in)

# Gibbs Sampling
for (iter in 1:n_iter) {
  XtX <- t(X) %*% X
  XtY <- t(X) %*% y
  Sigma_n_inv <- XtX / sigma2 + diag(1 / tau2, P)
  Sigma_n <- solve(Sigma_n_inv)
  mu_n <- Sigma_n %*% XtY / sigma2
  beta <- as.vector(rmvnorm_manual(1, mu_n, Sigma_n))

  resid <- y - X %*% beta
  a_post <- a + N / 2
  b_post <- b + sum(resid^2) / 2
  sigma2 <- 1 / rgamma(1, shape = a_post, rate = b_post)

  if (iter > burn_in) {
    beta_samples[iter - burn_in, ] <- beta
    sigma2_samples[iter - burn_in] <- sigma2
  }
}

save(beta_samples, sigma2_samples, file = paste0("trace_seed_", seed, ".RData"))

# trace plot
png(paste0("trace_plots_seed_", seed, ".png"), width = 3000, height = 2000, res = 300)
par(mfrow = c(3, 3))  # For 9 predictors
for (j in 1:ncol(beta_samples)) {
  plot(beta_samples[, j], type = "l", main = paste("Trace: beta", j),
       xlab = "Iteration", ylab = paste("beta", j), cex.lab = 1.4, cex.main = 1.5)
}
dev.off()

# posterior histogram
png(paste0("density_plots_seed_", seed, ".png"), width = 3000, height = 2000, res = 300)
par(mfrow = c(3, 3))
for (j in 1:ncol(beta_samples)) {
  hist(beta_samples[, j], breaks = 40, probability = TRUE,
       main = paste("Posterior: beta", j),
       xlab = paste("beta", j), ylab = "Density",
       cex.lab = 1.4, cex.main = 1.5)
  abline(v = mean(beta_samples[, j]), col = "red", lty = 2)
}
dev.off()
