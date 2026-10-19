# Architecture and Relational Schema Design

## 1. Cloud Infrastructure & Cost Control

Project Siren-LTV is engineered to operate within Google Cloud BigQuery Free Tier limitations (10 GiB active storage, 1 TiB query processing per month). To prevent accidental cost overruns, the pipeline enforces:
* **Dry-Run Estimations:** Every query is pre-screened using a dry-run execution configuration to calculate processed bytes.
* **Strict Byte Ceilings:** A hard ceiling (`maximum_bytes_billed = 1,000,000,000` bytes / 1 GB) is enforced on all interactive SELECT queries.
* **Partition Pruning:** Fact tables are partitioned by date and clustered by primary entity keys to minimize scan volume.

---

## 2. Relational Schema Specification

The database comprises two dimension tables, two fact tables, and one experimental assignment table:

### `dim_members`
* **Purpose:** Stores core member attributes and acquisition metadata.
* **Schema:** `member_id` (STRING, PK), `join_date` (DATE), `reward_tier` (STRING: 'Green', 'Gold'), `acquisition_channel` (STRING), `home_store_id` (INT64).

### `dim_store_locations`
* **Purpose:** Stores physical store metadata and geographic classifications.
* **Schema:** `store_id` (INT64, PK), `region` (STRING), `store_format` (STRING).

### `fact_transactions`
* **Purpose:** Granular log of all point-of-sale and mobile-order-pay (MOP) transactions.
* **Schema:** `transaction_id` (STRING, PK), `member_id` (STRING, FK), `transaction_date` (DATE), `gross_sales_amount` (FLOAT64), `discount_amount` (FLOAT64), `net_sales_amount` (FLOAT64), `daypart` (STRING), `is_mop_order` (INT64), `store_id` (INT64, FK).
* **Partitioning & Clustering:** Partitioned by `transaction_date` (DAY) with a 60-day Sandbox retention policy; clustered by `member_id` and `daypart`.

### `fact_offers`
* **Purpose:** Promotional offer distribution and completion tracking.
* **Schema:** `offer_id` (STRING, PK), `member_id` (STRING, FK), `offer_type` (STRING), `offer_start_date` (DATE), `offer_end_date` (DATE), `is_completed` (INT64: 0 or 1).
* **Clustering:** Clustered by `offer_type` and `member_id`.

### `fact_experiment_assignment`
* **Purpose:** Randomized control trial (RCT) member assignment log.
* **Schema:** `experiment_id` (STRING), `member_id` (STRING, FK), `assignment_date` (DATE), `assignment_group` (STRING: 'control', 'treatment').
