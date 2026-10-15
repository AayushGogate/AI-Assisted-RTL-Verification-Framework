# AI-Assisted RTL Verification Framework - Master Plan

## 1. Project Overview & Objective
This proof-of-concept investigates whether machine learning (Supervised Classification via `RandomForestClassifier` with `RandomForestRegressor` numerical boundary fallback) can predict untested input vectors/sequences most likely to hit missing coverage bins, thereby closing functional coverage gaps with fewer total simulations than continued constrained-random verification (CRV) alone.

Every result is backed by real Icarus Verilog (`iverilog`/`vvp`) simulation. No numbers are hardcoded, fabricated, or artificially tuned.

---

## 2. Complete DUT Set & Pre-Fixed Test Budgets

Budgets are fixed before observing any ML output and will not be altered to manufacture artificial coverage gaps.

### Combinational DUTs (12)
| Index | DUT Name | Inputs / Bits | Total Space | Intended Coverage Bins | Fixed CRV Budget | Space Characteristics |
|:---:|:---|:---:|:---:|:---|:---:|:---|
| C01 | `mux_2to1` | A, B, S (3b) | 8 | 4 bins: {S=0, S=1} x {selected data 0, 1} | 20 tests | Small space; CRV closes 100% |
| C02 | `mux_4to2` | I[3:0], S[1:0] (6b) | 64 | 8 bins: 4 select combos x 2 data values | 30 tests | Small space; CRV closes 100% |
| C03 | `full_adder` | A, B, Cin (3b) | 8 | 8 bins: full enumeration of (A, B, Cin) | 20 tests | Small space; CRV closes 100% |
| C04 | `adder_4bit` | A[3:0], B[3:0], Cin (9b) | 512 | 6 bins: `sum_zero` (0), `sum_max` (31), `carry_out_0`, `carry_out_1`, `mid_range_low` (1..15), `mid_range_high` (16..30) | 60 tests | Real gap: sum=0 (1/512) and sum=31 (1/512) |
| C05 | `adder_subtractor_4bit` | A[3:0], B[3:0], sub (9b) | 512 | 7 bins: `add_zero`, `add_max`, `sub_zero`, `sub_min_neg`, `overflow_pos`, `overflow_neg`, `normal_op` | 60 tests | Real gap: sum=0, diff=-15, overflow corners |
| C06 | `comparator_2bit` | A[1:0], B[1:0] (4b) | 16 | 3 bins: `A_gt_B`, `A_eq_B`, `A_lt_B` | 25 tests | Small space; CRV closes 100% |
| C07 | `comparator_4bit` | A[3:0], B[3:0] (8b) | 256 | 5 bins: `gt`, `eq`, `lt`, `eq_zero` (A=0,B=0), `eq_max` (A=15,B=15) | 40 tests | Boundary gap: eq_zero (1/256), eq_max (1/256) |
| C08 | `decoder_2to4` | enable, in[1:0] (3b) | 8 | 5 bins: `disabled`, `en_out0`, `en_out1`, `en_out2`, `en_out3` | 20 tests | Small space; CRV closes 100% |
| C09 | `priority_encoder_4to2` | in[3:0], enable (5b) | 32 | 5 bins: `disabled`, `pri_0`, `pri_1`, `pri_2`, `pri_3` | 25 tests | Small space; CRV closes 100% |
| C10 | `binary_to_gray_3bit` | B[2:0] (3b) | 8 | 8 bins: all 8 Gray code mappings | 20 tests | Small space; CRV closes 100% |
| C11 | `barrel_shifter_8bit` | data[7:0], amt[2:0], dir (12b) | 4096 | 18 bins: 16 (dir x amt) bins, `all_zero_data`, `all_one_data` | 80 tests | Large space; corner patterns rare |
| C12 | `multiplier_4bit` | A[3:0], B[3:0] (8b) | 256 | 6 bins: `prod_zero`, `prod_max` (225), `prod_one` (1), `prod_low`, `prod_mid`, `prod_high` | 40 tests | Real gap: prod=225 (1/256), prod=1 (1/256) |

