simulate_tumor_simeoni <- function(
    n_per_arm = 100,
    dose_levels = c(50, 100),
    times = seq(0, 60, by = 1),
    dose_times = seq(0, 42, by = 7),
    CL_pop = 5,
    V_pop = 40,
    omega_CL = 0.2,
    omega_V = 0.2,
    kg_pop = 0.03,
    kkill_pop = 0.06,
    omega_kg = 0.15,
    omega_kkill = 0.15,
    ktr = 0.25,
    seed = 123
) {
  if (!requireNamespace("deSolve", quietly = TRUE)) {
    stop("Le package 'deSolve' est requis.")
  }
  
  set.seed(seed)
  
  simeoni_pkpd <- function(t, state, parameters) {
    with(as.list(c(state, parameters)), {
      
      C_t <- simulate_pk_repeated(
        t = t,
        dose = dose,
        dose_times = dose_times,
        V = V,
        ke = ke
      )
      
      dT  <- kg * T - kkill * C_t * T
      dD1 <- kkill * C_t * T - ktr * D1
      dD2 <- ktr * D1 - ktr * D2
      dD3 <- ktr * D2 - ktr * D3
      
      Tumor_obs <- T + D1 + D2 + D3
      
      list(
        c(dT, dD1, dD2, dD3),
        C = C_t,
        Tumor_obs = Tumor_obs
      )
    })
  }
  
  sim_one_patient <- function(id, dose) {
    CL <- CL_pop * exp(rnorm(1, 0, omega_CL))
    V  <- V_pop  * exp(rnorm(1, 0, omega_V))
    ke <- CL / V
    
    kg    <- kg_pop    * exp(rnorm(1, 0, omega_kg))
    kkill <- kkill_pop * exp(rnorm(1, 0, omega_kkill))
    
    state <- c(T = 100, D1 = 0, D2 = 0, D3 = 0)
    
    pars <- c(
      kg = kg,
      kkill = kkill,
      ktr = ktr,
      V = V,
      ke = ke,
      dose = dose
    )
    
    out <- deSolve::ode(
      y = state,
      times = times,
      func = simeoni_pkpd,
      parms = pars
    )
    
    out <- as.data.frame(out)
    out$id <- id
    out$dose_group <- factor(
      paste0("Dose_", dose, "mg"),
      levels = c("Dose_100mg", "Dose_50mg")
    )
    out$CL <- CL
    out$V <- V
    out$ke <- ke
    out$kg <- kg
    out$kkill <- kkill
    out
  }
  
  out_list <- list()
  idx <- 1
  
  for (dose in dose_levels) {
    for (j in seq_len(n_per_arm)) {
      out_list[[idx]] <- sim_one_patient(id = idx, dose = dose)
      idx <- idx + 1
    }
  }
  out_all <- do.call(rbind, out_list)
  out_all$dose_group <- factor(
    out_all$dose_group,
    levels = c("Dose_100mg", "Dose_50mg")
  )
  out_all
}