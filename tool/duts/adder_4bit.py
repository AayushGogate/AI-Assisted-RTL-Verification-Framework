"""
DUT Plugin: 4-bit Adder with Regressor Fallback
"""

DUT_NAME = "adder_4bit"
DESCRIPTION = "4-bit Adder (9 inputs, 512 possible vectors, 6 coverage bins, demonstrates numeric regressor fallback)"
INPUTS = {"A": (0, 15), "B": (0, 15), "Cin": (0, 1)}
DECODE_COLS = []

def bin_fn(row):
    s = int(row["A"]) + int(row["B"]) + int(row["Cin"])
    cout = 1 if s >= 16 else 0
    cin = int(row["Cin"])
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

def numeric_target_fn(row):
    return int(row["A"]) + int(row["B"]) + int(row["Cin"])

# Target information for regressor fallback extrapolation
NUMERIC_BIN_TARGETS = {
    "sum_zero": {"direction": "min", "target_val": 0},
    "sum_max": {"direction": "max", "target_val": 31},
}

def rtl_drive_fn(row):
    a = int(row["A"])
    b = int(row["B"])
    cin = int(row["Cin"])
    s = a + b + cin
    return (
        {"A": a, "B": b, "Cin": cin},
        {"S": s & 0xF, "Cout": (s >> 4) & 1},
    )

RTL_MODULE = "adder_4bit"
RTL_WIDTHS = {"A": 4, "B": 4, "Cin": 1, "S": 4, "Cout": 1}
DEFAULT_RTL_PATH = "bundled_rtl/adder_4bit.v"
