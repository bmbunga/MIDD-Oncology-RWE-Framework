run_rwe_ps_cox <- function(data, treatment, time, event, covariates) {
  
  # Vérifications minimales
  required_vars <- c(treatment, time, event, covariates)
  missing_vars <- setdiff(required_vars, names(data))
  
  if (length(missing_vars) > 0) {
    stop(
      paste("Variables manquantes dans data :", paste(missing_vars, collapse = ", "))
    )
  }
  
  # Packages nécessaires
  if (!requireNamespace("survival", quietly = TRUE)) {
    stop("Le package 'survival' est requis.")
  }
  
  if (!requireNamespace("cobalt", quietly = TRUE)) {
    stop("Le package 'cobalt' est requis.")
  }
  
  # Copie locale des données
  df <- data
  
  # 1) Propensity score model
  ps_formula <- as.formula(
    paste(treatment, "~", paste(covariates, collapse = " + "))
  )
  
  ps_model <- glm(
    ps_formula,
    data = df,
    family = binomial()
  )
  
  df$ps <- predict(ps_model, type = "response")
  
  # Vérification positivity simple
  if (any(df$ps <= 0 | df$ps >= 1, na.rm = TRUE)) {
    warning("Certaines valeurs de propensity score sont égales à 0 ou 1.")
  }
  
  # 2) IPTW weights
  df$weight <- ifelse(
    df[[treatment]] == 1,
    1 / df$ps,
    1 / (1 - df$ps)
  )
  
  # 3) Balance diagnostics
  balance_formula <- ps_formula
  
  balance <- cobalt::bal.tab(
    balance_formula,
    data = df,
    weights = df$weight,
    method = "weighting"
  )
  
  # 4) Weighted Cox model
  cox_formula <- as.formula(
    paste0("survival::Surv(", time, ", ", event, ") ~ ", treatment)
  )
  
  cox_iptw <- survival::coxph(
    cox_formula,
    data = df,
    weights = df$weight
  )
  
  # 5) Doubly robust Cox model
  cox_dr_formula <- as.formula(
    paste0(
      "survival::Surv(", time, ", ", event, ") ~ ",
      treatment, " + ",
      paste(covariates, collapse = " + ")
    )
  )
  
  cox_dr <- survival::coxph(
    cox_dr_formula,
    data = df,
    weights = df$weight
  )
  
  # 6) Résultat structuré
  result <- list(
    data = df,
    ps_formula = ps_formula,
    ps_model = ps_model,
    balance = balance,
    cox_iptw = cox_iptw,
    cox_dr = cox_dr
  )
  
  class(result) <- "rwe_ps_cox"
  
  return(result)
}