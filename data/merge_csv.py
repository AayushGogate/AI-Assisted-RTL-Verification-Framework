import pandas as pd
import os

# path -> dut_name
files = {
    "verification_sequential/d_flip_flop/data/results.csv": "d_flip_flop",
    "verification/mux_2to1/data/results.csv":        "mux_2to1",
    "verification/mux_4to1/data/results.csv":        "mux_4to1",
    "verification/full_adder/data/results.csv":      "full_adder",
    "verification/4bit_adder/data/results.csv":      "4bit_adder_ML",
    "verification/4bit_adder/data/results_crv.csv":      "4bit_adder_CRV",
    "verification/2bit_comparator/data/results.csv": "2bit_comparator",
}

dfs = []
for path, dut_name in files.items():
    df = pd.read_csv(path)
    df.insert(0, "dut_name", dut_name)   # tag every row with its DUT
    dfs.append(df)
    print(f"{dut_name}: {len(df)} rows, columns = {list(df.columns)}")

combined = pd.concat(dfs, ignore_index=True, sort=False)
# columns unique to one DUT (e.g. I0,I1,I2,I3 for mux_4to1) become NaN for other DUTs' rows

combined.to_csv("data/combined_dataset.csv", index=False)

print(f"\nTotal combined rows: {len(combined)}")
print(f"Expected total: {sum(len(pd.read_csv(p)) for p in files)}")