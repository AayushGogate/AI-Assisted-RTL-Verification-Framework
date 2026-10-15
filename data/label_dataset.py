"""
Labels combined_dataset.csv with rare/common indicators.
Rare bin definition: bin hit count < 50% of mean bin count for that DUT, or never hit (count = 0).
Outputs data/combined_dataset_labeled.csv.
"""

import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import pandas as pd
from coverage.coverage_config import DUT_CONFIG

def label_dataset():
    input_path = "data/combined_dataset.csv"
    output_path = "data/combined_dataset_labeled.csv"

    if not os.path.exists(input_path):
        raise FileNotFoundError(f"{input_path} does not exist. Run merge_datasets.py first.")

    df = pd.read_csv(input_path)
    print(f"[LABELING] Loaded {len(df)} rows from {input_path}")

    df["is_rare"] = 0
    df["bin_hit_count"] = 0
    df["mean_bin_count"] = 0.0

    stats = []

    for dut_name, group in df.groupby("dut_name"):
        bin_counts = group["coverage_bin"].value_counts()
        mean_cnt = bin_counts.mean()
        rare_threshold = 0.5 * mean_cnt

        rare_bins = set(bin_counts[bin_counts < rare_threshold].index)

        # Also identify any theoretical bins from DUT_CONFIG that were NEVER hit
        cfg = DUT_CONFIG.get(dut_name, {})
        all_possible = set(cfg.get("all_bins", []))
        hit_bins = set(bin_counts.index)
        missing_bins = all_possible - hit_bins
        rare_bins = rare_bins | missing_bins

        # Map back to rows
        idx = group.index
        df.loc[idx, "mean_bin_count"] = round(mean_cnt, 2)
        df.loc[idx, "bin_hit_count"] = df.loc[idx, "coverage_bin"].map(bin_counts)
        df.loc[idx, "is_rare"] = df.loc[idx, "coverage_bin"].apply(lambda b: 1 if b in rare_bins else 0)

        n_rare_rows = (df.loc[idx, "is_rare"] == 1).sum()
        stats.append({
            "dut_name": dut_name,
            "total_tests": len(group),
            "distinct_bins_hit": len(hit_bins),
            "total_bins_possible": len(all_possible),
            "missing_bins_count": len(missing_bins),
            "rare_bins_count": len(rare_bins),
            "rare_rows_count": n_rare_rows,
            "mean_bin_count": round(mean_cnt, 2)
        })

    df.to_csv(output_path, index=False)
    print(f"[LABELING SUCCESS] Wrote {len(df)} labeled rows to {output_path}")

    stats_df = pd.DataFrame(stats)
    print("\n[COVERAGE & RARITY SUMMARY PER DUT]")
    print(stats_df.to_string(index=False))

    return df, stats_df

if __name__ == "__main__":
    label_dataset()
