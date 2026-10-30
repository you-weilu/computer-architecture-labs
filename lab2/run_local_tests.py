#!/usr/bin/env python3
"""
CompEng 361 - Lab 2
Local Practice Mutation Runner (`run_local_tests.py`)

Validates `test_vectors.csv` and runs it in parallel against:
  1. Your own `ExecutionUnit` Verilog implementation
  2. Public Mutant A (`SRA_logical`)
  3. Public Mutant B (`ADD_sub`)
"""

import argparse
import os
import subprocess
import sys
import tempfile

from csv_to_tb import CSVValidationError, parse_and_validate_csv

PUBLIC_MUTANTS = [
    {"id": "Mutant A", "name": "SRA_logical", "module": "Public_Mutant_A"},
    {"id": "Mutant B", "name": "ADD_sub",     "module": "Public_Mutant_B"},
]


def build_local_mutation_tb(vectors) -> str:
    n_mut = len(PUBLIC_MUTANTS)
    lines = [
        "`timescale 1ns/1ps",
        "module local_mutation_tb;",
        "  reg  [31:0] opA, opB;",
        "  reg  [2:0]  func;",
        "  reg  [6:0]  auxFunc;",
        "  wire [31:0] student_out;",
        f"  wire [31:0] mutant_out [1:{n_mut}];",
        f"  reg  [{n_mut}:1] killed;",
        f"  integer killed_by_line [1:{n_mut}];",
        "  integer invalid_out_line;",
        "  integer m;",
        "",
        "  ExecutionUnit u_dut(",
        "    .out(student_out), .opA(opA), .opB(opB), .func(func), .auxFunc(auxFunc)",
        "  );",
    ]

    for idx, pm in enumerate(PUBLIC_MUTANTS, start=1):
        lines.append(
            f"  {pm['module']} u_pm{idx}("
            f".out(mutant_out[{idx}]), .opA(opA), .opB(opB), .func(func), .auxFunc(auxFunc));"
        )

    lines.extend([
        "",
        "  task run_vec(",
        "    input integer line_no,",
        "    input [2:0]   f,",
        "    input [6:0]   af,",
        "    input [31:0]  a,",
        "    input [31:0]  b",
        "  );",
        "    begin",
        "      func = f; auxFunc = af; opA = a; opB = b;",
        "      #5;",
        "      if ((^student_out === 1'bx) && (invalid_out_line == 0)) begin",
        "        invalid_out_line = line_no;",
        "      end",
        f"      for (m = 1; m <= {n_mut}; m = m + 1) begin",
        "        if (!killed[m] && (mutant_out[m] !== student_out)) begin",
        "          killed[m] = 1'b1;",
        "          killed_by_line[m] = line_no;",
        "        end",
        "      end",
        "    end",
        "  endtask",
        "",
        "  initial begin",
        f"    killed = {n_mut}'b0;",
        "    invalid_out_line = 0;",
        f"    for (m = 1; m <= {n_mut}; m = m + 1) killed_by_line[m] = 0;",
    ])

    for v in vectors:
        lines.append(
            f"    run_vec(32'd{v['line_num']}, 3'h{v['func']:x}, 7'h{v['auxFunc']:02x}, "
            f"32'h{v['opA']:08x}, 32'h{v['opB']:08x});"
        )

    lines.extend([
        '    $display("DUT_STATUS %0d", invalid_out_line);',
        f"    for (m = 1; m <= {n_mut}; m = m + 1) begin",
        '      $display("MUTANT %0d %0d %0d", m, killed[m], killed_by_line[m]);',
        "    end",
        "    $finish;",
        "  end",
        "endmodule",
    ])
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(
        description="Run test_vectors.csv against your ALU and the 2 public practice mutants."
    )
    parser.add_argument(
        "--alu", default="template_execute.v",
        help="Path to your Verilog ALU file (default: template_execute.v)"
    )
    parser.add_argument(
        "--vectors", default="test_vectors.csv",
        help="Path to your test_vectors.csv file (default: test_vectors.csv)"
    )
    parser.add_argument(
        "--mutants", default=os.path.join("public_mutants", "public_mutants.v"),
        help="Path to public mutants Verilog file (default: public_mutants/public_mutants.v)"
    )
    args = parser.parse_args()

    try:
        vectors = parse_and_validate_csv(args.vectors)
    except CSVValidationError as e:
        print(f"[ERROR] test_vectors.csv validation failed:\n  {e}", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(args.alu):
        print(f"[ERROR] ALU file not found: '{args.alu}'", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(args.mutants):
        print(f"[ERROR] Public mutants file not found: '{args.mutants}'", file=sys.stderr)
        sys.exit(1)

    tb_src = build_local_mutation_tb(vectors)

    with tempfile.TemporaryDirectory() as tmpdir:
        tb_path = os.path.join(tmpdir, "local_mutation_tb.v")
        sim_bin = os.path.join(tmpdir, "local_mutation_sim")

        with open(tb_path, "w", encoding="utf-8") as f:
            f.write(tb_src)

        comp = subprocess.run(
            ["iverilog", "-o", sim_bin, args.alu, args.mutants, tb_path],
            capture_output=True, text=True
        )
        if comp.returncode != 0:
            print(f"[FAIL] iverilog compilation error:\n{comp.stderr.strip()}", file=sys.stderr)
            sys.exit(1)

        sim = subprocess.run(["vvp", sim_bin], capture_output=True, text=True, timeout=15)
        if sim.returncode != 0:
            print(f"[FAIL] Simulation execution error:\n{sim.stderr.strip()}", file=sys.stderr)
            sys.exit(1)

    invalid_line = 0
    results = {}
    for line in sim.stdout.strip().splitlines():
        parts = line.strip().split()
        if len(parts) == 2 and parts[0] == "DUT_STATUS":
            invalid_line = int(parts[1])
        elif len(parts) == 4 and parts[0] == "MUTANT":
            m_idx = int(parts[1])
            is_killed = int(parts[2])
            line_no = int(parts[3])
            results[m_idx] = (bool(is_killed), line_no)

    alu_name = os.path.basename(args.alu)
    if invalid_line == 0:
        print(f"[PASS] All vectors match your own {alu_name}")
    else:
        print(f"[WARN] Your {alu_name} produced X/Z (uninitialized) output on vector at line {invalid_line}")

    killed_count = 0
    total_mutants = len(PUBLIC_MUTANTS)

    for idx, pm in enumerate(PUBLIC_MUTANTS, start=1):
        is_killed, line_no = results.get(idx, (False, 0))
        if is_killed:
            killed_count += 1
            print(f"[KILL] {pm['id']} ({pm['name']}) detected by vector on line {line_no}")
        else:
            print(f"[MISS] {pm['id']} ({pm['name']}) survived all vectors in {args.vectors}")

    pct = int(round((killed_count / total_mutants) * 100)) if total_mutants else 0
    print(f"Public Mutant Score: {killed_count}/{total_mutants} ({pct}%)")


if __name__ == "__main__":
    main()
