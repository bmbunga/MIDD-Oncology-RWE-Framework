library(ggplot2)
set.seed(123)

# nombre de patients
n <- 500

# paramètres population PK
CL_pop <- 5
V_pop  <- 50

# variabilité inter-individuelle
omega_CL <- 0.3
omega_V  <- 0.25

# paramètres individuels
eta_CL <- rnorm(n, 0, omega_CL)
eta_V  <- rnorm(n, 0, omega_V)

CL_i <- CL_pop * exp(eta_CL)
V_i  <- V_pop  * exp(eta_V)

ke_i <- CL_i / V_i

# schéma de doses
dose <- 100
dose_times <- seq(0, 8, by = 2)

# grille temporelle
time_grid <- seq(0, 10, by = 0.1)

# fonction concentration
conc_fun <- function(t, dose_times, dose, V, ke) {
  sum((dose / V) * exp(-ke * (t - dose_times)) * (t >= dose_times))
}

# simulation PK
pk_long <- data.frame()

for(i in 1:n){
  
  conc <- sapply(time_grid, function(t)
    conc_fun(t, dose_times, dose, V_i[i], ke_i[i]))
  
  tmp <- data.frame(
    id = i,
    time = time_grid,
    C = conc
  )
  
  pk_long <- rbind(pk_long, tmp)
}

head(pk_long)

library(ggplot2)

ggplot(pk_long[pk_long$id <= 10,], 
       aes(time, C, group = id)) +
  geom_line(alpha = 0.6) +
  labs(
    title = "PK profiles (repeated dosing)",
    x = "Time",
    y = "Concentration C(t)"
  )

Emax <- 50
EC50 <- 2

pk_long$effect <- (Emax * pk_long$C) / (EC50 + pk_long$C)

# Génération du biomarqueur longitudinal
# On ajoute#  :
# effet pharmacodynamique
# pente temporelle
# effets aléatoires patient

beta0 <- 20
beta_time <- -0.2

rand_int <- rnorm(n, 0, 4)
rand_slope <- rnorm(n, 0, 0.1)

pk_long$rand_int <- rand_int[pk_long$id]
pk_long$rand_slope <- rand_slope[pk_long$id]

pk_long$biomarker <- beta0 +
  beta_time * pk_long$time +
  pk_long$effect +
  pk_long$rand_int +
  pk_long$rand_slope * pk_long$time +
  rnorm(nrow(pk_long),0,3)

ggplot(pk_long[pk_long$id <= 20,], 
       aes(time, biomarker, group = id)) +
  geom_line(alpha = 0.3) +
  labs(
    title = "Biomarker trajectories driven by PK-PD",
    x = "Time",
    y = "Biomarker"
  )

# Résumé patient-level du biomarqueur PK-PD
patient_biom_pkpd <- aggregate(
  biomarker ~ id,
  data = pk_long,
  FUN = mean
)

head(patient_biom_pkpd)

# simuler le temps d’événement
set.seed(789)

lambda0 <- 0.03
alpha_surv <- 0.025

patient_biom_pkpd$hazard <- lambda0 * exp(alpha_surv * patient_biom_pkpd$biomarker)

patient_biom_pkpd$event_time <- rexp(
  nrow(patient_biom_pkpd),
  rate = patient_biom_pkpd$hazard
)

censor_time <- 10

patient_biom_pkpd$time <- pmin(patient_biom_pkpd$event_time, censor_time)
patient_biom_pkpd$event <- ifelse(patient_biom_pkpd$event_time <= censor_time, 1, 0)

summary(patient_biom_pkpd[, c("hazard", "time", "event")])
mean(patient_biom_pkpd$event)

#library(ggplot2)

ggplot(patient_biom_pkpd,
       aes(x = biomarker, y = time, color = factor(event))) +
  geom_point(alpha = 0.7) +
  labs(
    title = "Mean PK-PD biomarker vs observed survival time",
    x = "Mean biomarker",
    y = "Observed time",
    color = "Event"
  )

library(nlme)

lme_pkpd <- nlme::lme(
  biomarker ~ time + effect,
  random = ~ time | id,
  data = pk_long,
  method = "REML"
)

summary(lme_pkpd)

# Ajuster sur le modèle de survie
library(survival)

surv_pkpd <- patient_biom_pkpd[, c("id", "time", "event")]

cox_pkpd <- survival::coxph(
  Surv(time, event) ~ 1,
  data = surv_pkpd,
  x = TRUE
)

summary(cox_pkpd)

# Ajuster le joint model PK-PD + survie
library(JMbayes2)

jm_pkpd <- JMbayes2::jm(
  cox_pkpd,
  lme_pkpd,
  time_var = "time"
)

summary(jm_pkpd)

# Faire une prédiction dynamique
patient_id <- 1

newdata_pkpd <- subset(pk_long, id == patient_id & time <= 6)
newdata_pkpd <- newdata_pkpd[order(newdata_pkpd$time), ]
newdata_pkpd$event <- 0

pred_pkpd <- predict(
  jm_pkpd,
  newdata = newdata_pkpd,
  process = "event",
  return_newdata = TRUE,
  times = seq(6.1, 10, by = 0.25)
)

plot(pred_pkpd)


# ==========================================
# SECTION 8: PK-PD biomarker -> survival
# ==========================================

# 1) Patient-level summary
patient_biom_pkpd <- aggregate(
  biomarker ~ id,
  data = pk_long,
  FUN = mean
)

# 2) Simulate survival
set.seed(789)

lambda0 <- 0.03
alpha_surv <- 0.025

patient_biom_pkpd$hazard <- lambda0 * exp(alpha_surv * patient_biom_pkpd$biomarker)
patient_biom_pkpd$event_time <- rexp(
  nrow(patient_biom_pkpd),
  rate = patient_biom_pkpd$hazard
)

censor_time <- 10
patient_biom_pkpd$time <- pmin(patient_biom_pkpd$event_time, censor_time)
patient_biom_pkpd$event <- ifelse(patient_biom_pkpd$event_time <= censor_time, 1, 0)

# 3) Visual check
ggplot(patient_biom_pkpd,
       aes(x = biomarker, y = time, color = factor(event))) +
  geom_point(alpha = 0.7) +
  labs(
    title = "Mean PK-PD biomarker vs observed survival time",
    x = "Mean biomarker",
    y = "Observed time",
    color = "Event"
  )

# 4) Longitudinal mixed model
library(nlme)

lme_pkpd <- nlme::lme(
  biomarker ~ time + effect,
  random = ~ time | id,
  data = pk_long,
  method = "REML"
)

summary(lme_pkpd)

# 5) Survival model
library(survival)

surv_pkpd <- patient_biom_pkpd[, c("id", "time", "event")]

cox_pkpd <- survival::coxph(
  Surv(time, event) ~ 1,
  data = surv_pkpd,
  x = TRUE
)

summary(cox_pkpd)

# 6) Joint model
library(JMbayes2)

jm_pkpd <- JMbayes2::jm(
  cox_pkpd,
  lme_pkpd,
  time_var = "time"
)

summary(jm_pkpd)

# 7) Dynamic prediction
patient_id <- 1

newdata_pkpd <- subset(pk_long, id == patient_id & time <= 6)
newdata_pkpd <- newdata_pkpd[order(newdata_pkpd$time), ]
newdata_pkpd$event <- 0

pred_pkpd <- predict(
  jm_pkpd,
  newdata = newdata_pkpd,
  process = "event",
  return_newdata = TRUE,
  times = seq(6.1, 10, by = 0.25)
)

plot(pred_pkpd)
