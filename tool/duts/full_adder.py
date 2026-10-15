"""
DUT Plugin: 1-bit Full Adder
"""

DUT_NAME = "full_adder"
DESCRIPTION = "1-bit Full Adder (3 inputs, 8 possible vectors, 8 coverage bins)"
INPUTS = {"A": (0, 1), "B": (0, 1), "Cin": (0, 1)}
DECODE_COLS = []

def bin_fn(row):
    return f"A{int(row['A'])}_B{int(row['B'])}_Cin{int(row['Cin'])}"

numeric_target_fn = None

def rtl_drive_fn(row):
    a = int(row["A"])
    b = int(row["B"])
    cin = int(row["Cin"])
    s = a + b + cin
    return ({"A": a, "B": b, "Cin": cin}, {"S": s & 1, "Cout": (s >> 1) & 1})

RTL_MODULE = "full_adder"
RTL_WIDTHS = {"A": 1, "B": 1, "Cin": 1, "S": 1, "Cout": 1}
DEFAULT_RTL_PATH = "bundled_rtl/full_adder.v"
