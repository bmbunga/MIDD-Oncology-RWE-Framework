simulate_pk_repeated <- function(
    t,
    dose,
    dose_times,
    V,
    ke
) {
  sum((dose / V) * exp(-ke * (t - dose_times)) * (t >= dose_times))
}