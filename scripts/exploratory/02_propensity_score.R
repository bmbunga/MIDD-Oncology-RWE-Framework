# Propensity score estimation

ps_model <- glm(
  treatment ~ age + sex + biomarker,
  data = data,
  family = binomial()
)

data$ps <- predict(ps_model, type = "response")

head(data$ps)