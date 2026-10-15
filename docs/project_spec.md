# Formal Specification: AI-Assisted RTL Verification Framework

## 1. Problem Formulation & Scope

### 1.1 Constrained-Random Verification (CRV) Plateau
Modern digital hardware verification relies extensively on Constrained-Random Verification (CRV). While CRV provides rapid coverage growth during early simulation cycles, it inevitably suffers from a coverage plateau. Boundary states, extreme arithmetic combinations, and rare sequence transitions possess low probability mass in uniform or pseudo-random distributions.

For example, in a 4-bit unsigned adder ($A[3:0] + B[3:0] + C_{in}$), the input domain contains $2^4 \times 2^4 \times 2^1 = 512$ combinations. The extreme boundary sum $S=0$ requires $(A=0, B=0, C_{in}=0)$, a probability of $1/512 \approx 0.195\%$ per test. Similarly, $S=31$ requires $(A=15, B=15, C_{in}=1)$, also with probability $1/512$. Running 60 random tests leaves both bins empty with high probability ($P(\text{empty}) = (1 - 1/512)^{60} \approx 88.9\%$). Closing these residual coverage holes by sheer scale of random simulations requires exponential compute budgets.

### 1.2 Core Research Question
Can an empirical Machine Learning model, trained on prior CRV simulation traces, predict which unvisited input candidates are most likely to trigger missing functional coverage bins, thereby achieving coverage closure with fewer total simulation cycles (training tests + ML-directed tests) than continued CRV alone?

---

## 2. Machine Learning Architecture

The AI module serves strictly as an **offline prioritization and ranking engine**. RTL modeling, reference implementations, scoreboards, and simulation assertions remain 100% standard hardware verification logic.

### 2.1 Primary Architecture: `RandomForestClassifier`
- **Objective**: Predict probability of an unvisited candidate belonging to a rare coverage bin:
  $$\hat{y} = P(\text{is\_rare} = 1 \mid \mathbf{x})$$
- **Feature Vector $\mathbf{x}$**:
  - Combinational DUTs: Decimal input vector $(i_1, i_2, \dots, i_m)$.
  - Sequential DUTs: Internal state $+$ last-$k$ input window $+$ current inputs:
    $$\mathbf{x} = (s_t, w_k, i_{t,1}, \dots, i_{t,m})$$
- **Target Label $y$**: Binary label where $y=1$ if the coverage bin was classified as rare ($< 50\%$ of mean bin occurrences or unvisited), and $y=0$ otherwise.
- **Deduplication Discipline**: All training rows are deduplicated on feature columns before train/validation partitioning. A stratified 75/25 train/validation split is applied to prevent data leakage and evaluate real generalization.

### 2.2 Fallback Architecture: `RandomForestRegressor`
- **Condition for Invocation**: Used strictly when a functional coverage bin has **zero examples in training data** AND represents a **numerical/arithmetic boundary** (e.g., maximum product, zero sum, overflow wrap).
- **Rationale**: A classifier cannot predict a discrete class label that has never appeared in its training distribution ($P(C_{\text{unseen}}) = 0$). A regressor, however, can model the underlying continuous arithmetic function (e.g. $f(A, B) = A \times B$) and extrapolate toward extreme numeric frontiers, selecting candidates at the predicted boundaries.
- **Constraint**: If an unvisited bin is non-numeric/structural and has zero training examples, it is flagged as **"unreachable by this method"** and never artificially hand-crafted.

---

## 3. Toolchain & Environmental Constraints

- **Hardware Description Language**: Verilog-2001 strictly.
- **RTL Simulator**: Icarus Verilog (`iverilog` and `vvp` v10+ / v12+).
- **Prohibited Constructs**: No SystemVerilog features (no `constraint`, `rand`, `covergroup`, `mailbox`, `semaphore`).
- **Pseudo-Random Number Generation**: Standard `$urandom_range(min, max)`.
- **Reproducibility**: Parameterized `+SEED` plusarg via `$value$plusargs`. The initial seed must be recorded before invoking `$urandom(seed)` because Icarus Verilog updates seeds by reference.
- **Data Logging**: All stimulus and signal values logged to CSV in **decimal integer format (`%0d`)** to avoid string/hex parsing corruption in data science pipelines.
- **Python Toolchain**: Limited strictly to standard scientific packages: `pandas`, `scikit-learn`, `numpy`, `matplotlib`.

---

