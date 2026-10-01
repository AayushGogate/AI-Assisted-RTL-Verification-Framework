import pandas as pd

df = pd.read_csv("data/combined_dataset.csv")

def label_row(row):
    dut = row["dut_name"]

    if dut == "mux_2to1":
        S = int(row["S"])
        chosen = int(row["A"]) if S == 0 else int(row["B"])
        return f"S{S}_val{chosen}"

    elif dut == "mux_4to1":
        S1 = int(row["S1"])
        S0 = int(row["S0"])
        chosen = int(row["expected"])  # value of the selected input line
        return f"S1{S1}_S0{S0}_val{chosen}"

    elif dut == "full_adder":
        A = int(row["A"])
        B = int(row["B"])
        Cin = int(row["Cin"])
        return f"A{A}_B{B}_Cin{Cin}"

    elif dut == "adder_4bit":
        tags = []
        expected = int(row["expected"])
        Cout = int(row["Cout"])
        Cin = int(row["Cin"])
        if expected == 0:
            tags.append("zero_result")
        if expected == 31:
            tags.append("max_result")
        tags.append("carry" if Cout == 1 else "no_carry")
        tags.append("cin_1" if Cin == 1 else "cin_0")
        return ",".join(tags)

    elif dut == "comparator_2bit":
        exp = int(row["expected"])  # 100=gt, 010=eq, 001=lt (as decimal-parsed binary string)
        if exp == 100:
            return "gt"
        elif exp == 10:
            return "eq"
        elif exp == 1:
            return "lt"
        else:
            return "unknown"

    return "unlabeled"

df["coverage_bin"] = df.apply(label_row, axis=1)

df.to_csv("data/combined_dataset_labeled.csv", index=False)

print(f"Labeled {len(df)} rows")
print(df.groupby("dut_name")["coverage_bin"].nunique())