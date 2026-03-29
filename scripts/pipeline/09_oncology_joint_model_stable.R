library(nlme)
library(survival)
library(JMbayes2)

func_files <- list.files("functions/midd/oncology", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(func_files, source))

trial_onco <- readRDS("data/simulated_trials/oncology_trial1.rds")

joint_onco_stable <- fit_oncology_joint_model_stable(trial_onco)

saveRDS(
  joint_onco_stable,
  "data/simulated_trials/oncology_joint_fits_stable1.rds"
)

cat("\n===== STABLE ONCOLOGY JOINT MODEL SUMMARY =====\n")
print(summary(joint_onco_stable$jm_fit))

cat("09_oncology_joint_model_stable.R terminé.\n")