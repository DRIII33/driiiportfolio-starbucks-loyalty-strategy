-- ============================================================================
-- Project Siren-LTV: Analytical View Definitions
-- BigQuery Dialect (Standard SQL)
-- ============================================================================

-- 1. Descriptive Offer Performance View
CREATE OR REPLACE VIEW `driiiportfolio.starbucks_loyalty_analytics.vw_offer_performance` AS
WITH offer_base AS (
  SELECT
    o.offer_id,
    o.member_id,
    o.offer_type,
    COALESCE(m.reward_tier, 'UNKNOWN') AS reward_tier,
    o.offer_start_date,
    o.offer_end_date,
    o.is_completed
  FROM `driiiportfolio.starbucks_loyalty_analytics.fact_offers` AS o
  LEFT JOIN `driiiportfolio.starbucks_loyalty_analytics.dim_members` AS m
    ON o.member_id = m.member_id
),
offer_summary AS (
  SELECT
    offer_type,
    reward_tier,
    COUNT(DISTINCT offer_id) AS total_offers_issued,
    COUNTIF(is_completed = 1) AS total_offers_completed,
    SAFE_DIVIDE(COUNTIF(is_completed = 1), COUNT(DISTINCT offer_id)) AS completion_rate
  FROM offer_base
  GROUP BY offer_type, reward_tier
),
transaction_offer_candidates AS (
  SELECT
    t.transaction_id,
    o.offer_type,
    o.reward_tier,
    t.gross_sales_amount,
    t.discount_amount,
    t.net_sales_amount,
    ROW_NUMBER() OVER (
      PARTITION BY t.transaction_id
      ORDER BY o.offer_start_date DESC, o.offer_id
    ) AS attribution_rank
  FROM `driiiportfolio.starbucks_loyalty_analytics.fact_transactions` AS t
  JOIN offer_base AS o
    ON t.member_id = o.member_id
   AND t.transaction_date BETWEEN o.offer_start_date AND o.offer_end_date
),
attributed_sales AS (
  SELECT
    offer_type,
    reward_tier,
    COUNT(DISTINCT transaction_id) AS attributed_unique_transactions,
    SUM(gross_sales_amount) AS attributed_gross_sales,
    SUM(discount_amount) AS attributed_transaction_discount_amount,
    SUM(net_sales_amount) AS attributed_net_sales,
    SAFE_DIVIDE(SUM(net_sales_amount), SUM(gross_sales_amount)) AS net_to_gross_sales_ratio
  FROM transaction_offer_candidates
  WHERE attribution_rank = 1
  GROUP BY offer_type, reward_tier
)
SELECT
  s.offer_type,
  s.reward_tier,
  s.total_offers_issued,
  s.total_offers_completed,
  s.completion_rate,
  COALESCE(a.attributed_unique_transactions, 0) AS attributed_unique_transactions,
  COALESCE(a.attributed_gross_sales, 0) AS attributed_gross_sales,
  COALESCE(a.attributed_transaction_discount_amount, 0) AS attributed_transaction_discount_amount,
  COALESCE(a.attributed_net_sales, 0) AS attributed_net_sales,
  a.net_to_gross_sales_ratio
FROM offer_summary AS s
LEFT JOIN attributed_sales AS a
  USING (offer_type, reward_tier);


