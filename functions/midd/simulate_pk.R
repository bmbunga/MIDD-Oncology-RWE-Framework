simulate_pk <- function(
    n = 500,
    dose = 100,
    dose_times = seq(0, 8, by = 2),
    time_grid = seq(0, 10, by = 0.1),
    CL_pop = 5,
    V_pop = 50,
    omega_CL = 0.3,
    omega_V = 0.25,
    seed = 123
) {
  set.seed(seed)
  ex
  eta_CL <- rnorm(n, 0, omega_CL)
  eta_V  <- rnorm(n, 0, omega_V)
  
  CL_i <- CL_pop * exp(eta_CL)
  V_i  <- V_pop  * exp(eta_V)
  ke_i <- CL_i / V_i
  
  conc_fun <- function(t, dose_times, dose, V, ke) {
    sum((dose / V) * exp(-ke * (t - dose_times)) * (t >= dose_times))
  }
  
  pk_long <- do.call(
    rbind,
    lapply(seq_len(n), function(i) {
      conc <- sapply(time_grid, function(t) {
        conc_fun(t, dose_times, dose, V_i[i], ke_i[i])
      })
      
      data.frame(
        id = i,
        time = time_grid,
        C = conc,
        CL = CL_i[i],
        V = V_i[i],
        ke = ke_i[i],
        dose = dose
      )
    })
  )
  
  pk_long
}