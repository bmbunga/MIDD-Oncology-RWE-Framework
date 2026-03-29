predict_oncology_dynamic <- function(
    jm_fit,
    tumor_data,
    patient_id,
    t_landmark = 20,
    horizon = 60
) {
  
  patient_data <- subset(tumor_data, id == patient_id & time <= t_landmark)
  
  # 🔥 FIX FACTOR LEVELS
  patient_data$dose_group <- factor(
    patient_data$dose_group,
    levels = levels(tumor_data$dose_group)
  )
  
  patient_data <- patient_data[order(patient_data$time), ]
  patient_data$event <- 0
  
  levels(patient_data$dose_group)
  levels(tumor_data$dose_group)
  
  pred <- predict(
    jm_fit,
    newdata = patient_data,
    process = "event",
    return_newdata = TRUE,
    times = seq(t_landmark + 0.1, horizon, by = 1)
  )
  
  pred
}