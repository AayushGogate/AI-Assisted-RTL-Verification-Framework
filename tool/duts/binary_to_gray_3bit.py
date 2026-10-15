"""
DUT Plugin: 3-bit Binary to Gray Code Converter
"""

DUT_NAME = "binary_to_gray_3bit"
DESCRIPTION = "3-bit Binary to Gray Code Converter (8 possible vectors, 8 coverage bins)"
INPUTS = {"B": (0, 7)}
DECODE_COLS = ["B"]

def bin_fn(row):
    return f"B{int(row['B'])}"

numeric_target_fn = None

def rtl_drive_fn(row):
    b = int(row["B"])
    g2 = (b >> 2) & 1
    g1 = ((b >> 1) & 1) ^ g2
    g0 = (b & 1) ^ ((b >> 1) & 1)
    return ({"B": b}, {"G": (g2 << 2) | (g1 << 1) | g0})

RTL_MODULE = "binary_to_gray_3bit"
RTL_WIDTHS = {"B": 3, "G": 3}
DEFAULT_RTL_PATH = "bundled_rtl/binary_to_gray_3bit.v"
