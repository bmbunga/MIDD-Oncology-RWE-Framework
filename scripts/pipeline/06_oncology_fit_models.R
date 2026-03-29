library(nlme)
library(survival)

func_files <- list.files("functions/midd/oncology", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(func_files, source))

trial_onco <- readRDS("data/simulated_trials/oncology_trial1.rds")

fits_onco <- fit_oncology_models(trial_onco)

saveRDS(fits_onco, "data/simulated_trials/oncology_fits1.rds")

cat("\n===== ONCOLOGY LME SUMMARY =====\n")
print(summary(fits_onco$lme_fit))

cat("\n===== ONCOLOGY COX SUMMARY =====\n")
trial_onco$survival_data |>
  head()

plot(
  trial_onco$survival_data$mean_tumor,
  trial_onco$survival_data$slope_tumor,
  pch = 19,
  col = ifelse(trial_onco$survival_data$dose_group == "Dose_100mg", "red", "blue"),
  xlab = "Mean tumor size",
  ylab = "Tumor slope"
)
legend("topright", legend = c("Dose 50 mg", "Dose 100 mg"),
       col = c("blue", "red"), pch = 19)
print(summary(fits_onco$cox_fit))

cat("06_oncology_fit_models.R terminé.\n")