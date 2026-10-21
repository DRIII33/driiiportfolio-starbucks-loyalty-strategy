# Executive Summary: Project Siren-LTV
---

**Project Title:** Project Siren-LTV: Loyalty Promotion Performance & Member Value Analytics  

**Author:** Daniel Rodriguez III  

**Cloud Environment:** Google Cloud BigQuery (`driiiportfolio.starbucks_loyalty_analytics`)  

**Target Audience:** Starbucks Global Digital Ventures & Marketing, Loyalty Strategy & Performance Leadership  

---

## Strategic Context & Business Problem

Starbucks Rewards boasts over 35.5 million active U.S. members who drive a significant share of company revenue. However, reliance on generic promotional challenges (e.g., bonus star multipliers and discount offers) risks falling into the **Cannibalization Trap**—where mass promotional discounting erodes gross margins while subsidizing purchases that high-frequency Gold and Reserve members would have made organically.

To solve this, **Project Siren-LTV** was engineered as an enterprise-grade analytics framework designed to:
1. **Eliminate Cannibalization:** Evaluate promotional offer incrementality versus discount erosion using randomized controlled trials (RCTs) and difference-in-differences (DiD) econometric models.
2. **Decode LTV Drivers:** Connect early digital onboarding milestones (specifically Days 1–14 Mobile Order & Pay adoption) to 90-day Customer Lifetime Value (`LTV`) and transaction frequency.
3. **Unify Siloed Telemetry:** Centralize fragmented app telemetry, POS transaction logs, and financial margin data into a secure, partitioned BigQuery cloud warehouse.

---

## Key Analytical Findings

* **Net Margin Health:** Across 120,000 issued offers, the overall completion rate stands at **39.11%** with an average net-to-gross margin ratio of **92.7%**, confirming strong baseline unit economics that must be protected against indiscriminate discounting.
* **The Gold Tier Subsidy:** Attribution analysis reveals that `Bonus_Star_Multiplier` and `Dollar_Off_Beverage` generate high gross revenue (`$83.53K` and `$63.13K`, respectively) but siphon heavy discount costs (`$2.89K` and `$2.26K`) to Gold tier members, confirming the need for stricter targeting thresholds.
* **Causal Lift Verification:** Econometric difference-in-differences regression isolates an RCT estimated causal lift of **+$0.02** in daily net sales change for treated members over control baselines, proving genuine behavioral shift.
* **Digital Habituation Velocity:** Mature cohort analysis proves that members who adopt Mobile Order & Pay (MOP) within their first 14 days achieve a 90-day net spend of **~$26.21 to ~$26.82**, compared to under **~$5.00** for non-MOP users, establishing a concrete product roadmap target.

[View Live Looker Studio Dashboard](https://datastudio.google.com/embed/reporting/dc472cc0-4f38-4fac-ae1f-816e0b222ceb/page/p_d76wfmwh8d) 

* **Note:** *If you experience any issues viewing the dashboard, please request access.*
