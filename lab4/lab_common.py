#!/usr/bin/env python3
"""
Shared Test Runner and Autograder Library for CompEng 361 (lab_common.py)
Single source of truth live at common/lab_common.py and copied into lab3/ and lab4_v2/.
Compatible with Python 3.6+ using only the Python standard library.
"""

import argparse
import csv
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from typing import Any, Dict, List, Optional, Tuple

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if not sys.path or sys.path[0] != SCRIPT_DIR:
    if SCRIPT_DIR in sys.path:
        sys.path.remove(SCRIPT_DIR)
    sys.path.insert(0, SCRIPT_DIR)

from tracediff import compare_traces

DEFAULT_LAB3_CONFIG: Dict[str, Any] = {
    "lab_name": "Lab 3",
    "tb_file": "lab3_tb.v",
    "dut_suffix": "_lab3.v",
    "template_file": "template_lab3.v",
    "solution_files": ["template_lab3.v", "solution_lab3.v", "basic_lab3.v"],
    "top_module": "SingleCycleCPU",
    "manifest_relpath": os.path.join("tests", "manifest"),
    "build_relpath": os.path.join("tests", "build"),
    "golden_relpath": os.path.join("tests", "golden"),
    "regs_in_file": "regs_in.hex",
    "vcd_file": "single.vcd",
    "tier_a_title": "Milestone A Tests (ALU, Loads/Stores, Branches, A-Tier Halts)",
}

DEFAULT_LAB4_CONFIG: Dict[str, Any] = {
    "lab_name": "Lab 4",
    "tb_file": "lab4_tb.v",
    "dut_suffix": "_lab4.v",
    "template_file": "template_lab4.v",
    "solution_files": ["template_lab4.v", "solution_lab4.v", "single_lab4.v"],
    "top_module": "PipelinedCPU",
    "manifest_relpath": os.path.join("tests", "manifest"),
    "build_relpath": os.path.join("tests", "build"),
    "golden_relpath": os.path.join("tests", "golden"),
    "regs_in_file": "regs_in.hex",
    "vcd_file": "pipeline.vcd",
    "tier_a_title": "Milestone A Tests (Straight-Line ALU, LUI/AUIPC, Loads/Stores, Halts)",
}

CANVAS_FILE_RE = re.compile(
    r"^(?P<student>[a-zA-Z0-9_-]+?)_(?:(?P<late>LATE)_)?(?P<canvas_id>\d+)_(?P<att_id>\d+)_(?P<orig>.+)$"
)

WILKINSON_IVERILOG_NEW_BIN = "/vol/eecs362/iverilog-new/bin"

REQUIRED_CSV_COLUMNS: List[str] = [
    "submission",
    "student_name",
    "canvas_id",
    "late",
    "compiled",
    "rule_flags",
    "tier_a_passed",
    "tier_a_total",
    "tier_a_pct",
    "tier_a_recovery_80_pct",
    "initial_tier_a_pct",
    "effective_tier_a_pct",
    "milestone_a_pts_25",
    "tier_b_passed",
    "tier_b_total",
    "tier_b_pct",
    "milestone_b_pts_55",
    "oral_checkoff_pts_20",
    "auto_score_80",
    "cumulative_passed",
    "cumulative_total",
    "cumulative_pct",
    "failed_public_tests",
    "hidden_failed_count",
]


def parse_manifest(manifest_path: str) -> List[Dict[str, str]]:
    entries: List[Dict[str, str]] = []
    with open(manifest_path, "r", encoding="utf-8") as f:
        for line_no, raw in enumerate(f, start=1):
            line = raw.split("#", 1)[0].strip()
            if not line:
                continue
            parts = line.split()
            if len(parts) < 3:
                raise ValueError(f"{manifest_path}:{line_no}: expected at least 3 columns, got: {raw!r}")
            name, tier, expected_end = parts[0], parts[1], parts[2]
            visibility = parts[3] if len(parts) >= 4 else "public"
            entries.append(
                {
                    "name": name,
                    "tier": tier,
                    "expected_end": expected_end,
                    "visibility": visibility,
                }
            )
    return entries


def strip_verilog_comments(src: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", src, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", "", text)
    return text


def check_structural_rules(verilog_path: str) -> List[str]:
    """
    Coarse static check for structural Verilog rules:
    - No `include
    - No `always` or `initial` procedural blocks
    - No `reg` declarations
    - No procedural `if` or `case` statements
    Returns a list of human-readable warning flags (empty list if clean).
    Never auto-fails a submission.
    """
    try:
        with open(verilog_path, "r", encoding="utf-8", errors="replace") as f:
            raw = f.read()
    except OSError as e:
        return [f"read_error:{e}"]

    code = strip_verilog_comments(raw)
    flags: List[str] = []

    if re.search(r"`include\b", code):
        flags.append("uses `include directive")
    if re.search(r"\b(always|always_comb|always_ff|always_latch)\b", code):
        flags.append("contains 'always' block")
    if re.search(r"\binitial\b", code):
        flags.append("contains 'initial' block")
    if re.search(r"\breg\b", code):
        flags.append("declares 'reg' type")
    if re.search(r"\bif\s*\(", code):
        flags.append("contains procedural 'if'")
    if re.search(r"\b(case|casez|casex)\s*\(", code):
        flags.append("contains procedural 'case'")

    return flags