## 4. Benchmark Design Suite (24 DUTs)

The benchmark set spans 24 designs mixing small, fully enumerable input spaces with large, sparse state-input domains:

### 4.1 Combinational Designs (12)
1. `mux_2to1`: 2-to-1 Multiplexer (input space = 8).
2. `mux_4to2`: 4-to-1 Multiplexer (input space = 64).
3. `full_adder`: 1-bit Full Adder with Carry (input space = 8).
4. `adder_4bit`: 4-bit Ripple-Carry Adder (input space = 512).
5. `adder_subtractor_4bit`: 4-bit Adder/Subtractor with Overflow (input space = 512).
6. `comparator_2bit`: 2-bit Magnitude Comparator (input space = 16).
7. `comparator_4bit`: 4-bit Magnitude Comparator with extreme equality bins (input space = 256).
8. `decoder_2to4`: 2-to-4 Active-High Decoder with Enable (input space = 8).
9. `priority_encoder_4to2`: 4-to-2 Priority Encoder with Valid Flag (input space = 32).
10. `binary_to_gray_3bit`: 3-bit Binary-to-Gray Converter (input space = 8).
11. `barrel_shifter_8bit`: 8-bit Bidirectional Rotate Barrel Shifter (input space = 4,096).
12. `multiplier_4bit`: 4-bit Unsigned Multiplier (input space = 256).

### 4.2 Sequential Designs (12)
1. `up_down_counter_4bit`: 4-bit Synchronous Up/Down Counter with Wrap.
2. `shift_register_4bit`: 4-bit Multi-function Shift Register (Hold, Shr, Shl, Load).
3. `sequence_detector_1011`: Overlapping "1011" Sequence Detector FSM.
4. `sync_fifo_8x8`: Synchronous 8-word x 8-bit FIFO with Full/Empty/Overflow flags.
5. `traffic_light_fsm`: 4-phase Traffic Controller FSM.
6. `lfsr_8bit`: 8-bit Galois Linear Feedback Shift Register with Seed Load.
7. `mod10_counter_with_load`: Modulo-10 Decade Counter with Synchronous Load.
8. `register_file_4x8`: 4-register x 8-bit Register File (Simultaneous Read/Write).
9. `uart_tx`: 8-N-1 UART Transmitter with Baud Tick & Start/Stop framing.
10. `vending_machine_fsm`: Coin Accumulator FSM (5c, 10c, 25c) with Dispense/Change.
11. `button_debouncer`: Digital Button Debouncer with Sampling Filter.
12. `pwm_generator`: Pulse Width Modulation Generator with Dynamic Duty Cycle.

---

## 5. Verification Architecture

Every testbench implements four decoupled architectural tasks:
1. **Driver**: Injects stimulus into the DUT ports with precise timing (`#1` settle for combinational, synchronized `@(negedge clk)` / `@(posedge clk)` for sequential).
2. **Reference Model**: Software model computing independent ground-truth expected outputs directly from stimulus. The reference model never duplicates internal RTL assignments.
3. **Scoreboard**: Bit-exact comparator comparing DUT outputs against reference outputs on every evaluation cycle. Every failure triggers an explicit `$display("[FAIL] ...")`.
4. **Coverage Sampler**: Tracks visited functional bins using manual integer counters and records active bins for CSV export.

---

## 6. Evaluation Methodology

A fair, rigorous evaluation discipline is enforced:
1. **Total ML Cost Accountability**:
   $$\text{Total ML Simulations} = N_{\text{CRV Baseline (Training)}} + N_{\text{ML Targeted}}$$
   ML claims victory only if $\text{Total ML Simulations} < \text{Mean CRV Tests to Closure}$.
2. **10-Seed CRV Baseline**: For designs with coverage gaps, CRV is simulated across 10 distinct pseudo-random seeds (seeds 101 to 110) up to 300 cycles to measure the empirical mean and standard deviation of cycles required to close all bins.
3. **Random-Selection Baseline**: An identical number of candidates ($N_{\text{ML Targeted}}$) is drawn randomly from the unvisited candidate space. ML is considered effective only if its closed gaps exceed the random baseline.
4. **Transparency & Negative Results**:
   - Small enumerable spaces reaching 100% under baseline CRV are documented as expected, confirming CRV optimality on small domains.
   - Any gaps unreachable by the model due to lack of training data or non-numeric representations are recorded explicitly as unclosed.