-- 2. Mature 90-Calendar-Day Cohort Value and Frequency View
CREATE OR REPLACE VIEW `driiiportfolio.starbucks_loyalty_analytics.vw_cohort_90d_ltv` AS
WITH data_cutoff AS (
  SELECT MAX(transaction_date) AS max_transaction_date
  FROM `driiiportfolio.starbucks_loyalty_analytics.fact_transactions`
),
first_mop AS (
  SELECT
    t.member_id,
    MIN(t.transaction_date) AS first_mop_date
  FROM `driiiportfolio.starbucks_loyalty_analytics.fact_transactions` AS t
  JOIN `driiiportfolio.starbucks_loyalty_analytics.dim_members` AS m
    ON t.member_id = m.member_id
  WHERE t.is_mop_order = 1
    AND t.transaction_date >= m.join_date
  GROUP BY t.member_id
),
mature_members AS (
  SELECT
    m.member_id,
    m.join_date,
    DATE_TRUNC(m.join_date, MONTH) AS cohort_month,
    m.acquisition_channel,
    f.first_mop_date,
    CASE
      WHEN f.first_mop_date < DATE_ADD(m.join_date, INTERVAL 14 DAY)
        THEN 'MOP_WITHIN_14D'
      WHEN f.first_mop_date IS NOT NULL
        THEN 'MOP_AFTER_14D'
      ELSE 'NO_MOP_OBSERVED'
    END AS mop_onboarding_group
  FROM `driiiportfolio.starbucks_loyalty_analytics.dim_members` AS m
  LEFT JOIN first_mop AS f USING (member_id)
  CROSS JOIN data_cutoff AS d
  WHERE m.join_date <= DATE_SUB(d.max_transaction_date, INTERVAL 89 DAY)
),
member_spend AS (
  SELECT
    m.member_id,
    m.cohort_month,
    m.acquisition_channel,
    m.mop_onboarding_group,
    COALESCE(SUM(t.net_sales_amount), 0) AS net_spend_90d,
    COUNT(DISTINCT t.transaction_id) AS tx_count_90d
  FROM mature_members AS m
  LEFT JOIN `driiiportfolio.starbucks_loyalty_analytics.fact_transactions` AS t
    ON t.member_id = m.member_id
   AND t.transaction_date >= m.join_date
   AND t.transaction_date < DATE_ADD(m.join_date, INTERVAL 90 DAY)
  GROUP BY m.member_id, m.cohort_month, m.acquisition_channel, m.mop_onboarding_group
)
SELECT
  cohort_month,
  acquisition_channel,
  mop_onboarding_group,
  COUNT(DISTINCT member_id) AS total_members,
  AVG(net_spend_90d) AS avg_90d_net_sales_per_member,
  AVG(tx_count_90d) AS avg_90d_transactions_per_member
FROM member_spend
GROUP BY cohort_month, acquisition_channel, mop_onboarding_group;


-- 3. Randomized Synthetic Experiment Member-Level Change View
CREATE OR REPLACE VIEW `driiiportfolio.starbucks_loyalty_analytics.vw_experiment_member_change` AS
WITH member_period AS (
  SELECT
    a.experiment_id,
    a.member_id,
    a.assignment_date,
    a.assignment_group,
    SUM(CASE
      WHEN t.transaction_date >= DATE '2025-09-01'
       AND t.transaction_date < DATE '2025-10-01'
      THEN COALESCE(t.net_sales_amount, 0) ELSE 0 END) AS pre_30d_net_sales,
    SUM(CASE
      WHEN t.transaction_date >= DATE '2025-10-01'
       AND t.transaction_date < DATE '2025-10-31'
      THEN COALESCE(t.net_sales_amount, 0) ELSE 0 END) AS post_30d_net_sales,
    COUNTIF(t.transaction_id IS NOT NULL
      AND t.transaction_date >= DATE '2025-09-01'
      AND t.transaction_date < DATE '2025-10-01') AS pre_30d_transactions,
    COUNTIF(t.transaction_id IS NOT NULL
      AND t.transaction_date >= DATE '2025-10-01'
      AND t.transaction_date < DATE '2025-10-31') AS post_30d_transactions
  FROM `driiiportfolio.starbucks_loyalty_analytics.fact_experiment_assignment` AS a
  LEFT JOIN `driiiportfolio.starbucks_loyalty_analytics.fact_transactions` AS t
    ON t.member_id = a.member_id
   AND t.transaction_date >= DATE '2025-09-01'
   AND t.transaction_date < DATE '2025-10-31'
  GROUP BY a.experiment_id, a.member_id, a.assignment_date, a.assignment_group
)
SELECT
  experiment_id,
  member_id,
  assignment_date,
  assignment_group,
  pre_30d_net_sales,
  post_30d_net_sales,
  pre_30d_net_sales / 30.0 AS pre_avg_daily_net_sales,
  post_30d_net_sales / 30.0 AS post_avg_daily_net_sales,
  (post_30d_net_sales - pre_30d_net_sales) / 30.0 AS change_avg_daily_net_sales,
  pre_30d_transactions,
  post_30d_transactions
FROM member_period;
