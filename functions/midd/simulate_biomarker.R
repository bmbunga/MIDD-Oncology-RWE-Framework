simulate_biomarker <- function(
    pd_data,
    beta0 = 20,
    beta_time = -0.2,
    sd_intercept = 4,
    sd_slope = 0.1,
    sd_error = 3,
    seed = 456
) {
  set.seed(seed)
  
  ids <- sort(unique(pd_data$id))
  n <- length(ids)
  
  rand_int <- rnorm(n, 0, sd_intercept)
  rand_slope <- rnorm(n, 0, sd_slope)
  
  pd_data$rand_int <- rand_int[pd_data$id]
  pd_data$rand_slope <- rand_slope[pd_data$id]
  
  pd_data$biomarker <- beta0 +
    beta_time * pd_data$time +
    pd_data$effect +
    pd_data$rand_int +
    pd_data$rand_slope * pd_data$time +
    rnorm(nrow(pd_data), 0, sd_error)
  
  pd_data
}