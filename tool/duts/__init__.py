"""
DUT Plugin Registry for AI-Assisted RTL Verification Framework.

Dynamically discovers and loads all DUT plugins in this directory.
Adding a new DUT requires only adding a single Python file defining:
  INPUTS = {col: (min, max)}
  DECODE_COLS = [...]
  bin_fn(row) -> str
  numeric_target_fn(row) -> num or None
  rtl_drive_fn(row) -> (inputs_dict, expected_dict)
  RTL_MODULE = "module_name"
  RTL_WIDTHS = {port: width}
  DEFAULT_RTL_PATH = "path/to/rtl.v"
"""

import importlib.util
from pathlib import Path
from typing import Dict, Any, List

_DUT_REGISTRY: Dict[str, Any] = {}

def load_all_duts() -> Dict[str, Any]:
    """
    Scans the duts directory and loads all valid DUT plugins.
    """
    global _DUT_REGISTRY
    duts_dir = Path(__file__).resolve().parent

    for file_path in duts_dir.glob("*.py"):
        if file_path.name.startswith("__"):
            continue
        stem = file_path.stem
        # Skip alias file comparator_2bit if 2bit_comparator is present
        if stem == "comparator_2bit":
            continue

        try:
            spec = importlib.util.spec_from_file_location(stem, file_path)
            if spec and spec.loader:
                mod = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(mod)

                dut_name = getattr(mod, "DUT_NAME", stem)
                # Check required fields
                if hasattr(mod, "INPUTS") and hasattr(mod, "bin_fn") and hasattr(mod, "rtl_drive_fn"):
                    _DUT_REGISTRY[dut_name] = mod
                    # Add common aliases
                    if dut_name == "2bit_comparator":
                        _DUT_REGISTRY["comparator_2bit"] = mod
                    elif dut_name == "comparator_2bit":
                        _DUT_REGISTRY["2bit_comparator"] = mod
                    elif dut_name == "mux_4to1":
                        _DUT_REGISTRY["mux_4to2"] = mod
        except Exception as e:
            print(f"Warning: Failed to load DUT plugin '{file_path.name}': {e}")

    return _DUT_REGISTRY

def get_dut(name: str):
    """
    Retrieve a registered DUT plugin by name.
    """
    if not _DUT_REGISTRY:
        load_all_duts()
    dut = _DUT_REGISTRY.get(name)
    if not dut:
        # Retry scan in case new file was added
        load_all_duts()
        dut = _DUT_REGISTRY.get(name)
    return dut

def list_registered_duts() -> List[Dict[str, Any]]:
    """
    Returns list of registered DUT metadata for the dashboard.
    """
    if not _DUT_REGISTRY:
        load_all_duts()

    duts_info = []
    seen = set()
    # Preferred order
    order = [
        "mux_2to1",
        "mux_4to1",
        "full_adder",
        "2bit_comparator",
        "binary_to_gray_3bit",
        "decoder_2to4",
        "demux_1to4",
        "adder_4bit",
    ]

    for name in order:
        if name in _DUT_REGISTRY:
            seen.add(name)
            mod = _DUT_REGISTRY[name]
            duts_info.append({
                "name": name,
                "description": getattr(mod, "DESCRIPTION", f"{name} verification plugin"),
                "inputs": getattr(mod, "INPUTS", {}),
                "has_numeric_target": getattr(mod, "numeric_target_fn", None) is not None,
                "rtl_module": getattr(mod, "RTL_MODULE", name),
            })

    for name, mod in _DUT_REGISTRY.items():
        if name not in seen and name not in ["comparator_2bit", "mux_4to2"]:
            duts_info.append({
                "name": name,
                "description": getattr(mod, "DESCRIPTION", f"{name} verification plugin"),
                "inputs": getattr(mod, "INPUTS", {}),
                "has_numeric_target": getattr(mod, "numeric_target_fn", None) is not None,
                "rtl_module": getattr(mod, "RTL_MODULE", name),
            })

    return duts_info

# Initialize registry at import time
load_all_duts()
