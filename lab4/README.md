# CompEng 361 — Lab 4: Five-Stage Pipelined RV32I Processor

## 1. Overview & Rules

In Lab 4, you will design and verify a **five-stage pipelined 32-bit RISC-V (`RV32I`) processor (`IF`, `ID`, `EX`, `MEM`, `WB`) in structural Verilog**, built from your Lab 3 single-cycle design:
- **Single file submission:** Name your file `<group>_lab4.v` (starting from `template_lab4.v`).
- **Structural Verilog only:** Use only continuous `assign` statements and module instantiations (`Mem`, `RegFile`, `Reg`, `D`, `PipeReg`, `Retire`, and your own combinational/structural submodules). Do **not** use `always`, `initial`, `reg`, procedural `if`/`case` blocks, or `` `include `` directives.
- **Unmodified library interfaces:** Do not change the module names or port lists of `PipelinedCPU`, `Mem`, `RegFile`, `Reg`, `D`, `PipeReg`, or `Retire` in `lab4_tb.v`. See `LIBRARY_REFERENCE.md` for complete port tables, pipeline register (`PipeReg`) and retirement (`Retire`) specifications, `RegFile` internal bypass behavior, clocking rules, and testbench plusargs.
- **Milestone A & Milestone B:** Currently, **only Milestone A tests (`61` public straight-line tests) are included** in `tests/`. Milestone B tests and CPI performance thresholds will be released later on Canvas (see Canvas for milestone deadlines).

---

## 2. Quick Start (One-Command Workflow)

### Wilkinson Environment `PATH` Setup (`batman.eecs.northwestern.edu`)

On the Wilkinson machines (`batman.eecs.northwestern.edu`), add `/vol/eecs362/iverilog-new/bin` (Icarus Verilog 11.0) to your `PATH` (do **not** use `/vol/eecs362/iverilog/bin`, which is the old `0.10.0` version):

```tcsh
# tcsh (default login shell on Wilkinson; add to ~/.cshrc to make permanent):
setenv PATH /vol/eecs362/iverilog-new/bin:$PATH
rehash

# bash (add to ~/.bashrc to make permanent):
export PATH=/vol/eecs362/iverilog-new/bin:$PATH

# Confirm version 11.0+:
iverilog -V
```

Look at the first line of `iverilog -V` output, which must say version 11 or newer (`Icarus Verilog version 11.0 ...`), and ignore any `"Unable to get version from ..."` lines that may follow.

### Day-One Baseline Check (Compile & Run `template_lab4.v` on `nop_empty`)

Before modifying `template_lab4.v`, verify that your environment compiles `template_lab4.v` with `lab4_tb.v`, simulates the `nop_empty` program, and compares `trace.txt` against the golden trace:

```bash
cp tests/build/nop_empty.hex mem_in.hex
iverilog -o pipeline template_lab4.v lab4_tb.v
vvp pipeline
python3 tracediff.py trace.txt tests/golden/nop_empty.trace
```

### Running the Public Test Suite (`run_tests.py`)

Run the public Milestone A test suite against your processor with a single command:

```bash
python3 run_tests.py <group>_lab4.v
```

Or using `make`:

```bash
make test CPU=<group>_lab4.v
```

At the end of the run, `run_tests.py` prints your Milestone A public test summary:

```text
------------------------------------------------------------------------
Milestone A tests:               61 / 61 (100.0%)
------------------------------------------------------------------------
```

When run on the starter `template_lab4.v`, `run_tests.py` passes `3 / 61` (`nop_empty` and the two position-0 halt tests `halt_illegal_pos0` and `halt_ecall_pos0_behind_alu_two`) and prints `tracediff.py` diagnostics on the remaining 58 Milestone A tests.

### Useful Filtering & Timeout Options

```bash
# Run only Milestone A tests (see Canvas for milestone deadlines):
python3 run_tests.py <group>_lab4.v --tier A

# Run a single test (also writes trace.txt and pipeline.vcd in the current directory):
python3 run_tests.py <group>_lab4.v --test alu_fwd_rs1

# Compare any generated trace.txt against a golden trace directly:
python3 tracediff.py trace.txt tests/golden/alu_fwd_rs1.trace

# Override the per-test wall-clock timeout (default is 30 seconds, with 1x auto-retry):
python3 run_tests.py <group>_lab4.v --timeout 60
```

### Manual Compilation & Simulation with Plusargs

You can also compile and run any test image directly with `iverilog` and `vvp`:

```bash
iverilog -o pipeline <group>_lab4.v lab4_tb.v
vvp pipeline +MEM_IN=tests/build/alu_fwd_rs1.hex +REGS_IN=regs_in.hex
python3 tracediff.py trace.txt tests/golden/alu_fwd_rs1.trace
```

### Writing & Assembling Your Own Test Programs (`rv32asm.py`)

You can write your own RV32I assembly test programs (`.s` files) and assemble them directly into `mem_in.hex` with `rv32asm.py` (no external cross-compiler required). See `ASSEMBLER_GUIDE.md` for step-by-step examples of designing custom tests and verifying results in `regs_out.hex`, `mem_out.hex`, and `trace.txt`:

```bash
# Assemble my_test.s -> mem_in.hex (with optional -l listing):
python3 rv32asm.py my_test.s -o mem_in.hex -l

