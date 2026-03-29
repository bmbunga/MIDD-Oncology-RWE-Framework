library(survival)

func_files <- list.files("functions/midd/oncology", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(func_files, source))

adaptive_trial <- simulate_adaptive_oncology_trial(
  n_total = 200,
  interim_n = 100,
  dose_levels = c(50, 100),
  seed = 123
)

cat("\n===== INTERIM ANALYSIS =====\n")
print(summary(adaptive_trial$cox_interim))

cat("\nDecision interim : ", adaptive_trial$decision, "\n", sep = "")
cat("HR interim : ", round(adaptive_trial$hr_interim, 3), "\n", sep = "")
cat("IC95% : [", round(adaptive_trial$lower_interim, 3), "; ",
    round(adaptive_trial$upper_interim, 3), "]\n", sep = "")

cat("\nTaille dataset final : ", nrow(adaptive_trial$final_surv), "\n", sep = "")

cat("11_oncology_adaptive_trial_simulation.R terminé.\n")