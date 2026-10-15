# AI-Assisted RTL Verification Framework (Proof of Concept)

A complete, end-to-end empirical framework demonstrating Machine Learning-guided functional coverage closure for digital hardware verification using open-source tools (Icarus Verilog + Python).

---

## 1. Executive Summary

Constrained-Random Verification (CRV) rapidly explores typical digital design behaviors but plateaus on rare corner cases and boundary states (e.g., maximum sum in an adder, boundary loads in a counter, extreme FIFO occupancy). In large state/input spaces, closing these remaining functional gaps using continued random simulation yields diminishing returns.

This framework implements an **empirical, two-tier ML prioritization engine**:
1. **Primary Model — RandomForestClassifier**: Learns feature distributions associated with rare coverage bins ($P(\text{rare})$) and ranks untested candidate vectors/sequences to maximize the likelihood of hitting under-covered scenarios.
2. **Fallback Model — RandomForestRegressor**: Used strictly when target coverage bins represent extreme numeric boundaries (e.g. arithmetic overflows, max products, wrap-around conditions) that were never sampled during random testing ($0$ training examples). The regressor extrapolates toward predicted numerical extremes without handcrafting tests.
3. **Empirical Grounding**: AI is utilized **only** for the ranking/prediction step. RTL synthesis models, independent verification reference models, scoreboards, and simulation assertions are written in standard Verilog-2001 and executed on real RTL using Icarus Verilog (`iverilog` / `vvp`). Every reported metric is measured directly from simulation output.

---

## 2. Directory Structure

```
.
├── rtl/                                  # Verilog-2001 RTL implementations
│   ├── combinational/<dut>/<dut>.v       # 12 Combinational DUTs
│   └── sequential/<dut>/<dut>.v          # 12 Sequential DUTs
├── verification/                         # Verification environments
│   ├── combinational/<dut>/
│   │   ├── tb/tb_<dut>.v                 # Self-checking CRV testbench
│   │   ├── tb/tb_<dut>_ml_targeted.v     # Auto-generated directed testbench
│   │   ├── data/results_crv_baseline.csv # CRV baseline test logs
│   │   ├── data/results_ml_targeted.csv  # ML directed test logs
│   │   └── scripts/run_sim.bat & .sh     # Per-DUT compilation scripts
│   └── sequential/<dut>/                 # Matching structure for sequential DUTs
├── coverage/
│   ├── coverage_config.py                # Centralized python config & bin functions
│   └── coverage_definitions.md           # Markdown specifications of all functional bins
├── data/
│   ├── combined_dataset.csv              # Unified baseline simulation logs (1070 rows)
│   ├── combined_dataset_labeled.csv      # Binned & rarity-annotated dataset
│   ├── merge_datasets.py                 # Dataset merger with strict zero-loss assertions
│   └── label_dataset.py                  # Statistical rarity labeling engine
├── ml/
│   ├── analyze_dut.py                    # ML classifier/regressor training & prioritization
│   ├── models/                           # Serialized scikit-learn model artifacts (.pkl)
│   └── validation/                       # Held-out validation metrics (.json)
├── evaluation/
│   ├── baseline_vs_ml.csv                # 10-seed empirical comparison metrics table
│   ├── report.md                         # Formal analysis report
│   └── plots/                            # High-resolution matplotlib comparison plots
├── dashboard/
│   └── index.html                        # Self-contained glassmorphic dashboard (inline JSON)
├── docs/
│   ├── README.md                         # This file
│   └── project_spec.md                   # Formal proof-of-concept specification
├── PLAN.md                               # Pre-fixed budgets, bins, and execution plan
├── STATUS.md                             # Live execution status across all 24 DUTs
└── run_all.py                            # Master single-command orchestration script
```

---

## 3. Environment & Prerequisites

### System Requirements
- **Operating System**: Windows 10/11 or Linux (Ubuntu 20.04+)
- **Python**: Version 3.9+
- **Verilog Simulator**: Icarus Verilog (v10.0 or higher; v12.0 recommended)

### Installing Icarus Verilog on Windows
1. Download the Icarus Verilog Windows installer from [bleyer.org/icarus](https://bleyer.org/icarus/) (e.g. `iverilog-v12-20220611-x64_setup.exe`).
2. Run the installer and ensure **"Add executable folder(s) to system PATH"** is checked.
3. Open PowerShell or Command Prompt and verify installation:
   ```powershell
   iverilog -v
   vvp -v
   ```

### Python Dependencies
Install the required scientific packages (only `pandas`, `scikit-learn`, `numpy`, and `matplotlib` are used):
```bash
pip install pandas scikit-learn numpy matplotlib
```

---

## 4. Quick Start & Execution

### Running the Entire End-to-End Pipeline
To run all phases (RTL compilation, baseline CRV simulation, dataset merge/labeling, ML training, directed test generation, 10-seed CRV statistical evaluation, plot rendering, and dashboard generation):
```bash
python run_all.py
```

### Command-Line Options
- `--force`: Force re-simulation of baseline CRVs even if cached results exist:
  ```bash
  python run_all.py --force
  ```
- `--dut <dut_name>`: Execute pipeline for a single target design:
  ```bash
  python run_all.py --dut adder_4bit
  ```

### Launching the Interactive Dashboard
The interactive dashboard in `dashboard/index.html` has all simulation and evaluation data embedded directly as **inline JSON**. It has zero external server or internet dependencies and works immediately via any standard web browser:
- Double-click `dashboard/index.html` or open via browser:
  ```powershell
  start dashboard/index.html
  ```

---

## 5. Adding a New Design Under Test (DUT)

To extend the framework with a 25th DUT (e.g., `alu_8bit`):

### Step 1: Implement RTL
Create `rtl/combinational/alu_8bit/alu_8bit.v` (or `sequential/`) using standard Verilog-2001. Declare inputs, outputs, and behavioral logic.

### Step 2: Implement Self-Checking Testbench
Create `verification/combinational/alu_8bit/tb/tb_alu_8bit.v`:
- Declare reference model with exact bitwidths (avoid integer type mismatch).
- Synchronize stimulus using `#1` for combinational or `@(negedge clk)` / `@(posedge clk)` for sequential.
- Log test results to `verification/combinational/alu_8bit/data/results_crv_baseline.csv` formatted with decimal `%0d` specifiers (never `%b`).
- Capture initial seed before calling `$urandom(seed)`:
  ```verilog
  if ($value$plusargs("SEED=%d", seed)) begin end
  init_seed = seed;
  dummy = $urandom(seed);
  ```

### Step 3: Register in Coverage Configuration
In `coverage/coverage_config.py`:
1. Define the functional coverage bin function `bin_alu_8bit(r)`.
2. Define the input boundaries and numeric target function (if applicable).
3. Add the entry to `DUT_CONFIG`:
   ```python
   "alu_8bit": {
       "category": "combinational",
       "inputs": {"A": (0, 255), "B": (0, 255), "op": (0, 7)},
       "default_tests": 80,
       "all_bins": ["bin_add_zero", "bin_ovf", ...],
       "bin_fn": bin_alu_8bit,
       "numeric_target_fn": lambda r: r["A"] + r["B"] if r["op"] == 0 else 0
   }
   ```

### Step 4: Run the Framework
Run `python run_all.py --dut alu_8bit` to automatically compile, simulate, analyze, and evaluate the new design.
