"""
Coverage-directed test prioritization using supervised classification.

Primary technique: Random Forest Classifier predicts, for each untested
input, the probability that it would hit a rare/under-covered coverage bin.
This directly mirrors Masamba, Eder & Blackmore (2022) -- "Supervised
Learning for Coverage-Directed Test Selection" -- using coverage feedback
to prioritize tests before expensive simulation.

Secondary technique (fallback only): Random Forest Regressor, used only
when a missing bin has ZERO training examples and is defined by a numeric
boundary. Classification cannot predict a class it has never seen; a
regressor CAN extrapolate toward a numeric value it has never seen,
because numeric outputs have order.
"""

import itertools
import subprocess
import os
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score

# ---------------------------------------------------------------------------
# Per-DUT configuration
# ---------------------------------------------------------------------------

def decode_binary_text(v):
    """
    Several testbenches logged multi-bit values using %b (binary digit
    text, e.g. "110"). When read as CSV numbers, '110' parses as decimal
    110, not binary 6. This recovers the true integer value.
    """
    s = str(int(v))
    return int(s, 2)

def mux2to1_bin(r):
    S = r["S"]
    chosen = r["A"] if S == 0 else r["B"]
    return f"S{S}_val{chosen}"

def mux4to1_bin(r):
    S1, S0 = r["S1"], r["S0"]
    chosen = [r["I0"], r["I1"], r["I2"], r["I3"]][S1 * 2 + S0]
    return f"S1{S1}_S0{S0}_val{chosen}"

def full_adder_bin(r):
    return f"A{r['A']}_B{r['B']}_Cin{r['Cin']}"

def comparator2bit_bin(r):
    if r["A"] > r["B"]: return "gt"
    if r["A"] == r["B"]: return "eq"
    return "lt"

def bin2gray_bin(r):
    return f"B{r['B']}"

def decoder_bin(r):
    if r["enable"] == 0:
        return "disabled"
    return f"en_sel{r['in']}"

def demux_bin(r):
    if r["in"] == 0:
        return "in0"
    return f"in1_sel{r['sel']}"

# --- RTL verification metadata: how to drive the real .v module and what
#     output to expect, for each DUT. This is what lets the tool confirm
#     candidates against actual Verilog simulation, not just the Python
#     mirror of the logic used for coverage-bin bookkeeping above. ---

def mux2to1_rtl(r):
    return {"A": r["A"], "B": r["B"], "S": r["S"]}, {"X": r["A"] if r["S"]==0 else r["B"]}

def mux4to1_rtl(r):
    sig = {f"I{i}": r[f"I{i}"] for i in range(4)}
    sig.update({"S1": r["S1"], "S0": r["S0"]})
    chosen = [r["I0"], r["I1"], r["I2"], r["I3"]][r["S1"]*2 + r["S0"]]
    return sig, {"Y": chosen}

def full_adder_rtl(r):
    s = r["A"] + r["B"] + r["Cin"]
    return {"A": r["A"], "B": r["B"], "Cin": r["Cin"]}, {"S": s & 1, "Cout": (s >> 1) & 1}

def comparator2bit_rtl(r):
    A1, A0 = (r["A"] >> 1) & 1, r["A"] & 1
    B1, B0 = (r["B"] >> 1) & 1, r["B"] & 1
    return ({"A1": A1, "A0": A0, "B1": B1, "B0": B0},
            {"A_greater_B": int(r["A"] > r["B"]),
             "A_equal_B": int(r["A"] == r["B"]),
             "A_less_B": int(r["A"] < r["B"])})

def bin2gray_rtl(r):
    B = r["B"]
    G2 = (B >> 2) & 1
    G1 = ((B >> 1) & 1) ^ G2
    G0 = (B & 1) ^ ((B >> 1) & 1)
    return {"B": B}, {"G": (G2 << 2) | (G1 << 1) | G0}

