#On resume la tumeur par patient
simulate_oncology_survival <- function(
    tumor_data,
    lambda0 = 0.01,
    alpha_surv = 0.03,
    censor_time = 60,
    seed = 456
) {
  set.seed(seed)
  
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("Le package 'dplyr' est requis.")
  }
  
  tumor_summary <- tumor_data |>
    dplyr::group_by(id, dose_group) |>
    dplyr::summarise(
      mean_tumor = mean(Tumor_obs),
      slope_tumor = coef(lm(Tumor_obs ~ time))[2],
      .groups = "drop"
    )
  
  tumor_summary$hazard <- lambda0 * exp(alpha_surv * tumor_summary$mean_tumor)
  tumor_summary$event_time <- rexp(nrow(tumor_summary), rate = tumor_summary$hazard)
  tumor_summary$time <- pmin(tumor_summary$event_time, censor_time)
  tumor_summary$event <- ifelse(tumor_summary$event_time <= censor_time, 1, 0)
  
  tumor_summary
}