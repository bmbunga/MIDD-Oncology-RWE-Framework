library(ggplot2)

func_files <- list.files("functions/midd/oncology", pattern = "\\.R$", full.names = TRUE)
invisible(lapply(func_files, source))

oc <- simulate_adaptive_oncology_trials(
  n_sim = 100,
  n_total = 200,
  interim_n = 100,
  dose_levels = c(50, 100),
  seed = 999
)

print(head(oc))
print(table(oc$decision))

p <- ggplot(oc, aes(x = hr_interim, fill = decision)) +
  geom_histogram(bins = 20, alpha = 0.7, position = "identity") +
  labs(
    title = "Operating characteristics of the interim rule",
    x = "Interim hazard ratio (50 mg vs 100 mg)",
    y = "Count"
  )

print(p)

cat("12_oncology_adaptive_operating_characteristics.R terminé.\n")