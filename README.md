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

## Key Results

### Tumor Dynamics under Treatment

<p align="center">
  <img src="reports/figures/oncology_tumor_trajectories.png" width="700">
</p>

Simulated tumor trajectories using a mechanistic oncology model (Simeoni model).  
Higher dose levels lead to faster tumor shrinkage and reduced inter-individual variability.

---

### Dynamic Risk Prediction (Joint Modeling)

<p align="center">
  <img src="reports/figures/dynamic_prediction_patient1.png" width="700">
</p>

Individualized prediction of future event risk based on longitudinal tumor dynamics.  
This approach enables real-time risk stratification and adaptive clinical decision-making.

---

### Bayesian Dose Selection

<p align="center">
  <img src="./reports/figures/posterior_probability_50mg_worse.png" width="700">
</p>

Across repeated simulated trials, the posterior probability that the 50 mg dose was inferior remained consistently close to 1.  

This indicates a very strong treatment effect and highly robust Bayesian dose selection, with the 100 mg dose being selected in nearly all scenarios.

Note: the limited variability in posterior probabilities reflects a high signal-to-noise ratio in the simulated scenario.
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

Project Structure
MIDD_RWE_Project/
├── data/
├── functions/
│   ├── rwe/
│   └── midd/
│       └── oncology/
├── scripts/
│   ├── exploratory/
│   └── pipeline/
├── reports/
├── renv.lock
└── README.md

Main Methods and Packages
survival
nlme
JMbayes2
deSolve
ggplot2
dplyr

Example Outputs

The framework produces:

propensity-score weighted treatment effect estimates
repeated-dose PK profiles
biomarker trajectories
tumor growth/shrinkage trajectories
Cox model estimates
joint model estimates
dynamic patient-specific risk predictions
adaptive trial decisions
Bayesian dose selection probabilities
Example Oncology Insight

---


How to Run
Example pipeline scripts
scripts/pipeline/01_simulate_trial.R
scripts/pipeline/02_fit_models.R
scripts/pipeline/03_dynamic_prediction.R
scripts/pipeline/04_adaptive_trial.R
scripts/pipeline/05_oncology_simulate_trial.R
scripts/pipeline/06_oncology_fit_models.R
scripts/pipeline/08_oncology_joint_model.R
scripts/pipeline/09_oncology_joint_model_stable.R
scripts/pipeline/10_oncology_dynamic_prediction.R
scripts/pipeline/11_oncology_adaptive_trial_simulation.R
scripts/pipeline/13_oncology_bayesian_dose_optimization.R
scripts/pipeline/14_oncology_bayesian_operating_characteristics.R


Positioning

This project is relevant for roles such as:

Quantitative Scientist
MIDD Scientist
Pharmacometrics Scientist
Advanced Biostatistician
Real-World Data Scientist
Author

Blaise Mbunga Mputu
Senior Biostatistics / RWE / Quantitative Clinical Modeling