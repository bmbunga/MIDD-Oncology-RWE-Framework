library(survival)

source("functions/midd/oncology/simulate_pk_repeated.R")
source("functions/midd/oncology/simulate_tumor_simeoni.R")
source("functions/midd/oncology/simulate_oncology_survival.R")
source("functions/midd/oncology/simulate_oncology_trial.R")
source("functions/midd/oncology/simulate_adaptive_oncology_trial.R")
source("functions/midd/oncology/bayesian_dose_optimization.R")

adaptive_trial <- simulate_adaptive_oncology_trial(
  n_total = 200,
  interim_n = 100,
  dose_levels = c(50, 100),
  seed = 123
)

bayes_decision <- bayesian_dose_optimization(adaptive_trial$cox_interim)

print(bayes_decision)

cat("13_oncology_bayesian_dose_optimization.R terminé.\n")