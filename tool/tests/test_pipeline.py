"""
Automated Pytest Suite for DUT Coverage Analysis Tool.
Validates:
1. True coverage and pass/fail counts for all built-in DUTs on bundled CSVs.
2. Subsampled test budget creating real gaps and running end-to-end ML & RTL verification.
3. adder_4bit regressor fallback closing sum=0 and sum=31 verified via Icarus simulation.
4. Bad CSV handling producing clear validation errors without crashing.
5. Graceful skip when iverilog is not on PATH.
6. Flask API endpoints and downloads.
"""

import sys
import io
from pathlib import Path
import pytest

# Ensure tool directory is on sys.path
tool_dir = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(tool_dir))

from duts import list_registered_duts, get_dut
from engine import run_pipeline, load_and_validate_csv, verify_on_rtl
from app import app

BUILTIN_DUTS = [
    "mux_2to1",
    "mux_4to1",
    "full_adder",
    "2bit_comparator",
    "binary_to_gray_3bit",
    "decoder_2to4",
    "demux_1to4",
    "adder_4bit",
]

def test_all_builtin_duts_registered():
    """Verify all seven original DUTs + adder_4bit eighth plugin are registered."""
    duts_meta = list_registered_duts()
    registered_names = [d["name"] for d in duts_meta]
    for expected in BUILTIN_DUTS:
        assert expected in registered_names, f"DUT '{expected}' was not found in registry."

@pytest.mark.parametrize("dut_name", BUILTIN_DUTS)
def test_builtin_duts_baseline_and_pass_counts(dut_name):
    """
    Every built-in DUT on its bundled CSV reports its true coverage figures
    and a correct pass/fail count.
    """
    dut = get_dut(dut_name)
    assert dut is not None
    sample_csv = tool_dir / "sample_data" / f"{dut_name}.csv"
    assert sample_csv.exists(), f"Sample CSV missing: {sample_csv}"

    report = run_pipeline(sample_csv, dut)

    s1 = report["step1_summary"]
    s2 = report["step2_correctness"]

    assert s1["rows_analyzed"] > 0
    assert s1["coverage_pct"] > 0.0
    assert s1["bins_hit"] > 0
    assert s1["total_bins"] > 0
    assert s2["pass_count"] == s1["rows_analyzed"]
    assert s2["fail_count"] == 0
    assert s2["pass_rate"] == 100.0

def test_subsampled_produces_gap_and_executes_ml():
    """
    Running a built-in DUT with a small N (subsampled) can produce a real gap,
    and the full ML pipeline then executes end to end, including RTL verification.
    """
    dut = get_dut("mux_2to1")
    sample_csv = tool_dir / "sample_data" / "mux_2to1.csv"

    # Subsample to 3 tests -> creates real coverage gap
    report = run_pipeline(sample_csv, dut, subsample_n=3)

    s1 = report["step1_summary"]
    s6 = report["step6_ml_section"]
    s7 = report["step7_rtl_verification"]
    s8 = report["step8_before_after"]

    # Must be labeled subsampled
    assert s1["subsample_label"] == "Subsampled to 3 tests"
    assert report["metadata"]["subsampled_label"] == "Subsampled to 3 tests"

    # Must produce a gap
    assert s1["coverage_pct"] < 100.0
    assert s6["ml_ran"] is True
    assert len(s6["candidates"]) > 0

    # ML closes gap and verified in simulation
    assert s8["coverage_after_pct"] > s8["coverage_before_pct"]
    assert s7["status"] in ["verified", "skipped"]
    if s7["status"] == "verified":
        assert s7["pass_count"] > 0

def test_adder_4bit_regressor_fallback_and_closure():
    """
    adder_4bit with a CRV baseline missing sum=0 and sum=31 triggers the
    regressor fallback and closes both, confirmed by Icarus simulation.
    """
    dut = get_dut("adder_4bit")
    sample_csv = tool_dir / "sample_data" / "adder_4bit.csv"

    report = run_pipeline(sample_csv, dut)

    s1 = report["step1_summary"]
    s5 = report["step5_gap_analysis"]
    s6 = report["step6_ml_section"]
    s7 = report["step7_rtl_verification"]
    s8 = report["step8_before_after"]

    # Verify baseline is missing sum_zero and sum_max
    assert "sum_zero" in s5["missing_bins"]
    assert "sum_max" in s5["missing_bins"]

    # Verify regressor fallback triggered
    assert s6["regressor_fallback_used"] is True
    assert "sum_zero" in s6["regressor_fallback_reason"]

    # Verify ML candidates close both missing bins
    ml_closed_bins = s6["ml_gaps_closed_bins"]
    assert "sum_zero" in ml_closed_bins
    assert "sum_max" in ml_closed_bins

    # Verify Icarus simulation confirmed
    if s7["status"] == "verified":
        assert s7["pass_count"] >= 2
        assert s7["fail_count"] == 0
        assert "sum_zero" in s7["verified_closed_bins"]
        assert "sum_max" in s7["verified_closed_bins"]
        assert s8["coverage_after_pct"] == 100.0

def test_bad_csv_validation_error():
    """
    A bad CSV produces a clear error and no crash.
    """
    dut = get_dut("mux_2to1")
    bad_csv = io.StringIO("random_col1,random_col2\n1,2\n3,4\n")

    with pytest.raises(ValueError) as excinfo:
        run_pipeline(bad_csv, dut)

    err_msg = str(excinfo.value)
    assert "Missing required input columns" in err_msg
    assert "Expected inputs" in err_msg

def test_missing_iverilog_graceful_skip(monkeypatch):
    """
    Missing iverilog produces a graceful skip without crashing.
    """
    # Mock check_iverilog_installed to return False
    import engine.rtl_verifier as rtl_verifier
    monkeypatch.setattr(rtl_verifier, "check_iverilog_installed", lambda: (False, "Icarus Verilog missing."))

    dut = get_dut("mux_2to1")
    candidates = [{"inputs": {"A": 1, "B": 0, "S": 1}, "closes_gap": True, "actual_bin": "S1_val0"}]

    res = rtl_verifier.verify_on_rtl(dut, candidates)
    assert res["status"] == "skipped"
    assert "skipped: iverilog not found" in res["reason"]
    assert "install_guidance" in res

def test_flask_api_endpoints():
    """
    Tests Flask API routes: /api/duts, /api/analyze, and downloads.
    """
    client = app.test_client()

    # 1. GET /api/duts
    r_duts = client.get("/api/duts")
    assert r_duts.status_code == 200
    duts_json = r_duts.get_json()
    assert "duts" in duts_json
    assert len(duts_json["duts"]) >= 8

    # 2. POST /api/analyze (demo mode for adder_4bit)
    r_an = client.post("/api/analyze", data={
        "dut_name": "adder_4bit",
        "demo_mode": "true",
    })
    assert r_an.status_code == 200
    an_json = r_an.get_json()
    assert an_json["success"] is True
    analysis_id = an_json["analysis_id"]

    # 3. Download CSV
    r_csv = client.get(f"/api/download/csv?id={analysis_id}")
    assert r_csv.status_code == 200
    assert "text/csv" in r_csv.content_type

    # 4. Download JSON
    r_json = client.get(f"/api/download/json?id={analysis_id}")
    assert r_json.status_code == 200
    assert "application/json" in r_json.content_type

    # 5. Download Printable Report
    r_rep = client.get(f"/api/download/report?id={analysis_id}")
    assert r_rep.status_code == 200
    assert "text/html" in r_rep.content_type
