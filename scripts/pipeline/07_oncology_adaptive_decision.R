func_files <- list.files("functions/midd/oncology", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(func_files, source))

fits_onco <- readRDS("data/simulated_trials/oncology_fits1.rds")

decision_onco <- adaptive_oncology_decision(fits_onco$cox_fit)

print(decision_onco)

cat("07_oncology_adaptive_decision.R terminé.\n")