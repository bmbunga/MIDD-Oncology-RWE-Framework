simulate_survival <- function(
    biomarker_data,
    lambda0 = 0.03,
    alpha_surv = 0.025,
    censor_time = 10,
    seed = 789
) {
  set.seed(seed)
  
  patient_level <- aggregate(
    biomarker ~ id,
    data = biomarker_data,
    FUN = mean
  )
  
  patient_level$hazard <- lambda0 * exp(alpha_surv * patient_level$biomarker)
  patient_level$event_time <- rexp(nrow(patient_level), rate = patient_level$hazard)
  patient_level$time <- pmin(patient_level$event_time, censor_time)
  patient_level$event <- ifelse(patient_level$event_time <= censor_time, 1, 0)
  
  patient_level
}