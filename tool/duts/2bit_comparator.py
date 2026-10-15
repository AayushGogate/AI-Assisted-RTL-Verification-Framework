"""
DUT Plugin: 2-bit Comparator
"""

DUT_NAME = "2bit_comparator"
DESCRIPTION = "2-bit Magnitude Comparator (2 inputs, 16 possible vectors, 3 coverage bins)"
INPUTS = {"A": (0, 3), "B": (0, 3)}
DECODE_COLS = []

def bin_fn(row):
    a = int(row["A"])
    b = int(row["B"])
    if a > b:
        return "gt"
    if a == b:
        return "eq"
    return "lt"

numeric_target_fn = None

def rtl_drive_fn(row):
    a = int(row["A"])
    b = int(row["B"])
    a1, a0 = (a >> 1) & 1, a & 1
    b1, b0 = (b >> 1) & 1, b & 1
    return (
        {"A1": a1, "A0": a0, "B1": b1, "B0": b0},
        {
            "A_greater_B": int(a > b),
            "A_equal_B": int(a == b),
            "A_less_B": int(a < b),
        },
    )

RTL_MODULE = "comparator_2bit"
RTL_WIDTHS = {
    "A1": 1,
    "A0": 1,
    "B1": 1,
    "B0": 1,
    "A_greater_B": 1,
    "A_equal_B": 1,
    "A_less_B": 1,
}
DEFAULT_RTL_PATH = "bundled_rtl/comparator_2bit.v"
