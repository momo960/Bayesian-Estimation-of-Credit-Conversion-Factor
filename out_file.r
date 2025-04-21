
# out_file.r 

num_seeds <- 10
n_iter <- 2000  # num of samples in each trace
load("trace_seed_1.RData")
p <- ncol(beta_samples) # number of betas   

beta_all <- array(NA, dim = c(num_seeds, n_iter, p))
sigma2_all <- matrix(NA, nrow = num_seeds, ncol = n_iter)

# merge samples from all traces
for (s in 1:num_seeds) {
  load(paste0("trace_seed_", s, ".RData"))
  beta_all[s, , ] <- beta_samples
  sigma2_all[s, ] <- sigma2_samples
}

# Calculate the posterior mean, standard deviation, and confidence interval for each parameter (combining all seeds)
beta_combined <- matrix(NA, nrow = num_seeds * n_iter, ncol = p)
for (s in 1:num_seeds) {
  rows <- ((s - 1) * n_iter + 1):(s * n_iter)
  beta_combined[rows, ] <- beta_all[s, , ]
}

# posterior mean, std
beta_post_mean <- colMeans(beta_combined)
beta_post_sd <- apply(beta_combined, 2, sd)

# 95% credible intervals
beta_ci_lower <- apply(beta_combined, 2, function(x) quantile(x, 0.025))
beta_ci_upper <- apply(beta_combined, 2, function(x) quantile(x, 0.975))

cat("Posterior mean of beta parameters (aggregated over seeds):\n")
print(round(beta_post_mean, 4))

cat("\nPosterior standard deviations:\n")
print(round(beta_post_sd, 4))

cat("\n95% credible intervals:\n")
ci_table <- data.frame(
  Lower = round(beta_ci_lower, 4),
  Upper = round(beta_ci_upper, 4)
)
print(ci_table)

# sigma2 post mean and CI
sigma2_combined <- as.vector(t(sigma2_all))
cat("\nPosterior mean of sigma^2:\n")
print(mean(sigma2_combined))

cat("\n95% credible interval of sigma^2:\n")
print(quantile(sigma2_combined, probs = c(0.025, 0.975)))


# If there is a true beta value (assuming true_beta = 0 for all j)
true_beta <- rep(0, p)

# each beta's posterior mean per seed
posterior_means <- matrix(NA, nrow = num_seeds, ncol = p)
for (j in 1:p) {
  for (s in 1:num_seeds) {
    posterior_means[s, j] <- mean(beta_all[s, , j])
  }
}

# hist of posterior mean and true beta
png("posterior_mean_histograms.png", width = 3000, height = 2000, res = 300)
par(mfrow = c(3, 3))  =
for (j in 1:p) {
  hist(posterior_means[, j], breaks = 10, probability = TRUE,
       main = paste("Mean of beta", j),
       xlab = "Posterior Mean", ylab = "Density", cex.main = 1.6, cex.lab = 1.4)
  abline(v = true_beta[j], col = "red", lty = 2, lwd = 2)
}
dev.off()