# Simulate your CPU on mem_in.hex:
iverilog -o pipeline <group>_lab4.v lab4_tb.v
vvp pipeline
```

---

## 3. Pipeline Architecture & Milestone A Scope

### Five-Stage Pipeline & Library Primitives
1. **Required top-level & instance names:**
   - Top module: `module PipelinedCPU(halt, clk, rst);`
   - Unified 16 KiB memory (`0x0000`–`0x3fff`): `Mem MEM (...)` (code is located below `0x2000`; data loads/stores use `0x2000`–`0x3ffc`; programs never store into the instruction region).
   - Register file: `RegFile RF (...)` — **includes an internal same-cycle `WB -> ID` write bypass** (`DataOutA` / `DataOutB` return `DataInW` when `WenW === 1'b1` and `AddrW` matches a non-zero read register). You do **not** need to build external `WB -> ID` forwarding logic. Because of this combinational path inside `RegFile`, a Lab 3 single-cycle CPU cannot run against `lab4_tb.v`.
   - Retirement observer: `Retire RETIRE (.Valid(wb_valid), .PC(wb_pc))` driven from your **WB** stage.
   - State elements (`Reg`, `D`, `PipeReg`): All state elements update on the **falling clock edge (`negedge CLK`)** with nonblocking assignments.
2. **Critical Pipeline Rules:**
   - **`MEM` and `WB` never stall:** `EX/MEM` and `MEM/WB` must never be held (`WE = 1'b1`). Do **not** freeze the entire pipeline on a load-use hazard; `lab4_tb.v` pairs each cycle's `MEM`-stage data-port snapshot with the instruction retiring in `WB` on the next cycle.
   - **Load-use hazard interlock (1-cycle stall):** When an instruction in `EX` is a load (`lw`, `lh`, `lhu`, `lb`, `lbu`) with destination `ex_rd != 0` and the instruction in `ID` reads `ex_rd` in `EX`, hold `PC` (`stall_if = 1`) and `IF/ID` (`stall_id = 1`) for one cycle and insert a bubble into `ID/EX` (`squash_id_ex = 1`).
   - **Forwarding paths:**
     - `EX/MEM -> EX` and `MEM/WB -> EX` on ALU/address operands `rs1` and `rs2` (with `EX/MEM` taking priority over `MEM/WB` when both stages write the same non-zero register `rd != 0`).
     - `MEM/WB -> MEM` store-data forwarding (`StoreData`), so a load immediately followed by a store of the loaded register does not need to stall.
   - **Bubbles & valid-bit gating:** Bubbles use `valid = 0` (and canonical `NOP` `32'h00000013` for instruction words). Every fault/halt check, `RF.WenW`, and `MEM.WE` **must be gated by the stage's `valid` bit** so a bubble never halts the machine or writes architectural state.

### Supported Instructions in Milestone A (61 Public Straight-Line Tests)
Milestone A tests **straight-line programs only** (no conditional branches, `jal`, or `jalr`):
- **Register-Immediate ALU (`0010011`):** `addi`, `slti`, `sltiu`, `xori`, `ori`, `andi`, `slli` (`funct7=0000000`), `srli` (`funct7=0000000`), `srai` (`funct7=0100000`)
- **Register-Register ALU (`0110011`):** `add`, `sub`, `sll`, `slt`, `sltu`, `xor`, `srl`, `sra`, `or`, `and`
- **Upper Immediates:** `lui` (`0110111`), `auipc` (`0010111`)
- **Loads (`0000011`):** `lb`, `lh`, `lw`, `lbu`, `lhu` (aligned, in data region `0x2000`–`0x3ffc`)
- **Stores (`0100011`):** `sb`, `sh`, `sw` (aligned, in data region `0x2000`–`0x3ffc`)
- **Precise Halting on Decode Faults:** `ecall` (`0x00000073`) and illegal/unsupported instructions (including `ebreak`, `fence`, M-extension `mul`/`div`/`rem`, all-zero words `0x00000000`, and reserved `funct3`/`funct7` encodings).
  - When an instruction faults in decode, carry a fault flag with it down the pipeline to **WB**, squash younger instructions fetched behind it so they cannot modify memory or registers, allow all older instructions ahead of it to retire normally, and assert `halt = 1` in the cycle the faulting instruction reaches **WB** (`wb_valid == 1`).

---

## 4. Understanding the Trace Format, `STRAY` Lines, `STATS`, & `tracediff.py`

During simulation, `lab4_tb.v` records one line per retired instruction in `WB` (`Retire.Valid === 1'b1` and `halt === 1'b0`) to `trace.txt`, using the exact same format as Lab 3:

```text
<n> pc=<8 hex> inst=<8 hex> [rd=x<N>:<8 hex>] [ld=<8 hex addr>:<size>] [st=<8 hex addr>:<size>:<data>]
```

When `halt` is asserted in `WB`, the trace ends with:
```text
HALT pc=<8 hex> inst=<8 hex>
```

### `STRAY` Architectural State Lines
In a pipelined processor, a bug may cause a register write or memory store on a cycle when no valid instruction is retiring (`Retire.Valid == 0`), or a `MEM`-stage store when the instruction retiring in `WB` on the next cycle is not a store. `lab4_tb.v` logs any such write as a `STRAY` record:
```text
STRAY cycle=<clock_cycle> [rd=x<N>:<8 hex>] [st=<8 hex addr>:<size>:<data>]
```
`tracediff.py` immediately flags `STRAY` lines with the cycle number and the next retiring instruction's `PC` so you can inspect that cycle in `pipeline.vcd`.

### `STATS` Performance Line
At the end of every simulation run, `lab4_tb.v` prints the total clock cycles, retired instruction count, and cycles per instruction (`CPI`) to standard output:
```text
STATS clock_cycles=<C> retired_instructions=<I> CPI=<C/I>
```
Grading for correctness compares **what retires and what is written, in program order, never when** — pipeline stalls and forwarding affect only `clock_cycles` and `CPI`.
