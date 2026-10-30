#!/usr/bin/env python3
"""
CompEng 361 - Lab 2
CSV Test Vector Validator & Testbench Stimulus Generator (`csv_to_tb.py`)

Validates `test_vectors.csv` against the Lab 2 formatting & constraint rules
and generates a Verilog header (`tb_stimulus.vh`) included by `lab2_tb.v`.
"""

import argparse
import os
import re
import sys

MAX_FILE_SIZE_BYTES = 32 * 1024  # 32 KB
MAX_VECTORS = 128
MAX_COMMENT_LEN = 80

OPCODE_MAP = {
    "ADD":  (0x0, 0x00),
    "SUB":  (0x0, 0x20),
    "SLL":  (0x1, 0x00),
    "SLT":  (0x2, 0x00),
    "SLTU": (0x3, 0x00),
    "XOR":  (0x4, 0x00),
    "SRL":  (0x5, 0x00),
    "SRA":  (0x5, 0x20),
    "OR":   (0x6, 0x00),
    "AND":  (0x7, 0x00),
}

HEX32_RE = re.compile(r"^0[xX][0-9a-fA-F]{8}$")


class CSVValidationError(Exception):
    pass


def parse_and_validate_csv(filepath: str):
    if not os.path.exists(filepath):
        raise CSVValidationError(f"File not found: '{filepath}'")

    if not os.path.isfile(filepath):
        raise CSVValidationError(f"Not a regular file: '{filepath}'")

    file_size = os.path.getsize(filepath)
    if file_size > MAX_FILE_SIZE_BYTES:
        raise CSVValidationError(
            f"File size ({file_size} bytes) exceeds the 32 KB ({MAX_FILE_SIZE_BYTES} bytes) limit."
        )

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            raw_lines = f.readlines()
    except UnicodeDecodeError as e:
        raise CSVValidationError(f"File is not valid UTF-8/ASCII text: {e}")

    vectors = []

    for line_num, raw_line in enumerate(raw_lines, start=1):
        stripped = raw_line.strip()
        if not stripped or stripped.startswith("#") or stripped.startswith("//"):
            continue

        parts = [p.strip() for p in stripped.split(",")]
        if len(parts) < 4:
            raise CSVValidationError(
                f"Line {line_num}: Expected 4 comma-separated fields "
                f"(OPCODE, RS1_HEX, RS2_HEX, COMMENT), found {len(parts)}: '{stripped}'"
            )
        if len(parts) > 4:
            raise CSVValidationError(
                f"Line {line_num}: Found {len(parts)} comma-separated fields (expected 4). "
                f"Commas are not permitted inside COMMENT: '{stripped}'"
            )

        opcode_raw, rs1_raw, rs2_raw, comment = parts
        opcode = opcode_raw.upper()

        if opcode not in OPCODE_MAP:
            valid_ops = ", ".join(sorted(OPCODE_MAP.keys()))
            raise CSVValidationError(
                f"Line {line_num}: Unsupported OPCODE '{opcode_raw}'. "
                f"Must be one of: {valid_ops}"
            )

        if not HEX32_RE.match(rs1_raw):
            raise CSVValidationError(
                f"Line {line_num}: Invalid RS1_HEX '{rs1_raw}'. "
                f"Must be an 8-character hexadecimal string prefixed with 0x or 0X (e.g., 0x00000001)."
            )

        if not HEX32_RE.match(rs2_raw):
            raise CSVValidationError(
                f"Line {line_num}: Invalid RS2_HEX '{rs2_raw}'. "
                f"Must be an 8-character hexadecimal string prefixed with 0x or 0X (e.g., 0x00000001)."
            )

        if not comment:
            raise CSVValidationError(f"Line {line_num}: COMMENT field must not be empty.")

        if len(comment) > MAX_COMMENT_LEN:
            raise CSVValidationError(
                f"Line {line_num}: COMMENT length ({len(comment)} chars) exceeds "
                f"the {MAX_COMMENT_LEN}-character limit."
            )

        func, aux_func = OPCODE_MAP[opcode]
        op_a = int(rs1_raw, 16)
        op_b = int(rs2_raw, 16)

        vectors.append({
            "vec_index": len(vectors) + 1,
            "line_num": line_num,
            "opcode": opcode,
            "func": func,
            "auxFunc": aux_func,
            "opA": op_a,
            "opB": op_b,
            "comment": comment,
        })

    if len(vectors) == 0:
        raise CSVValidationError("File contains 0 active test vectors (at least 1 required).")

    if len(vectors) > MAX_VECTORS:
        raise CSVValidationError(
            f"File contains {len(vectors)} active test vectors, exceeding the maximum budget of {MAX_VECTORS}."
        )

    return vectors


def generate_verilog_stimulus(vectors, output_path: str):
    lines = [
        "// Auto-generated from test_vectors.csv by csv_to_tb.py -- DO NOT EDIT MANUALLY",
    ]
    for v in vectors:
        safe_comment = v["comment"].replace('"', "'").replace("\\", "/")
        op_padded = f"{v['opcode']:<4s}"
        lines.append(
            f'doExecute(32\'d{v["vec_index"]}, "{op_padded}", '
            f'3\'h{v["func"]:x}, 7\'h{v["auxFunc"]:02x}, '
            f'32\'h{v["opA"]:08x}, 32\'h{v["opB"]:08x}); // Line {v["line_num"]}: {safe_comment}'
        )

    with open(output_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main():
    parser = argparse.ArgumentParser(
        description="Validate test_vectors.csv and generate Verilog stimulus for lab2_tb.v"
    )
    parser.add_argument(
        "-i", "--input", default="test_vectors.csv",
        help="Path to input CSV file (default: test_vectors.csv)"
    )
    parser.add_argument(
        "-o", "--output", default="tb_stimulus.vh",
        help="Path to generated Verilog include file (default: tb_stimulus.vh)"
    )
    parser.add_argument(
        "--check", action="store_true",
        help="Validate CSV format and constraints only without generating Verilog output"
    )
    args = parser.parse_args()

    try:
        vectors = parse_and_validate_csv(args.input)
    except CSVValidationError as e:
        if not args.check and os.path.exists(args.output):
            os.remove(args.output)
        print(f"[ERROR] test_vectors.csv validation failed:\n  {e}", file=sys.stderr)
        sys.exit(1)

    file_size = os.path.getsize(args.input)
    print(
        f"[OK] Validated '{args.input}': {len(vectors)}/{MAX_VECTORS} active vectors "
        f"({file_size}/{MAX_FILE_SIZE_BYTES} bytes)"
    )

    if not args.check:
        generate_verilog_stimulus(vectors, args.output)
        print(f"[OK] Generated Verilog testbench stimulus: '{args.output}'")


if __name__ == "__main__":
    main()
