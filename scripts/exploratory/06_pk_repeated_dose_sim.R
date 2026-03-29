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