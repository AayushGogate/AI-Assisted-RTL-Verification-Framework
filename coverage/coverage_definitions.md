# Functional Coverage Bin Definitions

This document details the functional coverage bins defined across all 24 designs under test (DUTs) in the framework. Rather than performing simple raw input enumeration, coverage bins represent meaningful functional states, boundary limits, arithmetic carries, comparison outcomes, control paths, and state machine transitions.

## 1. Combinational DUT Set (12)

### C01: `mux_2to1`
- **Description**: 2-to-1 single-bit multiplexer.
- **Inputs**: `A`, `B`, `S`.
- **Bins**:
  - `S0_val0`: Select line 0 chosen with data value 0.
  - `S0_val1`: Select line 0 chosen with data value 1.
  - `S1_val0`: Select line 1 chosen with data value 0.
  - `S1_val1`: Select line 1 chosen with data value 1.
- **Space**: 8 combinations. Fully enumerable.

### C02: `mux_4to2`
- **Description**: 4-to-1 single-bit multiplexer with 2-bit select lines (`S1`, `S0`).
- **Inputs**: `I0`, `I1`, `I2`, `I3`, `S1`, `S0`.
- **Bins**: Select combination $\times$ chosen boolean value ($4 \times 2 = 8$ bins):
  - `S00_I0_0`, `S00_I0_1`
  - `S01_I1_0`, `S01_I1_1`
  - `S10_I2_0`, `S10_I2_1`
  - `S11_I3_0`, `S11_I3_1`
- **Space**: 64 combinations.

### C03: `full_adder`
- **Description**: 1-bit full adder.
- **Inputs**: `A`, `B`, `Cin`.
- **Bins**: Full functional combination mapping ($2^3 = 8$ bins):
  - `A0_B0_Cin0` through `A1_B1_Cin1`.

### C04: `adder_4bit`
- **Description**: 4-bit ripple carry adder.
- **Inputs**: `A[3:0]`, `B[3:0]`, `Cin`.
- **Bins**:
  - `sum_zero`: Arithmetic sum equals 0 ($A=0, B=0, Cin=0$). $P = 1/512$.
  - `sum_max`: Arithmetic sum equals 31 ($A=15, B=15, Cin=1$). $P = 1/512$.
  - `carry_gen`: $Cin=0$ produces $Cout=1$.
  - `carry_prop`: $Cin=1$ propagates to $Cout=1$.
  - `carry_kill`: $Cin=1$ absorbed, $Cout=0$.
  - `no_carry`: $Cin=0, Cout=0$.
- **Space**: 512 combinations. Zero and max sum bins represent true statistical gaps under CRV.

### C05: `adder_subtractor_4bit`
- **Description**: 4-bit adder/subtractor with mode line `sub` and 2's complement overflow detection.
- **Inputs**: `A[3:0]`, `B[3:0]`, `sub`.
- **Bins**:
  - `add_zero`: Addition yielding sum 0 ($P=1/512$).
  - `add_max`: Addition yielding max sum 30 ($P=1/512$).
  - `sub_zero`: Subtraction yielding 0 difference ($A=B$).
  - `sub_min_neg`: Subtraction yielding maximum negative difference ($A=0, B=15$).
  - `overflow_pos`: Signed positive overflow ($> +7$).
  - `overflow_neg`: Signed negative overflow ($< -8$).
  - `normal_add`, `normal_sub`: Within range operations.

### C06: `comparator_2bit`
- **Description**: 2-bit unsigned magnitude comparator.
- **Inputs**: `A[1:0]`, `B[1:0]`.
- **Bins**: `gt` ($A>B$), `eq` ($A=B$), `lt` ($A<B$).

### C07: `comparator_4bit`
- **Description**: 4-bit unsigned magnitude comparator.
- **Inputs**: `A[3:0]`, `B[3:0]`.
- **Bins**:
  - `eq_zero`: Boundary match $A=0, B=0$ ($P=1/256$).
  - `eq_max`: Boundary match $A=15, B=15$ ($P=1/256$).
  - `gt_max_min`: Extreme divergence $A=15, B=0$ ($P=1/256$).
  - `lt_min_max`: Extreme divergence $A=0, B=15$ ($P=1/256$).
  - `mid_gt`, `mid_eq`, `mid_lt`: Interior region outcomes.

### C08: `decoder_2to4`
- **Description**: 2-to-4 binary decoder with active-high enable.
- **Inputs**: `enable`, `in[1:0]`.
- **Bins**: `disabled`, `en_out0`, `en_out1`, `en_out2`, `en_out3`.

### C09: `priority_encoder_4to2`
- **Description**: 4-input priority encoder with enable.
- **Inputs**: `enable`, `in[3:0]`.
- **Bins**: `disabled`, `none_active`, `pri_0`, `pri_1`, `pri_2`, `pri_3`.

### C10: `binary_to_gray_3bit`
- **Description**: 3-bit binary to Gray code converter.
- **Inputs**: `B[2:0]`.
- **Bins**: `gray_0` through `gray_7`.

### C11: `barrel_shifter_8bit`
- **Description**: 8-bit barrel rotator (supports circular left/right rotations).
- **Inputs**: `data[7:0]`, `amt[2:0]`, `dir`.
- **Bins**:
  - 16 directional amount combinations: `dir_L_amt_0` through `dir_R_amt_7`.
  - Boundary data patterns: `data_all_0` ($P=1/256$) and `data_all_1` ($P=1/256$).

