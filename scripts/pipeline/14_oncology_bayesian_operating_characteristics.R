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

p <- ggplot(res, aes(x = post_prob_50_worse)) +
  geom_histogram(bins = 20, fill = "steelblue", alpha = 0.7) +
  labs(
    title = "Posterior probability that 50 mg is worse",
    x = "Posterior probability",
    y = "Count"
  )

print(p)

cat("14_oncology_bayesian_operating_characteristics.R terminé.\n")