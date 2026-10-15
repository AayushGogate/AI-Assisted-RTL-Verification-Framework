"""
Engine Orchestrator: Combines CSV validation, Coverage Analysis, ML Engine,
and RTL Verification into a Unified Analysis Pipeline.
"""

from typing import Dict, Any, Optional, Union
import io
from pathlib import Path

from .analyzer import load_and_validate_csv
from .ml_engine import run_ml_analysis
from .rtl_verifier import verify_on_rtl

def run_pipeline(
    csv_source: Union[str, Path, io.StringIO, io.BytesIO],
    dut_plugin: Any,
    subsample_n: Optional[int] = None,
    custom_rtl_path: Optional[str] = None,
    top_n: int = 10,
    random_state: int = 42
) -> Dict[str, Any]:
    """
    Executes the full 9-step analysis pipeline and returns structured report data.
    """
    # 1-5: Load, Decode, Functional Correctness, Coverage, and Gap Analysis
    analysis_data = load_and_validate_csv(csv_source, dut_plugin, subsample_n=subsample_n)

    # 6: Machine Learning Candidate Prioritization & Baseline Benchmarking
    ml_result = run_ml_analysis(analysis_data, dut_plugin, top_n=top_n, random_state=random_state)

    # 7: Real RTL Verification in Icarus Verilog
    candidates_to_verify = ml_result.get("candidates", [])
    if candidates_to_verify:
        rtl_result = verify_on_rtl(dut_plugin, candidates_to_verify, custom_rtl_path=custom_rtl_path)
    else:
        rtl_result = {
            "status": "skipped",
            "reason": "No candidate stimulus required (coverage at 100% or no gaps).",
            "pass_count": 0,
            "fail_count": 0,
            "total": 0,
            "testbench_code": "",
            "simulator_output": "No targeted simulation needed.",
            "verified_closed_bins": [],
        }

    # 8: Before and After Coverage calculation
    bins_hit_before = analysis_data["bins_hit"]
    total_bins = analysis_data["total_bins"]
    verified_closed_bins = rtl_result.get("verified_closed_bins", [])
    tests_added_count = len(candidates_to_verify)

    # Only count bins that actually passed RTL simulation
    if rtl_result.get("status") == "verified":
        bins_hit_after = bins_hit_before + len(verified_closed_bins)
    elif rtl_result.get("status") == "skipped":
        # If iverilog is missing, show projected closure from ML reference model
        bins_hit_after = bins_hit_before + ml_result.get("ml_gaps_closed_count", 0)
    else:
        bins_hit_after = bins_hit_before

    coverage_before_pct = analysis_data["coverage_pct"]
    coverage_after_pct = round((bins_hit_after / total_bins * 100.0), 2) if total_bins > 0 else 0.0
    coverage_delta_pct = round(coverage_after_pct - coverage_before_pct, 2)

    # 9: Actionable Recommendations
    recommended_inputs = []
    for c in candidates_to_verify:
        recommended_inputs.append({
            "rank": c["rank"],
            "inputs": c["inputs"],
            "target_bin": c["actual_bin"],
            "closes_gap": c["closes_gap"],
            "selection_method": c["selection_method"],
            "rare_probability": c.get("rare_probability"),
            "predicted_numeric": c.get("predicted_numeric"),
        })

    unreachable_recommendations = []
    for ub in ml_result.get("unreachable_bins", []):
        unreachable_recommendations.append({
            "bin": ub,
            "guidance": (
                f"Coverage bin '{ub}' had 0 examples in baseline and lacks a numeric order relation. "
                "Supervised ML cannot extrapolate to this state without training data. "
                "Recommendation: Write a targeted directed testbench driving the specific conditions for this bin."
            )
        })

    # Assemble complete report structure (Section 6 ordering)
    report = {
        "metadata": {
            "dut_name": dut_plugin.DUT_NAME,
            "description": getattr(dut_plugin, "DESCRIPTION", ""),
            "random_seed": random_state,
            "coverage_type": "Functional Coverage (Bin-based). Line/toggle/branch code coverage not reported (Icarus Verilog does not support it).",
            "support_scope": "Combinational DUTs (enumerable input space).",
            "subsampled_label": analysis_data["subsampled_label"],
            "warnings": analysis_data["warnings"],
        },
        # 1. Summary Card
        "step1_summary": {
            "dut_name": dut_plugin.DUT_NAME,
            "description": getattr(dut_plugin, "DESCRIPTION", ""),
            "rows_loaded": analysis_data["total_rows_loaded"],
            "rows_analyzed": analysis_data["rows_analyzed"],
            "rows_excluded": analysis_data["rows_excluded"],
            "unique_vectors": analysis_data["unique_vectors_tested"],
            "input_space_size": analysis_data["input_space_size"],
            "coverage_pct": analysis_data["coverage_pct"],
            "bins_hit": analysis_data["bins_hit"],
            "total_bins": analysis_data["total_bins"],
            "pass_rate": analysis_data["pass_rate"],
            "subsample_label": analysis_data["subsampled_label"],
        },
        # 2. Functional Correctness
        "step2_correctness": {
            "pass_count": analysis_data["pass_count"],
            "fail_count": analysis_data["fail_count"],
            "pass_rate": analysis_data["pass_rate"],
            "failing_rows": analysis_data["failing_rows"],
        },
        # 3. Coverage by Bin
        "step3_bin_coverage": {
            "per_bin_data": analysis_data["per_bin_data"],
            "total_bins": analysis_data["total_bins"],
            "bins_hit": analysis_data["bins_hit"],
            "missing_count": len(analysis_data["missing_bins"]),
            "under_covered_count": len(analysis_data["under_covered_bins"]),
            "mean_bin_count": analysis_data["mean_bin_count"],
        },
        # 4. Input-Space Coverage
        "step4_input_space": {
            "unique_tested": analysis_data["unique_vectors_tested"],
            "untested_count": analysis_data["untested_vectors_count"],
            "total_space": analysis_data["input_space_size"],
            "tested_pct": analysis_data["input_space_coverage_pct"],
            "balance_cv": analysis_data["balance_cv"],
        },
        # 5. Gap Analysis
        "step5_gap_analysis": {
            "has_gap": len(analysis_data["missing_bins"]) > 0 or len(analysis_data["under_covered_bins"]) > 0,
            "missing_bins": analysis_data["missing_bins"],
            "under_covered_bins": analysis_data["under_covered_bins"],
            "narratives": analysis_data["gap_narrative"],
        },
        # 6. ML Section (shown only when a gap exists)
        "step6_ml_section": {
            "ml_ran": ml_result.get("ml_needed", False),
            "status": ml_result.get("status"),
            "message": ml_result.get("message"),
            "labelling_rule": ml_result.get("labelling_rule"),
            "unique_vectors_used": ml_result.get("unique_vectors_used"),
            "classifier_skipped": ml_result.get("classifier_skipped"),
            "classifier_skip_reason": ml_result.get("classifier_skip_reason"),
            "validation_metrics": ml_result.get("validation_metrics"),
            "confusion_table": ml_result.get("confusion_table"),
            "regressor_fallback_used": ml_result.get("regressor_fallback_used"),
            "regressor_fallback_reason": ml_result.get("regressor_fallback_reason"),
            "unreachable_bins": ml_result.get("unreachable_bins", []),
            "candidates": ml_result.get("candidates", []),
            "random_baseline": ml_result.get("random_baseline"),
            "ml_gaps_closed_count": ml_result.get("ml_gaps_closed_count", 0),
            "ml_gaps_closed_bins": ml_result.get("ml_gaps_closed_bins", []),
        },
        # 7. Real RTL Simulation Verification
        "step7_rtl_verification": rtl_result,
        # 8. Before / After Coverage
        "step8_before_after": {
            "coverage_before_pct": coverage_before_pct,
            "coverage_after_pct": coverage_after_pct,
            "coverage_delta_pct": coverage_delta_pct,
            "bins_hit_before": bins_hit_before,
            "bins_hit_after": bins_hit_after,
            "total_bins": total_bins,
            "tests_added_count": tests_added_count,
            "verified_new_bins_closed": verified_closed_bins,
        },
        # 9. Recommendations
        "step9_recommendations": {
            "recommended_inputs": recommended_inputs,
            "unreachable_guidance": unreachable_recommendations,
        },
    }

    return report
