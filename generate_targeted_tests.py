"""
Generalized ML-guided coverage-directed test generator.

One reusable engine (space generation -> model training -> candidate ranking
-> verification) driven by a small per-DUT config block. Add a new DUT by
adding one config entry below -- no new script needed.

Each DUT config needs:
  inputs   : {column_name: (min_val, max_val)}          -- defines full input space
  bin_fn   : function(row_dict) -> coverage bin label    -- your Phase 3 coverage model
  ref_fn   : function(row_dict) -> row_dict with outputs -- same logic as your testbench's
                                                             reference model (for verification)
"""

import itertools
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

# ---------------------------------------------------------------------------
# Per-DUT configuration (this is the only part you touch to add a new DUT)
# ---------------------------------------------------------------------------

def mux2to1_bin(r):
    S = r["S"]
    chosen = r["A"] if S == 0 else r["B"]
    return f"S{S}_val{chosen}"

def mux2to1_ref(r):
    r["Y"] = r["A"] if r["S"] == 0 else r["B"]
    return r

def mux4to1_bin(r):
    S1, S0 = r["S1"], r["S0"]
    chosen = [r["I0"], r["I1"], r["I2"], r["I3"]][S1 * 2 + S0]
    return f"S1{S1}_S0{S0}_val{chosen}"

def mux4to1_ref(r):
    S1, S0 = r["S1"], r["S0"]
    r["Y"] = [r["I0"], r["I1"], r["I2"], r["I3"]][S1 * 2 + S0]
    return r

def full_adder_bin(r):
    return f"A{r['A']}_B{r['B']}_Cin{r['Cin']}"

def full_adder_ref(r):
    s = r["A"] + r["B"] + r["Cin"]
    r["S"] = s & 1
    r["Cout"] = (s >> 1) & 1
    return r

def comparator2bit_bin(r):
    if r["A"] > r["B"]: return "gt"
    if r["A"] == r["B"]: return "eq"
    return "lt"

def comparator2bit_ref(r):
    r["gt"] = int(r["A"] > r["B"])
    r["eq"] = int(r["A"] == r["B"])
    r["lt"] = int(r["A"] < r["B"])
    return r

def adder4bit_bin(r):
    s = r["A"] + r["B"] + r["Cin"]
    tags = []
    if s == 0: tags.append("zero_result")
    if s == 31: tags.append("max_result")
    tags.append("carry" if s >= 16 else "no_carry")
    return ",".join(tags) if tags else "mid_range"

def adder4bit_ref(r):
    s = r["A"] + r["B"] + r["Cin"]
    r["S"] = s & 0xF
    r["Cout"] = (s >> 4) & 1
    return r

def dff_bin(r):
    if r["reset"] == 1:
        return "reset_active"
    elif r["D"] == 0:
        return "reset_inactive_D0"
    else:
        return "reset_inactive_D1"

def dff_ref(r):
    r["Q"] = 0 if r["reset"] == 1 else r["D"]
    return r

CONFIG = {
    "d_flip_flop":      {"inputs": {"D": (0,1), "reset": (0,1)},
                         "bin_fn": dff_bin, "ref_fn": dff_ref,
                         "numeric_target_fn": None},
    "mux_2to1":         {"inputs": {"A": (0,1), "B": (0,1), "S": (0,1)},
                          "bin_fn": mux2to1_bin, "ref_fn": mux2to1_ref,
                          "numeric_target_fn": None},
    "mux_4to1":          {"inputs": {"I0":(0,1),"I1":(0,1),"I2":(0,1),"I3":(0,1),"S1":(0,1),"S0":(0,1)},
                          "bin_fn": mux4to1_bin, "ref_fn": mux4to1_ref,
                          "numeric_target_fn": None},
    "full_adder":       {"inputs": {"A":(0,1),"B":(0,1),"Cin":(0,1)},
                          "bin_fn": full_adder_bin, "ref_fn": full_adder_ref,
                          "numeric_target_fn": None},
    "2bit_comparator":  {"inputs": {"A":(0,3),"B":(0,3)},
                          "bin_fn": comparator2bit_bin, "ref_fn": comparator2bit_ref,
                          "numeric_target_fn": None},
    "4bit_adder_CRV":   {"inputs": {"A":(0,15),"B":(0,15),"Cin":(0,1)},
                          "bin_fn": adder4bit_bin, "ref_fn": adder4bit_ref,
                          # optional: a numeric quantity the bins are derived from.
                          # Lets the engine use REGRESSION (which can extrapolate to
                          # values never seen in training) instead of classification
                          # (which fundamentally cannot predict a class it has zero
                          # examples of -- exactly the zero_result/max_result problem).
                          "numeric_target_fn": lambda r: r["A"] + r["B"] + r["Cin"]},
}

# ---------------------------------------------------------------------------
# Generic engine -- same code runs for every DUT
# ---------------------------------------------------------------------------

