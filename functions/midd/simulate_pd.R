simulate_pd <- function(
    pk_data,
    Emax = 50,
    EC50 = 2
) {
  pk_data$effect <- (Emax * pk_data$C) / (EC50 + pk_data$C)
  pk_data
}