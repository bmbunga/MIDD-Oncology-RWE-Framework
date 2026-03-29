library(ggplot2)
library(dplyr)

func_files <- list.files("functions/midd/oncology", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(func_files, source))

dir.create("data/simulated_trials", recursive = TRUE, showWarnings = FALSE)
dir.create("reports/figures", recursive = TRUE, showWarnings = FALSE)

trial_onco <- simulate_oncology_trial(
  n_per_arm = 100,
  dose_levels = c(50, 100)
)

saveRDS(trial_onco, "data/simulated_trials/oncology_trial1.rds")

p1 <- ggplot(
  subset(trial_onco$tumor_data, id <= 40),
  aes(time, Tumor_obs, group = id, color = dose_group)
) +
  geom_line(alpha = 0.15) +
  labs(
    title = "Oncology tumor trajectories by dose",
    x = "Time",
    y = "Observed tumor size"
  )

print(p1)

ggsave("reports/figures/oncology_tumor_trajectories.png", p1, width = 8, height = 5)

cat("05_oncology_simulate_trial.R terminé.\n")
