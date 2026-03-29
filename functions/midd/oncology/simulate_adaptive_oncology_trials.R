simulate_adaptive_oncology_trials <- function(
    n_sim = 100,
    n_total = 200,
    interim_n = 100,
    dose_levels = c(50, 100),
    seed = 999
) {
  results <- vector("list", n_sim)
  
  for (i in seq_len(n_sim)) {
    sim_i <- simulate_adaptive_oncology_trial(
      n_total = n_total,
      interim_n = interim_n,
      dose_levels = dose_levels,
      seed = seed + i
    )
    
    results[[i]] <- data.frame(
      sim = i,
      hr_interim = sim_i$hr_interim,
      lower_interim = sim_i$lower_interim,
      upper_interim = sim_i$upper_interim,
      pval_interim = sim_i$pval_interim,
      decision = sim_i$decision,
      stringsAsFactors = FALSE
    )
  }
  
  do.call(rbind, results)
}