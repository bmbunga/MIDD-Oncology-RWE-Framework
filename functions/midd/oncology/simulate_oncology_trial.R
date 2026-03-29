simulate_oncology_trial <- function(
    n_per_arm = 100,
    dose_levels = c(50, 100),
    times = seq(0, 60, by = 1),
    dose_times = seq(0, 42, by = 7)
) {
  tumor_data <- simulate_tumor_simeoni(
    n_per_arm = n_per_arm,
    dose_levels = dose_levels,
    times = times,
    dose_times = dose_times
  )
  
  survival_data <- simulate_oncology_survival(
    tumor_data = tumor_data
  )
  
  list(
    tumor_data = tumor_data,
    survival_data = survival_data
  )
}