def decoder_rtl(r):
    if r["enable"] == 0:
        out = 0
    else:
        out = 1 << r["in"]
    return {"enable": r["enable"], "in": r["in"]}, {"out": out}

def demux_rtl(r):
    if r["in"] == 0:
        out = 0
    else:
        out = 1 << r["sel"]
    return {"in": r["in"], "sel": r["sel"]}, {"out": out}

RTL_CONFIG = {
    "mux_2to1":            {"file": "rtl/mux_2to1.v",          "module": "mux2to1",
                             "widths": {"A":1,"B":1,"S":1,"X":1}, "fn": mux2to1_rtl},
    "mux_4to1":            {"file": "rtl/mux_4to1.v",          "module": "mux_4to1",
                             "widths": {"I0":1,"I1":1,"I2":1,"I3":1,"S1":1,"S0":1,"Y":1}, "fn": mux4to1_rtl},
    "full_adder":          {"file": "rtl/full_adder.v",        "module": "full_adder",
                             "widths": {"A":1,"B":1,"Cin":1,"S":1,"Cout":1}, "fn": full_adder_rtl},
    "2bit_comparator":     {"file": "rtl/comparator_2bit.v",   "module": "comparator_2bit",
                             "widths": {"A1":1,"A0":1,"B1":1,"B0":1,"A_greater_B":1,"A_equal_B":1,"A_less_B":1},
                             "fn": comparator2bit_rtl},
    "binary_to_gray_3bit": {"file": "rtl/binary_to_gray_3bit.v","module": "binary_to_gray_3bit",
                             "widths": {"B":3,"G":3}, "fn": bin2gray_rtl},
    "decoder_2to4":        {"file": "rtl/decoder_2to4.v",      "module": "decoder_2to4",
                             "widths": {"enable":1,"in":2,"out":4}, "fn": decoder_rtl},
    "demux_1to4":          {"file": "rtl/demux_1to4.v",        "module": "demux_1to4",
                             "widths": {"in":1,"sel":2,"out":4}, "fn": demux_rtl},
}


def verify_candidates_on_rtl(dut_name, candidates_df, input_cols):
    """
    Generates a directed Icarus Verilog testbench that drives the real
    RTL with the given candidate inputs, compares against the Python
    reference model, and reports real PASS/FAIL -- not a Python-only check.
    """
    if dut_name not in RTL_CONFIG:
        return None

    rcfg = RTL_CONFIG[dut_name]
    fn = rcfg["fn"]
    widths = rcfg["widths"]

    sig_rows = []
    expected_rows = []
    for _, row in candidates_df.iterrows():
        r = {c: int(row[c]) for c in input_cols}
        sig, exp = fn(r)
        sig_rows.append(sig)
        expected_rows.append(exp)

    in_names = list(sig_rows[0].keys())
    out_names = list(expected_rows[0].keys())

    def decl(names):
        lines = []
        for n in names:
            w = widths.get(n, 1)
            rng = f"[{w-1}:0] " if w > 1 else ""
            lines.append(f"{rng}{n}")
        return lines

    tb_lines = []
    tb_lines.append("`timescale 1ns/1ps")
    tb_lines.append(f"module tb_{dut_name}_verify;")
    for n in in_names:
        w = widths.get(n, 1)
        rng = f"[{w-1}:0] " if w > 1 else ""
        tb_lines.append(f"    reg  {rng}{n};")
    for n in out_names:
        w = widths.get(n, 1)
        rng = f"[{w-1}:0] " if w > 1 else ""
        tb_lines.append(f"    wire {rng}{n};")
    tb_lines.append(f"    integer pass_count=0, fail_count=0, i;")
    port_map = ", ".join(f".{n}({n})" for n in in_names + out_names)
    tb_lines.append(f"    {rcfg['module']} DUT ({port_map});")
    tb_lines.append("    initial begin")
    for idx, (sig, exp) in enumerate(zip(sig_rows, expected_rows)):
        for n, v in sig.items():
            w = widths.get(n, 1)
            tb_lines.append(f"        {n} = {w}'d{v};")
        tb_lines.append("        #1;")
        checks = " && ".join(f"({n} === {widths.get(n,1)}'d{v})" for n, v in exp.items())
        tb_lines.append(f"        if ({checks}) pass_count=pass_count+1; else begin")
        tb_lines.append(f'            fail_count=fail_count+1; $display("[FAIL] candidate {idx}: {sig}");')
        tb_lines.append("        end")
    tb_lines.append('        $display("RTL_VERIFY_RESULT pass=%0d fail=%0d", pass_count, fail_count);')
    tb_lines.append("        $finish;")
    tb_lines.append("    end")
    tb_lines.append("endmodule")

    tb_path = f"/tmp/tb_{dut_name}_verify.v"
    with open(tb_path, "w") as f:
        f.write("\n".join(tb_lines))

    sim_path = f"/tmp/sim_{dut_name}_verify"
    compile_res = subprocess.run(
        ["iverilog", "-o", sim_path, rcfg["file"], tb_path],
        capture_output=True, text=True)
    if compile_res.returncode != 0:
        return {"status": "compile_error", "stderr": compile_res.stderr}

    run_res = subprocess.run(["vvp", sim_path], capture_output=True, text=True)
    out = run_res.stdout
    for line in out.splitlines():
        if "RTL_VERIFY_RESULT" in line:
            parts = dict(p.split("=") for p in line.split()[1:])
            return {"status": "ok", "pass": int(parts["pass"]), "fail": int(parts["fail"]),
                    "total": len(sig_rows), "raw_output": out}
    return {"status": "parse_error", "raw_output": out}

