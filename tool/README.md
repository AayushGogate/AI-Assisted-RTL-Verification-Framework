# DUT Coverage Analysis Tool (Local Web Dashboard)

An AI-assisted functional verification framework that detects coverage gaps in constrained-random verification (CRV) baselines, uses machine learning to prioritize untested candidate stimulus, and confirms closure through real Icarus Verilog simulation.

---

## 1. Why This Exists

Constrained-Random Verification (CRV) covers typical hardware behavior rapidly, but then reaches a coverage plateau. Rare boundary cases and corner conditions are statistically improbable to hit by pure chance.

For example, a **4-bit ripple adder** has 512 input combinations $(A, B, C_{in})$. Exactly **one** vector results in $sum = 0$ ($A=0, B=0, C_{in}=0$), and exactly **one** vector results in $sum = 31$ ($A=15, B=15, C_{in}=1$). In 200 random simulations, the probability of missing both extremes is high, leaving critical coverage bins empty despite a 100% functional pass rate.

This tool:
1. Ingests a DUT's testbench results CSV.
2. Identifies missing and under-covered bins and calculates their 1-in-$N$ random hitting probability.
3. Uses machine learning (`RandomForestClassifier` with `RandomForestRegressor` boundary fallback) to score and rank untested vectors.
4. Auto-generates directed Icarus Verilog testbenches and executes simulation on the actual hardware RTL to prove closure.

---

## 2. Quickstart & Installation (Windows & Cross-Platform)

### Prerequisites
- **Python 3.10+** (Tested on Python 3.11)
- **Icarus Verilog (`iverilog` & `vvp`)**

### Windows Setup for Icarus Verilog
1. Download the Icarus Verilog installer for Windows from:
   [https://bleyer.org/icarus/](https://bleyer.org/icarus/) (e.g. `iverilog-v12-20220611-x64_setup.exe`).
2. Run the installer and ensure the option **"Add executable folder(s) to system PATH"** is checked.
3. Default installation path is typically `C:\iverilog\bin`.
4. Verify from PowerShell:
   ```powershell
   where.exe iverilog
   where.exe vvp
   iverilog -V
   ```
*(Note: If `iverilog` is not installed or not on PATH, the dashboard gracefully reports "skipped: iverilog not found" with installation guidance and continues operating without crashing).*

### Python Dependencies
Install required packages:
```powershell
pip install flask pandas scikit-learn numpy pytest
```

### Running the Dashboard
From the project root or the `tool/` directory:
```powershell
python app.py
```
Open your browser to:
[http://127.0.0.1:5000](http://127.0.0.1:5000)

---

## 3. How to Add a New DUT (Under Ten Lines)

To add a new hardware design, create a single Python file in `tool/duts/<name>.py`. The registry discovers it automatically:

```python
DUT_NAME = "and_gate"
INPUTS = {"A": (0, 1), "B": (0, 1)}
DECODE_COLS = []
bin_fn = lambda r: f"A{int(r['A'])}_B{int(r['B'])}"
numeric_target_fn = None
rtl_drive_fn = lambda r: ({"A": int(r["A"]), "B": int(r["B"])}, {"Y": int(r["A"]) & int(r["B"])})
RTL_MODULE = "and_gate"
RTL_WIDTHS = {"A": 1, "B": 1, "Y": 1}
DEFAULT_RTL_PATH = "bundled_rtl/and_gate.v"
```

Drop this into `tool/duts/` and your DUT will immediately appear in the dashboard dropdown!

---

## 4. Verification Scope & Honesty Rules

- **Functional Coverage Only**: This tool analyzes and reports **functional coverage** (coverage bins sampled during testbench execution). It does **not** report line, toggle, or branch code coverage, because Icarus Verilog does not calculate code coverage.
- **Combinational Enumeration (v1)**: v1 computes the complete enumerable input space for combinational DUTs. The plugin architecture is designed to accommodate sequential state sequences in future versions.
- **Zero Fabrication**: All metrics, bin counts, and simulation pass/fail numbers are computed directly from test results and simulator execution. No synthetic numbers are hardcoded or artificially inflated.
- **Strict Model-Only Selection**: Candidate inputs are selected strictly by model prediction outputs (e.g., $P(rare)$ descending or predicted boundary extremes). The reference model and `bin_fn` are never used to pre-filter candidates; they are evaluated only after selection to verify coverage.
- **Random-Selection Baseline Comparison**: Every ML result is benchmarked against a 20-draw uniform random selection of the same budget size. ML is only credited with a "WIN" if it outperforms random selection.
- **Zero-Example Boundaries**: If a missing bin has zero training examples and no `numeric_target_fn`, it is marked as `unreachable by this method`. It is never hand-crafted and falsely credited to machine learning.

---

## 5. Dashboard User Flow & Features

1. **Target DUT Selection**: Choose between the 8 built-in DUTs (`mux_2to1`, `mux_4to1`, `full_adder`, `2bit_comparator`, `binary_to_gray_3bit`, `decoder_2to4`, `demux_1to4`, `adder_4bit`) or custom plugins.
2. **Data Source**:
   - **Demo Mode**: Loads bundled real CRV simulation logs.
   - **Upload Custom CSV**: Upload testbench results (validated with clear column error reporting).
3. **Optional RTL Override**: Upload custom `.v` module for hardware simulation verification.
4. **Subsampling Slider**: "Use only first N tests" to simulate test budget constraints and evaluate what-if gap closure. Subsampled reports are prominently marked.
5. **Report Sequence**:
   - **Step 1**: Executive Summary (DUT, tests, unique vectors, coverage %, pass rate).
   - **Step 2**: Functional Correctness (passes, failures, failing rows table).
   - **Step 3**: Coverage by Bin (interactive inline SVG bar chart and frequency table).
   - **Step 4**: Input-Space Coverage (tested vs untested vectors, coefficient of variation).
   - **Step 5**: Gap Analysis in Plain Language (missing/under-covered bins and 1-in-$N$ hitting probabilities).
   - **Step 6**: AI-Assisted Candidate Prioritization (supervised labelling, validation accuracy/precision/recall, confusion matrix, ranked candidates, regressor fallback flags, random-selection baseline benchmark).
   - **Step 7**: Hardware Simulation Verification (Icarus Verilog status, testbench source viewer, simulation stdout log).
   - **Step 8**: Before vs After Coverage Impact (coverage % jump, tests added).
   - **Step 9**: Actionable Recommendations (exact input vectors to add to verification suites).
6. **Downloads**:
   - Self-contained printable HTML report (`coverage_report_<dut>.html`).
   - Machine-readable candidate stimuli (`recommended_tests.csv`).
   - Full structured analysis data (`analysis_<dut>.json`).

---

## 6. Running Tests

Execute the automated test suite with pytest:
```powershell
pytest tool/tests/test_pipeline.py -v
```

Tests validate:
- True coverage and pass/fail counts for all built-in DUTs.
- Subsampled test budgets triggering ML and RTL verification end-to-end.
- `adder_4bit` regressor fallback closing $sum=0$ and $sum=31$ confirmed by Icarus simulation.
- Bad CSV handling and column validation errors without crashing.
- Graceful degradation when `iverilog` is absent.
- Flask API endpoints and file downloads.