def check_iverilog() -> None:
    iv_path = shutil.which("iverilog")
    if not iv_path and os.path.isfile(os.path.join(WILKINSON_IVERILOG_NEW_BIN, "iverilog")):
        os.environ["PATH"] = WILKINSON_IVERILOG_NEW_BIN + os.pathsep + os.environ.get("PATH", "")
        iv_path = shutil.which("iverilog")

    if not iv_path:
        print(
            "ERROR: 'iverilog' not found in PATH.\n"
            "On the Wilkinson machines (batman.eecs.northwestern.edu), add '/vol/eecs362/iverilog-new/bin'\n"
            "(Icarus Verilog 11.0) to your PATH (do NOT use '/vol/eecs362/iverilog/bin', which is version 0.10.0):\n"
            "  tcsh (default): setenv PATH /vol/eecs362/iverilog-new/bin:$PATH\n"
            "  bash:           export PATH=/vol/eecs362/iverilog-new/bin:$PATH",
            file=sys.stderr,
        )
        sys.exit(1)

    real_iv = os.path.realpath(iv_path)
    ver_res = subprocess.run(
        [iv_path, "-V"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )
    first_line = (ver_res.stdout or ver_res.stderr or "").splitlines()
    ver_str = first_line[0].strip() if first_line else "unknown version"
    m_ver = re.search(r"version\s+(\d+)\.(\d+)", ver_str)
    if not m_ver:
        print(
            f"WARNING: Could not parse Icarus Verilog version from '{ver_str}' ({iv_path}); continuing.",
            file=sys.stderr,
        )
        return

    major = int(m_ver.group(1))
    if major < 11 or real_iv.startswith("/vol/eecs362/iverilog/"):
        if os.path.isfile(os.path.join(WILKINSON_IVERILOG_NEW_BIN, "iverilog")) and not real_iv.startswith(
            WILKINSON_IVERILOG_NEW_BIN
        ):
            os.environ["PATH"] = WILKINSON_IVERILOG_NEW_BIN + os.pathsep + os.environ.get("PATH", "")
            return
        print(
            f"ERROR: Outdated or unsupported Icarus Verilog detected: {iv_path} ({ver_str}).\n"
            "Please use '/vol/eecs362/iverilog-new/bin' (Icarus Verilog 11.0) instead of '/vol/eecs362/iverilog/bin' (0.10.0):\n"
            "  tcsh (default): setenv PATH /vol/eecs362/iverilog-new/bin:$PATH\n"
            "  bash:           export PATH=/vol/eecs362/iverilog-new/bin:$PATH",
            file=sys.stderr,
        )
        sys.exit(1)


def run_suite(
    verilog_path: str,
    manifest_entries: List[Dict[str, str]],
    tb_path: str,
    build_dir: str,
    golden_dir: str,
    regs_in_path: str,
    wall_timeout: float = 30.0,
    max_cycles: int = 100000,
    half_period: int = 5,
) -> Dict[str, Any]:
    check_iverilog()
    rule_flags = check_structural_rules(verilog_path)

    with tempfile.TemporaryDirectory() as tmpdir:
        dut_copy = os.path.join(tmpdir, "submission_dut.v")
        shutil.copyfile(verilog_path, dut_copy)
        sim_bin = os.path.join(tmpdir, "sim_cpu")

        iverilog_cmd = [
            "iverilog",
            f"-Ptb.HALF_PERIOD={half_period}",
            f"-Ptb.MAX_CYCLES={max_cycles}",
            "-o",
            sim_bin,
            dut_copy,
            tb_path,
        ]
        comp = subprocess.run(
            iverilog_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
        )
        if comp.returncode != 0:
            total_a = sum(1 for e in manifest_entries if e["tier"] == "A")
            total_b = sum(1 for e in manifest_entries if e["tier"] == "B")
            total_all = len(manifest_entries)
            return {
                "file": verilog_path,
                "compiled": False,
                "compile_error": comp.stderr.strip() or comp.stdout.strip(),
                "rule_flags": rule_flags,
                "results": [],
                "summary": {
                    "tier_a_passed": 0,
                    "tier_a_total": total_a,
                    "tier_a_pct": 0.0,
                    "tier_b_passed": 0,
                    "tier_b_total": total_b,
                    "tier_b_pct": 0.0,
                    "cumulative_passed": 0,
                    "cumulative_total": total_all,
                    "cumulative_pct": 0.0,
                },
            }

        results: List[Dict[str, Any]] = []
        for entry in manifest_entries:
            tname = entry["name"]
            tier = entry["tier"]
            vis = entry["visibility"]
            hex_path = os.path.join(build_dir, f"{tname}.hex")
            golden_path = os.path.join(golden_dir, f"{tname}.trace")
            trace_out = os.path.join(tmpdir, f"{tname}_trace.txt")
            regs_out = os.path.join(tmpdir, f"{tname}_regs.hex")
            mem_out = os.path.join(tmpdir, f"{tname}_mem.hex")

            sim_cmd = [
                sim_bin,
                f"+MEM_IN={hex_path}",
                f"+REGS_IN={regs_in_path}",
                f"+TRACE_OUT={trace_out}",
                f"+REGS_OUT={regs_out}",
                f"+MEM_OUT={mem_out}",
                f"+MAX_CYCLES={max_cycles}",
                "+NO_VCD=1",
            ]
            passed = False
            msg = ""
            for attempt in range(2):
                if os.path.exists(trace_out):
                    os.remove(trace_out)
                try:
                    sim = subprocess.run(
                        sim_cmd,
                        cwd=tmpdir,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        universal_newlines=True,
                        timeout=wall_timeout,
                    )
                    if sim.returncode != 0:
                        err_detail = sim.stderr.strip() or sim.stdout.strip()
                        passed = False
                        msg = f"Simulator exited with non-zero code ({sim.returncode}): {err_detail}"
                    else:
                        passed, msg = compare_traces(trace_out, golden_path)
                    break
                except subprocess.TimeoutExpired:
                    if attempt == 0:
                        continue
                    passed = False
                    msg = f"Simulation hung (exceeded {wall_timeout:.1f}s wall-clock timeout)"
                except Exception as e:
                    passed = False
                    msg = f"Simulation crash: {e}"
                    break

            results.append(
                {
                    "name": tname,
                    "tier": tier,
                    "visibility": vis,
                    "passed": passed,
                    "message": msg,
                }
            )

    tier_a_res = [r for r in results if r["tier"] == "A"]
    tier_b_res = [r for r in results if r["tier"] == "B"]

    a_pass = sum(1 for r in tier_a_res if r["passed"])
    a_tot = len(tier_a_res)
    b_pass = sum(1 for r in tier_b_res if r["passed"])
    b_tot = len(tier_b_res)
    all_pass = a_pass + b_pass
    all_tot = a_tot + b_tot

    summary = {
        "tier_a_passed": a_pass,
        "tier_a_total": a_tot,
        "tier_a_pct": round((a_pass / a_tot * 100.0) if a_tot else 0.0, 2),
        "tier_b_passed": b_pass,
        "tier_b_total": b_tot,
        "tier_b_pct": round((b_pass / b_tot * 100.0) if b_tot else 0.0, 2),
        "cumulative_passed": all_pass,
        "cumulative_total": all_tot,
        "cumulative_pct": round((all_pass / all_tot * 100.0) if all_tot else 0.0, 2),
    }

    return {
        "file": verilog_path,
        "compiled": True,
        "compile_error": None,
        "rule_flags": rule_flags,
        "results": results,
        "summary": summary,
    }


def format_report(report: Dict[str, Any], tier_a_title: Optional[str] = None) -> str:
    lines: List[str] = []
    lines.append("=" * 72)
    lines.append(f"Submission: {report['file']}")
    if report["rule_flags"]:
        lines.append(f"Rule Check: WARNING - {', '.join(report['rule_flags'])} (flagged for review)")
    else:
        lines.append("Rule Check: OK (pure structural Verilog)")
    lines.append("=" * 72)

    if not report["compiled"]:
        lines.append("[COMPILE FAIL] iverilog failed to compile submission:")
        lines.append(report["compile_error"] or "Unknown compilation error")
        return "\n".join(lines)

    a_title = tier_a_title or "Milestone A Tests (ALU, Loads/Stores, Branches, A-Tier Halts)"
    for tier_label, tier_title in [
        ("A", a_title),
        ("B", "Milestone B Tests (LUI/AUIPC, Jumps, Fetch-Align Halts, C Programs)"),
    ]:
        t_res = [r for r in report["results"] if r["tier"] == tier_label]
        if not t_res:
            continue
        lines.append(f"\n--- {tier_title} ---")
        for r in t_res:
            status = "PASS" if r["passed"] else "FAIL"
            if r["passed"]:
                lines.append(f"  [{status}] {r['name']:24s} : {r['message']}")
            else:
                lines.append(f"  [{status}] {r['name']:24s}")
                for mline in r["message"].splitlines():
                    lines.append(f"         {mline}")

    s = report["summary"]
    lines.append("\n" + "-" * 72)
    lines.append(
        f"Milestone A tests:               {s['tier_a_passed']:2d} / {s['tier_a_total']:2d} "
        f"({s['tier_a_pct']:.1f}%)"
    )
    if s["tier_b_total"] > 0:
        lines.append(
            f"Milestone B tests (B tier only): {s['tier_b_passed']:2d} / {s['tier_b_total']:2d} "
            f"({s['tier_b_pct']:.1f}%)"
        )
        lines.append(
            f"Cumulative (A+B, informational): {s['cumulative_passed']:2d} / {s['cumulative_total']:2d} "
            f"({s['cumulative_pct']:.1f}%)"
        )
    lines.append("-" * 72)
    return "\n".join(lines)


def autodetect_cpu_file(lab_dir: str, cfg: Optional[Dict[str, Any]] = None) -> str:
    if cfg is None:
        cfg = DEFAULT_LAB3_CONFIG
    suffix = cfg["dut_suffix"]
    tpl_name = cfg["template_file"]
    excluded = set(cfg.get("solution_files", [tpl_name]))
    candidates = sorted(glob.glob(os.path.join(lab_dir, f"*{suffix}")))
    custom = [c for c in candidates if os.path.basename(c) not in excluded]
    if len(custom) == 1:
        return custom[0]
    default_tpl = os.path.join(lab_dir, tpl_name)
    if os.path.exists(default_tpl):
        return default_tpl
    if candidates:
        return candidates[0]
    return tpl_name


def run_student_cli(cfg: Dict[str, Any], lab_dir: str) -> None:
    parser = argparse.ArgumentParser(
        description=f"Compile and run your {cfg['lab_name']} {cfg['top_module']} against the golden trace test suite."
    )
    parser.add_argument(
        "cpu_file",
        nargs="?",
        default=None,
        help=f"Path to your Verilog file (e.g., group1{cfg['dut_suffix']}; defaults to auto-detected *{cfg['dut_suffix']})",
    )
    parser.add_argument(
        "--tier",
        choices=["A", "B", "all"],
        default="all",
        help="Run only Milestone A tests (--tier A), Milestone B tests (--tier B), or all tests (default: all)",
    )
    parser.add_argument(
        "--test",
        help="Run a single named test (e.g., --test add) and write trace.txt to the current directory",
    )
    parser.add_argument(
        "--keep",
        action="store_true",
        help=f"When running with --test, keep trace.txt and {cfg['vcd_file']} in the current directory",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=30.0,
        help="Wall-clock timeout in seconds per test (default: 30.0)",
    )
    args = parser.parse_args()

    check_iverilog()

    cpu_file = args.cpu_file or autodetect_cpu_file(lab_dir, cfg)
    if not os.path.exists(cpu_file):
        print(f"ERROR: Verilog file '{cpu_file}' not found.", file=sys.stderr)
        print(f"Usage: python3 run_tests.py <your_group{cfg['dut_suffix']}>", file=sys.stderr)
        sys.exit(1)

    manifest_path = os.path.join(lab_dir, cfg["manifest_relpath"])
    tb_path = os.path.join(lab_dir, cfg["tb_file"])
    build_dir = os.path.join(lab_dir, cfg["build_relpath"])
    golden_dir = os.path.join(lab_dir, cfg["golden_relpath"])
    regs_in_path = os.path.join(lab_dir, cfg["regs_in_file"])

    entries = [e for e in parse_manifest(manifest_path) if e["visibility"] == "public"]

    if args.test:
        matched = [e for e in entries if e["name"] == args.test]
        if not matched:
            print(f"ERROR: Unknown test '{args.test}'. Available tests:", file=sys.stderr)
            print("  " + ", ".join(e["name"] for e in entries), file=sys.stderr)
            sys.exit(1)
        entries = matched
    elif args.tier == "A":
        entries = [e for e in entries if e["tier"] == "A"]
    elif args.tier == "B":
        entries = [e for e in entries if e["tier"] == "B"]

    report = run_suite(
        cpu_file,
        entries,
        tb_path,
        build_dir,
        golden_dir,
        regs_in_path,
        wall_timeout=args.timeout,
    )

    if args.test and report["compiled"]:
        tname = args.test
        hex_path = os.path.join(build_dir, f"{tname}.hex")
        golden_path = os.path.join(golden_dir, f"{tname}.trace")
        sim_bin = os.path.join(lab_dir, "single_test_sim")
        comp = subprocess.run(
            ["iverilog", "-o", sim_bin, cpu_file, tb_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
        )
        if comp.returncode == 0:
            try:
                for attempt in range(2):
                    try:
                        subprocess.run(
                            [
                                sim_bin,
                                f"+MEM_IN={hex_path}",
                                f"+REGS_IN={regs_in_path}",
                                "+TRACE_OUT=trace.txt",
                            ],
                            timeout=args.timeout,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                        )
                        break
                    except subprocess.TimeoutExpired:
                        if attempt == 0:
                            continue
            finally:
                if os.path.exists(sim_bin):
                    os.remove(sim_bin)
        print(format_report(report, tier_a_title=cfg.get("tier_a_title")))
        print(f"\nWrote 'trace.txt' and '{cfg['vcd_file']}' for test '{tname}'.")
        print(f"To inspect the diff directly:\n  python3 tracediff.py trace.txt {golden_path}")
    else:
        print(format_report(report, tier_a_title=cfg.get("tier_a_title")))

    s = report.get("summary", {})
    if args.tier == "A":
        ok = report["compiled"] and (s.get("tier_a_passed") == s.get("tier_a_total"))
    elif args.tier == "B":
        ok = report["compiled"] and (s.get("tier_b_passed") == s.get("tier_b_total"))
    else:
        ok = report["compiled"] and (s.get("cumulative_passed") == s.get("cumulative_total"))
    sys.exit(0 if ok else 1)


def grade_submission(
    verilog_path: str,
    manifest_entries: List[Dict[str, str]],
    tb_path: str,
    build_dir: str,
    golden_dir: str,
    regs_in_path: str,
    wall_timeout: float = 30.0,
    max_cycles: int = 100000,
    half_period: int = 5,
) -> Dict[str, Any]:
    """Compile and grade a single Verilog submission across manifest_entries."""
    if not os.path.exists(verilog_path):
        return {
            "file": verilog_path,
            "compiled": False,
            "compile_error": f"File not found: '{verilog_path}'",
            "rule_flags": ["file_not_found"],
            "results": [],
            "summary": {},
        }

    rep = run_suite(
        verilog_path=verilog_path,
        manifest_entries=manifest_entries,
        tb_path=tb_path,
        build_dir=build_dir,
        golden_dir=golden_dir,
        regs_in_path=regs_in_path,
        wall_timeout=wall_timeout,
        max_cycles=max_cycles,
        half_period=half_period,
    )
    s = rep.get("summary", {})
    a_pct = float(s.get("tier_a_pct", 0.0))
    b_pct = float(s.get("tier_b_pct", 0.0))
    a_rec80_pct = round(0.80 * a_pct, 2)
    ma_pts = round(0.25 * a_pct, 2)
    mb_pts = round(0.55 * b_pct, 2)

    s["tier_a_recovery_80_pct"] = a_rec80_pct
    s["effective_tier_a_pct"] = a_pct
    s["milestone_a_pts_25"] = ma_pts
    s["milestone_b_pts_55"] = mb_pts
    s["auto_score_80"] = round(ma_pts + mb_pts, 2)
    return rep


def format_grade_report(report: Dict[str, Any], show_hidden_label: bool = True) -> str:
    """
    Format human-readable grading report for stdout and TA/Canvas text files.
    IMPORTANT: Hidden test names are NEVER printed here; only public test names
    are shown, and hidden results are summarized by count.
    """
    lines: List[str] = []
    lines.append("=" * 72)
    lines.append(f"Submission: {report['file']}")
    if report["rule_flags"]:
        lines.append(f"Rule Check: WARNING - {', '.join(report['rule_flags'])} (flagged for review)")
    else:
        lines.append("Rule Check: OK (pure structural Verilog)")
    lines.append("=" * 72)

    if not report["compiled"]:
        lines.append("[COMPILE FAIL] iverilog failed to compile submission:")
        lines.append(report["compile_error"] or "Unknown compilation error")
        return "\n".join(lines)

    for tier_label, tier_title in [
        ("A", "Milestone A Tests (ALU, Loads/Stores, Branches, A-Tier Halts)"),
        ("B", "Milestone B Tests (LUI/AUIPC, Jumps, Fetch-Align Halts, C Programs)"),
    ]:
        t_res = [r for r in report["results"] if r["tier"] == tier_label]
        if not t_res:
            continue
        lines.append(f"\n--- {tier_title} ---")
        pub_res = [r for r in t_res if r.get("visibility") != "hidden"]
        hid_res = [r for r in t_res if r.get("visibility") == "hidden"]
        for r in pub_res:
            status = "PASS" if r["passed"] else "FAIL"
            if r["passed"]:
                lines.append(f"  [{status}] {r['name']:24s} : {r['message']}")
            else:
                lines.append(f"  [{status}] {r['name']:24s}")
                for mline in r["message"].splitlines():
                    lines.append(f"         {mline}")
        if hid_res and show_hidden_label:
            h_pass = sum(1 for r in hid_res if r["passed"])
            h_tot = len(hid_res)
            h_fail = h_tot - h_pass
            lines.append(
                f"  [HIDDEN] {h_pass} / {h_tot} hidden Milestone {tier_label} tests passed ({h_fail} failed)"
            )

    s = report["summary"]
    lines.append("\n" + "-" * 72)
    lines.append(
        f"Milestone A tests:               {s['tier_a_passed']:2d} / {s['tier_a_total']:2d} "
        f"({s['tier_a_pct']:.1f}%)"
    )
    lines.append(
        f"Milestone A 80% Recovery Cap:    {s.get('tier_a_recovery_80_pct', 0.0):.1f}% "
        f"(or M_A + 0.80 * max(0, {s['tier_a_pct']:.1f}% - M_A))"
    )
    if "initial_tier_a_pct" in s:
        lines.append(
            f"Effective Milestone A (w/80%):   {s['effective_tier_a_pct']:.2f}% "
            f"(initial M_A: {s.get('initial_tier_a_pct', 0.0):.2f}%)"
        )
    lines.append(
        f"Milestone B tests (B tier only): {s['tier_b_passed']:2d} / {s['tier_b_total']:2d} "
        f"({s['tier_b_pct']:.1f}%)"
    )
    lines.append(
        f"Cumulative (A+B, informational): {s['cumulative_passed']:2d} / {s['cumulative_total']:2d} "
        f"({s['cumulative_pct']:.1f}%)"
    )
    lines.append(
        f"Weighted Auto Score (A 25 + B 55): {s.get('auto_score_80', 0.0):.2f} / 80.00 "
        f"(A: {s.get('milestone_a_pts_25', 0.0):.2f}/25, B: {s.get('milestone_b_pts_55', 0.0):.2f}/55, +20 oral)"
    )
    lines.append("-" * 72)
    return "\n".join(lines)


def write_csv(reports: List[Dict[str, Any]], csv_path: str) -> None:
    fieldnames = list(REQUIRED_CSV_COLUMNS)
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for rep in reports:
            s = rep.get("summary", {})
            results = rep.get("results", [])
            failed_pub = [
                r["name"] for r in results if not r["passed"] and r.get("visibility") != "hidden"
            ]
            hidden_fail_cnt = sum(
                1 for r in results if not r["passed"] and r.get("visibility") == "hidden"
            )
            writer.writerow(
                {
                    "submission": os.path.basename(rep["file"]),
                    "student_name": rep.get("student_name", ""),
                    "canvas_id": rep.get("canvas_id", ""),
                    "late": rep.get("late", False),
                    "compiled": rep["compiled"],
                    "rule_flags": "; ".join(rep["rule_flags"]) if rep["rule_flags"] else "OK",
                    "tier_a_passed": s.get("tier_a_passed", 0),
                    "tier_a_total": s.get("tier_a_total", 0),
                    "tier_a_pct": s.get("tier_a_pct", 0.0),
                    "tier_a_recovery_80_pct": s.get("tier_a_recovery_80_pct", 0.0),
                    "initial_tier_a_pct": s.get("initial_tier_a_pct", ""),
                    "effective_tier_a_pct": s.get("effective_tier_a_pct", s.get("tier_a_pct", 0.0)),
                    "milestone_a_pts_25": s.get("milestone_a_pts_25", 0.0),
                    "tier_b_passed": s.get("tier_b_passed", 0),
                    "tier_b_total": s.get("tier_b_total", 0),
                    "tier_b_pct": s.get("tier_b_pct", 0.0),
                    "milestone_b_pts_55": s.get("milestone_b_pts_55", 0.0),
                    "oral_checkoff_pts_20": "",
                    "auto_score_80": s.get("auto_score_80", 0.0),
                    "cumulative_passed": s.get("cumulative_passed", 0),
                    "cumulative_total": s.get("cumulative_total", 0),
                    "cumulative_pct": s.get("cumulative_pct", 0.0),
                    "failed_public_tests": " ".join(failed_pub) if rep["compiled"] else "COMPILE_FAIL",
                    "hidden_failed_count": hidden_fail_cnt if rep["compiled"] else "COMPILE_FAIL",
                }
            )


def discover_canvas_submissions(canvas_input: str, work_dir: str) -> List[Dict[str, Any]]:
    """Extract and discover student .v files from a Canvas bulk download zip or directory."""
    extract_dir = os.path.join(work_dir, "canvas_extracted")
    os.makedirs(extract_dir, exist_ok=True)

    if os.path.isfile(canvas_input) and zipfile.is_zipfile(canvas_input):
        with zipfile.ZipFile(canvas_input, "r") as zf:
            zf.extractall(extract_dir)
        scan_root = extract_dir
    elif os.path.isdir(canvas_input):
        scan_root = canvas_input
    else:
        raise ValueError(f"Invalid --canvas argument: {canvas_input}")

    by_student: Dict[str, Dict[str, Any]] = {}
    for entry in sorted(os.listdir(scan_root)):
        full_path = os.path.join(scan_root, entry)
        if not os.path.isfile(full_path):
            continue
        m = CANVAS_FILE_RE.match(entry)
        if m:
            student = m.group("student")
            canvas_id = m.group("canvas_id")
            att_id = int(m.group("att_id"))
            late = bool(m.group("late"))
            orig = m.group("orig")
        else:
            if not entry.lower().endswith(".v"):
                continue
            student = os.path.splitext(entry)[0]
            canvas_id = ""
            att_id = 0
            late = False
            orig = entry

        if not orig.lower().endswith(".v"):
            continue

        key = f"{student}_{canvas_id}"
        if key not in by_student or att_id >= by_student[key]["att_id"]:
            by_student[key] = {
                "student_name": student,
                "canvas_id": canvas_id,
                "att_id": att_id,
                "late": late,
                "path": full_path,
            }

    return list(by_student.values())


def apply_recovery_bounds(cur_a: float, cur_b: float, init_a: Optional[float]) -> Tuple[float, float, float, float]:
    """
    Percentage-based fallback recovery:
    Compute (effective_tier_a_pct, milestone_a_pts_25, milestone_b_pts_55, auto_score_80).
    When init_a is provided, effective_tier_a_pct = init_a + 0.80 * max(0.0, cur_a - init_a),
    clamped and verified to lie within [init_a, 100.0].
    Note: Lateness never affects any score in grade.py.
    """
    if init_a is not None:
        init_clamped = max(0.0, min(100.0, float(init_a)))
        raw_eff = init_clamped + 0.80 * max(0.0, float(cur_a) - init_clamped)
        eff_a = round(min(100.0, max(init_clamped, raw_eff)), 2)
        assert eff_a >= round(init_clamped, 2) - 1e-9 and eff_a <= 100.0 + 1e-9, (
            f"effective_tier_a_pct ({eff_a}) violated bounds [{init_clamped}, 100.0]"
        )
    else:
        eff_a = round(max(0.0, min(100.0, float(cur_a))), 2)
        assert 0.0 <= eff_a <= 100.0, f"effective_tier_a_pct ({eff_a}) violated bounds [0.0, 100.0]"

    ma_pts = round(0.25 * eff_a, 2)
    mb_pts = round(0.55 * float(cur_b), 2)
    auto_80 = round(ma_pts + mb_pts, 2)
    return eff_a, ma_pts, mb_pts, auto_80


def apply_per_test_recovery(
    tier_a_results: List[Dict[str, Any]],
    cur_b_pct: float,
    init_a_test_map: Dict[str, bool],
) -> Dict[str, Any]:
    """
    Per-test Milestone A recovery:
    - Each A-tier test that passed at the A deadline earns full weight (1.0),
      even if it later fails at the B deadline.
    - Each A-tier test that failed at the A deadline and passes at the B deadline
      earns 0.80 weight.
    - All A-tier tests (public and hidden) have equal weight.
    Returns dict with:
      initial_tier_a_passed, initial_tier_a_pct, recovered_a_count, regressed_a_count,
      effective_a_units, effective_tier_a_pct, milestone_a_pts_25, milestone_b_pts_55, auto_score_80.
    """
    n_a = len(tier_a_results)
    if n_a == 0:
        eff_a, ma_pts, mb_pts, auto_80 = apply_recovery_bounds(0.0, cur_b_pct, 0.0)
        return {
            "initial_tier_a_passed": 0,
            "initial_tier_a_pct": 0.0,
            "recovered_a_count": 0,
            "regressed_a_count": 0,
            "effective_a_units": 0.0,
            "effective_tier_a_pct": eff_a,
            "milestone_a_pts_25": ma_pts,
            "milestone_b_pts_55": mb_pts,
            "auto_score_80": auto_80,
        }

    init_passed = 0
    recovered_count = 0
    regressed_count = 0

    for r in tier_a_results:
        tname = r["name"]
        passed_a = bool(init_a_test_map.get(tname, False))
        passed_b = bool(r["passed"])
        if passed_a:
            init_passed += 1
            if not passed_b:
                regressed_count += 1
        else:
            if passed_b:
                recovered_count += 1

    eff_units = round(float(init_passed) + 0.80 * float(recovered_count), 4)
    init_pct = round((float(init_passed) / float(n_a)) * 100.0, 2)
    raw_eff_pct = (eff_units / float(n_a)) * 100.0
    eff_a = round(min(100.0, max(init_pct, raw_eff_pct)), 2)
    assert eff_a >= init_pct - 1e-9 and eff_a <= 100.0 + 1e-9, (
        f"effective_tier_a_pct ({eff_a}) violated bounds [{init_pct}, 100.0]"
    )

    ma_pts = round(0.25 * eff_a, 2)
    mb_pts = round(0.55 * float(cur_b_pct), 2)
    auto_80 = round(ma_pts + mb_pts, 2)
    return {
        "initial_tier_a_passed": init_passed,
        "initial_tier_a_pct": init_pct,
        "recovered_a_count": recovered_count,
        "regressed_a_count": regressed_count,
        "effective_a_units": eff_units,
        "effective_tier_a_pct": eff_a,
        "milestone_a_pts_25": ma_pts,
        "milestone_b_pts_55": mb_pts,
        "auto_score_80": auto_80,
    }


def ensure_instructor_only_json_path(path: str) -> str:
    """Ensure any JSON file containing per-test (including hidden) results is named *_instructor_only.json."""
    if path.endswith("_instructor_only.json"):
        return path
    if path.lower().endswith(".json"):
        return path[:-5] + "_instructor_only.json"
    return path + "_instructor_only.json"


def save_instructor_json(reports: List[Dict[str, Any]], json_path: str) -> str:
    out_path = ensure_instructor_only_json_path(json_path)
    out_dir = os.path.dirname(os.path.abspath(out_path))
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as jf:
        json.dump(reports, jf, indent=2)
    return out_path


def load_milestone_a_json(json_path: str) -> Tuple[Dict[str, Dict[str, bool]], Dict[str, float]]:
    """
    Load per-test Milestone A results from an *_instructor_only.json file saved at the A deadline.
    Returns (per_test_lookup, pct_lookup) keyed by canvas_id, student_name, and submission basename.
    """
    per_test_lookup: Dict[str, Dict[str, bool]] = {}
    pct_lookup: Dict[str, float] = {}
    if not json_path or not os.path.exists(json_path):
        return per_test_lookup, pct_lookup

    with open(json_path, "r", encoding="utf-8") as jf:
        data = json.load(jf)

    records = data if isinstance(data, list) else data.get("reports", [])
    for rec in records:
        res_list = rec.get("results", [])
        test_map: Dict[str, bool] = {}
        for r in res_list:
            if r.get("tier", "A") == "A":
                test_map[r["name"]] = bool(r.get("passed", False))
        if not test_map and isinstance(rec.get("tier_a_tests"), dict):
            test_map = {k: bool(v) for k, v in rec["tier_a_tests"].items()}

        s = rec.get("summary", {})
        init_pct = float(s.get("tier_a_pct", rec.get("tier_a_pct", 0.0)))

        keys = [
            str(rec.get("canvas_id", "")).strip(),
            str(rec.get("student_name", "")).strip(),
            os.path.basename(str(rec.get("file", rec.get("submission", "")))).strip(),
        ]
        for k in keys:
            if k:
                if test_map:
                    per_test_lookup[k] = test_map
                pct_lookup[k] = init_pct

    return per_test_lookup, pct_lookup


def run_grade_cli(cfg: Dict[str, Any], lab_dir: str) -> None:
    parser = argparse.ArgumentParser(description=f"CompEng 361 {cfg['lab_name']} Autograder")
    parser.add_argument("submissions", nargs="*", help="Verilog submission file(s) to grade")
    parser.add_argument(
        "--canvas",
        help="Path to Canvas submissions.zip or directory for bulk grading",
    )
    parser.add_argument(
        "--out-dir",
        default="grading_results",
        help="Output directory for --canvas mode (default: grading_results)",
    )
    parser.add_argument(
        "--csv",
        help="Write summary grades to CSV file",
    )
    parser.add_argument(
        "--json",
        help="Write detailed instructor-only grading results to JSON file (*_instructor_only.json)",
    )
    parser.add_argument(
        "--save-a-json",
        help="Save Milestone A per-test results to an instructor-only JSON file (*_instructor_only.json)",
    )
    parser.add_argument(
        "--milestone-a-json",
        help="Load Milestone A per-test results from *_instructor_only.json for per-test 80%% recovery",
    )
    parser.add_argument(
        "--public-only",
        action="store_true",
        help="Run only student-visible (public) tests",
    )
    parser.add_argument(
        "--tier",
        choices=["A", "B", "all"],
        default="all",
        help="Filter tests by tier (default: all)",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=30.0,
        help="Wall-clock timeout in seconds per test (default: 30.0)",
    )
    parser.add_argument(
        "--max-cycles",
        type=int,
        default=100000,
        help="Maximum simulated clock cycles per test (default: 100000)",
    )
    parser.add_argument(
        "--half-period",
        type=int,
        default=5,
        help="Clock half-period in simulation time units (default: 5)",
    )
    parser.add_argument(
        "--milestone-a-csv",
        help="Optional Milestone A grades CSV fallback for percentage-based 80%% recovery",
    )
    parser.add_argument(
        "--milestone-a-pct",
        type=float,
        default=None,
        help="Optional initial Milestone A percentage (0..100) fallback for percentage-based 80%% recovery",
    )
    args = parser.parse_args()

    ma_test_lookup, ma_json_pct_lookup = load_milestone_a_json(args.milestone_a_json or "")

    ma_lookup_pct: Dict[str, float] = dict(ma_json_pct_lookup)
    if args.milestone_a_csv and os.path.exists(args.milestone_a_csv):
        with open(args.milestone_a_csv, "r", encoding="utf-8") as mf:
            for row in csv.DictReader(mf):
                val = float(row.get("tier_a_pct") or 0.0)
                if row.get("canvas_id"):
                    ma_lookup_pct[row["canvas_id"]] = val
                if row.get("student_name"):
                    ma_lookup_pct[row["student_name"]] = val
                if row.get("submission"):
                    ma_lookup_pct[row["submission"]] = val

    def apply_recovery(rep: Dict[str, Any]) -> None:
        s = rep.get("summary", {})
        cur_a = float(s.get("tier_a_pct", 0.0))
        cur_b = float(s.get("tier_b_pct", 0.0))
        candidate_keys = [
            str(rep.get("canvas_id", "")).strip(),
            str(rep.get("student_name", "")).strip(),
            os.path.basename(str(rep.get("file", ""))).strip(),
        ]

        # 1. Prefer per-test recovery if per-test Milestone A data is available for this student/group
        matched_test_map: Optional[Dict[str, bool]] = None
        for k in candidate_keys:
            if k and k in ma_test_lookup:
                matched_test_map = ma_test_lookup[k]
                break

        tier_a_results = [r for r in rep.get("results", []) if r.get("tier") == "A"]
        if matched_test_map is not None and tier_a_results:
            rec_info = apply_per_test_recovery(tier_a_results, cur_b, matched_test_map)
            s.update(rec_info)
            return

        # 2. Fallback to percentage-based recovery (--milestone-a-pct or --milestone-a-csv)
        init_a: Optional[float] = args.milestone_a_pct
        if init_a is None and ma_lookup_pct:
            for k in candidate_keys:
                if k and k in ma_lookup_pct:
                    init_a = ma_lookup_pct[k]
                    break
        eff_a, ma_pts, mb_pts, auto_80 = apply_recovery_bounds(cur_a, cur_b, init_a)
        if init_a is not None:
            s["initial_tier_a_pct"] = round(float(init_a), 2)
        s["effective_tier_a_pct"] = eff_a
        s["milestone_a_pts_25"] = ma_pts
        s["milestone_b_pts_55"] = mb_pts
        s["auto_score_80"] = auto_80

    manifest_path = os.path.join(lab_dir, cfg["manifest_relpath"])
    tb_path = os.path.join(lab_dir, cfg["tb_file"])
    build_dir = os.path.join(lab_dir, cfg["build_relpath"])
    golden_dir = os.path.join(lab_dir, cfg["golden_relpath"])
    regs_in_path = os.path.join(lab_dir, cfg["regs_in_file"])

    entries = parse_manifest(manifest_path)
    if args.public_only:
        entries = [e for e in entries if e["visibility"] == "public"]
    if args.tier == "A":
        entries = [e for e in entries if e["tier"] == "A"]
    elif args.tier == "B":
        entries = [e for e in entries if e["tier"] == "B"]

    reports: List[Dict[str, Any]] = []

    if args.canvas:
        os.makedirs(args.out_dir, exist_ok=True)
        reports_dir = os.path.join(args.out_dir, "reports")
        os.makedirs(reports_dir, exist_ok=True)
        with tempfile.TemporaryDirectory() as work_dir:
            subs = discover_canvas_submissions(args.canvas, work_dir)
            for sub in subs:
                rep = grade_submission(
                    sub["path"],
                    entries,
                    tb_path,
                    build_dir,
                    golden_dir,
                    regs_in_path,
                    wall_timeout=args.timeout,
                    max_cycles=args.max_cycles,
                    half_period=args.half_period,
                )
                rep["student_name"] = sub["student_name"]
                rep["canvas_id"] = sub["canvas_id"]
                rep["late"] = sub["late"]
                apply_recovery(rep)
                reports.append(rep)
                txt = format_grade_report(rep)
                print(txt)
                slug = f"{sub['student_name']}_{sub['canvas_id']}".strip("_")
                with open(os.path.join(reports_dir, f"{slug}_report.txt"), "w", encoding="utf-8") as rf:
                    rf.write(txt + "\n")

        csv_out = args.csv or os.path.join(args.out_dir, "canvas_grades.csv")
        write_csv(reports, csv_out)
        print(f"\nCanvas CSV written to: {csv_out}")
        inst_json = os.path.join(args.out_dir, "grading_instructor_only.json")
        save_instructor_json(reports, inst_json)
    else:
        if not args.submissions:
            parser.error("Provide at least one Verilog submission file or use --canvas.")
        for sub_path in args.submissions:
            rep = grade_submission(
                sub_path,
                entries,
                tb_path,
                build_dir,
                golden_dir,
                regs_in_path,
                wall_timeout=args.timeout,
                max_cycles=args.max_cycles,
                half_period=args.half_period,
            )
            bname = os.path.basename(sub_path)
            m = CANVAS_FILE_RE.match(bname)
            if m:
                rep["student_name"] = m.group("student")
                rep["canvas_id"] = m.group("canvas_id")
                rep["late"] = bool(m.group("late"))
            else:
                rep["student_name"] = os.path.splitext(bname)[0]
                rep["canvas_id"] = ""
                rep["late"] = False
            apply_recovery(rep)
            reports.append(rep)
            print(format_grade_report(rep, show_hidden_label=not args.public_only))

        if args.csv:
            write_csv(reports, args.csv)
            print(f"\nGrades CSV written to: {args.csv}")

    if args.save_a_json:
        saved_path = save_instructor_json(reports, args.save_a_json)
        print(f"\nInstructor-only Milestone A JSON written to: {saved_path}")

    if args.json:
        saved_path = save_instructor_json(reports, args.json)
        print(f"\nInstructor-only JSON written to: {saved_path}")

    all_passed = all(
        r["compiled"] and r["summary"].get("cumulative_passed") == r["summary"].get("cumulative_total")
        for r in reports
    )
    sys.exit(0 if all_passed else 1)