### C12: `multiplier_4bit`
- **Description**: 4-bit unsigned binary multiplier ($16 \times 16 = 256$ product space, max product 225).
- **Inputs**: `A[3:0]`, `B[3:0]`.
- **Bins**:
  - `prod_zero`: Multiplicand or multiplier is 0.
  - `prod_max`: Peak product 225 ($A=15, B=15$, $P=1/256$).
  - `prod_one`: Identity product 1 ($A=1, B=1$, $P=1/256$).
  - `prod_low`: Product in range $2..50$.
  - `prod_mid`: Product in range $51..150$.
  - `prod_high`: Product in range $151..224$.

---

## 2. Sequential DUT Set (5)

### S01: `d_flip_flop`
- **Description**: D Flip-Flop with asynchronous active-high reset.
- **Inputs**: `D`, `reset`, `clk`. State: `Q`.
- **Bins**:
  - `bin_q0_hold_d0`: State Q=0 holds when D=0 without reset.
  - `bin_q0_set_d1`: State Q=0 transitions to 1 when D=1.
  - `bin_q1_clear_d0`: State Q=1 transitions to 0 when D=0.
  - `bin_q1_hold_d1`: State Q=1 holds when D=1.
  - `bin_rst_clear_q1`: Asynchronous reset asserted while Q=1, verifying immediate clear.
  - `bin_rst_held_d1`: Reset held active across clock edge while D=1, verifying reset priority.
  - `bin_rst_pulse_d1`: Short reset pulse clears Q, followed by D=1 loading at edge.
  - `bin_rst_held_d0`: Reset held active across clock edge while D=0.

### S02: `jk_flip_flop`
- **Description**: JK Flip-Flop with asynchronous active-high reset.
- **Inputs**: `J`, `K`, `reset`, `clk`. State: `Q`.
- **Bins**:
  - 8 operational state/input bins (`q{Q}_j{J}_k{K}`):
    - `q0_j0_k0`, `q1_j0_k0`: Hold state (J=0, K=0).
    - `q0_j0_k1`, `q1_j0_k1`: Reset state to 0 (J=0, K=1).
    - `q0_j1_k0`, `q1_j1_k0`: Set state to 1 (J=1, K=0).
    - `q0_j1_k1`, `q1_j1_k1`: Toggle state (J=1, K=1).
  - `bin_rst_clear_q1`: Async reset applied while state Q=1.
  - `bin_rst_held_j1k0`: Reset held through clock edge during set command (reset priority over set).
  - `bin_rst_pulse_j1k1`: Async pulse clears state, followed by toggle to 1 at clock edge.
  - `bin_rst_idle`: Reset applied during idle conditions.

### S03: `sr_flip_flop`
- **Description**: SR Flip-Flop with asynchronous active-high reset and forbidden condition ($S=R=1 \rightarrow X$).
- **Inputs**: `S`, `R`, `reset`, `clk`. State: `Q`.
- **Bins**:
  - 12 state $\times$ stimulus bins (`q{Q}_s{S}_r{R}` where Q $\in \{0, 1, x\}$):
    - Legal hold, reset, and set combinations from known states 0 and 1.
    - Transitions to and from the forbidden state ($S=1, R=1$).
  - `bin_rst_clear_q1`: Async reset clears active 1 state.
  - `bin_rst_clear_qx`: Async reset applied while state is X, verifying recovery from forbidden state.
  - `bin_rst_held_s1r0`: Reset held through edge while S=1, R=0 (reset wins over set).
  - `bin_rst_pulse_s1r0`: Reset pulse clears state, then S=1 sets state at clock edge.
  - `bin_rst_idle`: Reset asserted during idle/hold.

### S04: `t_flip_flop`
- **Description**: T Flip-Flop with asynchronous active-high reset.
- **Inputs**: `T`, `reset`, `clk`. State: `Q`.
- **Bins**:
  - 4 operational bins: `q0_t0` (hold 0), `q0_t1` (toggle to 1), `q1_t0` (hold 1), `q1_t1` (toggle to 0).
  - `bin_rst_clear_q1`: Async reset clears state Q=1.
  - `bin_rst_held_t1`: Reset held across clock edge while T=1 (reset wins over toggle).
  - `bin_rst_pulse_t1`: Pulse clears state, then T=1 toggles to 1 at edge.
  - `bin_rst_idle`: Reset asserted during idle.

### S05: `pipo`
- **Description**: 4-bit Parallel-In Parallel-Out synchronous register with async reset.
- **Inputs**: `parallel_in[3:0]`, `reset`, `clk`. Output: `parallel_out[3:0]`.
- **Bins**:
  - `bin_load_zero`: Loading `4'b0000`.
  - `bin_load_ones`: Loading `4'b1111`.
  - `bin_load_alt`: Loading alternating patterns `4'b0101` or `4'b1010`.
  - `bin_load_onehot`: Loading one-hot vectors (`0001`, `0010`, `0100`, `1000`).
  - `bin_load_other`: Loading all other standard 4-bit values.
  - `bin_hold_same`: Stored value equals newly presented input (no bit change).
  - `bin_all_flip`: Presented input is exact bitwise complement of stored register state.
  - `bin_rst_clear_nonzero`: Async reset applied while stored value is nonzero.
  - `bin_rst_held_nonzero`: Reset held through edge while parallel_in is nonzero.
  - `bin_rst_pulse_nonzero`: Pulse clears register, then nonzero value loads at edge.
  - `bin_rst_idle`: Reset applied when register is already zero.

