fit_oncology_joint_model <- function(trial_data) {
  if (!requireNamespace("nlme", quietly = TRUE)) {
    stop("Le package 'nlme' est requis.")
  }
  if (!requireNamespace("survival", quietly = TRUE)) {
    stop("Le package 'survival' est requis.")
  }
  if (!requireNamespace("JMbayes2", quietly = TRUE)) {
    stop("Le package 'JMbayes2' est requis.")
  }
  
  tumor_data <- trial_data$tumor_data
  survival_data <- trial_data$survival_data
  
  # Modèle longitudinal sur la taille tumorale
  lme_fit <- nlme::lme(
    Tumor_obs ~ time * dose_group,
    random = ~ time | id,
    data = tumor_data,
    method = "REML"
  )
  
  # Modèle de survie de base
  cox_fit <- survival::coxph(
    survival::Surv(time, event) ~ dose_group,
    data = survival_data,
    x = TRUE
  )
  
  # Joint model
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