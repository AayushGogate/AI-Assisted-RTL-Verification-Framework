"""
Merges individual DUT simulation results into data/combined_dataset.csv
Asserts that no rows were lost during the aggregation.
"""

import os
import glob
import pandas as pd

def merge_all():
    search_patterns = [
        "verification/combinational/*/data/results_crv_baseline.csv",
        "verification/sequential/*/data/results_crv_baseline.csv"
    ]

    files = []
    for pattern in search_patterns:
        files.extend(glob.glob(pattern))

    files.sort()
    print(f"[MERGE] Found {len(files)} baseline CSV files.")

    total_source_rows = 0
    dfs = []

    for f in files:
        df = pd.read_csv(f)
        total_source_rows += len(df)
        dfs.append(df)
        dut_name = df["dut_name"].iloc[0] if not df.empty else "unknown"
        print(f"  -> Loaded {dut_name:25s}: {len(df):>4} rows from {f}")

    if not dfs:
        raise RuntimeError("No results_crv_baseline.csv files found to merge!")

    combined = pd.concat(dfs, ignore_index=True, sort=False)
    combined_rows = len(combined)

    # Hard assertion that no rows were lost
    assert combined_rows == total_source_rows, (
        f"Row count mismatch! Source sum={total_source_rows}, Combined={combined_rows}"
    )

    out_path = "data/combined_dataset.csv"
    os.makedirs("data", exist_ok=True)
    combined.to_csv(out_path, index=False)
    print(f"[MERGE SUCCESS] Wrote {combined_rows} rows to {out_path} (0 rows lost).")
    return combined

if __name__ == "__main__":
    merge_all()
