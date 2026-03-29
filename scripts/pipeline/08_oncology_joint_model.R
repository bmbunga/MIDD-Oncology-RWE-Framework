library(nlme)
library(survival)
library(JMbayes2)

func_files <- list.files("functions/midd/oncology", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(func_files, source))

trial_onco <- readRDS("data/simulated_trials/oncology_trial1.rds")

joint_onco <- fit_oncology_joint_model(trial_onco)

saveRDS(joint_onco, "data/simulated_trials/oncology_joint_fits1.rds")

cat("\n===== ONCOLOGY JOINT MODEL SUMMARY =====\n")
print(summary(joint_onco$jm_fit))

cat("08_oncology_joint_model.R terminé.\n")