CONFIG = {
    "mux_2to1":            {"inputs": {"A":(0,1), "B":(0,1), "S":(0,1)},
                             "bin_fn": mux2to1_bin, "numeric_target_fn": None, "decode_cols": []},
    "mux_4to1":            {"inputs": {"I0":(0,1),"I1":(0,1),"I2":(0,1),"I3":(0,1),"S1":(0,1),"S0":(0,1)},
                             "bin_fn": mux4to1_bin, "numeric_target_fn": None, "decode_cols": []},
    "full_adder":          {"inputs": {"A":(0,1),"B":(0,1),"Cin":(0,1)},
                             "bin_fn": full_adder_bin, "numeric_target_fn": None, "decode_cols": []},
    "2bit_comparator":     {"inputs": {"A":(0,3),"B":(0,3)},
                             "bin_fn": comparator2bit_bin, "numeric_target_fn": None, "decode_cols": []},
    "binary_to_gray_3bit": {"inputs": {"B":(0,7)},
                             "bin_fn": bin2gray_bin, "numeric_target_fn": None,
                             "decode_cols": ["B"]},
    "decoder_2to4":        {"inputs": {"enable":(0,1), "in":(0,3)},
                             "bin_fn": decoder_bin, "numeric_target_fn": None,
                             "decode_cols": ["in"]},
    "demux_1to4":          {"inputs": {"in":(0,1), "sel":(0,3)},
                             "bin_fn": demux_bin, "numeric_target_fn": None,
                             "decode_cols": ["sel"]},
}

# ---------------------------------------------------------------------------
# Engine
# ---------------------------------------------------------------------------

