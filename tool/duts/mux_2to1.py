"""
DUT Plugin: 2-to-1 Multiplexer
"""

DUT_NAME = "mux_2to1"
DESCRIPTION = "2-to-1 Multiplexer (3 inputs, 8 possible vectors, 4 coverage bins)"
INPUTS = {"A": (0, 1), "B": (0, 1), "S": (0, 1)}
DECODE_COLS = []

def bin_fn(row):
    s = int(row["S"])
    val = int(row["A"]) if s == 0 else int(row["B"])
    return f"S{s}_val{val}"

numeric_target_fn = None

def rtl_drive_fn(row):
    a = int(row["A"])
    b = int(row["B"])
    s = int(row["S"])
    expected_out = a if s == 0 else b
    return ({"A": a, "B": b, "S": s}, {"X": expected_out})

RTL_MODULE = "mux2to1"
RTL_WIDTHS = {"A": 1, "B": 1, "S": 1, "X": 1}
DEFAULT_RTL_PATH = "bundled_rtl/mux_2to1.v"
