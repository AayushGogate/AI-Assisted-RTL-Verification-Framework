"""
Centralized coverage configuration for all 24 DUTs in the AI-Assisted RTL Verification Framework.

Contains:
- Signal definitions and bit widths
- Full input spaces and ranges
- Fixed CRV default budgets
- Coverage bin categorization functions
- Numeric target functions for regressor fallback
"""

import itertools
import pandas as pd

# Combinational Coverage Bin Functions
def bin_mux_2to1(r):
    S = int(r["S"])
    val = int(r["A"]) if S == 0 else int(r["B"])
    return f"S{S}_val{val}"

def bin_mux_4to2(r):
    s1, s0 = int(r["S1"]), int(r["S0"])
    idx = s1 * 2 + s0
    val = int(r[f"I{idx}"])
    return f"S{s1}{s0}_I{idx}_{val}"

def bin_full_adder(r):
    return f"A{int(r['A'])}_B{int(r['B'])}_Cin{int(r['Cin'])}"

def bin_adder_4bit(r):
    s = int(r["A"]) + int(r["B"]) + int(r["Cin"])
    cout = 1 if s >= 16 else 0
    cin = int(r["Cin"])
    if s == 0:
        return "sum_zero"
    if s == 31:
        return "sum_max"
    if cin == 0 and cout == 1:
        return "carry_gen"
    if cin == 1 and cout == 1:
        return "carry_prop"
    if cin == 1 and cout == 0:
        return "carry_kill"
    return "no_carry"

def bin_adder_subtractor_4bit(r):
    a = int(r["A"])
    b = int(r["B"])
    sub = int(r["sub"])
    if sub == 0:
        s = a + b
        if s == 0:
            return "add_zero"
        if s == 30:
            return "add_max"
        # Signed 4-bit overflow for addition
        # A, B are 4-bit signed (-8..7)
        sa = a if a < 8 else a - 16
        sb = b if b < 8 else b - 16
        sres = sa + sb
        if sres > 7:
            return "overflow_pos"
        if sres < -8:
            return "overflow_neg"
        return "normal_add"
    else:
        diff = a - b
        if diff == 0:
            return "sub_zero"
        if a == 0 and b == 15:
            return "sub_min_neg"
        sa = a if a < 8 else a - 16
        sb = b if b < 8 else b - 16
        sres = sa - sb
        if sres > 7:
            return "overflow_pos"
        if sres < -8:
            return "overflow_neg"
        return "normal_sub"

def bin_comparator_2bit(r):
    a = int(r["A"])
    b = int(r["B"])
    if a > b:
        return "gt"
    if a == b:
        return "eq"
    return "lt"

def bin_comparator_4bit(r):
    a = int(r["A"])
    b = int(r["B"])
    if a == 0 and b == 0:
        return "eq_zero"
    if a == 15 and b == 15:
        return "eq_max"
    if a == 15 and b == 0:
        return "gt_max_min"
    if a == 0 and b == 15:
        return "lt_min_max"
    if a > b:
        return "mid_gt"
    if a == b:
        return "mid_eq"
    return "mid_lt"

def bin_decoder_2to4(r):
    en = int(r["enable"])
    inp = int(r["in"])
    if en == 0:
        return "disabled"
    return f"en_out{inp}"

def bin_priority_encoder_4to2(r):
    en = int(r["enable"])
    inp = int(r["in"])
    if en == 0:
        return "disabled"
    if inp == 0:
        return "none_active"
    if inp & 8:
        return "pri_3"
    if inp & 4:
        return "pri_2"
    if inp & 2:
        return "pri_1"
    return "pri_0"

def bin_binary_to_gray_3bit(r):
    return f"gray_{int(r['B'])}"

def bin_barrel_shifter_8bit(r):
    data = int(r["data"])
    amt = int(r["amt"])
    d = "L" if int(r["dir"]) == 0 else "R"
    if data == 0:
        return "data_all_0"
    if data == 255:
        return "data_all_1"
    return f"dir_{d}_amt_{amt}"

