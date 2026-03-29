func_files <- list.files("functions/midd", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(func_files, source))

stopifnot(exists("adaptive_decision"))

fits <- readRDS("data/simulated_trials/fits1.rds")

decision <- adaptive_decision(
  jm_fit = fits$jm_fit,
  assoc_pattern = "value\\(",
  rule = "positive_CrI"
)

print(decision)

cat("04_adaptive_trial.R terminé.\n")