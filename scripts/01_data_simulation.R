# Simulation dataset for MIDD / RWE analysis

set.seed(123)

n <- 1000

patient_id <- 1:n

age <- rnorm(n, mean = 55, sd = 10)

sex <- rbinom(n, 1, 0.5)

treatment <- rbinom(n, 1, 0.5)

biomarker <- rnorm(n, mean = 100 - 5*treatment, sd = 15)

time <- rexp(n, rate = 0.1)

event <- rbinom(n, 1, 0.7)

data <- data.frame(
  patient_id,
  age,
  sex,
  treatment,
  biomarker,
  time,
  event
)

head(data)
dim(data)
str(data)
summary(data)
