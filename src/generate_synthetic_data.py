"""
Project Siren-LTV: Reproducible Relational Data Generator
Generates synthetic member dimensions, store locations, transactional facts,
promotional offer logs, and RCT experiment assignments.
"""

from pathlib import Path
import numpy as np
import pandas as pd

def generate_synthetic_dataset(seed=42, num_members=50_000, num_stores=150, num_transactions=500_000, num_offers=120_000):
    rng = np.random.default_rng(seed)
    data_start = pd.Timestamp("2024-01-01")
    data_cutoff = pd.Timestamp("2025-12-31")
    join_cutoff = pd.Timestamp("2025-09-30")
    
    experiment_id = "SIREN_LTV_RCT_2025_10"
    assignment_date = pd.Timestamp("2025-10-01")
    pre_period_start = pd.Timestamp("2025-09-01")
    post_period_end_exclusive = pd.Timestamp("2025-10-31")

    # 1. Members Dimension
    member_ids = np.array([f"SBX_MEM_{i:06d}" for i in range(1, num_members + 1)])
    join_span = (join_cutoff - data_start).days
    join_dates = data_start.to_datetime64().astype("datetime64[D]") + rng.integers(0, join_span + 1, num_members).astype("timedelta64[D]")
    df_members = pd.DataFrame({
        "member_id": member_ids,
        "join_date": pd.to_datetime(join_dates),
        "reward_tier": rng.choice(["Green", "Gold"], num_members, p=[0.55, 0.45]),
        "acquisition_channel": rng.choice(["Mobile_App", "In_Store_QR", "Web_Portal", "Partner_Link"], num_members, p=[0.60, 0.25, 0.10, 0.05]),
        "home_store_id": rng.integers(1001, 1001 + num_stores, num_members),
    })

    # 2. Stores Dimension
    store_ids = np.arange(1001, 1001 + num_stores)
    df_stores = pd.DataFrame({
        "store_id": store_ids,
        "region": rng.choice(["Pacific_NW", "California", "Northeast", "Southeast", "Midwest"], num_stores),
        "store_format": rng.choice(["Traditional_Cafe", "Drive_Thru_Only", "Urban_Inline", "Express"], num_stores, p=[0.50, 0.30, 0.15, 0.05]),
    })

    # 3. Experiment Assignment (Balanced RCT for eligible members)
    eligible = df_members.loc[df_members["join_date"] <= pre_period_start, ["member_id", "join_date"]].copy().reset_index(drop=True)
    groups = np.array(["control"] * len(eligible), dtype=object)
    perm = rng.permutation(len(eligible))
    groups[perm[:len(eligible) // 2]] = "treatment"
    df_assignment = pd.DataFrame({
        "experiment_id": experiment_id,
        "member_id": eligible["member_id"],
        "assignment_date": assignment_date,
        "assignment_group": groups,
    })

    # 4. Transactions Fact
    tx_member_idx = rng.integers(0, num_members, num_transactions)
    tx_member_ids = member_ids[tx_member_idx]
    member_join_days = df_members["join_date"].to_numpy(dtype="datetime64[D]")[tx_member_idx]
    max_offsets = (np.datetime64(data_cutoff.date(), "D") - member_join_days).astype(int)
    tx_offsets = np.floor(rng.random(num_transactions) * (max_offsets + 1)).astype(int)
    tx_dates = member_join_days + tx_offsets.astype("timedelta64[D]")
    
    assignment_map = df_assignment.set_index("member_id")["assignment_group"]
    tx_groups = pd.Series(tx_member_ids).map(assignment_map).fillna("not_in_experiment").to_numpy()
    treatment_post = (tx_groups == "treatment") & (tx_dates >= np.datetime64(assignment_date.date(), "D")) & (tx_dates < np.datetime64(post_period_end_exclusive.date(), "D"))
    
    base_gross = np.maximum(rng.gamma(shape=3.0, scale=2.5, size=num_transactions), 1.50)
    gross = np.round(base_gross * np.where(treatment_post, 1.12, 1.0), 2)
    promo_used = rng.random(num_transactions) < 0.25
    discount_draw = np.where(promo_used, rng.uniform(1.0, 4.0, num_transactions), 0.0)
    discounts = np.round(np.minimum(discount_draw, np.maximum(gross - 1.50, 0.0)), 2)
    net_sales = np.round(gross - discounts, 2)
    
    df_transactions = pd.DataFrame({
        "transaction_id": [f"TX_{i:08d}" for i in range(1, num_transactions + 1)],
        "member_id": tx_member_ids,
        "transaction_date": pd.to_datetime(tx_dates),
        "gross_sales_amount": gross,
        "discount_amount": discounts,
        "net_sales_amount": net_sales,
        "daypart": rng.choice(["Morning_Peak", "Mid_Day", "Afternoon_Lull", "Evening"], num_transactions, p=[0.45, 0.25, 0.20, 0.10]),
        "is_mop_order": rng.choice([1, 0], num_transactions, p=[0.68, 0.32]),
        "store_id": rng.choice(store_ids, num_transactions),
    })

    # 5. Offers Fact
    offer_types = np.array(["Bonus_Star_Multiplier", "Dollar_Off_Beverage", "Free_Food_Item", "Daypart_Challenge"])
    offer_member_idx = rng.integers(0, num_members, num_offers)
    offer_member_ids = member_ids[offer_member_idx]
    offer_join_days = df_members["join_date"].to_numpy(dtype="datetime64[D]")[offer_member_idx]
    last_offer_start = np.datetime64((data_cutoff - pd.Timedelta(days=7)).date(), "D")
    offer_max_offsets = (last_offer_start - offer_join_days).astype(int)
    offer_offsets = np.floor(rng.random(num_offers) * (offer_max_offsets + 1)).astype(int)
    offer_starts = offer_join_days + offer_offsets.astype("timedelta64[D]")
    offer_ends = offer_starts + np.timedelta64(7, "D")
    
    types = rng.choice(offer_types, num_offers, p=[0.40, 0.30, 0.15, 0.15])
    member_tier_map = df_members.set_index("member_id")["reward_tier"]
    offer_tiers = pd.Series(offer_member_ids).map(member_tier_map).to_numpy()
    base_completion = {"Bonus_Star_Multiplier": 0.40, "Dollar_Off_Beverage": 0.36, "Free_Food_Item": 0.42, "Daypart_Challenge": 0.30}
    completion_p = np.array([base_completion[t] for t in types]) + np.where(offer_tiers == "Gold", 0.03, 0.0)
    completed = (rng.random(num_offers) < completion_p).astype(int)
    
    df_offers = pd.DataFrame({
        "offer_id": [f"OFFER_{i:06d}" for i in range(1, num_offers + 1)],
        "member_id": offer_member_ids,
        "offer_type": types,
        "offer_start_date": pd.to_datetime(offer_starts),
        "offer_end_date": pd.to_datetime(offer_ends),
        "is_completed": completed,
    })

    return df_members, df_stores, df_transactions, df_offers, df_assignment

if __name__ == "__main__":
    members, stores, transactions, offers, assignment = generate_synthetic_dataset()
    print(f"Generated successfully: {len(members):,} members, {len(transactions):,} transactions.")
