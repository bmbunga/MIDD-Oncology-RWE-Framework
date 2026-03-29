
print.rwe_ps_cox <- function(x, ...) {
  cat("\n===== RWE PS Cox Analysis =====\n")
  cat("\nPropensity score model:\n")
  print(x$ps_formula)
  
  cat("\nWeighted Cox model:\n")
  print(summary(x$cox_iptw)$coefficients)
  
  cat("\nDoubly robust Cox model:\n")
  print(summary(x$cox_dr)$coefficients)
  
  invisible(x)