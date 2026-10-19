# Project Siren-LTV: Loyalty Promotion Performance & Member Value Analytics

**Author:** Daniel Rodriguez III  
**Cloud Environment:** Google Cloud BigQuery (`driiiportfolio`)  
**Dataset:** `starbucks_loyalty_analytics`  
**GitHub Repository:** [starbucks-loyalty-analytics-siren-ltv](https://github.com/DRIIIGistus/starbucks-loyalty-analytics-siren-ltv)  

---

## Executive Summary

**Project Siren-LTV** is an enterprise-grade portfolio project designed to evaluate loyalty promotion effectiveness, measure mature 90-day member lifetime value (LTV), and isolate causal incrementality via a synthetic randomized controlled trial (RCT). Operating within BigQuery Free Tier guardrails, this project establishes a fully reproducible end-to-end data engineering and econometric pipeline—from relational synthetic data generation and partitioned cloud loading to advanced econometric modeling using Python and SQL.

> **Important Disclosure:** All underlying member records, transaction histories, and promotional responses are synthetic. This project does not incorporate proprietary Starbucks data, nor does it establish actual operational performance for Starbucks Corporation. It serves strictly as a technical demonstration of advanced data warehousing, data quality auditing, and econometric evaluation techniques.

---

## Key Technical Components

1. **Relational Data Engineering:** Generates 50,000 members, 150 stores, 500,000 transactions, 120,000 offers, and randomized experiment assignments, maintaining strict referential integrity and financial reconciliation ($net = gross - discount$, with a $1.50 minimum ticket).
2. **Cloud Data Warehouse Architecture:** Loaded into BigQuery with explicit schemas, date partitioning (`transaction_date`), and member-level clustering (`member_id`, `daypart`). Dataset and schema expiration policies are configured for Sandbox compliance.
3. **Advanced Econometric Modeling:** 
   * **Intent-to-Treat (ITT) RCT Analysis:** Deploys a difference-in-differences change-score regression with heteroscedasticity-robust standard errors (HC3) to evaluate a simulated promotional campaign.
   * **Difference-in-Differences (DiD) Transaction Model:** Examines raw offer completion effects versus randomized assignment to highlight the dangers of selection bias and cannibalization.
4. **Reproducible Artifacts:** Complete automation scripts, SQL views, validation reports, and execution manifests packaged cleanly for stakeholder review.

---

## Repository Architecture

* `notebooks/`: Contains the master executable Jupyter/Colab notebook (`Project_Siren_LTV_Portfolio.ipynb`).
* `sql/`: BigQuery DDL definitions (`01_create_views.sql`) and data quality auditing scripts (`02_validation.sql`).
* `src/`: Python scripts for reproducible data generation (`generate_synthetic_data.py`) and econometric lift modeling (`run_econometric_model.py`).
* `docs/`: In-depth documentation covering architecture, data dictionaries, and auditing guardrails.
* `artifacts/`: Machine-readable CSV reports and run manifests (`run_manifest.json`).

---

## Quickstart & Reproducibility

1. Clone the repository and navigate to the project root.
2. Execute the data generation script:
   ```bash
   python src/generate_synthetic_data.py
