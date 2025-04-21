# Bayesian Estimation of Credit Conversion Factor (CCF)
This project is part of DSA 595 Bayesian computations for machine learning. 

This project implements a fully Bayesian modeling pipeline to estimate the **Credit Conversion Factor (CCF)** using real-world data from LendingClub. CCF is a key input in regulatory capital calculations under Basel III.

---

## 📄 Report

See the complete methodology, exploratory analysis, model details, and simulation results in the final report:

👉 [report.pdf](./report.pdf)

---

## 🔧 Files Included

| File             | Description |
|------------------|-------------|
| `report.pdf`     | Final report (10 pages + appendix) |
| `eda_script.r`   | Data cleaning, feature selection, EDA |
| `run_file.r`     | Gibbs sampler for Bayesian linear regression |
| `out_file.r`     | Aggregates simulation results and computes credible intervals |
| `workflow.sh`    | Runs all scripts to reproduce results end-to-end |

---

## 🧪 Reproducibility

To fully reproduce the results:

```bash
bash workflow.sh
