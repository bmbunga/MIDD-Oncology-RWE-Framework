simulate_bayesian_dose_selection <- function(
    n_sim = 100,
    n_total = 200,
    interim_n = 100,
    dose_levels = c(50, 100),
    seed = 123
) {
  results <- vector("list", n_sim)
  
  for (i in seq_len(n_sim)) {
    trial_i <- simulate_adaptive_oncology_trial(
      n_total = n_total,
      interim_n = interim_n,
      dose_levels = dose_levels,
      seed = seed + i
    )
    
    bayes_i <- bayesian_dose_optimization(trial_i$cox_interim)
    
    results[[i]] <- data.frame(
      sim = i,
      post_prob_50_worse = bayes_i$post_prob_50_worse,
      preferred_dose = bayes_i$preferred_dose
    )
  }
  
  do.call(rbind, results)
}