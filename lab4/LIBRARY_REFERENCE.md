# CompEng 361 — Lab 4 Hardware Library & Testbench Reference (`lab4_tb.v`)

This document describes the instructor-supplied hardware library modules (`Mem`, `RegFile`, `Reg`, `D`, `PipeReg`, `Retire`) and simulation testbench (`tb`) provided in `lab4_tb.v` (Version `2.0 (2026-FA-RV32I-PIPE-TRACE)`).

> **Important:** Do **not** modify `lab4_tb.v` or copy `Mem`, `RegFile`, `Reg`, `D`, `PipeReg`, or `Retire` into your submission file. Submit only your single processor file (`<group>_lab4.v`) and compile it together with `lab4_tb.v`:
> ```bash
> iverilog -o pipeline <group>_lab4.v lab4_tb.v
> ```

---

## 1. Required Module & Instance Names

Your submission must define the top-level processor module:

```verilog
module PipelinedCPU(halt, clk, rst);
    output halt;
    input  clk, rst;
```

Inside `PipelinedCPU`, you **must** instantiate:
1. `Mem` with instance name **`MEM`**
2. `RegFile` with instance name **`RF`**
3. `Retire` driven from your **Writeback (WB)** stage (`Valid` and `PC`)

```verilog
Mem MEM (
    .InstAddr(if_pc),
    .InstOut(if_inst),
    .DataAddr(DataAddr),
    .DataSize(MemSize),
    .DataIn(StoreData),
    .DataOut(DataWord),
    .WE(MemWrEn),
    .CLK(clk)
);

RegFile RF (
    .AddrA(id_rs1),
    .DataOutA(id_rdata1),
    .AddrB(id_rs2),
    .DataOutB(id_rdata2),
    .AddrW(wb_rf_addr),
    .DataInW(wb_rf_wdata),
    .WenW(wb_rf_wen),
    .CLK(clk)
);

Retire RETIRE (
    .Valid(wb_valid),
    .PC(wb_pc)
);
```

### Common Compile Error When Instance Names Are Wrong

The testbench (`tb`) initializes and dumps memory and registers via hierarchical references `CPU.MEM.Mem` and `CPU.RF.Mem`. If you rename `MEM` or `RF` (or omit them), `iverilog` will fail during elaboration with:

```text
lab4_tb.v:300: error: Unable to bind wire/reg/memory `CPU.MEM.Mem' in `tb'
lab4_tb.v:302: error: Unable to bind wire/reg/memory `CPU.RF.Mem' in `tb'
```

---

## 2. Clocking, Pipeline Stall Rule, & Bubble Encoding

### Clocking Convention
All architectural and pipeline state elements (`Mem`, `RegFile`, `Reg`, `D`, and `PipeReg`) update on the **falling edge of the clock (`negedge CLK`)** using **nonblocking assignments (`<=`)**. At `negedge CLK`, `lab4_tb.v` samples `Retire.Valid`, `Retire.PC`, `halt`, `RF` write signals, and the `Mem` data port in the Active region, immediately before nonblocking (`<=`) state updates take effect in the NBA region.

### Rule 1: `MEM` and `WB` Never Stall (No Global Pipeline Freeze)
- **`EX/MEM` and `MEM/WB` must never stall (`WE = 1'b1`).**
- **A global pipeline freeze on a load-use hazard is NOT allowed.** When a load-use hazard occurs between an instruction in `EX` (`lw`/`lh`/`lhu`/`lb`/`lbu`) and a dependent instruction in `ID`, only `IF` (`PC_REG`) and `ID` (`IF_ID`) hold their state (`WE = 1'b0`), while `ID_EX` is squashed (`Squash = 1'b1`) to insert a bubble into `EX`. `EX/MEM` and `MEM/WB` continue advancing normally every cycle.
- Because data memory accesses occur in the **MEM** stage (one clock cycle before an instruction retires in **WB**), `lab4_tb.v` captures a nonblocking snapshot of the `Mem` data port on each `negedge CLK` and pairs that snapshot with the instruction retiring in **WB** on the immediately following cycle. Holding `EX/MEM` or `MEM/WB` decouples the `MEM`-stage snapshot from `WB` retirement and triggers a `STRAY` trace error.

