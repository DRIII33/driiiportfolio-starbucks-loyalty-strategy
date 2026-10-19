"""
Project Siren-LTV: Econometric Lift & DiD Estimation Script
Executes OLS regressions with HC3 robust standard errors on synthetic experiment data.
"""

import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf

def run_econometric_models():
    print("Loading transaction and offer logs for Econometric Lift Analysis...")
    df_tx = pd.read_csv('fact_transactions.csv')
    df_offers = pd.read_csv('fact_offers.csv')

    df_offers['offer_start_date'] = pd.to_datetime(df_offers['offer_start_date'])
    df_tx['transaction_date'] = pd.to_datetime(df_tx['transaction_date'])

    df_did = df_offers.merge(df_tx, on='member_id', how='inner')
    df_did['post_period'] = np.where(df_did['transaction_date'] >= df_did['offer_start_date'], 1, 0)
    df_did['treatment_group'] = df_did['is_completed']

    model = smf.ols('net_sales_amount ~ treatment_group * post_period', data=df_did).fit(cov_type="HC3")

    print("\n==============================================================================")
    print("             ECONOMETRIC DIFFERENCE-IN-DIFFERENCES LTV MODEL RESULTS           ")
    print("==============================================================================")
    print(model.summary().tables[1])

    did_coef = model.params['treatment_group:post_period']
    p_val = model.pvalues['treatment_group:post_period']

    print("\n------------------------------------------------------------------------------")
    print(f"Incremental Lift per Transaction (DiD Interaction): ${did_coef:.2f}")
    print(f"Statistical Significance (P-Value): {p_val:.4f}")
    print("------------------------------------------------------------------------------")

if __name__ == "__main__":
    run_econometric_models()
