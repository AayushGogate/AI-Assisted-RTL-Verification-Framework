"""
DUT Coverage Analysis Tool - Main Entry Point.
Directs execution to tool/app.py and serves on http://127.0.0.1:5000.
"""

import sys
from pathlib import Path

# Add tool directory to sys.path
tool_dir = Path(__file__).resolve().parent / "tool"
sys.path.insert(0, str(tool_dir))

from tool.app import app

if __name__ == "__main__":
    print("==================================================================")
    print("  DUT COVERAGE ANALYSIS TOOL (Local Web Dashboard)")
    print("  Serving at: http://127.0.0.1:5000")
    print("  Press Ctrl+C to stop.")
    print("==================================================================")
    app.run(host="127.0.0.1", port=5000, debug=False)
