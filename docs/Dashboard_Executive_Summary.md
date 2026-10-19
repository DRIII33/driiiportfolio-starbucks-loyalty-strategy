# Looker Studio Dashboard Executive Summary: Project Siren-LTV
---

**Author:** Daniel Rodriguez III  

**Dashboard Title:** Project Siren-LTV: Executive Loyalty Strategy & Member Value Intelligence  

**Platform:** Google Looker Studio  

**Data Sources:** BigQuery Analytical Views (`vw_offer_performance`, `vw_cohort_90d_ltv`, `vw_experiment_member_change`)  

---

## Dashboard Architecture & Navigation

The Looker Studio dashboard is structured into two dedicated executive pages designed around the Pyramid Principle—distilling complex multi-terabyte data streams into immediate, scannable insights for C-suite stakeholders without relying on raw code or cluttered pivot tables.

---

### Page 1: Executive Overview & Campaign Incrementality
* **Purpose:** Addresses **Bottleneck 1 (The Cannibalization Trap)** by auditing campaign volume, net-to-gross margin retention, and true causal lift.
* **Key Visualizations & Data Story:**
  1. **Executive Scorecards:** Tracks total offers issued (120.0K), completion rate (39.11%), attributed net sales ($207.70K), and average net-to-gross margin ratio (92.7%).
  2. **Offer Performance & Net Margin by Tier:** Stacked bar charts contrasting Green vs. Gold tier revenue and discount impact, exposing margin-eroding subsidies funneled to high-frequency members.
  3. **Randomized Controlled Trial (RCT) Lift Analysis:** Difference-in-differences bar chart showing incremental daily net sales lift ($0.0243 treatment vs. $0.0028 control).

---

### Page 2: Member LTV & Behavioral Onboarding Velocity
* **Purpose:** Resolves **Bottleneck 2 (Ambiguous LTV Drivers)** and **Bottleneck 3 (Siloed Insights)** by connecting early digital adoption to 90-day LTV.
* **Key Visualizations & Data Story:**
  1. **90-Day LTV KPI Scorecards:** Highlights mature member base (50,000), mean 90-day net spend ($19.97), and transaction frequency (2.85).
  2. **90-Day LTV by MOP Onboarding Velocity:** Clustered column chart demonstrating that early Mobile Order & Pay adoption within 14 days multiplies 90-day spend.
  3. **Cohort Transaction Frequency & Channel Breakdown:** Comprehensive data table unifying acquisition channels, monthly cohorts, and transaction counts.
