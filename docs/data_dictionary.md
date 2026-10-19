# Project Siren-LTV: Data Dictionary

| Table Name | Column Name | Data Type | Nullable | Description |
| :--- | :--- | :--- | :--- | :--- |
| **dim_members** | `member_id` | STRING | NO | Unique member identifier (e.g., `SBX_MEM_000001`). |
| | `join_date` | DATE | NO | Calendar date when the member registered. |
| | `reward_tier` | STRING | NO | Loyalty program tier (`Green` or `Gold`). |
| | `acquisition_channel`| STRING | NO | Channel through which the member joined (`Mobile_App`, `In_Store_QR`, etc.). |
| | `home_store_id` | INT64 | NO | Foreign key referencing `dim_store_locations.store_id`. |
| **dim_store_locations**| `store_id` | INT64 | NO | Unique store identifier. |
| | `region` | STRING | NO | Geographic region (`Pacific_NW`, `California`, `Northeast`, etc.). |
| | `store_format` | STRING | NO | Store architectural format (`Traditional_Cafe`, `Drive_Thru_Only`, etc.). |
| **fact_transactions** | `transaction_id` | STRING | NO | Unique transaction identifier (e.g., `TX_00000001`). |
| | `member_id` | STRING | NO | Foreign key referencing `dim_members.member_id`. |
| | `transaction_date` | DATE | NO | Calendar date of transaction (Partitioning field). |
| | `gross_sales_amount` | FLOAT64 | NO | Pre-discount transaction ticket total ($\ge \$1.50$). |
| | `discount_amount` | FLOAT64 | NO | Applied promotional discount ($0.00 \le discount < gross$). |
| | `net_sales_amount` | FLOAT64 | NO | Final revenue collected (`gross_sales_amount - discount_amount`). |
| | `daypart` | STRING | NO | Operational daypart (`Morning_Peak`, `Mid_Day`, `Afternoon_Lull`, `Evening`). |
| | `is_mop_order` | INT64 | NO | Binary flag indicating Mobile Order & Pay (`1` = Yes, `0` = No). |
| | `store_id` | INT64 | NO | Foreign key referencing `dim_store_locations.store_id`. |
| **fact_offers** | `offer_id` | STRING | NO | Unique offer issuance identifier. |
| | `member_id` | STRING | NO | Foreign key referencing `dim_members.member_id`. |
| | `offer_type` | STRING | NO | Promotional mechanism type (`Bonus_Star_Multiplier`, `Dollar_Off_Beverage`, etc.). |
| | `offer_start_date` | DATE | NO | Promotion validity window start date. |
| | `offer_end_date` | DATE | NO | Promotion validity window end date. |
| | `is_completed` | INT64 | NO | Binary indicator of offer goal completion (`1` = Completed, `0` = Uncompleted). |
| **fact_experiment_assignment**| `experiment_id` | STRING | NO | Campaign experiment identifier (`SIREN_LTV_RCT_2025_10`). |
| | `member_id` | STRING | NO | Foreign key referencing `dim_members.member_id`. |
| | `assignment_date` | DATE | NO | Date of randomized exposure (`2025-10-01`). |
| | `assignment_group` | STRING | NO | Experimental arm (`control` or `treatment`). |
