# Auditing, Data Quality Gates, & Cloud Guardrails

## 1. Automated Quality Gates
Before any transactional fact or promotional log is published to BigQuery, the pipeline enforces strict automated assertions:
* **Referential Integrity:** 100% of foreign keys (`member_id`, `store_id`) must resolve to active dimension records.
* **Temporal Logic:** `transaction_date >= join_date` and `offer_start_date <= offer_end_date`.
* **Financial Reconciliation:** Gross sales minus discount amount must equal net sales within a $0.01 tolerance, with an enforced minimum ticket floor of $\ge \$1.50$.

## 2. BigQuery Cost & Storage Governance
* **Partition Expiration:** Fact tables retain a 60-day active sandbox partition lifecycle.
* **Query Ceilings:** Interactive queries enforce a strict 1 GB maximum bytes billed ceiling.