### Rule 2: Bubbles, the `NOP` Encoding (`32'h00000013`), and Gating Faults by `valid`
- `PipeReg` resets (and squashes) its output `Qout` to its `init` parameter.
- In RV32I, an all-zero word (`32'h00000000`, opcode `7'b0000000`) decodes as an **illegal instruction**, whereas canonical `NOP` is `addi x0, x0, 0` (`32'h00000013`).
- Therefore:
  1. Any instruction-word field carried inside a `PipeReg` (such as `id_inst` in `IF_ID`) should reset to `32'h00000013`.
  2. **All fault and halt detection MUST be gated by the stage's `valid` bit** (e.g., `assign halt = wb_valid && wb_invalid_op;`), and register/memory write enables (`WenW`, `WE`) must also be gated by `valid` and `!halt` so pipeline bubbles (`valid == 0`) never cause a false halt or stray state write.

---

## 3. Register File Module (`RegFile`) — Internal WB $\rightarrow$ ID Bypass

```verilog
module RegFile(AddrA, DataOutA, AddrB, DataOutB, AddrW, DataInW, WenW, CLK);
```

In Lab 4, `RegFile` keeps the exact same module name and port list as Lab 3, and adds an **internal same-cycle write-to-read bypass**:

```verilog
assign DataOutA = (AddrA == 0) ? 32'h0 : ((WenW === 1'b1) && (AddrW === AddrA)) ? DataInW : Mem[AddrA];
assign DataOutB = (AddrB == 0) ? 32'h0 : ((WenW === 1'b1) && (AddrW === AddrB)) ? DataInW : Mem[AddrB];
```

- When an instruction in **WB** writes to register `AddrW != 0` (`WenW === 1'b1`) in the same cycle that an instruction in **ID** reads `AddrA == AddrW` (or `AddrB == AddrW`), `RegFile` combinationally forwards `DataInW` directly to `DataOutA` (or `DataOutB`).
- Reading `x0` (`AddrA == 0` or `AddrB == 0`) always returns `32'h00000000` regardless of `WenW` or `AddrW`.
- **Warning — Lab 3 Single-Cycle CPUs Cannot Run Against `lab4_tb.v`:** Because `DataOutA`/`DataOutB` depend combinationally on `WenW`, `AddrW`, and `DataInW`, connecting a single-cycle CPU (where `DataInW` and `WenW` are driven combinationally from `DataOutA`/`DataOutB` in the same stage without pipeline registers) creates an unclocked combinational loop.

---

## 4. Pipeline Register Module (`PipeReg`)

```verilog
module PipeReg(Din, Qout, WE, Squash, CLK, RST);
    parameter width = 32;
    parameter init  = 0;
```

`PipeReg` is built on `D` and provides synchronous hold (`WE`) and synchronous clear/flush (`Squash`) in addition to asynchronous active-low reset (`RST`):

```verilog
wire [width-1:0] d_in = Squash ? init[width-1:0] : Din;
wire             d_we = WE | Squash;

D #(.width(width), .init(init)) U_D (
    .Din(d_in), .Qout(Qout), .WE(d_we), .CLK(CLK), .RST(RST)
);
```

### `PipeReg` Truth Table (on `negedge CLK` when `RST == 1'b1`)

| `Squash` | `WE` | Action on `negedge CLK` | Typical Pipeline Use Case |
| :---: | :---: | :--- | :--- |
| `1'b0` | `1'b1` | `Qout <= Din` | Normal pipeline advance (`~stall`) |
| `1'b0` | `1'b0` | `Qout <= Qout` (Hold) | Stage stalled (`WE = ~stall`) |
| `1'b1` | `1'b0` or `1'b1` | `Qout <= init` (Bubble/Flush) | Stage flushed (`Squash` overrides `WE` and loads `init`, clearing `valid` to `0`) |

