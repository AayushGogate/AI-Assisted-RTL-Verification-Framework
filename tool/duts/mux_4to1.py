"""
DUT Plugin: 4-to-1 Multiplexer
"""

DUT_NAME = "mux_4to1"
DESCRIPTION = "4-to-1 Multiplexer (6 inputs, 64 possible vectors, 8 coverage bins)"
INPUTS = {
    "I0": (0, 1),
    "I1": (0, 1),
    "I2": (0, 1),
    "I3": (0, 1),
    "S1": (0, 1),
    "S0": (0, 1),
}
DECODE_COLS = []

def bin_fn(row):
    s1 = int(row["S1"])
    s0 = int(row["S0"])
    idx = s1 * 2 + s0
    val = int(row[f"I{idx}"])
    return f"S1{s1}_S0{s0}_val{val}"

numeric_target_fn = None

def rtl_drive_fn(row):
    sig = {f"I{i}": int(row[f"I{i}"]) for i in range(4)}
    sig.update({"S1": int(row["S1"]), "S0": int(row["S0"])})
    idx = int(row["S1"]) * 2 + int(row["S0"])
    chosen = sig[f"I{idx}"]
    return (sig, {"Y": chosen})

RTL_MODULE = "mux_4to1"
RTL_WIDTHS = {"I0": 1, "I1": 1, "I2": 1, "I3": 1, "S1": 1, "S0": 1, "Y": 1}
DEFAULT_RTL_PATH = "bundled_rtl/mux_4to1.v"