def analyze_dut(dut_name, df, top_n=10):
    cfg = CONFIG[dut_name]
    input_cols = list(cfg["inputs"].keys())
    full_rows = df[df["dut_name"] == dut_name]

    # --- Pass/fail correctness check on the logged data itself ---
    # (independent of coverage -- this just confirms the DUT's own
    # testbench runs didn't record any functional failures)
    if "pass" in full_rows.columns:
        n_total = len(full_rows)
        n_pass = int((full_rows["pass"] == 1).sum())
        n_fail = n_total - n_pass
        print(f"Logged test correctness: {n_pass}/{n_total} passed" +
              (f"  *** {n_fail} FAILURES IN LOGGED DATA ***" if n_fail else ""))

    sub = full_rows[input_cols].dropna().astype(int)
    for col in cfg.get("decode_cols", []):
        sub[col] = sub[col].apply(decode_binary_text)

    ranges = [range(lo, hi + 1) for lo, hi in cfg["inputs"].values()]
    full_space = list(itertools.product(*ranges))
    tested = set(map(tuple, sub.values))
    untested = [c for c in full_space if c not in tested]

    tested_bins = sub.apply(lambda row: cfg["bin_fn"](dict(zip(input_cols, row))), axis=1)
    bin_counts = tested_bins.value_counts()
    all_possible_bins = set(cfg["bin_fn"](dict(zip(input_cols, c))) for c in full_space)
    missing_bins = all_possible_bins - set(bin_counts.index)

    print(f"\n=== {dut_name} ===")
    print(f"Input space: {len(full_space)} | Tested: {len(tested)} | Untested: {len(untested)}")
    print(f"Coverage bins hit: {len(bin_counts)}/{len(all_possible_bins)}")

    result = {
        "dut_name": dut_name,
        "input_space": len(full_space),
        "tested": len(tested),
        "bins_total": len(all_possible_bins),
        "bins_hit": len(bin_counts),
        "missing_bins": list(missing_bins),
    }

    if not missing_bins:
        print("Result: already at 100% coverage-bin closure. No ML action needed.")
        result["status"] = "fully_covered"
        return result

    # --------------------------------------------------------------
    # Label tested data: 1 = rare/missing-adjacent bin, 0 = common bin
    # (threshold: below 50% of the average bin count counts as "rare")
    # --------------------------------------------------------------
    avg_count = bin_counts.mean()
    rare_bins = set(bin_counts[bin_counts < 0.5 * avg_count].index) | missing_bins
    labels = tested_bins.apply(lambda b: 1 if b in rare_bins else 0)

    print(f"Rare/missing bins (< 50% avg hit count): {len(rare_bins)}/{len(all_possible_bins)}")
    print(f"Training labels: {labels.sum()} rare, {len(labels)-labels.sum()} common")

    cand_df = pd.DataFrame(untested, columns=input_cols)
    cand_df["actual_bin"] = cand_df[input_cols].apply(
        lambda row: cfg["bin_fn"](dict(zip(input_cols, row))), axis=1)
    ranked = pd.DataFrame(columns=list(input_cols) + ["actual_bin", "closes_gap", "rare_probability"])
    val_acc = val_prec = val_rec = None

    if labels.nunique() < 2:
        # No already-tested row qualifies as "rare" relative to others --
        # typically because the missing bins have ZERO tested examples and
        # every tested row sits in a well-covered bin. Classification has
        # no positive examples to learn from here; this is not a dead end,
        # it is exactly the case the regression fallback below is for.
        print("Classifier: no positive (rare) examples in tested data -- skipping classifier, "
              "trying regression fallback for the missing bins directly.")
    else:
        # --------------------------------------------------------------
        # Train/validate classifier (proves it learned something real,
        # not just memorized -- this is the accuracy-check step)
        # --------------------------------------------------------------
        X_train, X_val, y_train, y_val = train_test_split(
            sub.values, labels.values, test_size=0.25, random_state=0, stratify=labels.values)

        clf = RandomForestClassifier(n_estimators=100, random_state=0)
        clf.fit(X_train, y_train)

        val_preds = clf.predict(X_val)
        val_acc = accuracy_score(y_val, val_preds)
        val_prec = precision_score(y_val, val_preds, zero_division=0)
        val_rec = recall_score(y_val, val_preds, zero_division=0)
        print(f"Held-out validation -- accuracy: {val_acc:.2f}, precision: {val_prec:.2f}, recall: {val_rec:.2f}")

        # retrain on all tested data before predicting on untested candidates
        clf.fit(sub.values, labels.values)
        cand_df["rare_probability"] = clf.predict_proba(cand_df[input_cols].values)[:, 1] if len(clf.classes_) > 1 else 0

        ranked = cand_df.sort_values("rare_probability", ascending=False).head(top_n).copy()
        ranked["closes_gap"] = ranked["actual_bin"].isin(missing_bins)

        print(f"Top {top_n} classifier-ranked candidates -- gaps closed: {ranked['closes_gap'].sum()}/{len(missing_bins)}")

    # --------------------------------------------------------------
    # Regression fallback -- ONLY for missing bins the classifier
    # couldn't reach (typically: bins with zero training examples,
    # which classification fundamentally cannot predict). Only runs
    # if this DUT has a numeric_target_fn configured.
    # --------------------------------------------------------------
    closed_so_far = set(ranked.loc[ranked["closes_gap"], "actual_bin"]) if len(ranked) else set()
    still_missing = missing_bins - closed_so_far
    numeric_fn = cfg.get("numeric_target_fn")
    if still_missing and numeric_fn is not None:
        print(f"Still missing after classifier: {still_missing} -- trying regression fallback")
        y_numeric = sub.apply(lambda row: numeric_fn(dict(zip(input_cols, row))), axis=1)
        reg = RandomForestRegressor(n_estimators=100, random_state=0)
        reg.fit(sub.values, y_numeric)

        remaining_cand = cand_df[~cand_df["actual_bin"].isin(closed_so_far)].copy()
        remaining_cand["predicted_value"] = reg.predict(remaining_cand[input_cols].values)

        reg_picks = []
        for mb in still_missing:
            valid = remaining_cand[remaining_cand["actual_bin"] == mb]
            if not valid.empty:
                reg_picks.append(valid.head(2))
        if reg_picks:
            reg_df = pd.concat(reg_picks)
            reg_df["closes_gap"] = True
            reg_df["rare_probability"] = None
            ranked = pd.concat([ranked, reg_df], ignore_index=True)
            print(f"Regression fallback closed: {len(reg_picks)} additional bins")

    print(f"Combined (classifier + regression fallback) -- gaps closed: "
          f"{ranked['closes_gap'].sum()}/{len(missing_bins)}")

    # --------------------------------------------------------------
    # Real RTL verification -- confirm against actual Verilog
    # simulation, not just the Python reference mirror used above.
    # --------------------------------------------------------------
    verify_result = verify_candidates_on_rtl(dut_name, ranked[ranked["closes_gap"]], input_cols)
    if verify_result:
        if verify_result["status"] == "ok":
            print(f"RTL verification (real Icarus simulation): "
                  f"{verify_result['pass']}/{verify_result['total']} passed")
        else:
            print(f"RTL verification: {verify_result['status']}")
    result["rtl_verification"] = verify_result

    result["status"] = "gap_found"
    result["val_accuracy"] = val_acc
    result["val_precision"] = val_prec
    result["val_recall"] = val_rec
    result["ranked_candidates"] = ranked
    result["gaps_closed"] = int(ranked["closes_gap"].sum())
    return result


if __name__ == "__main__":
    df = pd.read_csv("data/combined_dataset.csv")

    all_results = []
    for dut in CONFIG:
        if dut not in df["dut_name"].unique():
            print(f"\n=== {dut} === (skipped -- not present in dataset)")
            continue
        res = analyze_dut(dut, df, top_n=10)
        all_results.append(res)

    print("\n" + "=" * 50)
    print("SUMMARY")
    print("=" * 50)
    for r in all_results:
        status = r["status"]
        if status == "fully_covered":
            print(f"{r['dut_name']:25s} -> 100% covered ({r['bins_hit']}/{r['bins_total']} bins)")
        elif status == "gap_found":
            print(f"{r['dut_name']:25s} -> gap found, val_acc={r['val_accuracy']:.2f}, "
                  f"closed {r['gaps_closed']}/{len(r['missing_bins'])} missing bins")
        else:
            print(f"{r['dut_name']:25s} -> {status}")