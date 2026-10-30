# CompEng 361 — Lab 2: RV32I ALU Datapath & Verification Test Suite

In this lab, you will design a synthesizable 32-bit RISC-V (`RV32I`) Arithmetic Logic Unit (`ExecutionUnit`) in Verilog and engineer a compact, high-coverage functional verification test suite (`test_vectors.csv`).

---

## Deliverables

You will submit two files:
1. **`template_execute.v`** (or your completed `ExecutionUnit` Verilog file)
2. **`test_vectors.csv`** (your functional verification stimulus suite)

---

## Part 1: Synthesizable RV32I ALU (`ExecutionUnit`)

Your `ExecutionUnit` module in `template_execute.v` must preserve the exact port interface below so that it integrates directly into your single-cycle processor in Lab 3:

```verilog
module ExecutionUnit(
    output [31:0] out,
    input  [31:0] opA,
    input  [31:0] opB,
    input  [2:0]  func,
    input  [6:0]  auxFunc
);
```

### Supported RV32I Operations

| Mnemonic | Category | `func` (`funct3`) | `auxFunc` (`funct7`) | Operation (`out`) |
| :--- | :--- | :---: | :---: | :--- |
| **`ADD`** | Arithmetic | `3'b000` (`0x0`) | `7'b0000000` (`0x00`) | `opA + opB` |
| **`SUB`** | Arithmetic | `3'b000` (`0x0`) | `7'b0100000` (`0x20`) | `opA - opB` |
| **`SLL`** | Shift | `3'b001` (`0x1`) | `7'b0000000` (`0x00`) | `opA << opB[4:0]` (zero-fill) |
| **`SLT`** | Comparison | `3'b010` (`0x2`) | `7'b0000000` (`0x00`) | `(signed(opA) < signed(opB)) ? 32'd1 : 32'd0` |
| **`SLTU`** | Comparison | `3'b011` (`0x3`) | `7'b0000000` (`0x00`) | `(unsigned(opA) < unsigned(opB)) ? 32'd1 : 32'd0` |
| **`XOR`** | Logical | `3'b100` (`0x4`) | `7'b0000000` (`0x00`) | `opA ^ opB` |
| **`SRL`** | Shift | `3'b101` (`0x5`) | `7'b0000000` (`0x00`) | `opA >> opB[4:0]` (logical zero-fill) |
| **`SRA`** | Shift | `3'b101` (`0x5`) | `7'b0100000` (`0x20`) | `signed(opA) >>> opB[4:0]` (sign-bit replication) |
| **`OR`** | Logical | `3'b110` (`0x6`) | `7'b0000000` (`0x00`) | `opA \| opB` |
| **`AND`** | Logical | `3'b111` (`0x7`) | `7'b0000000` (`0x00`) | `opA & opB` |

---

## Part 2: Verification Test Suite (`test_vectors.csv`)

In addition to your synthesizable ALU implementation, you will design and submit a targeted functional test suite named `test_vectors.csv`.

In professional digital verification, test quality is quantified by **fault coverage** (mutation testing)—the ability of a test suite to detect subtle, deliberate hardware bugs. Your submission will be graded automatically against a hidden suite of faulty ALU implementations ("mutants") containing common real-world design flaws (e.g., subtle signed comparison bugs, incorrect shift masking, overflow mishandling).

### 1. File Format Specification

The deliverable must be a standard, comma-delimited text file named exactly `test_vectors.csv`. Each non-empty line represents a single stimulus vector consisting of four fields:

```text
OPCODE, RS1_HEX, RS2_HEX, COMMENT
```

#### Field Definitions
* **`OPCODE` (String):** The exact RV32I ALU operation mnemonic (case-insensitive):
  * Arithmetic: `ADD`, `SUB`
  * Logical: `AND`, `OR`, `XOR`
  * Shifts: `SLL`, `SRL`, `SRA`
  * Comparisons: `SLT`, `SLTU`
* **`RS1_HEX` (32-bit Hexadecimal):** The value applied to the `opA` input. Must be an 8-character hexadecimal string, prefixed with `0x` or `0X` (e.g., `0x00000001`, `0x80000000`, `0xFFFFFFFF`).
* **`RS2_HEX` (32-bit Hexadecimal):** The value applied to the `opB` input. Same hexadecimal formatting rules as `RS1_HEX`.
* **`COMMENT` (String):** A brief, single-line explanation (at most 80 characters) describing the architectural pathology or corner case this vector targets. Commas are not permitted within the comment text.

