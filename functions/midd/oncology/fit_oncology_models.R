fit_oncology_models <- function(trial_data) {
  if (!requireNamespace("survival", quietly = TRUE)) {
    stop("Le package 'survival' est requis.")
  }
  if (!requireNamespace("nlme", quietly = TRUE)) {
    stop("Le package 'nlme' est requis.")
  }
  
  tumor_data <- trial_data$tumor_data
  survival_data <- trial_data$survival_data
  
  lme_fit <- nlme::lme(
    Tumor_obs ~ time * dose_group,
    random = ~ time | id,
    data = tumor_data,
    method = "REML"
  )
  
  cox_fit <- survival::coxph(
    survival::Surv(time, event) ~ dose_group + mean_tumor + slope_tumor,
    data = survival_data,
    x = TRUE
  )
  
  list(
    lme_fit = lme_fit,
    cox_fit = cox_fit
  )
}