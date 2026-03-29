# Simulation with confounding + true treatment effect
library(survival)
set.seed(123)

n <- 2000

patient_id <- 1:n
age <- rnorm(n, mean = 60, sd = 10)
sex <- rbinom(n, 1, 0.5)
biomarker <- rnorm(n, mean = 100, sd = 15)

# Treatment assignment depends on covariates
# Older / sicker patients are more likely to be treated
linpred_treat <- -8 + 0.06 * age + 0.03 * biomarker + 0.4 * sex
ps_true <- plogis(linpred_treat)
treatment <- rbinom(n, 1, ps_true)

# True event risk depends on age, sex, biomarker, and treatment
# Treatment is protective: HR < 1
linpred_event <- -3 + 0.03 * age + 0.02 * biomarker + 0.3 * sex - 0.7 * treatment
rate <- exp(linpred_event)

time <- rexp(n, rate = rate)
censoring <- rexp(n, rate = 0.05)

event <- ifelse(time <= censoring, 1, 0)
time <- pmin(time, censoring)

df <- data.frame(
  patient_id,
  age,
  sex,
  biomarker,
  treatment,
  ps_true,
  time,
  event
)

str(df)
summary(df)
mean(df$treatment)
mean(df$event)

# Propensity score model
ps_model <- glm(
  treatment ~ age + sex + biomarker,
  data = df,
  family = binomial()
)

df$ps <- predict(ps_model, type = "response")

# IPTW weights
df$weight <- ifelse(
  df$treatment == 1,
  1 / df$ps,
  1 / (1 - df$ps)
)

summary(df$weight)


cox_naive <- coxph(Surv(time, event) ~ treatment, data = df)
summary(cox_naive)

cox_iptw <- coxph(
  Surv(time, event) ~ treatment,
  data = df,
  weights = weight
)

summary(cox_iptw)

cox_dr <- coxph(
  Surv(time, event) ~ treatment + age + sex + biomarker,
  data = df,
  weights = df$weight
)

summary(cox_dr)
