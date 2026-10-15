"""
DUT Coverage Analysis Tool - Flask Server.
Serves the local dashboard on http://127.0.0.1:5000.
"""

import os
import io
import json
import uuid
import tempfile
from pathlib import Path
from typing import Dict, Any

from flask import Flask, request, jsonify, render_template, send_file, Response
import pandas as pd

from duts import list_registered_duts, get_dut
from engine import run_pipeline

app = Flask(__name__, static_folder="static", template_folder="templates")
app.config["MAX_CONTENT_LENGTH"] = 16 * 1024 * 1024  # 16 MB max upload size

# In-memory store for recent analyses (session cache for downloads)
ANALYSIS_CACHE: Dict[str, Dict[str, Any]] = {}

@app.route("/")
def index():
    """
    Main dashboard page.
    """
    return render_template("index.html")

@app.route("/api/duts", methods=["GET"])
def get_duts():
    """
    Returns list of registered DUTs with metadata.
    """
    duts = list_registered_duts()
    # Check bundled sample data availability
    base_dir = Path(__file__).resolve().parent
    for d in duts:
        name = d["name"]
        sample_path = base_dir / "sample_data" / f"{name}.csv"
        rtl_path = base_dir / "bundled_rtl" / f"{name}.v"
        d["has_bundled_sample"] = sample_path.exists()
        d["has_bundled_rtl"] = rtl_path.exists()
        if sample_path.exists():
            try:
                df_sample = pd.read_csv(sample_path)
                d["sample_rows_count"] = len(df_sample)
            except Exception:
                d["sample_rows_count"] = 0
        else:
            d["sample_rows_count"] = 0
    return jsonify({"duts": duts})

@app.route("/api/analyze", methods=["POST"])
def analyze():
    """
    Executes the analysis pipeline on uploaded or bundled test data.
    """
    try:
        dut_name = request.form.get("dut_name", "").strip()
        demo_mode = request.form.get("demo_mode", "false").lower() == "true"
        subsample_str = request.form.get("subsample_n", "").strip()
        subsample_n = int(subsample_str) if subsample_str and subsample_str.isdigit() else None

        if not dut_name:
            return jsonify({"success": False, "error": "No DUT selected."}), 400

        dut_plugin = get_dut(dut_name)
        if not dut_plugin:
            return jsonify({"success": False, "error": f"DUT plugin '{dut_name}' not found."}), 404

        base_dir = Path(__file__).resolve().parent

        # 1. Determine CSV source
        csv_file = request.files.get("csv_file")
        if demo_mode or not csv_file or not csv_file.filename:
            # Load bundled sample CSV
            sample_path = base_dir / "sample_data" / f"{dut_name}.csv"
            if not sample_path.exists():
                return jsonify({
                    "success": False,
                    "error": f"Bundled sample data for '{dut_name}' not found at {sample_path.name}."
                }), 404
            csv_source = sample_path
        else:
            # Read uploaded file
            content = csv_file.read()
            csv_source = io.BytesIO(content)

        # 2. Determine RTL source (optional custom upload)
        custom_rtl_path = None
        rtl_file = request.files.get("rtl_file")
        temp_rtl = None
        if rtl_file and rtl_file.filename:
            temp_dir = tempfile.mkdtemp()
            temp_rtl = Path(temp_dir) / f"custom_{rtl_file.filename}"
            rtl_file.save(str(temp_rtl))
            custom_rtl_path = str(temp_rtl)

        # 3. Execute Analysis Engine
        report = run_pipeline(
            csv_source=csv_source,
            dut_plugin=dut_plugin,
            subsample_n=subsample_n,
            custom_rtl_path=custom_rtl_path,
            top_n=10,
            random_state=42
        )

        # Cache analysis for downloads
        analysis_id = str(uuid.uuid4())
        ANALYSIS_CACHE[analysis_id] = report
        # Limit cache size
        if len(ANALYSIS_CACHE) > 20:
            oldest_key = next(iter(ANALYSIS_CACHE))
            del ANALYSIS_CACHE[oldest_key]

        return jsonify({
            "success": True,
            "analysis_id": analysis_id,
            "report": report
        })

    except ValueError as e:
        return jsonify({"success": False, "error": str(e)}), 400
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"success": False, "error": f"Server processing error: {str(e)}"}), 500

@app.route("/api/download/csv", methods=["GET"])
def download_csv():
    """
    Downloads recommended tests as CSV.
    """
    analysis_id = request.args.get("id", "")
    report = ANALYSIS_CACHE.get(analysis_id)
    if not report:
        return Response("Analysis report not found or expired.", status=404, mimetype="text/plain")

    candidates = report["step9_recommendations"]["recommended_inputs"]
    if not candidates:
        return Response("No recommendations generated for this analysis.", status=400, mimetype="text/plain")

    rows = []
    for c in candidates:
        row = {
            "rank": c["rank"],
            **c["inputs"],
            "target_bin": c["target_bin"],
            "closes_gap": c["closes_gap"],
            "selection_method": c["selection_method"],
            "rare_probability": c.get("rare_probability", ""),
            "predicted_numeric": c.get("predicted_numeric", ""),
        }
        rows.append(row)

    df_out = pd.DataFrame(rows)
    output = io.StringIO()
    df_out.to_csv(output, index=False)
    csv_bytes = output.getvalue().encode("utf-8")

    filename = f"recommended_tests_{report['metadata']['dut_name']}.csv"
    return Response(
        csv_bytes,
        mimetype="text/csv",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )

@app.route("/api/download/json", methods=["GET"])
def download_json():
    """
    Downloads full computed analysis as JSON.
    """
    analysis_id = request.args.get("id", "")
    report = ANALYSIS_CACHE.get(analysis_id)
    if not report:
        return Response("Analysis report not found or expired.", status=404, mimetype="text/plain")

    json_str = json.dumps(report, indent=2)
    filename = f"analysis_{report['metadata']['dut_name']}.json"
    return Response(
        json_str.encode("utf-8"),
        mimetype="application/json",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )

@app.route("/api/download/report", methods=["GET"])
def download_printable_report():
    """
    Generates and downloads a self-contained printable HTML report.
    """
    analysis_id = request.args.get("id", "")
    report = ANALYSIS_CACHE.get(analysis_id)
    if not report:
        return Response("Analysis report not found or expired.", status=404, mimetype="text/plain")

    html_content = render_template("report_printable.html", report=report)
    filename = f"coverage_report_{report['metadata']['dut_name']}.html"
    return Response(
        html_content.encode("utf-8"),
        mimetype="text/html",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )

if __name__ == "__main__":
    # Serves http://127.0.0.1:5000 only per specification
    app.run(host="127.0.0.1", port=5000, debug=False)
