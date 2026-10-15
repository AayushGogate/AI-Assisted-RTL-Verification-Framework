# DUT Coverage Analysis Tool (Local Web Dashboard)

> **AI-Assisted RTL Verification Framework**  
> Identifies coverage gaps in hardware testbenches, uses machine learning to prioritize untested stimulus, and confirms coverage closure via real Icarus Verilog simulation.

---

## Quick Start

1. **Install dependencies:**
   ```powershell
   pip install flask pandas scikit-learn numpy pytest
   ```

2. **Ensure Icarus Verilog is on PATH:**
   ```powershell
   where.exe iverilog
   where.exe vvp
   ```
   *(If not installed, download from [bleyer.org/icarus](https://bleyer.org/icarus/). The dashboard continues to function with clear skip notices if iverilog is not installed).*

3. **Launch the dashboard:**
   ```powershell
   python app.py
   ```
   Open [http://127.0.0.1:5000](http://127.0.0.1:5000) in your browser.

4. **Run the test suite:**
   ```powershell
   pytest tool/tests/test_pipeline.py -v
   ```

---

## Directory Structure

```text
├── app.py                      # Root launcher (python app.py -> http://127.0.0.1:5000)
├── tool/                       # Tool package
│   ├── app.py                  # Flask web application & REST API
│   ├── duts/                   # DUT plugin interface (extensible in <10 lines)
│   │   ├── __init__.py         # Dynamic plugin registry loader
│   │   ├── mux_2to1.py
│   │   ├── mux_4to1.py
│   │   ├── full_adder.py
│   │   ├── 2bit_comparator.py
│   │   ├── binary_to_gray_3bit.py
│   │   ├── decoder_2to4.py
│   │   ├── demux_1to4.py
│   │   └── adder_4bit.py       # Demonstrates numeric regressor fallback
│   ├── engine/                 # Core analysis & verification pipeline
│   │   ├── __init__.py         # Pipeline orchestrator
│   │   ├── analyzer.py         # CSV decoding, validation, functional correctness & bin coverage
│   │   ├── ml_engine.py        # Random Forest Classifier & Regressor Fallback, Random Baseline
│   │   └── rtl_verifier.py     # Directed Verilog testbench generator & Icarus Verilog runner
│   ├── sample_data/            # Bundled real CSVs for demo mode
│   ├── bundled_rtl/            # Bundled Verilog RTL designs
│   ├── static/                 # Offline presentation layer (CSS & Vanilla JS inline SVG charts)
│   ├── templates/              # Dashboard & self-contained printable report HTML templates
│   ├── tests/                  # Automated pytest suite
│   └── README.md               # Detailed technical documentation
```

---

## Key Verification & Honesty Rules

- **Functional Coverage Only**: Analyzes user-defined and automatic functional coverage bins. Does not report line/branch/toggle code coverage (an Icarus Verilog limitation).
- **No Fabricated Numbers**: All metrics, bin distributions, and pass/fail counts are computed directly from simulation data.
- **Model-Only Candidate Selection**: Candidates are selected strictly by model outputs ($P(\text{rare})$ or predicted numeric boundaries). The reference model and `bin_fn` evaluate candidates only after selection.
- **Random-Selection Baseline Benchmark**: ML candidate closure is compared against 20 independent uniform random draws of the same budget size. ML is only marked a "WIN" if it outperforms random stimulus.
- **Unreachable Bins**: Missing bins with 0 training examples and no numeric order relation are honestly marked as `unreachable by this method` and given directed testing guidance.
