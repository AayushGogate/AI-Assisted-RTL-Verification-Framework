"""
Alias for 2bit_comparator
"""
from . import dut_loader

# Re-export from 2bit_comparator if imported directly
try:
    from .duts import *
except Exception:
    pass
