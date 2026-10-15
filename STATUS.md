# Verification Status Tracking

| DUT Index | DUT Name | Category | RTL | TB (CRV) | Sim Compile | Sim Run PASS | Baseline Data | ML Analyzed | Targeted Sim | Final Status | Notes |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| C01 | `mux_2to1` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (20 rows) | EVALUATED | N/A | COMPLETE | Small space (8), 100% covered by CRV (no gap) |
| C02 | `mux_4to2` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (30 rows) | EVALUATED | N/A | COMPLETE | Small space (64), 100% covered by CRV (no gap) |
| C03 | `full_adder` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (20 rows) | EVALUATED | N/A | COMPLETE | Small space (8), 100% covered by CRV (no gap) |
| C04 | `adder_4bit` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (60 rows) | EVALUATED | PASS (100%) | COMPLETE | **ML WIN**: Closed `sum_zero` (70 total tests vs 210 CRV mean) |
| C05 | `adder_subtractor_4bit` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (60 rows) | EVALUATED | PASS (100%) | COMPLETE | 3 gaps; compound mode corners not reachable |
| C06 | `comparator_2bit` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (25 rows) | EVALUATED | N/A | COMPLETE | Small space (16), 100% covered by CRV (no gap) |
| C07 | `comparator_4bit` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (40 rows) | EVALUATED | PASS (100%) | COMPLETE | 4 extreme corner gaps unclosed |
| C08 | `decoder_2to4` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (20 rows) | EVALUATED | N/A | COMPLETE | Small space (8), 100% covered by CRV (no gap) |
| C09 | `priority_encoder_4to2` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (25 rows) | EVALUATED | N/A | COMPLETE | Small space (32), 100% covered by CRV (no gap) |
| C10 | `binary_to_gray_3bit` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (20 rows) | EVALUATED | N/A | COMPLETE | Small space (8), 100% covered by CRV (no gap) |
| C11 | `barrel_shifter_8bit` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (80 rows) | EVALUATED | PASS (100%) | COMPLETE | 4096 space, 2 rare corner data gaps |
| C12 | `multiplier_4bit` | Combinational | DONE | DONE | PASS | PASS (100%) | GENERATED (40 rows) | EVALUATED | PASS (100%) | COMPLETE | **ML WIN**: Closed `prod_max=225` (50 total tests vs 160 CRV mean) |
| S01 | `up_down_counter_4bit` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (40 rows) | EVALUATED | PASS (100%) | COMPLETE | Wrap corner sequential gaps |
| S02 | `shift_register_4bit` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (45 rows) | EVALUATED | PASS (100%) | COMPLETE | State all-1 gap |
| S03 | `sequence_detector_1011` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (50 rows) | EVALUATED | N/A | COMPLETE | Overlapping 1011011 gap (not reachable by supervised point ML) |
| S04 | `sync_fifo_8x8` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (60 rows) | EVALUATED | PASS (100%) | COMPLETE | FIFO full and overflow attempt gaps |
| S05 | `traffic_light_fsm` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (40 rows) | EVALUATED | N/A | COMPLETE | 4 states, 100% covered by CRV (no gap) |
| S06 | `lfsr_8bit` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (50 rows) | EVALUATED | PASS (100%) | COMPLETE | 255 states, all-ones and alternating pattern gaps |
| S07 | `mod10_counter_with_load` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (45 rows) | EVALUATED | PASS (100%) | COMPLETE | **ML WIN**: Val Acc 91.7%, closed `rollover_9_to_0` gap |
| S08 | `register_file_4x8` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (50 rows) | EVALUATED | N/A | COMPLETE | 4 regs, 100% covered by CRV (no gap) |
| S09 | `uart_tx` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (80 rows) | EVALUATED | N/A | COMPLETE | 4 states, 100% covered by CRV (no gap) |
| S10 | `vending_machine_fsm` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (50 rows) | EVALUATED | PASS (100%) | COMPLETE | Multi-coin change return gaps |
| S11 | `button_debouncer` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (60 rows) | EVALUATED | N/A | COMPLETE | Debounce release & pulse gaps |
| S12 | `pwm_generator` | Sequential | DONE | DONE | PASS | PASS (100%) | GENERATED (60 rows) | EVALUATED | PASS (100%) | COMPLETE | 0% and 100% duty boundary gaps |
