
library(lme4)
library(nlme)
library(survival)
library(ggplot2)
library(JMbayes2)

set.seed(123)

n <- 500

# doses possibles
dose_levels <- c(5, 10, 20)

dose <- sample(dose_levels, n, replace = TRUE)

# variabilité inter-individuelle de la clairance
CL <- rlnorm(n, log(10), 0.25)

# exposition
AUC <- dose / CL

pk_data <- data.frame(
  id = 1:n,
  dose = dose,
  CL = CL,
  AUC = AUC
)

head(pk_data)
summary(pk_data)

library(ggplot2)

ggplot(pk_data, aes(x = factor(dose), y = AUC)) +
  geom_boxplot(fill = "skyblue") +
  labs(
    title = "Exposure (AUC) by Dose",
    x = "Dose",
    y = "AUC"
  )

# paramètres PD
Emax <- 100
EC50 <- 1.5

# effet pharmacodynamique
Effect <- (Emax * pk_data$AUC) / (EC50 + pk_data$AUC)

# ajout bruit biologique
biomarker <- Effect + rnorm(n, 0, 5)

pk_data$biomarker <- biomarker

ggplot(pk_data, aes(x = AUC, y = biomarker)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "loess", color = "red") +
  labs(
    title = "Exposure → Biomarker relationship",
    x = "AUC",
    y = "Biomarker"
  )

# nombre de visites
n_visits <- 6

time_points <- seq(0, 10, length.out = n_visits)

long_data <- do.call(rbind,
                     lapply(1:n, function(i){
                       
                       data.frame(
                         id = i,
                         dose = pk_data$dose[i],
                         AUC = pk_data$AUC[i],
                         time = time_points
                       )
                       
                     })
)

#Effet aléatoire patient
random_intercept <- rnorm(n, 0, 5)
random_slope <- rnorm(n, 0, 0.3)

long_data$rand_int <- random_intercept[long_data$id]
long_data$rand_slope <- random_slope[long_data$id]

#génération du biomarqueur longitudinal
beta0 <- 20
beta_time <- -0.5
beta_exposure <- 15

long_data$biomarker_long <-
  beta0 +
  beta_time * long_data$time +
  beta_exposure * long_data$AUC +
  long_data$rand_int +
  long_data$rand_slope * long_data$time +
  rnorm(nrow(long_data), 0, 3)

# Visualisation des trajectoires
ggplot(long_data, aes(time, biomarker_long, group = id)) +
  geom_line(alpha = 0.15) +
  labs(
    title = "Longitudinal biomarker trajectories",
    x = "Time",
    y = "Biomarker"
  )
nrow(long_data)

#Modelisation (modèle linéaire mixte)
lmm_model <- lmer(
  biomarker_long ~ time + AUC + (1 + time | id),
  data = long_data
)

summary(lmm_model)

# Résumé patient-level du biomarqueur
patient_biom <- aggregate(
  biomarker_long ~ id + AUC + dose,
  data = long_data,
  FUN = mean
)

head(patient_biom)


set.seed(456)

# Paramètres de survie
lambda0 <- 0.05   # hazard de base
alpha <- 0.03     # effet du biomarqueur sur le hazard

# Hazard individuel
patient_biom$hazard <- lambda0 * exp(alpha * patient_biom$biomarker_long)

# Temps d'événement
patient_biom$event_time <- rexp(nrow(patient_biom), rate = patient_biom$hazard)

# Censure administrative
censor_time <- 10

patient_biom$time <- pmin(patient_biom$event_time, censor_time)
patient_biom$event <- ifelse(patient_biom$event_time <= censor_time, 1, 0)

summary(patient_biom[, c("hazard", "time", "event")])
mean(patient_biom$event)

ggplot(patient_biom, aes(x = biomarker_long, y = time, color = factor(event))) +
  geom_point(alpha = 0.7) +
  labs(
    title = "Biomarker vs observed survival time",
    x = "Mean biomarker",
    y = "Observed time",
    color = "Event"
  )

# ajuster un modèle de survie(survival)

cox_surv <- coxph(
  Surv(time, event) ~ biomarker_long,
  data = patient_biom
)

summary(cox_surv)

# A) joint model biostatistique classique

# on observe un biomarqueur longitudinal et 
# on veut savoir comment sa trajectoire est associée au risque d’événement.
# Le biomarqueur est traité comme une variable longitudinale observée, 
# sans insister sur son mécanisme PK/PD. Le joint model estime en substance :
# la trajectoire latente du biomarqueur
# l’association entre cette trajectoire et le risque d’événement
# Le paramètre clé est l’association parameter :
# si il est positif : biomarqueur élevé → risque plus élevé
# si il est négatif : biomarqueur élevé → risque plus faible


# dataset survie patient-level

surv_data <- patient_biom[, c("id", "time", "event")]
head(surv_data)

# modèle longitudinal mixte
lme_A <- nlme::lme(
  biomarker_long ~ time,
  random = ~ time | id,
  data = long_data,
  method = "REML"
)

summary(lme_A)

# modèle de survie
cox_A <- survival::coxph(
  Surv(time, event) ~ 1,
  data = surv_data,
  x = TRUE
)

summary(cox_A)

# joint model
jm_A <- JMbayes2::jm(
  cox_A,
  lme_A,
  time_var = "time"
)

summary(jm_A)

# B joint model pharmacométrie / MIDD
# modèle longitudinal mécanistique simplifié
# On met l’exposition AUC dans le mixed model.
# time = évolution naturelle
# AUC = effet de l’exposition
# random effects = variabilité inter-patient

lme_B <- nlme::lme(
  biomarker_long ~ time + AUC,
  random = ~ time | id,
  data = long_data,
  method = "REML"
)

summary(lme_B)

# modèle de survie, le Cox inclut aussi l’exposition en baseline.
cox_B <- survival::coxph(
  Surv(time, event) ~ AUC,
  data = surv_data |> merge(unique(long_data[, c("id", "AUC")]), by = "id"),
  x = TRUE
)

summary(cox_B)


# joint model mécanistique
# On relie le biomarqueur longitudinal au hazard.
# L’exposition influence le biomarqueur, et la trajectoire du biomarqueur influence le risque.
jm_B <- JMbayes2::jm(
  cox_B,
  lme_B,
  time_var = "time"
)

summary(jm_B)

# Exemple de prédiction dynamique
patient_id <- 1

newdata <- long_data[long_data$id == patient_id, ]
newdata$event <- 0

pred <- predict(
  jm_B,
  newdata = newdata,
  process = "event",
  return_newdata = TRUE
)

plot(pred)

ids <- c(1, 2, 3)

newdata_multi <- long_data[long_data$id %in% ids, ]
newdata_multi$event <- 0

pred_multi <- predict(
  jm_B,
  newdata = newdata_multi,
  process = "event",
  return_newdata = TRUE
)

plot(pred_multi)

# prédire plus loin dans le futur
#pred <- predict(
  #jm_B,
  #newdata = newdata,
  #process = "event",
  #return_newdata = TRUE,
  #times = seq(10, 20, by = 0.5)
#)

plot(pred)

patient_id <- 1

newdata_landmark <- subset(long_data, id == patient_id & time <= 6)
newdata_landmark <- newdata_landmark[order(newdata_landmark$time), ]

newdata_landmark$event <- 0

newdata_landmark

pred_landmark <- predict(
  jm_B,
  newdata = newdata_landmark,
  process = "event",
  return_newdata = TRUE,
  times = seq(6.1, 10, by = 0.25)
)
plot(pred_landmark)
