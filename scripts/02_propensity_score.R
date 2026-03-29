# Propensity score estimation
library(survival)
library(cobalt)
ps_model <- glm(
  treatment ~ age + sex + biomarker,
  data = data,
  family = binomial()
)

data$ps <- predict(ps_model, type = "response")

head(data$ps)
hist(data$ps)
data$weight <- ifelse(
  data$treatment == 1,
  1 / data$ps,
  1 / (1 - data$ps)
)
summary(data$weight)
hist(data$weight)
cox_model <- coxph(
  Surv(time, event) ~ treatment,
  data = data,
  weights = weight
)
summary(cox_model)
balance <- bal.tab(
  treatment ~ age + sex + biomarker,
  data = data,
  weights = data$weight,
  method = "weighting"
)
balance
love.plot(balance, threshold = 0.1)

coxph(Surv(time,event) ~ treatment + age + sex + biomarker)
