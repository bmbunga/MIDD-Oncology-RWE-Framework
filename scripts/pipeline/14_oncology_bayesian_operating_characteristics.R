library(ggplot2)

source("functions/midd/oncology/simulate_pk_repeated.R")
source("functions/midd/oncology/simulate_tumor_simeoni.R")
source("functions/midd/oncology/simulate_oncology_survival.R")
source("functions/midd/oncology/simulate_oncology_trial.R")
source("functions/midd/oncology/simulate_adaptive_oncology_trial.R")
source("functions/midd/oncology/bayesian_dose_optimization.R")
source("functions/midd/oncology/simulate_bayesian_dose_selection.R")

res <- simulate_bayesian_dose_selection(
  n_sim = 50,
  n_total = 200,
  interim_n = 100
)

print(table(res$preferred_dose))

p <- ggplot(res, aes(x = post_prob_50_worse, y = 1)) +
  geom_jitter(height = 0.05, alpha = 0.7, size = 2) +
  geom_vline(xintercept = 0.8, linetype = "dashed", linewidth = 1) +
  labs(
    title = "Posterior probability that 50 mg is worse",
    x = "Posterior probability",
    y = NULL
  ) +
  coord_cartesian(xlim = c(0, 1)) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  )

print(p)
#p <- ggplot(res, aes(x = post_prob_50_worse)) +
  #geom_histogram(bins = 20, fill = "steelblue", alpha = 0.7) +
  #labs(
    #title = "Posterior probability that 50 mg is worse",
    #x = "Posterior probability",
    #y = "Count"
  #)

#print(p)

cat("14_oncology_bayesian_operating_characteristics.R terminé.\n")