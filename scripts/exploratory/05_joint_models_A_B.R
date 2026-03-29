library(nlme)
library(lme4)
library(survival)
library(JMbayes2)

# -------------------------
# Données survie patient-level
# -------------------------
surv_data <- patient_biom[, c("id", "time", "event")]

# =========================
# VERSION A : Biostat classique
# =========================
lme_A <- nlme::lme(
  biomarker_long ~ time,
  random = ~ time | id,
  data = long_data,
  method = "REML"
)

cox_A <- survival::coxph(
  Surv(time, event) ~ 1,
  data = surv_data,
  x = TRUE
)

jm_A <- JMbayes2::jm(
  cox_A,
  lme_A,
  time_var = "time"
)

summary(lme_A)
summary(cox_A)
summary(jm_A)

# =========================
# VERSION B : Pharmacométrie / MIDD
# =========================
surv_data_B <- merge(
  surv_data,
  unique(long_data[, c("id", "AUC")]),
  by = "id"
)

lme_B <- nlme::lme(
  biomarker_long ~ time + AUC,
  random = ~ time | id,
  data = long_data,
  method = "REML"
)

cox_B <- survival::coxph(
  Surv(time, event) ~ AUC,
  data = surv_data_B,
  x = TRUE
)

jm_B <- JMbayes2::jm(
  cox_B,
  lme_B,
  time_var = "time"
)

summary(lme_B)
summary(cox_B)
summary(jm_B)