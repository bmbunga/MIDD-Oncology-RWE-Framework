predict_dynamic_risk <- function(
    jm_fit,
    biomarker_data,
    patient_id,
    landmark_time = 6,
    horizon_times = seq(6.1, 10, by = 0.25)
) {
  newdata <- subset(biomarker_data, id == patient_id & time <= landmark_time)
  newdata <- newdata[order(newdata$time), ]
  newdata$event <- 0
  
  pred <- predict(
    jm_fit,
    newdata = newdata,
    process = "event",
    return_newdata = TRUE,
    times = horizon_times
  )
  
  pred
}