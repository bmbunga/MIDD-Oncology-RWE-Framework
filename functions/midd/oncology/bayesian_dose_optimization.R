bayesian_dose_optimization <- function(cox_fit) {
  s <- summary(cox_fit)
  
  beta_hat <- s$coefficients["dose_groupDose_50mg", "coef"]
  se_hat   <- s$coefficients["dose_groupDose_50mg", "se(coef)"]
  
  post_prob_50_worse <- 1 - pnorm(0, mean = beta_hat, sd = se_hat)
  
  preferred_dose <- if (post_prob_50_worse > 0.8) {
    "100 mg"
  } else if (post_prob_50_worse < 0.2) {
    "50 mg"
  } else {
    "Inconclusive"
  }
  
  list(
    log_hr_mean = beta_hat,
    log_hr_se = se_hat,
    post_prob_50_worse = post_prob_50_worse,
    preferred_dose = preferred_dose
  )
}