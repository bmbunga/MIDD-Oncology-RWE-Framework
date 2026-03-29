
library(lme4)
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