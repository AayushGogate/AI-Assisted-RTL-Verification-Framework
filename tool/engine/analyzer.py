"""
Analysis Engine: Load, Validate, Decode, Functional Correctness & Coverage Analysis.
"""

import itertools
import io
from pathlib import Path
from typing import Dict, Any, List, Optional, Tuple, Union
import numpy as np
import pandas as pd

def decode_binary_text(v: Any) -> int:
    """
    Decodes multi-bit values logged as %b binary text (e.g. '110' or numeric 110)
    into the true integer value (6).
    """
    if pd.isna(v):
        return 0
    s = str(v).strip()
    # If float string like '110.0', strip decimal part
    if "." in s:
        s = s.split(".")[0]
    # Parse as binary
    try:
        return int(s, 2)
    except ValueError:
        # Fallback to int if already decimal
        return int(float(v))

def compute_full_input_space(inputs_spec: Dict[str, Tuple[int, int]]) -> Tuple[List[Tuple[int, ...]], List[str]]:
    """
    Computes all enumerable input vectors for combinational DUT.
    """
    cols = list(inputs_spec.keys())
    ranges = [range(lo, hi + 1) for lo, hi in inputs_spec.values()]
    full_space = list(itertools.product(*ranges))
    return full_space, cols

def load_and_validate_csv(
    csv_source: Union[str, Path, io.StringIO, io.BytesIO],
    dut_plugin: Any,
    subsample_n: Optional[int] = None
) -> Dict[str, Any]:
    """
    Validates CSV, checks required columns, filters baseline tests,
    applies subsampling, decodes columns, and checks functional correctness.
    """
    try:
        if isinstance(csv_source, (str, Path)):
            df = pd.read_csv(csv_source)
        else:
            df = pd.read_csv(csv_source)
    except Exception as e:
        raise ValueError(f"Could not parse CSV file: {str(e)}")

    total_rows_loaded = len(df)
    found_cols = list(df.columns)
    required_cols = list(dut_plugin.INPUTS.keys())

    # Check for missing required columns
    missing_cols = [c for c in required_cols if c not in found_cols]
    if missing_cols:
        raise ValueError(
            f"Missing required input columns for DUT '{dut_plugin.DUT_NAME}'. "
            f"Expected inputs: {required_cols}. Found in CSV: {found_cols}."
        )

    warnings: List[str] = []

    # Filter by test_type if present
    rows_excluded = 0
    if "test_type" in df.columns:
        baseline_mask = df["test_type"].astype(str).str.strip().str.lower() == "crv_baseline"
        rows_excluded = int((~baseline_mask).sum())
        if rows_excluded > 0:
            df = df[baseline_mask].copy()

    # Warn if file looks like targeted set rather than random baseline
    if len(df) < 10:
        warnings.append(
            f"CSV contains only {len(df)} test rows. This looks like a small targeted set rather "
            "than an extensive random verification baseline."
        )

    # Subsampling slider handling
    subsampled_label: Optional[str] = None
    if subsample_n is not None and 0 < subsample_n < len(df):
        df = df.iloc[:subsample_n].copy()
        subsampled_label = f"Subsampled to {subsample_n} tests"

    # Functional Correctness check from 'pass' column
    pass_col_found = "pass" in df.columns
    failing_rows: List[Dict[str, Any]] = []
    if pass_col_found:
        pass_series = pd.to_numeric(df["pass"], errors="coerce").fillna(0).astype(int)
        pass_count = int((pass_series == 1).sum())
        fail_count = len(df) - pass_count
        pass_rate = (pass_count / len(df) * 100.0) if len(df) > 0 else 0.0

        if fail_count > 0:
            fails_df = df[pass_series != 1]
            # Capture up to 10 failing rows for reporting
            for idx, r in fails_df.head(10).iterrows():
                failing_rows.append({
                    "row_index": int(idx),
                    "test_num": int(r.get("test_num", idx)),
                    "inputs": {c: r[c] for c in required_cols},
                    "expected": r.get("expected", "N/A"),
                })
    else:
        pass_count = len(df)
        fail_count = 0
        pass_rate = 100.0
        warnings.append("No 'pass' column found in CSV. Functional correctness assumed 100%.")

    # Decode binary text columns
    decode_cols = getattr(dut_plugin, "DECODE_COLS", [])
    decoded_sub = df[required_cols].copy()
    for col in decode_cols:
        if col in decoded_sub.columns:
            decoded_sub[col] = decoded_sub[col].apply(decode_binary_text)

    # Ensure all inputs are int
    for col in required_cols:
        decoded_sub[col] = pd.to_numeric(decoded_sub[col], errors="coerce").fillna(0).astype(int)

    # Full Input Space enumeration
    full_space, input_cols = compute_full_input_space(dut_plugin.INPUTS)
    total_space_size = len(full_space)

    # Tested unique input vectors
    tested_tuples = list(map(tuple, decoded_sub.values))
    tested_unique_set = set(tested_tuples)
    unique_tested_count = len(tested_unique_set)
    untested_count = total_space_size - unique_tested_count

    # Coverage by Bin
    # 1. Compute all possible bins across the complete input space
    full_space_df = pd.DataFrame(full_space, columns=input_cols)
    all_possible_bins_list = [dut_plugin.bin_fn(dict(zip(input_cols, vec))) for vec in full_space]
    all_possible_bins = sorted(list(set(all_possible_bins_list)))
    total_bins_count = len(all_possible_bins)

    # 2. Count bins for tested rows
    tested_bins = [dut_plugin.bin_fn(dict(zip(input_cols, row))) for row in decoded_sub.values]
    bin_counts_series = pd.Series(tested_bins).value_counts()
    hit_bins_set = set(bin_counts_series.index)
    missing_bins = [b for b in all_possible_bins if b not in hit_bins_set]

    # Calculate mean count across all hit bins (or all bins)
    mean_count = float(bin_counts_series.mean()) if len(bin_counts_series) > 0 else 0.0
    under_covered_threshold = 0.5 * mean_count

    per_bin_data = []
    under_covered_bins = []
    hit_bins = []

    for b in all_possible_bins:
        cnt = int(bin_counts_series.get(b, 0))
        pct_of_tests = (cnt / len(df) * 100.0) if len(df) > 0 else 0.0

        if cnt == 0:
            status = "missing"
        elif cnt < under_covered_threshold:
            status = "under_covered"
            under_covered_bins.append(b)
        else:
            status = "hit"
            hit_bins.append(b)

        per_bin_data.append({
            "bin": b,
            "count": cnt,
            "percentage": round(pct_of_tests, 2),
            "status": status,
        })

    bins_hit_count = len(hit_bins) + len(under_covered_bins)
    coverage_pct = round((bins_hit_count / total_bins_count * 100.0), 2) if total_bins_count > 0 else 0.0

    # Balance measure: standard deviation and CV across hit bins
    if len(bin_counts_series) > 1 and mean_count > 0:
        std_count = float(bin_counts_series.std())
        cov_balance = round(std_count / mean_count, 3)
    else:
        std_count = 0.0
        cov_balance = 0.0

    # Plain language gap analysis
    gap_narrative = []
    if not missing_bins and not under_covered_bins:
        gap_narrative.append(
            f"All {total_bins_count} functional coverage bins were thoroughly reached. "
            "The baseline constrained-random stimulus achieved 100% functional bin coverage."
        )
    else:
        if missing_bins:
            gap_narrative.append(
                f"Missing bins ({len(missing_bins)}): {', '.join(missing_bins)}. "
                "These coverage bins were never sampled in the baseline test run."
            )
            # Calculate 1-in-N probability for enumerable spaces
            for mb in missing_bins:
                count_in_space = all_possible_bins_list.count(mb)
                prob = count_in_space / total_space_size if total_space_size > 0 else 0
                prob_pct = prob * 100
                gap_narrative.append(
                    f"Bin '{mb}' has {count_in_space} matching input vector(s) out of {total_space_size} total combinations "
                    f"(1-in-{round(1/prob) if prob > 0 else 'inf'} probability, or {prob_pct:.3f}%). "
                    f"Because of this rare probability, random stimulus is unlikely to hit it by chance."
                )
        if under_covered_bins:
            gap_narrative.append(
                f"Under-covered bins ({len(under_covered_bins)}): {', '.join(under_covered_bins)}. "
                f"These bins have fewer hits than 50% of the mean bin count ({under_covered_threshold:.1f} hits)."
            )

    return {
        "dut_name": dut_plugin.DUT_NAME,
        "description": getattr(dut_plugin, "DESCRIPTION", ""),
        "total_rows_loaded": total_rows_loaded,
        "rows_analyzed": len(df),
        "rows_excluded": rows_excluded,
        "subsampled_label": subsampled_label,
        "input_cols": input_cols,
        "input_space_size": total_space_size,
        "unique_vectors_tested": unique_tested_count,
        "untested_vectors_count": untested_count,
        "input_space_coverage_pct": round(unique_tested_count / total_space_size * 100.0, 2) if total_space_size > 0 else 0.0,
        "pass_count": pass_count,
        "fail_count": fail_count,
        "pass_rate": round(pass_rate, 2),
        "failing_rows": failing_rows,
        "warnings": warnings,
        "total_bins": total_bins_count,
        "bins_hit": bins_hit_count,
        "coverage_pct": coverage_pct,
        "per_bin_data": per_bin_data,
        "missing_bins": missing_bins,
        "under_covered_bins": under_covered_bins,
        "mean_bin_count": round(mean_count, 2),
        "balance_cv": cov_balance,
        "gap_narrative": gap_narrative,
        "decoded_df": decoded_sub,
        "tested_tuples": tested_unique_set,
        "all_possible_bins": all_possible_bins,
        "all_possible_bins_list": all_possible_bins_list,
        "full_space": full_space,
    }
