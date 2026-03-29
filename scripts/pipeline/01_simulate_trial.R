# scripts/pipeline/01_simulate_trial.R

library(ggplot2)

# Charger les fonctions MIDD
#list.files("functions/midd", full.names = TRUE) |>
  #lapply(source)

project_root <- getwd()

func_files <- list.files(
  path = file.path(project_root, "functions", "midd"),
  pattern = "\\.R$",
  full.names = TRUE
)

print(func_files)

invisible(lapply(list.files("functions/midd", pattern = "\\.R$", full.names = TRUE), source))
exists("simulate_midd_trial")

# Créer les dossiers utiles
dir.create("data/simulated_trials", recursive = TRUE, showWarnings = FALSE)
dir.create("reports/figures", recursive = TRUE, showWarnings = FALSE)

# Simuler un essai MIDD
trial <- simulate_midd_trial(
  n = 500,
  dose = 100,
  dose_times = seq(0, 8, by = 2),
  time_grid = seq(0, 10, by = 0.1),
  CL_pop = 5,
  V_pop = 50,
  omega_CL = 0.3,
  omega_V = 0.25,
  Emax = 50,
  EC50 = 2,
  beta0 = 20,
  beta_time = -0.2,
  sd_intercept = 4,
  sd_slope = 0.1,
  sd_error = 3,
  lambda0 = 0.03,
  alpha_surv = 0.025,
  censor_time = 10
)

exists("simulate_midd_trial")

# Sauvegarde
saveRDS(
  trial,
  file = "data/simulated_trials/trial1.rds"
)

# Vérifications rapides
print(names(trial))
print(dim(trial$pk_data))
print(dim(trial$biomarker_data))
print(dim(trial$survival_data))

# Figure PK
p1 <- ggplot(
  subset(trial$pk_data, id <= 10),
  aes(time, C, group = id)
) +
  geom_line(alpha = 0.6) +
  labs(
    title = "PK profiles (repeated dosing)",
    x = "Time",
    y = "Concentration C(t)"
  )

print(p1)

ggsave(
  filename = "reports/figures/pk_profiles_trial1.png",
  plot = p1,
  width = 8,
  height = 5
)

# Figure biomarqueur
p2 <- ggplot(
  subset(trial$biomarker_data, id <= 20),
  aes(time, biomarker, group = id)
) +
  geom_line(alpha = 0.3) +
  labs(
    title = "Biomarker trajectories driven by PK-PD",
    x = "Time",
    y = "Biomarker"
  )

print(p2)

ggsave(
  filename = "reports/figures/biomarker_trajectories_trial1.png",
  plot = p2,
  width = 8,
  height = 5
)

cat("01_simulate_trial.R terminé.\n")