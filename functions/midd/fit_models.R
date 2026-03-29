fit_midd_models <- function(trial_data) {
  if (!requireNamespace("nlme", quietly = TRUE)) {
    stop("Le package 'nlme' est requis.")
  }
  if (!requireNamespace("survival", quietly = TRUE)) {
    stop("Le package 'survival' est requis.")
  }
  if (!requireNamespace("JMbayes2", quietly = TRUE)) {
    stop("Le package 'JMbayes2' est requis.")
  }
  
  biomarker_data <- trial_data$biomarker_data
  survival_data <- trial_data$survival_data
  
  lme_fit <- nlme::lme(
    biomarker ~ time + effect,
    random = ~ time | id,
    data = biomarker_data,
    method = "REML"
  )
  
  cox_fit <- survival::coxph(
    survival::Surv(time, event) ~ 1,
    data = survival_data,
    x = TRUE
  )
  
  jm_fit <- JMbayes2::jm(
    cox_fit,
    lme_fit,
    time_var = "time"
  )
  
  list(
    lme_fit = lme_fit,
    cox_fit = cox_fit,
    jm_fit = jm_fit
  )
}