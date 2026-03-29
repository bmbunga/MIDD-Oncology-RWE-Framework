adaptive_decision <- function(
    jm_fit,
    assoc_pattern = "value\\(",
    rule = c("positive_CrI", "posterior_mean")
) {
  rule <- match.arg(rule)
  
  txt <- capture.output(summary(jm_fit))
  
  # Trouver la section "Survival Outcome:"
  idx_start <- grep("^Survival Outcome:", txt)
  if (length(idx_start) == 0) {
    stop("Impossible de trouver la section 'Survival Outcome:' dans summary(jm_fit).")
  }
  
  # Prendre les lignes suivantes jusqu'à la première ligne vide
  block <- txt[(idx_start + 1):length(txt)]
  idx_end <- which(trimws(block) == "")[1]
  if (!is.na(idx_end)) {
    block <- block[seq_len(idx_end - 1)]
  }
  
  # Retirer les lignes d'en-tête vides/inutiles
  block <- block[nzchar(trimws(block))]
  if (length(block) < 2) {
    stop("Section 'Survival Outcome' trouvée mais vide ou illisible.")
  }
  
  # La première ligne est souvent l'en-tête
  header <- trimws(block[1])
  data_lines <- block[-1]
  
  # Garder la ligne du paramètre d'association
  assoc_idx <- grep(assoc_pattern, data_lines)
  if (length(assoc_idx) == 0) {
    stop(
      paste0(
        "Aucun paramètre d'association trouvé avec le motif : ", assoc_pattern,
        ". Vérifie le nom affiché dans 'Survival Outcome:'"
      )
    )
  }
  
  assoc_line <- trimws(data_lines[assoc_idx[1]])
  
  # Découpage par espaces multiples
  parts <- strsplit(assoc_line, "\\s+")[[1]]
  
  # On s'attend à : nom Mean StDev 2.5% 97.5% P Rhat
  if (length(parts) < 7) {
    stop(
      paste0(
        "Impossible d'interpréter la ligne d'association :\n",
        assoc_line
      )
    )
  }
  
  assoc_name <- parts[1]
  mean_est   <- as.numeric(parts[2])
  stdev_est  <- as.numeric(parts[3])
  low_ci     <- as.numeric(parts[4])
  upp_ci     <- as.numeric(parts[5])
  p_val      <- as.numeric(parts[6])
  rhat       <- as.numeric(parts[7])
  
  if (rule == "positive_CrI") {
    decision <- ifelse(low_ci > 0, "GO", "NO-GO")
    evidence <- paste0("95% CrI = [", round(low_ci, 4), ", ", round(upp_ci, 4), "]")
  } else {
    decision <- ifelse(mean_est > 0, "GO", "NO-GO")
    evidence <- paste0("Posterior mean = ", round(mean_est, 4))
  }
  
  list(
    assoc_name = assoc_name,
    posterior_mean = mean_est,
    posterior_sd = stdev_est,
    low_ci = low_ci,
    upp_ci = upp_ci,
    p_value_col = p_val,
    rhat = rhat,
    rule = rule,
    evidence = evidence,
    decision = decision
  )
}