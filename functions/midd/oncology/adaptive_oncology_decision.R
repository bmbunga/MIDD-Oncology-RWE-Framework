adaptive_oncology_decision <- function(
    cox_fit,
    dose_coef_name = "dose_groupDose_50mg"
) {
  s <- summary(cox_fit)
  
  hr <- s$coefficients[dose_coef_name, "exp(coef)"]
  lower <- s$conf.int[dose_coef_name, "lower .95"]
  upper <- s$conf.int[dose_coef_name, "upper .95"]
  
  decision <- ifelse(hr > 1, "NO-GO for 50 mg / Prefer 100 mg", "GO")
  
  list(
    hr = hr,
    lower_ci = lower,
    upper_ci = upper,
    decision = decision
  )
}