### Sequential DUTs (12)
| Index | DUT Name | Inputs / State | Space / States | Intended Coverage Bins | Fixed CRV Budget | Space Characteristics |
|:---:|:---|:---:|:---:|:---|:---:|:---|
| S01 | `up_down_counter_4bit` | up_down, enable / count[3:0] | 16 states | 19 bins: 16 states visited, `wrap_up` (15->0), `wrap_down` (0->15), `hold` | 40 cycles | Real gap: wrap corners require specific state + input |
| S02 | `shift_register_4bit` | mode[1:0], sin, pin[3:0] / q[3:0] | 16 states | 8 bins: 4 modes, `state_all_0`, `state_all_1`, `pattern_alt0`, `pattern_alt1` | 45 cycles | Corner states rare under random shifts |
| S03 | `sequence_detector_1011` | bit_in / 4 states | 4 states | 7 bins: S0, S1, S2, S3, `match_single`, `match_overlap` (1011011), `mismatch_reset` | 50 cycles | Real gap: overlapping match requires specific 7-bit sequence |
| S04 | `sync_fifo_8x8` | wr_en, rd_en, data[7:0] / 8 words | Depth 8 | 8 bins: `empty`, `almost_empty`, `mid_depth`, `almost_full`, `full`, `simul_wr_rd`, `overflow_attempt`, `underflow_attempt` | 60 cycles | Real gap: FIFO full (depth 8) and overflow attempt |
| S05 | `traffic_light_fsm` | car, timer_done / 4 states | 4 states | 8 bins: 4 states, 4 transitions (S0->S1, S1->S2, S2->S3, S3->S0) | 40 cycles | Small FSM; CRV closes 100% |
| S06 | `lfsr_8bit` | load, seed[7:0] / 8b state | 255 states | 6 bins: `seed_load`, `run_length_short`, `run_length_long`, `state_msb_set`, `state_lsb_set`, `all_ones_state` | 50 cycles | Large state space; specific patterns rare |
| S07 | `mod10_counter_with_load` | load, load_val[3:0], en / count[3:0] | 10 states | 13 bins: 10 count states, `roll_over_9to0`, `load_out_of_range`, `load_at_boundary` | 45 cycles | Boundary gap: roll_over at count 9 |
| S08 | `register_file_4x8` | wr_en, wr_addr, data, rd_addr | 4 regs (32b) | 9 bins: write R0..R3, read R0..R3, `simultaneous_wr_rd_same_addr` | 50 cycles | Corner: read/write collide on exact same address |
| S09 | `uart_tx` | tx_start, data[7:0], baud_tick | 4 FSM states | 7 bins: IDLE, START, DATA, STOP, `tx_done`, `corner_data_00`, `corner_data_FF` | 80 cycles | Corner data payload gaps |
| S10 | `vending_machine_fsm` | coin_5, 10, 25, cancel | 6 states | 8 bins: states 0c..25c, `dispense_exact`, `dispense_with_change`, `cancel_refund` | 50 cycles | Multi-coin sequence to reach change |
| S11 | `button_debouncer` | noisy_btn / filter count | 4 states | 6 bins: `idle_low`, `glitch_filtered_high`, `stable_high`, `idle_high`, `glitch_filtered_low`, `pulse_generated` | 60 cycles | Glitch duration < threshold vs >= threshold |
| S12 | `pwm_generator` | duty[7:0], period[7:0] | 256 levels | 6 bins: `duty_0_percent`, `duty_100_percent`, `duty_50_percent`, `duty_gt_period`, `normal_pulse_low`, `normal_pulse_high` | 60 cycles | Exact 0% and 100% duty boundaries |

---

## 3. Order of Work & Execution Strategy

1. **Phase 1-4 per DUT (Combinational C01 -> C12)**:
   - Implement Verilog RTL (`rtl/combinational/<dut>/<dut>.v`).
   - Create testbench (`verification/combinational/<dut>/tb/tb_<dut>.v`) with independent reference model, scoreboard ($display failures), monitor, manual integer coverage bins, CSV logging in decimal.
   - Script runner (`run_sim.bat` and `run_sim.sh`).
   - Compile and simulate with Icarus Verilog (`iverilog`/`vvp`). Verify 100% PASS on functional checks.
   - Log `results_crv_baseline.csv`.
   - Update `STATUS.md`.

2. **Phase 1-4 per DUT (Sequential S01 -> S12)**:
   - Implement Verilog RTL (`rtl/sequential/<dut>/<dut>.v`).
   - Create testbench (`verification/sequential/<dut>/tb/tb_<dut>.v`) with clock, async active-low reset, cycle-accurate reference model, state/window tracking, manual coverage counters, decimal CSV logging.
   - Compile, simulate, verify 100% PASS, log `results_crv_baseline.csv`.
   - Update `STATUS.md`.

3. **Phase 4 Integration (Dataset Merge & Labeling)**:
   - `merge_datasets.py`: Combines all baseline CSVs into `data/combined_dataset.csv`, asserting no rows lost.
   - `label_dataset.py`: Computes bin frequencies, marks rare bins (<50% mean count or 0), writes `data/combined_dataset_labeled.csv`.

4. **Phase 5 ML Analysis & Candidate Selection (`ml/analyze_dut.py`)**:
   - Deduplicate training vectors before stratified split.
   - Train `RandomForestClassifier` on rare/common targets.
   - Fallback `RandomForestRegressor` for zero-example numeric boundaries.
   - Rank candidates strictly via model predictions. No ground-truth filtering.

5. **Phase 6 Directed Simulation & Real RTL Verification**:
   - Generate directed testbench driving top candidates on real Verilog RTL.
   - Run simulation and log `results_ml_targeted.csv`.
   - Record actual simulation PASS/FAIL and gaps closed.

6. **Phase 7 Comprehensive Evaluation**:
   - Run 10-seed CRV closure vs ML cost (training + targeted) vs random-selection baseline.
   - Enumerable space statement for small DUTs.
   - Negative results documented cleanly.
   - Output `evaluation/baseline_vs_ml.csv`, matplotlib plots in `evaluation/plots/`, and `evaluation/report.md`.

7. **Phase 8 Interactive Dashboard**:
   - Standalone `dashboard/index.html` with inline JSON and SVG charts.
   - DUT switcher, baseline bars, missing bins, validation metrics, ranked candidates, before/after coverage.

8. **Phase 9 Acceptance & Resumable Pipeline**:
   - `run_all.py` runs all phases end-to-end, skipping finished steps unless `--force`.
   - `docs/README.md` and `docs/project_spec.md`.
