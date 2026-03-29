fit_oncology_joint_model_stable <- function(trial_data) {
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
  
  # Sous-échantillonnage longitudinal pour alléger le JM
  tumor_data_sub <- subset(tumor_data, time %% 2 == 0)
  
  # Modèle longitudinal
  lme_fit <- nlme::lme(
    Tumor_obs ~ time * dose_group,
    random = ~ time | id,
    data = tumor_data_sub,
    method = "REML"
  )
  
  # Cox simplifié : pas de dose explicite
  cox_fit <- survival::coxph(
    survival::Surv(time, event) ~ 1,
    data = survival_data,
    x = TRUE
  )
  
  # Joint model avec plus d'itérations
  jm_fit <- JMbayes2::jm(
    cox_fit,
    lme_fit,
    time_var = "time",
    n_iter = 6000L,
    n_burnin = 1000L,
    n_chains = 3L
  )
  
  list(
    tumor_data_sub = tumor_data_sub,
    lme_fit = lme_fit,
    cox_fit = cox_fit,
    jm_fit = jm_fit
  )
}