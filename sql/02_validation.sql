-- ============================================================================
-- Project Siren-LTV: Data Integrity & Reconciliation Audit Queries
-- ============================================================================

-- 1. Referential Integrity & Financial Reconciliation Check
SELECT
  COUNTIF(m.member_id IS NULL) AS transactions_without_member,
  COUNTIF(s.store_id IS NULL) AS transactions_without_store,
  COUNTIF(t.transaction_date < m.join_date) AS transactions_before_join,
  COUNTIF(t.gross_sales_amount < 1.50 OR t.discount_amount < 0 OR t.net_sales_amount < 1.50) AS invalid_amount_rows,
  COUNTIF(ABS(t.gross_sales_amount - t.discount_amount - t.net_sales_amount) > 0.01) AS amount_reconciliation_failures
FROM `driiiportfolio.starbucks_loyalty_analytics.fact_transactions` AS t
LEFT JOIN `driiiportfolio.starbucks_loyalty_analytics.dim_members` AS m USING (member_id)
LEFT JOIN `driiiportfolio.starbucks_loyalty_analytics.dim_store_locations` AS s USING (store_id);


-- 2. Offer Window & Completion Flag Validation
SELECT
  COUNTIF(o.offer_start_date > o.offer_end_date) AS invalid_offer_windows,
  COUNTIF(o.is_completed NOT IN (0, 1) OR o.is_completed IS NULL) AS invalid_completion_flags,
  COUNTIF(m.member_id IS NULL) AS offers_without_member,
  COUNTIF(o.offer_start_date < m.join_date) AS offers_before_member_join
FROM `driiiportfolio.starbucks_loyalty_analytics.fact_offers` AS o
LEFT JOIN `driiiportfolio.starbucks_loyalty_analytics.dim_members` AS m USING (member_id);


-- 3. Randomized Assignment Balance Check
SELECT
  assignment_group,
  COUNT(*) AS assigned_members,
  COUNT(DISTINCT member_id) AS distinct_members
FROM `driiiportfolio.starbucks_loyalty_analytics.fact_experiment_assignment`
GROUP BY assignment_group
ORDER BY assignment_group;
