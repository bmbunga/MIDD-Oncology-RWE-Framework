# scripts/pipeline/03_dynamic_prediction.R

library(JMbayes2)

# Charger les fonctions MIDD
list.files("functions/midd", full.names = TRUE) |>
  lapply(source)

dir.create("reports/figures", recursive = TRUE, showWarnings = FALSE)

# Charger données + modèles
trial <- readRDS("data/simulated_trials/trial1.rds")
fits  <- readRDS("data/simulated_trials/fits1.rds")

# Paramètres de prédiction
patient_id <- 1
landmark_time <- 6
horizon_times <- seq(6.1, 10, by = 0.25)

# Prédiction dynamique
pred <- predict_dynamic_risk(
  jm_fit = fits$jm_fit,
  biomarker_data = trial$biomarker_data,
  patient_id = patient_id,
  landmark_time = landmark_time,
  horizon_times = horizon_times
)

print(pred)

# Plot
png("reports/figures/dynamic_prediction_patient1.png", width = 900, height = 600)
plot(pred)
dev.off()

# Aussi afficher dans la session
plot(pred)

cat("03_dynamic_prediction.R terminé.\n")