---

## 5. Retirement Observer Module (`Retire`), `HALT`, and `STRAY` Records

```verilog
module Retire(Valid, PC);
    input        Valid;
    input [31:0] PC;
```

- Connect `Valid` to your **WB** stage valid bit (`wb_valid`) and `PC` to your **WB** stage program counter (`wb_pc`).
- **Normal retirement (`Valid === 1'b1` and `halt === 1'b0`):** `lab4_tb.v` reads the instruction word from `CPU.MEM.Mem` at `PC`, increments the retired-instruction counter, and writes a trace record matching the Lab 3 trace format (`<n> pc=... inst=... [rd=...] [ld=...] [st=...]`).
- **Precise-exception halt (`halt === 1'b1`):** Assert `halt = 1'b1` in the cycle the faulting/halting instruction reaches **WB** (with `Valid = 1'b1` and `PC` identifying the faulting instruction in **WB**). All older instructions have already retired; the faulting instruction in **WB** and all younger instructions in the pipeline must **not** modify architectural state (`RF.WenW = 0`, `MEM.WE = 0`).
  - If a register write or memory store occurs on the halting instruction / in the halt cycle, `lab4_tb.v` appends `stray_rd=x<N>:<8 hex>` and/or `stray_st=<8 hex addr>:<size>:<data>` directly to the `HALT` line (identical to Lab 3), and `tracediff.py` reports `"State changed on the halting instruction"`.
- **Non-halt cycle stray state (`STRAY`):** On any non-halt cycle, a register write while `Valid == 0` or a store snapshot from `MEM` with no matching retiring store in `WB` on the next cycle is logged on its own line:
  ```text
  STRAY cycle=<clock_cycle> [rd=x<N>:<8 hex>] [st=<8 hex addr>:<size>:<data>]
  ```

---

## 6. Memory (`Mem`), Register Primitives (`Reg`, `D`), and Plusargs

`Mem`, `Reg`, and `D` are unchanged from Lab 3:
- **`Mem` (`16384` bytes, unified instruction/data memory, little-endian):** `DataSize` is `2'b00` (byte), `2'b01` (halfword), `2'b10`/`2'b11` (word). `Mem` silently masks low address bits (`InstAddr & ~3`, `DataAddr & ~1` for halfword, `DataAddr & ~3` for word) and does not detect misalignment.
- **Instruction vs. Data Address Convention (`0x0000–0x1FFC` vs. `0x2000–0x3FFC`):** Although `Mem` is a single unified `16384`-byte (`0x0000–0x3FFF`) array with simultaneous instruction-fetch (`InstAddr`) and data (`DataAddr`) ports, all Lab 4 test programs place code below `0x2000` (`0x0000 <= PC <= 0x1FFC`) and all load/store data accesses in `0x2000–0x3FFC` (no self-modifying code).
- **`Reg` and `D`:** Parameterized width (`width = 32`) and reset value (`init = 0`), active-low asynchronous reset (`RST`), active-high write enable (`WE`), updating on `negedge CLK`.
- **Plusargs:** `+MEM_IN=<path>`, `+REGS_IN=<path>`, `+TRACE_OUT=<path>`, `+REGS_OUT=<path>`, `+MEM_OUT=<path>`, `+DUMP=<path>` (defaults to `pipeline.vcd`), `+MAX_CYCLES=<clock_cycles>` (defaults to `100000` clock cycles), and `+NO_VCD=<0|1>`.
- **End-of-Run Performance Summary:** Upon halting or timing out, `lab4_tb.v` prints:
  ```text
  STATS clock_cycles=<C> retired_instructions=<I> CPI=<C/I>
  ```
