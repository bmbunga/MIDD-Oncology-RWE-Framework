simulate_midd_trial <- function(
    n = 500,
    dose = 100,
    dose_times = seq(0, 8, by = 2),
    time_grid = seq(0, 10, by = 0.1),
    CL_pop = 5,
    V_pop = 50,
    omega_CL = 0.3,
    omega_V = 0.25,
    Emax = 50,
    EC50 = 2,
    beta0 = 20,
    beta_time = -0.2,
    sd_intercept = 4,
    sd_slope = 0.1,
    sd_error = 3,
    lambda0 = 0.03,
    alpha_surv = 0.025,
    censor_time = 10
) {
  pk <- simulate_pk(
    n = n,
    dose = dose,
    dose_times = dose_times,
    time_grid = time_grid,
    CL_pop = CL_pop,
    V_pop = V_pop,
    omega_CL = omega_CL,
    omega_V = omega_V
  )
  
  pd <- simulate_pd(
    pk_data = pk,
    Emax = Emax,
    EC50 = EC50
  )
  
  biom <- simulate_biomarker(
    pd_data = pd,
    beta0 = beta0,
    beta_time = beta_time,
    sd_intercept = sd_intercept,
    sd_slope = sd_slope,
    sd_error = sd_error
  )
  
  surv <- simulate_survival(
    biomarker_data = biom,
    lambda0 = lambda0,
    alpha_surv = alpha_surv,
    censor_time = censor_time
  )
  
  list(
    pk_data = pk,
    pd_data = pd,
    biomarker_data = biom,
    survival_data = surv
  )
}