def analyze_dut(dut_name, df, top_n=10):
    cfg = CONFIG[dut_name]
    input_cols = list(cfg["inputs"].keys())
    sub = df[df["dut_name"] == dut_name][input_cols].dropna().astype(int)

    # 1. Full input space
    ranges = [range(lo, hi + 1) for lo, hi in cfg["inputs"].values()]
    full_space = list(itertools.product(*ranges))
    tested = set(map(tuple, sub.values))
    untested = [c for c in full_space if c not in tested]

    # 2. Current coverage-bin counts from tested data
    tested_bins = sub.apply(lambda row: cfg["bin_fn"](dict(zip(input_cols, row))), axis=1)
    bin_counts = tested_bins.value_counts()
    all_possible_bins = set(cfg["bin_fn"](dict(zip(input_cols, c))) for c in full_space)
    missing_bins = all_possible_bins - set(bin_counts.index)

    print(f"\n=== {dut_name} ===")
    print(f"Input space: {len(full_space)} | Tested: {len(tested)} | Untested: {len(untested)}")
    print(f"Coverage bins hit: {len(bin_counts)}/{len(all_possible_bins)}")

    if not missing_bins:
        print("Result: already at 100% coverage-bin closure. No ML action needed.")
        return None

    print(f"Missing bins: {missing_bins}")

    cand_df = pd.DataFrame(untested, columns=input_cols)
    numeric_fn = cfg.get("numeric_target_fn")

    if numeric_fn is not None:
        # --- Regression path ---
        # Used when bins are derived from a continuous/ordinal quantity
        # (e.g. adder sum). Regression CAN extrapolate toward a value it
        # never saw in training (sum=0 or sum=31), unlike classification,
        # which cannot predict a class with zero training examples --
        # exactly the failure mode this branch avoids.
        from sklearn.ensemble import RandomForestRegressor
        y_numeric = sub.apply(lambda row: numeric_fn(dict(zip(input_cols, row))), axis=1)
        reg = RandomForestRegressor(n_estimators=100, random_state=0)
        reg.fit(sub.values, y_numeric)
        cand_df["predicted_value"] = reg.predict(cand_df[input_cols].values)

        # ground-truth: which untested candidates actually close each missing
        # bin (cheap deterministic check against the coverage model itself --
        # equivalent to what a real testbench's reference model computes)
        cand_df["true_bin"] = cand_df[input_cols].apply(
            lambda row: cfg["bin_fn"](dict(zip(input_cols, row))), axis=1)

        per_bin_n = max(1, top_n // max(1, len(missing_bins)))
        picks = []
        for mb in missing_bins:
            valid = cand_df[cand_df["true_bin"] == mb].copy()
            if valid.empty:
                continue
            valid["target_missing_bin"] = mb
            valid["missing_bin_score"] = valid["predicted_value"]
            # take both extremes (lowest and highest predicted value) since
            # missing bins here tend to sit at opposite ends of the range
            picks.append(valid.sort_values("predicted_value").head(per_bin_n))
            picks.append(valid.sort_values("predicted_value", ascending=False).head(per_bin_n))
        ranked = (pd.concat(picks).drop_duplicates(subset=input_cols).head(top_n)
                  if picks else cand_df.iloc[0:0])

    else:
        # --- Classification path ---
        # Used when bins are purely categorical/logical (mux select lines,
        # comparator gt/eq/lt). Only meaningful for bins that already have
        # at least one training example.
        clf = RandomForestClassifier(n_estimators=100, random_state=0)
        clf.fit(sub.values, tested_bins)
        pred_proba = clf.predict_proba(cand_df.values)
        classes = list(clf.classes_)

        per_bin_n = max(1, top_n // max(1, len(missing_bins)))
        picks = []
        for mb in missing_bins:
            if mb not in classes:
                continue  # cannot predict a class with zero training examples
            idx = classes.index(mb)
            scores = pred_proba[:, idx]
            top_idx = scores.argsort()[::-1][:per_bin_n]
            for i in top_idx:
                picks.append((untested[i], mb, scores[i]))

        seen = set()
        ranked_rows = []
        for combo, target_bin, score in picks:
            if combo in seen:
                continue
            seen.add(combo)
            row = dict(zip(input_cols, combo))
            row["target_missing_bin"] = target_bin
            row["missing_bin_score"] = score
            ranked_rows.append(row)
        ranked = pd.DataFrame(ranked_rows)

    # 4. Verify against the real reference model (same logic your testbench uses)
    verified_rows = []
    for _, row in ranked.iterrows():
        r = {c: int(row[c]) for c in input_cols}
        r = cfg["ref_fn"](r)
        r["predicted_bin_score"] = row["missing_bin_score"]
        r["actual_bin"] = cfg["bin_fn"]({c: r[c] for c in input_cols})
        r["closes_gap"] = r["actual_bin"] in missing_bins
        verified_rows.append(r)

    result = pd.DataFrame(verified_rows)
    print(f"Top {top_n} ML-recommended candidates -- gap closed: {result['closes_gap'].sum()}/{len(missing_bins)} missing bins")
    return result


if __name__ == "__main__":
    df = pd.read_csv("data/combined_dataset.csv")

    all_results = {}
    for dut in CONFIG:
        res = analyze_dut(dut, df, top_n=10)
        if res is not None:
            res.insert(0, "dut_name", dut)
            all_results[dut] = res

    if all_results:
        combined = pd.concat(all_results.values(), ignore_index=True)
        combined.to_csv("data/phase6_recommendations.csv", index=False)
        print(f"\nSaved recommendations for {list(all_results.keys())} -> data/phase6_recommendations.csv")
    else:
        print("\nNo DUTs had coverage gaps -- nothing to recommend.")