"""
DUT Plugin: 1-to-4 Demultiplexer
"""

DUT_NAME = "demux_1to4"
DESCRIPTION = "1-to-4 Demultiplexer (8 possible vectors, 5 coverage bins)"
INPUTS = {"in": (0, 1), "sel": (0, 3)}
DECODE_COLS = ["sel"]

def bin_fn(row):
    if int(row["in"]) == 0:
        return "in0"
    return f"in1_sel{int(row['sel'])}"

numeric_target_fn = None

def rtl_drive_fn(row):
    inp = int(row["in"])
    sel = int(row["sel"])
    out = (1 << sel) if inp else 0
    return ({"in": inp, "sel": sel}, {"out": out})

RTL_MODULE = "demux_1to4"
RTL_WIDTHS = {"in": 1, "sel": 2, "out": 4}
DEFAULT_RTL_PATH = "bundled_rtl/demux_1to4.v"
