# MIDD Oncology & RWE Framework

End-to-end R framework for Model-Informed Drug Development (MIDD) and Real-World Evidence (RWE), combining causal inference, PK/PD simulation, tumor dynamics, survival analysis, joint modeling, dynamic prediction, and Bayesian adaptive dose optimization.

## Project Overview

This project demonstrates how quantitative methods can be integrated across the drug development lifecycle:

- Real-World Evidence (RWE) causal inference using propensity scores and IPTW
- Repeated-dose PK simulation
- PK/PD biomarker and tumor dynamics modeling
- Disease progression modeling
- Survival analysis and joint longitudinal-survival models
- Dynamic risk prediction
- Adaptive trial simulation
- Bayesian dose selection

The framework is designed as a portfolio-grade project for quantitative clinical modeling, pharmacoepidemiology, and MIDD applications.

---

## Key Components

### 1. Real-World Evidence (RWE)
Implemented reusable R functions for:

- propensity score estimation
- inverse probability of treatment weighting (IPTW)
- weighted Cox models
- balance diagnostics

### 2. PK/PD and Disease Modeling
Implemented repeated-dose PK simulation and exposure-response modeling, including:

- one-compartment PK model
- Emax pharmacodynamic model
- longitudinal biomarker simulation
- mechanistic oncology tumor growth model (Simeoni model)

### 3. Survival and Joint Modeling
Implemented:

- Cox proportional hazards models
- longitudinal mixed-effects models
- joint longitudinal-survival models using `JMbayes2`
- dynamic prediction of individual event risk

### 4. Adaptive Trial Simulation
Implemented:

- interim analysis framework
- frequentist adaptive dose selection
- Bayesian dose optimization
- operating characteristics across repeated simulated trials

---

## Scientific Workflow

```text
Dose regimen
↓
PK simulation
↓
PD / biomarker or tumor dynamics
↓
Disease progression
↓
Survival risk
↓
Joint modeling
↓
Dynamic prediction
↓
Adaptive decision / dose optimization