def bin_multiplier_4bit(r):
    a = int(r["A"])
    b = int(r["B"])
    p = a * b
    if p == 0:
        return "prod_zero"
    if p == 225:
        return "prod_max"
    if p == 1:
        return "prod_one"
    if p <= 50:
        return "prod_low"
    if p <= 150:
        return "prod_mid"
    return "prod_high"

# ---------------------------------------------------------------------------
# Sequential Coverage Bin Functions
# ---------------------------------------------------------------------------

def bin_d_flip_flop(r):
    rst_mode = int(r.get("rst_mode", 0))
    prev_q = int(r.get("state", r.get("prev_q", 0)))
    D = int(r.get("D", 0))
    if rst_mode == 0:
        if prev_q == 0 and D == 0:
            return "bin_q0_hold_d0"
        if prev_q == 0 and D == 1:
            return "bin_q0_set_d1"
        if prev_q == 1 and D == 0:
            return "bin_q1_clear_d0"
        return "bin_q1_hold_d1"
    else:
        if rst_mode == 1 and D == 1:
            return "bin_rst_held_d1"
        if rst_mode == 2 and D == 1:
            return "bin_rst_pulse_d1"
        if prev_q == 1:
            return "bin_rst_clear_q1"
        return "bin_rst_held_d0"

def bin_jk_flip_flop(r):
    rst_mode = int(r.get("rst_mode", 0))
    q = int(r.get("state", r.get("prev_q", 0)))
    j = int(r.get("J", 0))
    k = int(r.get("K", 0))
    if rst_mode == 0:
        return f"q{q}_j{j}_k{k}"
    else:
        if rst_mode == 1 and j == 1 and k == 0:
            return "bin_rst_held_j1k0"
        if rst_mode == 2 and j == 1 and k == 1:
            return "bin_rst_pulse_j1k1"
        if q == 1:
            return "bin_rst_clear_q1"
        return "bin_rst_idle"

def bin_sr_flip_flop(r):
    rst_mode = int(r.get("rst_mode", 0))
    q_val = r.get("state", r.get("prev_q", 0))
    if str(q_val).lower() == "x" or str(q_val) == "2" or q_val == 2:
        q = "x"
    else:
        try:
            q = str(int(q_val))
        except (ValueError, TypeError):
            q = "0"
    s = int(r.get("S", 0))
    rr = int(r.get("R", 0))
    if rst_mode == 0:
        return f"q{q}_s{s}_r{rr}"
    else:
        if rst_mode == 1 and s == 1 and rr == 0:
            return "bin_rst_held_s1r0"
        if rst_mode == 2 and s == 1 and rr == 0:
            return "bin_rst_pulse_s1r0"
        if q == "1":
            return "bin_rst_clear_q1"
        if q == "x":
            return "bin_rst_clear_qx"
        return "bin_rst_idle"

def bin_t_flip_flop(r):
    rst_mode = int(r.get("rst_mode", 0))
    q = int(r.get("state", r.get("prev_q", 0)))
    t = int(r.get("T", 0))
    if rst_mode == 0:
        return f"q{q}_t{t}"
    else:
        if rst_mode == 1 and t == 1:
            return "bin_rst_held_t1"
        if rst_mode == 2 and t == 1:
            return "bin_rst_pulse_t1"
        if q == 1:
            return "bin_rst_clear_q1"
        return "bin_rst_idle"

def bin_pipo(r):
    rst_mode = int(r.get("rst_mode", 0))
    pin = int(r.get("parallel_in", 0))
    pout = int(r.get("state", r.get("prev_out", 0)))
    if rst_mode == 0:
        if pin == 0:
            return "bin_load_zero"
        if pin == 15:
            return "bin_load_ones"
        if pin in (5, 10):
            return "bin_load_alt"
        if pin in (1, 2, 4, 8):
            return "bin_load_onehot"
        if pin == pout:
            return "bin_hold_same"
        if pin == ((~pout) & 0xF):
            return "bin_all_flip"
        return "bin_load_other"
    else:
        if rst_mode == 1 and pin != 0:
            return "bin_rst_held_nonzero"
        if rst_mode == 2 and pin != 0:
            return "bin_rst_pulse_nonzero"
        if pout != 0:
            return "bin_rst_clear_nonzero"
        return "bin_rst_idle"

