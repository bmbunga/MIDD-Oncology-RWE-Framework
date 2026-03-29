simulate_adaptive_oncology_trial <- function(
    n_total = 200,
    interim_n = 100,
    dose_levels = c(50, 100),
    seed = 123
) {
  if (!requireNamespace("survival", quietly = TRUE)) {
    stop("Le package 'survival' est requis.")
  }
  
  set.seed(seed)
  
  if (interim_n >= n_total) {
    stop("interim_n doit être strictement inférieur à n_total.")
  }
  
  n_arms <- length(dose_levels)
  
  if (n_total %% n_arms != 0) {
    stop("n_total doit être divisible par le nombre de bras.")
  }
  if (interim_n %% n_arms != 0) {
    stop("interim_n doit être divisible par le nombre de bras.")
  }
  
  n_per_arm_total <- n_total / n_arms
  n_per_arm_interim <- interim_n / n_arms
  
  trial_full <- simulate_oncology_trial(
    n_per_arm = n_per_arm_total,
    dose_levels = dose_levels
  )
  
  surv_full <- trial_full$survival_data
  
  ids_50 <- surv_full$id[surv_full$dose_group == "Dose_50mg"][seq_len(n_per_arm_interim)]
  ids_100 <- surv_full$id[surv_full$dose_group == "Dose_100mg"][seq_len(n_per_arm_interim)]
  
  interim_ids <- c(ids_50, ids_100)
  
  surv_interim <- subset(surv_full, id %in% interim_ids)
  
  cox_interim <- survival::coxph(
    survival::Surv(time, event) ~ dose_group,
    data = surv_interim,
    x = TRUE
  )
  
  s <- summary(cox_interim)
  
  hr <- s$coefficients["dose_groupDose_50mg", "exp(coef)"]
  lower <- s$conf.int["dose_groupDose_50mg", "lower .95"]
  upper <- s$conf.int["dose_groupDose_50mg", "upper .95"]
  pval <- s$coefficients["dose_groupDose_50mg", "Pr(>|z|)"]
  
  decision <- if (hr > 1 && lower > 1) {
    "DROP_50mg"
  } else {
    "CONTINUE_BOTH"
  }
  
  if (decision == "DROP_50mg") {
    final_surv <- subset(
      surv_full,
      id %in% interim_ids |
        (dose_group == "Dose_100mg" & !(id %in% interim_ids))
    )
  } else {
    final_surv <- surv_full
  }
  
  list(
    trial_full = trial_full,
    surv_interim = surv_interim,
    cox_interim = cox_interim,
    hr_interim = hr,
    lower_interim = lower,
    upper_interim = upper,
    pval_interim = pval,
    decision = decision,
    final_surv = final_surv
  )
}