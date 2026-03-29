library(JMbayes2)

func_files <- list.files("functions/midd/oncology", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(func_files, source))

joint_onco <- readRDS("data/simulated_trials/oncology_joint_fits_stable1.rds")
trial_onco <- readRDS("data/simulated_trials/oncology_trial1.rds")

pred <- predict_oncology_dynamic(
  jm_fit = joint_onco$jm_fit,
  tumor_data = trial_onco$tumor_data,
  patient_id = 1,
  t_landmark = 20,
  horizon = 60
)

plot(pred)

cat("10_oncology_dynamic_prediction.R terminé.\n")