#### Syntax & Whitespace Rules
* Lines beginning with `#` or `//` are treated as comments and ignored.
* Blank lines are ignored.
* Leading and trailing whitespace around commas is stripped automatically.

#### Example `test_vectors.csv`

```csv
# RV32I ALU Verification Suite
# OPCODE, RS1_HEX,    RS2_HEX,    COMMENT
ADD,      0x7FFFFFFF, 0x00000001, Positive overflow boundary check
SUB,      0x80000000, 0x00000001, Negative underflow boundary check
SLT,      0xFFFFFFFF, 0x00000001, Signed comparison across zero boundary (-1 < 1)
SLTU,     0xFFFFFFFF, 0x00000001, Unsigned comparison across zero boundary (4294967295 > 1)
SRA,      0x80000000, 0x00000004, Sign-bit replication on arithmetic shift right
SLL,      0x00000001, 0x00000020, Shift amount uses only lower 5 bits (shamt=32 wraps to 0)
```

### 2. Constraints and Limits

To emulate realistic verification budgets and reward high fault-coverage density rather than blind fuzzing, your submission must satisfy the following constraints:
1. **Maximum Vector Budget:** Your file may contain at most **128 active test vectors** (comment lines and blank lines do not count toward this limit).
2. **File Size Limit:** The file size must not exceed **32 KB**.
3. **Stand-Alone Stimulus:** You do **not** provide the expected output. Our evaluation harness will execute your stimulus vectors in parallel against our verified reference implementation and each mutant circuit:

```text
Discrepancy Detected  <==>  ALU_mutant(op, opA, opB) != ALU_golden(op, opA, opB)
```

A mutant is considered **killed** if your suite causes its output (`out`) to diverge from the golden reference on at least one vector.

### 3. Evaluation and Grading Breakdown

Your test suite grade is calculated as follows:

```text
Test Suite Score = (Mutants Killed / Total Viable Mutants) * 100%
```

* **Formatting Gate:** If `test_vectors.csv` fails to parse, contains invalid hex representations, exceeds 128 vectors, or specifies unsupported opcodes, the autograder will abort with an execution error, resulting in **0 points** for the test deliverable.
* **Trivial Mutants (40%):** Basic operational accuracy across all ten required RV32I instructions.
* **Boundary & Corner Cases (40%):** Subtraction near zero, signed vs. unsigned extreme values (`0x00000000`, `0x7FFFFFFF`, `0x80000000`, `0xFFFFFFFF`), and shift amounts with non-zero upper bits (`opB[31:5] != 0`).
* **Subtle Pathologies (20%):** Atypical corner cases designed to expose subtle structural and sign-extension shortcuts.

### 4. In-Person Checkoff (~3 Minutes)

During your scheduled lab checkoff, you must be prepared to discuss your test suite:
* The course staff will select one or two vectors from your `test_vectors.csv`.
* You will be asked to explain what specific hardware fault, sign-extension issue, or arithmetic edge case that vector is engineered to expose.
* Inability to explain the technical rationale behind your submitted vectors will result in a deduction from the verification portion of your lab grade.

---

## Running Your Testbench & Public Practice Mutants Locally

### 1. Simulating Your ALU (`make sim`)
The provided testbench (`lab2_tb.v`) automatically reads the vectors in `test_vectors.csv` using `csv_to_tb.py`:

```bash
# Validate test_vectors.csv, compile with iverilog, and run simulation + local mutant check
make

# Run waveform trace simulation only
make sim

# Validate test_vectors.csv formatting & constraints only
make check-csv

# Clean generated simulation files and waveforms
make clean
```

Running `make sim` also generates a waveform file `lab2.vcd` that you can inspect in GTKWave (`gtkwave lab2.vcd`).

### 2. Local Mutation Testing Practice (`make local-test`)
To help you practice the mutation testing workflow locally, we provide two sample faulty ALU implementations in `public_mutants/public_mutants.v`:
* **Mutant A (`SRA_logical`):** Treats arithmetic right shifts (`SRA`) as logical right shifts (`SRL`).
* **Mutant B (`ADD_sub`):** Subtracts (`opA - opB`) instead of adding on `ADD`.

Run `make local-test` (or `python3 run_local_tests.py`) to test your `test_vectors.csv` against your own ALU and these two public mutants:

```bash
make local-test
```

Example output once your ALU and vectors are working:

```text
[PASS] All vectors match your own template_execute.v
[KILL] Mutant A (SRA_logical) detected by vector on line 7
[KILL] Mutant B (ADD_sub) detected by vector on line 3
Public Mutant Score: 2/2 (100%)
```
