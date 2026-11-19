#!/usr/bin/env python3
"""
Student One-Command Test Runner for CompEng 361 Lab 4 (run_tests.py)

Usage:
    python3 run_tests.py <your_group_lab4.v>
    python3 run_tests.py <your_group_lab4.v> --tier A
    python3 run_tests.py <your_group_lab4.v> --test alu_dist_rs1

Compiles your PipelinedCPU with lab4_tb.v, runs the public test suite,
compares each trace against the golden reference trace, and reports
Milestone A and Milestone B results with first-divergence diagnostics.
"""

import os
import sys
from typing import Any, Dict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
LAB_DIR = SCRIPT_DIR if os.path.isdir(os.path.join(SCRIPT_DIR, "tests")) else os.path.dirname(SCRIPT_DIR)
if not sys.path or sys.path[0] != SCRIPT_DIR:
    if SCRIPT_DIR in sys.path:
        sys.path.remove(SCRIPT_DIR)
    sys.path.insert(0, SCRIPT_DIR)

from lab_common import (
    DEFAULT_LAB4_CONFIG,
    autodetect_cpu_file as _autodetect_cpu_file,
    check_iverilog,
    check_structural_rules,
    format_report,
    parse_manifest,
    run_student_cli,
    run_suite,
)

LAB_CONFIG: Dict[str, Any] = dict(DEFAULT_LAB4_CONFIG)


def autodetect_cpu_file() -> str:
    return _autodetect_cpu_file(LAB_DIR, LAB_CONFIG)


def main() -> None:
    run_student_cli(LAB_CONFIG, LAB_DIR)


if __name__ == "__main__":
    main()