# ---------------------------------------------------------------------------
# Master Config Dictionary for all 17 DUTs (12 Combinational + 5 Sequential)
# ---------------------------------------------------------------------------

DUT_CONFIG = {
    # Combinational
    "mux_2to1": {
        "category": "combinational",
        "inputs": {"A": (0, 1), "B": (0, 1), "S": (0, 1)},
        "crv_budget": 20,
        "bin_fn": bin_mux_2to1,
        "numeric_target_fn": None,
        "all_bins": ["S0_val0", "S0_val1", "S1_val0", "S1_val1"]
    },
    "mux_4to2": {
        "category": "combinational",
        "inputs": {"I0": (0, 1), "I1": (0, 1), "I2": (0, 1), "I3": (0, 1), "S1": (0, 1), "S0": (0, 1)},
        "crv_budget": 30,
        "bin_fn": bin_mux_4to2,
        "numeric_target_fn": None,
        "all_bins": [f"S{s1}{s0}_I{s1*2+s0}_{v}" for s1 in (0,1) for s0 in (0,1) for v in (0,1)]
    },
    "full_adder": {
        "category": "combinational",
        "inputs": {"A": (0, 1), "B": (0, 1), "Cin": (0, 1)},
        "crv_budget": 20,
        "bin_fn": bin_full_adder,
        "numeric_target_fn": None,
        "all_bins": [f"A{a}_B{b}_Cin{c}" for a in (0,1) for b in (0,1) for c in (0,1)]
    },
    "adder_4bit": {
        "category": "combinational",
        "inputs": {"A": (0, 15), "B": (0, 15), "Cin": (0, 1)},
        "crv_budget": 60,
        "bin_fn": bin_adder_4bit,
        "numeric_target_fn": lambda r: int(r["A"]) + int(r["B"]) + int(r["Cin"]),
        "all_bins": ["sum_zero", "sum_max", "carry_gen", "carry_prop", "carry_kill", "no_carry"]
    },
    "adder_subtractor_4bit": {
        "category": "combinational",
        "inputs": {"A": (0, 15), "B": (0, 15), "sub": (0, 1)},
        "crv_budget": 60,
        "bin_fn": bin_adder_subtractor_4bit,
        "numeric_target_fn": lambda r: (int(r["A"]) + int(r["B"])) if int(r["sub"]) == 0 else (int(r["A"]) - int(r["B"])),
        "all_bins": ["add_zero", "add_max", "sub_zero", "sub_min_neg", "overflow_pos", "overflow_neg", "normal_add", "normal_sub"]
    },
    "comparator_2bit": {
        "category": "combinational",
        "inputs": {"A": (0, 3), "B": (0, 3)},
        "crv_budget": 25,
        "bin_fn": bin_comparator_2bit,
        "numeric_target_fn": None,
        "all_bins": ["gt", "eq", "lt"]
    },
    "comparator_4bit": {
        "category": "combinational",
        "inputs": {"A": (0, 15), "B": (0, 15)},
        "crv_budget": 40,
        "bin_fn": bin_comparator_4bit,
        "numeric_target_fn": lambda r: int(r["A"]) - int(r["B"]),
        "all_bins": ["eq_zero", "eq_max", "gt_max_min", "lt_min_max", "mid_gt", "mid_eq", "mid_lt"]
    },
    "decoder_2to4": {
        "category": "combinational",
        "inputs": {"enable": (0, 1), "in": (0, 3)},
        "crv_budget": 20,
        "bin_fn": bin_decoder_2to4,
        "numeric_target_fn": None,
        "all_bins": ["disabled", "en_out0", "en_out1", "en_out2", "en_out3"]
    },
    "priority_encoder_4to2": {
        "category": "combinational",
        "inputs": {"enable": (0, 1), "in": (0, 15)},
        "crv_budget": 25,
        "bin_fn": bin_priority_encoder_4to2,
        "numeric_target_fn": None,
        "all_bins": ["disabled", "none_active", "pri_0", "pri_1", "pri_2", "pri_3"]
    },
    "binary_to_gray_3bit": {
        "category": "combinational",
        "inputs": {"B": (0, 7)},
        "crv_budget": 20,
        "bin_fn": bin_binary_to_gray_3bit,
        "numeric_target_fn": None,
        "all_bins": [f"gray_{i}" for i in range(8)]
    },
    "barrel_shifter_8bit": {
        "category": "combinational",
        "inputs": {"data": (0, 255), "amt": (0, 7), "dir": (0, 1)},
        "crv_budget": 80,
        "bin_fn": bin_barrel_shifter_8bit,
        "numeric_target_fn": None,
        "all_bins": [f"dir_{d}_amt_{a}" for d in ("L", "R") for a in range(8)] + ["data_all_0", "data_all_1"]
    },
    "multiplier_4bit": {
        "category": "combinational",
        "inputs": {"A": (0, 15), "B": (0, 15)},
        "crv_budget": 40,
        "bin_fn": bin_multiplier_4bit,
        "numeric_target_fn": lambda r: int(r["A"]) * int(r["B"]),
        "all_bins": ["prod_zero", "prod_max", "prod_one", "prod_low", "prod_mid", "prod_high"]
    },

    # Sequential (5)
    "d_flip_flop": {
        "category": "sequential",
        "inputs": {"rst_mode": (0, 2), "D": (0, 1)},
        "state_signal": "state",
        "crv_budget": 100,
        "bin_fn": bin_d_flip_flop,
        "numeric_target_fn": None,
        "all_bins": [
            "bin_q0_hold_d0", "bin_q0_set_d1", "bin_q1_clear_d0", "bin_q1_hold_d1",
            "bin_rst_clear_q1", "bin_rst_held_d1", "bin_rst_pulse_d1", "bin_rst_held_d0"
        ]
    },
    "jk_flip_flop": {
        "category": "sequential",
        "inputs": {"rst_mode": (0, 2), "J": (0, 1), "K": (0, 1)},
        "state_signal": "state",
        "crv_budget": 100,
        "bin_fn": bin_jk_flip_flop,
        "numeric_target_fn": None,
        "all_bins": [
            f"q{q}_j{j}_k{k}" for q in (0, 1) for j in (0, 1) for k in (0, 1)
        ] + ["bin_rst_clear_q1", "bin_rst_held_j1k0", "bin_rst_pulse_j1k1", "bin_rst_idle"]
    },
    "sr_flip_flop": {
        "category": "sequential",
        "inputs": {"rst_mode": (0, 2), "S": (0, 1), "R": (0, 1)},
        "state_signal": "state",
        "crv_budget": 100,
        "bin_fn": bin_sr_flip_flop,
        "numeric_target_fn": None,
        "all_bins": [
            f"q{q}_s{s}_r{r}" for q in ("0", "1", "x") for s in (0, 1) for r in (0, 1)
        ] + ["bin_rst_clear_q1", "bin_rst_clear_qx", "bin_rst_held_s1r0", "bin_rst_pulse_s1r0", "bin_rst_idle"]
    },
    "t_flip_flop": {
        "category": "sequential",
        "inputs": {"rst_mode": (0, 2), "T": (0, 1)},
        "state_signal": "state",
        "crv_budget": 100,
        "bin_fn": bin_t_flip_flop,
        "numeric_target_fn": None,
        "all_bins": [
            "q0_t0", "q0_t1", "q1_t0", "q1_t1",
            "bin_rst_clear_q1", "bin_rst_held_t1", "bin_rst_pulse_t1", "bin_rst_idle"
        ]
    },
    "pipo": {
        "category": "sequential",
        "inputs": {"rst_mode": (0, 2), "parallel_in": (0, 15)},
        "state_signal": "state",
        "crv_budget": 200,
        "bin_fn": bin_pipo,
        "numeric_target_fn": lambda r: int(r.get("parallel_in", 0)),
        "all_bins": [
            "bin_load_zero", "bin_load_ones", "bin_load_alt", "bin_load_onehot", "bin_load_other",
            "bin_hold_same", "bin_all_flip", "bin_rst_clear_nonzero", "bin_rst_held_nonzero",
            "bin_rst_pulse_nonzero", "bin_rst_idle"
        ]
    }
}

