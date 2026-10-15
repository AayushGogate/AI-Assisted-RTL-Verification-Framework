import pandas as pd
import os

# Base verification directory
verification_dir = "verification"

# DUT type labels
dut_types = {
    "2bit_comparator": "COMPARATOR",
    "4bit_adder": "ADDER",
    "binary_to_gray_3bit": "CONVERTER",
    "decoder_2to4": "DECODER",
    "demux_1to4": "DEMUX",
    "full_adder": "ADDER",
    "mux_2to1": "MUX",
    "mux_4to1": "MUX"
}

dfs = []

# 
# Find results.csv from every DUT folder
for dut_name in os.listdir(verification_dir):

    dut_folder = os.path.join(verification_dir, dut_name)

    # Make sure it is a folder
    if not os.path.isdir(dut_folder):
        continue

    csv_path = os.path.join(
        dut_folder,
        "data",
        "results.csv"
    )

    # Skip DUTs that don't have results.csv
    if not os.path.exists(csv_path):
        print(f"SKIPPED: {dut_name} -> results.csv not found")
        continue

    # Read CSV
    df = pd.read_csv(csv_path)

    # --------------------------------------------------
    # Add labels
    # --------------------------------------------------

    df.insert(0, "dut_name", dut_name)

    dut_type = dut_types.get(
        dut_name,
        "UNKNOWN"
    )

    df.insert(1, "dut_type", dut_type)

    # Current datasets are constrained-random tests
    df.insert(2, "test_type", "random")

    # Add source file for traceability
    df.insert(3, "source_file", csv_path)

    dfs.append(df)

    print(
        f"LOADED: {dut_name:<20} "
        f"{len(df):>4} rows"
    )

# --------------------------------------------------
# Check if anything was found
# --------------------------------------------------

if not dfs:
    print("\nNo results.csv files were found.")
    exit()

# --------------------------------------------------
# Combine all datasets row-wise
# --------------------------------------------------

combined = pd.concat(
    dfs,
    ignore_index=True,
    sort=False
)

# --------------------------------------------------
# Create output directory
# --------------------------------------------------

os.makedirs("data", exist_ok=True)

# --------------------------------------------------
# Save combined dataset
# --------------------------------------------------

output_path = "data/combined_dataset.csv"

combined.to_csv(
    output_path,
    index=False
)

# --------------------------------------------------
# Final summary
# --------------------------------------------------

print("\n========================================")
print("COMBINED DATASET")
print("========================================")

print(f"Total rows    : {len(combined)}")
print(f"Total columns : {len(combined.columns)}")

print("\nRows per DUT:")
print(combined["dut_name"].value_counts())

print("\nRows per DUT type:")
print(combined["dut_type"].value_counts())

print("\nTest types:")
print(combined["test_type"].value_counts())

print("\nOutput:")
print(output_path)

print("========================================")