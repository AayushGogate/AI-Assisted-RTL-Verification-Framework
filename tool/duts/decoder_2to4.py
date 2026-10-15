"""
DUT Plugin: 2-to-4 Decoder
"""

DUT_NAME = "decoder_2to4"
DESCRIPTION = "2-to-4 Decoder with Enable (8 possible vectors, 5 coverage bins)"
INPUTS = {"enable": (0, 1), "in": (0, 3)}
DECODE_COLS = ["in"]

def bin_fn(row):
    if int(row["enable"]) == 0:
        return "disabled"
    return f"en_sel{int(row['in'])}"

numeric_target_fn = None

def rtl_drive_fn(row):
    enable = int(row["enable"])
    inp = int(row["in"])
    out = (1 << inp) if enable else 0
    return ({"enable": enable, "in": inp}, {"out": out})

RTL_MODULE = "decoder_2to4"
RTL_WIDTHS = {"enable": 1, "in": 2, "out": 4}
DEFAULT_RTL_PATH = "bundled_rtl/decoder_2to4.v"
