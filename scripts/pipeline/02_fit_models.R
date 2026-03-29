# scripts/pipeline/02_fit_models.R

library(nlme)
library(survival)
library(JMbayes2)

# Charger les fonctions MIDD
list.files("functions/midd", full.names = TRUE) |>
  lapply(source)

dir.create("data/simulated_trials", recursive = TRUE, showWarnings = FALSE)

# Charger les données simulées
trial <- readRDS("data/simulated_trials/trial1.rds")

# Ajuster les modèles
fits <- fit_midd_models(trial)

# Sauvegarde
saveRDS(
  fits,
  file = "data/simulated_trials/fits1.rds"
)

# Résumés
cat("\n===== LME SUMMARY =====\n")
print(summary(fits$lme_fit))

cat("\n===== COX SUMMARY =====\n")
print(summary(fits$cox_fit))

cat("\n===== JM SUMMARY =====\n")
print(summary(fits$jm_fit))

cat("02_fit_models.R terminé.\n")