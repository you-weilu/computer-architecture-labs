#!/usr/bin/env python3
"""
Standalone Pure-Python RV32I Assembler for CompEng 361 Lab 3 (rv32asm.py)

Features:
- Pure Python 3 standard library only (Python 3.6+ compatible), no external toolchain needed.
- Supports the complete Lab 3 RV32I instruction set (37 instructions + ecall),
  ABI and numeric register names (x0-x31, zero, ra, sp, gp, tp, t0-t6, s0-s11, fp, a0-a7),
  and standard RISC-V pseudo-instructions:
    nop, li, la, mv, not, neg, j, jr, ret,
    beqz, bnez, blez, bgez, bltz, bgtz, bgt, ble, bgtu, bleu, seqz, snez.
- Deterministic expansions for `li` and `la`:
    * Default mode (matches GNU as -march=rv32i):
      - `li rd, imm`:
          if -2048 <= s32(imm) <= 2047: `addi rd, x0, imm` (1 word)
          elif lo12 == 0:               `lui rd, hi20`     (1 word)
          else:                         `lui rd, hi20; addi rd, rd, lo12` (2 words)
      - `la rd, label`:
          `auipc rd, hi20(label - pc); addi rd, rd, lo12(label - pc)` (2 words)
    * `--milestone-a` mode (or `.option milestone_a`):
      - Expands `li` and `la` using only `addi` and `slli` (no `lui` or `auipc`).
- Supports directives: .text, .data, .word, .dword, .half, .byte, .space, .align, .balign, .org,
  .equ/.set, .globl/.global, .section, .pushsection, .popsection, and labels (named + numeric 1:/1b/1f).
- Raw `.word 0xXXXXXXXX` in `.text` is emitted verbatim for testing illegal/reserved halting encodings.
- Rejects unsupported instructions (mul, fence, ebreak, csrr, etc.) with a line-numbered error
  and suggests `.word 0xXXXXXXXX` if a halting test is intended.
"""

import argparse
import ast
import operator
import os
import re
import sys
from typing import Any, Dict, List, Optional, Tuple

MEM_LIMIT_BYTES = 16384  # 16 KiB: 0x00000000 .. 0x00003fff
DEFAULT_TEXT_BASE = 0x00000000
DEFAULT_DATA_BASE = 0x00001000


class AsmError(Exception):
    def __init__(self, line_num: int, message: str) -> None:
        super().__init__(f"Line {line_num}: {message}")
        self.line_num = line_num
        self.msg = message


REG_MAP: Dict[str, int] = {f"x{i}": i for i in range(32)}
REG_MAP.update(
    {
        "zero": 0,
        "ra": 1,
        "sp": 2,
        "gp": 3,
        "tp": 4,
        "t0": 5,
        "t1": 6,
        "t2": 7,
        "s0": 8,
        "fp": 8,
        "s1": 9,
        "a0": 10,
        "a1": 11,
        "a2": 12,
        "a3": 13,
        "a4": 14,
        "a5": 15,
        "a6": 16,
        "a7": 17,
        "s2": 18,
        "s3": 19,
        "s4": 20,
        "s5": 21,
        "s6": 22,
        "s7": 23,
        "s8": 24,
        "s9": 25,
        "s10": 26,
        "s11": 27,
        "t3": 28,
        "t4": 29,
        "t5": 30,
        "t6": 31,
    }
)

R_OPS: Dict[str, Tuple[int, int]] = {
    "add": (0b000, 0b0000000),
    "sub": (0b000, 0b0100000),
    "sll": (0b001, 0b0000000),
    "slt": (0b010, 0b0000000),
    "sltu": (0b011, 0b0000000),
    "xor": (0b100, 0b0000000),
    "srl": (0b101, 0b0000000),
    "sra": (0b101, 0b0100000),
    "or": (0b110, 0b0000000),
    "and": (0b111, 0b0000000),
}

I_ALU_OPS: Dict[str, int] = {
    "addi": 0b000,
    "slti": 0b010,
    "sltiu": 0b011,
    "xori": 0b100,
    "ori": 0b110,
    "andi": 0b111,
}

I_SHIFT_OPS: Dict[str, Tuple[int, int]] = {
    "slli": (0b001, 0b0000000),
    "srli": (0b101, 0b0000000),
    "srai": (0b101, 0b0100000),
}

LOAD_OPS: Dict[str, int] = {
    "lb": 0b000,
    "lh": 0b001,
    "lw": 0b010,
    "lbu": 0b100,
    "lhu": 0b101,
}

STORE_OPS: Dict[str, int] = {
    "sb": 0b000,
    "sh": 0b001,
    "sw": 0b010,
}

BRANCH_OPS: Dict[str, int] = {
    "beq": 0b000,
    "bne": 0b001,
    "blt": 0b100,
    "bge": 0b101,
    "bltu": 0b110,
    "bgeu": 0b111,
}

UNSUPPORTED_MNEMONICS = {
    "mul": "0x022081b3 (example: mul x3, x1, x2)",
    "mulh": "0x022091b3",
    "mulhsu": "0x0220a1b3",
    "mulhu": "0x0220b1b3",
    "div": "0x0220c1b3",
    "divu": "0x0220d1b3",
    "rem": "0x0220e1b3",
    "remu": "0x0220f1b3",
    "fence": "0x0ff0000f",
    "fence.i": "0x0000100f",
    "ebreak": "0x00100073",
    "csrrw": "0x30009073",
    "csrrs": "0x3000a073",
    "csrrc": "0x3000b073",
    "csrrwi": "0x3000d073",
    "csrrsi": "0x3000e073",
    "csrrci": "0x3000f073",
    "csrr": "0x30002073",
    "csrw": "0x30009073",
    "mret": "0x30200073",
    "sret": "0x10200073",
    "wfi": "0x10500073",
    "ld": "0x0000b083",
    "sd": "0x0000b023",
    "lwu": "0x0000e083",
    "addw": "0x0000003b",
    "subw": "0x4000003b",
    "addiw": "0x0000001b",
}


def to_s32(val: int) -> int:
    u = val & 0xFFFFFFFF
    return u - 0x100000000 if (u & 0x80000000) else u


def sext12(val: int) -> int:
    u = val & 0xFFF
    return u - 0x1000 if (u & 0x800) else u


def split_hi_lo(val: int) -> Tuple[int, int]:
    s = to_s32(val)
    lo = sext12(s & 0xFFF)
    hi = ((s - lo) >> 12) & 0xFFFFF
    return hi, lo


def parse_reg(tok: str, line_num: int) -> int:
    key = tok.strip().lower()
    if key not in REG_MAP:
        raise AsmError(line_num, f"Invalid register name '{tok.strip()}'")
    return REG_MAP[key]


def strip_comments(src: str) -> str:
    # Replace block comments /* ... */ preserving newlines so line numbers stay exact
    def repl_block(m: Any) -> str:
        return "\n" * m.group(0).count("\n")

    s = re.sub(r"/\*.*?\*/", repl_block, src, flags=re.DOTALL)
    out_lines: List[str] = []
    for ln in s.splitlines():
        ln = re.sub(r"//.*$", "", ln)
        ln = re.sub(r"#.*$", "", ln)
        out_lines.append(ln)
    return "\n".join(out_lines)


def split_operands(op_str: str) -> List[str]:
    if not op_str.strip():
        return []
    parts: List[str] = []
    cur: List[str] = []
    depth = 0
    for ch in op_str:
        if ch == "(":
            depth += 1
            cur.append(ch)
        elif ch == ")":
            depth = max(0, depth - 1)
            cur.append(ch)
        elif ch == "," and depth == 0:
            parts.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)
    if cur:
        parts.append("".join(cur).strip())
    return parts


SAFE_BIN_OPS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.FloorDiv: operator.floordiv,
    ast.Div: operator.floordiv,
    ast.Mod: operator.mod,
    ast.LShift: operator.lshift,
    ast.RShift: operator.rshift,
    ast.BitOr: operator.or_,
    ast.BitXor: operator.xor,
    ast.BitAnd: operator.and_,
}

SAFE_UNARY_OPS = {
    ast.UAdd: operator.pos,
    ast.USub: operator.neg,
    ast.Invert: operator.invert,
}


def eval_expr(
    expr_str: str,
    symbols: Dict[str, int],
    num_labels: Dict[str, List[Tuple[int, int]]],
    cur_section: str,
    cur_addr: int,
    line_num: int,
    allow_unresolved: bool = False,
) -> Optional[int]:
    s = expr_str.strip()
    if not s:
        raise AsmError(line_num, "Empty expression")

    # Handle %hi(expr) and %lo(expr)
    m_hi = re.match(r"^%hi\((.+)\)$", s)
    if m_hi:
        inner = eval_expr(m_hi.group(1), symbols, num_labels, cur_section, cur_addr, line_num, allow_unresolved)
        if inner is None:
            return None
        hi, _ = split_hi_lo(inner)
        return hi

    m_lo = re.match(r"^%lo\((.+)\)$", s)
    if m_lo:
        inner = eval_expr(m_lo.group(1), symbols, num_labels, cur_section, cur_addr, line_num, allow_unresolved)
        if inner is None:
            return None
        _, lo = split_hi_lo(inner)
        return lo

    # Replace numeric local label references like 1b / 1f
    unresolved = False

    def repl_num_label(m: Any) -> str:
        nonlocal unresolved
        num_id = m.group(1)
        direction = m.group(2).lower()
        locs = [addr for sec, addr in num_labels.get(num_id, []) if sec == cur_section]
        if direction == "b":
            cands = [a for a in locs if a <= cur_addr]
            if not cands:
                if allow_unresolved:
                    unresolved = True
                    return "0"
                raise AsmError(line_num, f"Undefined backward local label '{num_id}b'")
            return str(cands[-1])
        else:
            cands = [a for a in locs if a > cur_addr]
            if not cands:
                if allow_unresolved:
                    unresolved = True
                    return "0"
                raise AsmError(line_num, f"Undefined forward local label '{num_id}f'")
            return str(cands[0])

    s_resolved = re.sub(r"\b(\d+)([bfBF])\b", repl_num_label, s)
    if unresolved:
        return None

    # Replace `.` current PC symbol if used as standalone token
    s_resolved = re.sub(r"(?<![\w.])\.(?![\w.])", str(cur_addr), s_resolved)

    # Substitute known symbols (including label names like `pass` that are Python keywords)
    def repl_sym(m: Any) -> str:
        ident = m.group(0)
        if ident in symbols:
            return f"({symbols[ident]})"
        return ident

    s_resolved = re.sub(r"\b[a-zA-Z_.$][\w.$]*\b", repl_sym, s_resolved)

    if re.match(r"^[a-zA-Z_.$][\w.$]*$", s_resolved):
        if allow_unresolved:
            return None
        raise AsmError(line_num, f"Undefined symbol or label '{s_resolved}'")

    try:
        tree = ast.parse(s_resolved, mode="eval")
    except SyntaxError:
        raise AsmError(line_num, f"Invalid expression '{expr_str.strip()}'")

    def _eval(node: ast.AST) -> int:
        if isinstance(node, ast.Expression):
            return _eval(node.body)
        if hasattr(ast, "Constant") and isinstance(node, getattr(ast, "Constant")):
            val = getattr(node, "value")
            if isinstance(val, int):
                return int(val)
            raise AsmError(line_num, f"Unsupported constant in '{expr_str.strip()}'")
        if hasattr(ast, "Num") and isinstance(node, getattr(ast, "Num")):
            return int(getattr(node, "n"))
        if isinstance(node, ast.Name):
            if node.id in symbols:
                return symbols[node.id]
            if allow_unresolved:
                raise KeyError(node.id)
            raise AsmError(line_num, f"Undefined symbol or label '{node.id}'")
        if isinstance(node, ast.UnaryOp) and type(node.op) in SAFE_UNARY_OPS:
            return SAFE_UNARY_OPS[type(node.op)](_eval(node.operand))
        if isinstance(node, ast.BinOp) and type(node.op) in SAFE_BIN_OPS:
            return SAFE_BIN_OPS[type(node.op)](_eval(node.left), _eval(node.right))
        raise AsmError(line_num, f"Unsupported expression syntax in '{expr_str.strip()}'")

    try:
        return _eval(tree)
    except KeyError:
        return None


def parse_mem_operand(op: str, line_num: int) -> Tuple[str, int]:
    """Parse `imm(rs1)` or `(rs1)` into (imm_expr_str, rs1_index)."""
    m = re.match(r"^(.*?)\(\s*([^()]+?)\s*\)$", op.strip())
    if not m:
        raise AsmError(
            line_num,
            f"Expected memory operand in 'offset(rs1)' format, got '{op.strip()}'",
        )
    imm_str = m.group(1).strip() or "0"
    rs1 = parse_reg(m.group(2), line_num)
    return imm_str, rs1


def encode_r(funct7: int, rs2: int, rs1: int, funct3: int, rd: int, opcode: int = 0b0110011) -> int:
    return (
        ((funct7 & 0x7F) << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((funct3 & 0x7) << 12)
        | ((rd & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def encode_i(imm: int, rs1: int, funct3: int, rd: int, opcode: int, line_num: int, allow_hex_u12: bool = False) -> int:
    if allow_hex_u12 and 0 <= imm <= 0xFFF:
        pass
    elif not (-2048 <= imm <= 2047):
        raise AsmError(line_num, f"12-bit signed immediate out of range [-2048, 2047]: {imm}")
    return (
        ((imm & 0xFFF) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((funct3 & 0x7) << 12)
        | ((rd & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def encode_s(imm: int, rs2: int, rs1: int, funct3: int, line_num: int, opcode: int = 0b0100011) -> int:
    if not (-2048 <= imm <= 2047):
        raise AsmError(line_num, f"Store offset out of range [-2048, 2047]: {imm}")
    u = imm & 0xFFF
    imm_11_5 = (u >> 5) & 0x7F
    imm_4_0 = u & 0x1F
    return (
        (imm_11_5 << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((funct3 & 0x7) << 12)
        | (imm_4_0 << 7)
        | (opcode & 0x7F)
    )


def encode_b(offset: int, rs2: int, rs1: int, funct3: int, line_num: int, opcode: int = 0b1100011) -> int:
    if (offset & 1) != 0:
        raise AsmError(line_num, f"Branch offset must be a multiple of 2 bytes (got {offset})")
    if not (-4096 <= offset <= 4094):
        raise AsmError(line_num, f"Branch target offset out of range [-4096, 4094]: {offset}")
    u = offset & 0x1FFF
    b12 = (u >> 12) & 1
    b11 = (u >> 11) & 1
    b10_5 = (u >> 5) & 0x3F
    b4_1 = (u >> 1) & 0xF
    return (
        (b12 << 31)
        | (b10_5 << 25)
        | ((rs2 & 0x1F) << 20)
        | ((rs1 & 0x1F) << 15)
        | ((funct3 & 0x7) << 12)
        | (b4_1 << 8)
        | (b11 << 7)
        | (opcode & 0x7F)
    )


def encode_u(imm20: int, rd: int, opcode: int, line_num: int) -> int:
    if not (0 <= imm20 <= 0xFFFFF):
        raise AsmError(line_num, f"20-bit upper immediate out of range [0, 0xfffff]: {imm20}")
    return ((imm20 & 0xFFFFF) << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)


def encode_j(offset: int, rd: int, line_num: int, opcode: int = 0b1101111) -> int:
    if (offset & 1) != 0:
        raise AsmError(line_num, f"Jump offset must be a multiple of 2 bytes (got {offset})")
    if not (-1048576 <= offset <= 1048574):
        raise AsmError(line_num, f"JAL target offset out of range [-1048576, 1048574]: {offset}")
    u = offset & 0x1FFFFF
    b20 = (u >> 20) & 1
    b19_12 = (u >> 12) & 0xFF
    b11 = (u >> 11) & 1
    b10_1 = (u >> 1) & 0x3FF
    return (
        (b20 << 31)
        | (b10_1 << 21)
        | (b11 << 20)
        | (b19_12 << 12)
        | ((rd & 0x1F) << 7)
        | (opcode & 0x7F)
    )


def expand_li_words(rd: int, val: int, milestone_a: bool, line_num: int) -> List[Tuple[int, str]]:
    uval = val & 0xFFFFFFFF
    sval = to_s32(uval)
    if milestone_a:
        if uval < 0x800:
            return [(encode_i(uval, 0, 0b000, rd, 0b0010011, line_num), f"addi x{rd}, x0, {uval}")]
        if uval >= 0xFFFFF800:
            simm = uval - 0x100000000
            return [(encode_i(simm, 0, 0b000, rd, 0b0010011, line_num), f"addi x{rd}, x0, {simm}")]
        insns: List[Tuple[int, str]] = []
        top10 = (uval >> 22) & 0x3FF
        mid11 = (uval >> 11) & 0x7FF
        bot11 = uval & 0x7FF
        insns.append((encode_i(top10, 0, 0b000, rd, 0b0010011, line_num), f"addi x{rd}, x0, {top10}"))
        insns.append((encode_r(0b0000000, 11, rd, 0b001, rd, 0b0010011), f"slli x{rd}, x{rd}, 11"))
        if mid11 != 0:
            insns.append((encode_i(mid11, rd, 0b000, rd, 0b0010011, line_num), f"addi x{rd}, x{rd}, {mid11}"))
        insns.append((encode_r(0b0000000, 11, rd, 0b001, rd, 0b0010011), f"slli x{rd}, x{rd}, 11"))
        if bot11 != 0:
            insns.append((encode_i(bot11, rd, 0b000, rd, 0b0010011, line_num), f"addi x{rd}, x{rd}, {bot11}"))
        return insns

    if -2048 <= sval <= 2047:
        return [(encode_i(sval, 0, 0b000, rd, 0b0010011, line_num), f"addi x{rd}, x0, {sval}")]
    hi, lo = split_hi_lo(sval)
    if lo == 0:
        return [(encode_u(hi, rd, 0b0110111, line_num), f"lui x{rd}, 0x{hi:x}")]
    return [
        (encode_u(hi, rd, 0b0110111, line_num), f"lui x{rd}, 0x{hi:x}"),
        (encode_i(lo, rd, 0b000, rd, 0b0010011, line_num), f"addi x{rd}, x{rd}, {lo}"),
    ]


def assemble(
    src_text: str,
    milestone_a: bool = False,
) -> Tuple[Dict[int, int], List[Tuple[int, bytes, int, str]]]:
    """
    Assemble RV32I source text into:
      - mem_bytes: Dict[address, byte_val]
      - listing:   List[(address, raw_bytes, line_num, source_desc)]
    """
    cleaned = strip_comments(src_text)
    raw_lines = src_text.splitlines()

    # Statements list: (line_num, raw_source_line, statement_str)
    stmts: List[Tuple[int, str, str]] = []
    for idx, cln in enumerate(cleaned.splitlines()):
        line_num = idx + 1
        orig_line = raw_lines[idx].strip() if idx < len(raw_lines) else cln.strip()
        for part in cln.split(";"):
            p = part.strip()
            if p:
                stmts.append((line_num, orig_line, p))

    # Pass 1: Track section addresses, collect symbols and numeric labels, and record items
    sec_addrs: Dict[str, int] = {".text": DEFAULT_TEXT_BASE, ".data": DEFAULT_DATA_BASE}
    sec_stack: List[str] = []
    cur_sec = ".text"
    symbols: Dict[str, int] = {"DATA_PAGE_HI": 0x001}
    num_labels: Dict[str, List[Tuple[int, int]]] = {}
    items: List[Dict[str, Any]] = []
    use_milestone_a = milestone_a

    for line_num, orig_line, stmt in stmts:
        # Support bare-metal riscv_test.h wrapper macros so plain .S tests in tests/src/ assemble directly
        if stmt in ("RVTEST_RV32U", "RVTEST_RV64U", "RVTEST_CODE_END", "RVTEST_DATA_END"):
            continue
        if stmt == "RVTEST_CODE_BEGIN":
            cur_sec = ".text"
            rem = sec_addrs[cur_sec] % 4
            if rem != 0:
                pad = 4 - rem
                items.append(
                    {"kind": "pad", "sec": cur_sec, "addr": sec_addrs[cur_sec], "size": pad, "line_num": line_num, "orig": orig_line}
                )
                sec_addrs[cur_sec] += pad
            symbols["_start"] = sec_addrs[cur_sec]
            continue
        if stmt == "RVTEST_DATA_BEGIN":
            rem = sec_addrs[cur_sec] % 16
            if rem != 0:
                pad = 16 - rem
                items.append(
                    {"kind": "pad", "sec": cur_sec, "addr": sec_addrs[cur_sec], "size": pad, "line_num": line_num, "orig": orig_line}
                )
                sec_addrs[cur_sec] += pad
            continue
        if stmt == "RVTEST_PASS":
            stmt = "ecall"
        elif stmt == "RVTEST_FAIL":
            stmt = ".word 0x00000000"
        # Extract any leading labels on this statement (`foo:` or `1:`)
        while True:
            m_lbl = re.match(r"^([a-zA-Z_.$][\w.$]*|\d+)\s*:\s*(.*)$", stmt)
            if not m_lbl:
                break
            lbl_name = m_lbl.group(1)
            stmt = m_lbl.group(2).strip()
            addr = sec_addrs[cur_sec]
            if lbl_name.isdigit():
                num_labels.setdefault(lbl_name, []).append((cur_sec, addr))
            else:
                if lbl_name in symbols:
                    raise AsmError(line_num, f"Duplicate label definition '{lbl_name}'")
                symbols[lbl_name] = addr

        if not stmt:
            continue

        # Split mnemonic/directive from operands
        m_tok = re.match(r"^(\S+)(?:\s+(.*))?$", stmt)
        assert m_tok is not None
        mnem = m_tok.group(1)
        op_str = (m_tok.group(2) or "").strip()
        low_mnem = mnem.lower()

        # Directives
        if low_mnem.startswith("."):
            if low_mnem == ".text":
                cur_sec = ".text"
            elif low_mnem == ".data":
                cur_sec = ".data"
            elif low_mnem == ".section":
                if ".data" in op_str or ".rodata" in op_str or ".sdata" in op_str or ".bss" in op_str:
                    cur_sec = ".data"
                else:
                    cur_sec = ".text"
            elif low_mnem == ".pushsection":
                sec_stack.append(cur_sec)
                cur_sec = ".data" if ".data" in op_str else ".text"
            elif low_mnem == ".popsection":
                cur_sec = sec_stack.pop() if sec_stack else ".text"
            elif low_mnem in (".globl", ".global"):
                pass
            elif low_mnem == ".option":
                if op_str.lower() == "milestone_a":
                    use_milestone_a = True
                elif op_str.lower() == "milestone_b":
                    use_milestone_a = False
            elif low_mnem in (".equ", ".set"):
                ops = split_operands(op_str)
                if len(ops) != 2:
                    raise AsmError(line_num, f"'{low_mnem}' requires 2 arguments: symbol, value")
                val = eval_expr(ops[1], symbols, num_labels, cur_sec, sec_addrs[cur_sec], line_num)
                assert val is not None
                symbols[ops[0]] = val
            elif low_mnem == ".org":
                val = eval_expr(op_str, symbols, num_labels, cur_sec, sec_addrs[cur_sec], line_num)
                assert val is not None
                if val < 0 or val >= MEM_LIMIT_BYTES:
                    raise AsmError(line_num, f".org address 0x{val:x} exceeds 16 KiB memory [0x0, 0x3fff]")
                sec_addrs[cur_sec] = val
            elif low_mnem in (".align", ".p2align"):
                val = eval_expr(op_str, symbols, num_labels, cur_sec, sec_addrs[cur_sec], line_num)
                assert val is not None
                if val < 0 or val > 12:
                    raise AsmError(line_num, f"Invalid .align power {val}")
                align_bytes = 1 << val
                rem = sec_addrs[cur_sec] % align_bytes
                if rem != 0:
                    pad = align_bytes - rem
                    items.append(
                        {
                            "kind": "pad",
                            "sec": cur_sec,
                            "addr": sec_addrs[cur_sec],
                            "size": pad,
                            "line_num": line_num,
                            "orig": orig_line,
                        }
                    )
                    sec_addrs[cur_sec] += pad
            elif low_mnem == ".balign":
                val = eval_expr(op_str, symbols, num_labels, cur_sec, sec_addrs[cur_sec], line_num)
                assert val is not None
                if val <= 0 or (val & (val - 1)) != 0:
                    raise AsmError(line_num, f"Invalid .balign byte alignment {val}")
                rem = sec_addrs[cur_sec] % val
                if rem != 0:
                    pad = val - rem
                    items.append(
                        {
                            "kind": "pad",
                            "sec": cur_sec,
                            "addr": sec_addrs[cur_sec],
                            "size": pad,
                            "line_num": line_num,
                            "orig": orig_line,
                        }
                    )
                    sec_addrs[cur_sec] += pad
            elif low_mnem in (".space", ".skip", ".zero"):
                ops = split_operands(op_str)
                if not ops:
                    raise AsmError(line_num, f"'{low_mnem}' requires a byte count")
                cnt = eval_expr(ops[0], symbols, num_labels, cur_sec, sec_addrs[cur_sec], line_num)
                assert cnt is not None
                if cnt < 0:
                    raise AsmError(line_num, f"Negative {low_mnem} size: {cnt}")
                items.append(
                    {
                        "kind": "space",
                        "sec": cur_sec,
                        "addr": sec_addrs[cur_sec],
                        "size": cnt,
                        "line_num": line_num,
                        "orig": orig_line,
                    }
                )
                sec_addrs[cur_sec] += cnt
            elif low_mnem in (".byte", ".half", ".short", ".2byte", ".word", ".4byte", ".dword", ".8byte"):
                ops = split_operands(op_str)
                if not ops:
                    raise AsmError(line_num, f"'{low_mnem}' requires at least one value")
                elem_size = (
                    1
                    if low_mnem == ".byte"
                    else (2 if low_mnem in (".half", ".short", ".2byte") else (8 if low_mnem in (".dword", ".8byte") else 4))
                )
                for expr_item in ops:
                    items.append(
                        {
                            "kind": "data",
                            "sec": cur_sec,
                            "addr": sec_addrs[cur_sec],
                            "size": elem_size,
                            "expr": expr_item,
                            "line_num": line_num,
                            "orig": orig_line,
                        }
                    )
                    sec_addrs[cur_sec] += elem_size
            else:
                raise AsmError(line_num, f"Unsupported assembler directive '{mnem}'")
            continue

        # Check unsupported mnemonics explicitly
        if low_mnem in UNSUPPORTED_MNEMONICS:
            example_word = UNSUPPORTED_MNEMONICS[low_mnem]
            raise AsmError(
                line_num,
                f"Instruction '{low_mnem}' is not part of the Lab 3 RV32I subset. "
                f"To test that your CPU halts on an unsupported/illegal encoding, use '.word {example_word}'.",
            )

        ops = split_operands(op_str)

        # Determine size in bytes for Pass 1 address tracking
        if low_mnem == "li":
            if len(ops) != 2:
                raise AsmError(line_num, f"'li' requires 2 operands (rd, imm), got {len(ops)}")
            rd = parse_reg(ops[0], line_num)
            val = eval_expr(ops[1], symbols, num_labels, cur_sec, sec_addrs[cur_sec], line_num)
            if val is None:
                raise AsmError(line_num, f"'li' immediate must be a constant expression, got '{ops[1]}'")
            exp_words = expand_li_words(rd, val, use_milestone_a, line_num)
            size = 4 * len(exp_words)
        elif low_mnem in ("la", "lla"):
            if len(ops) != 2:
                raise AsmError(line_num, f"'{low_mnem}' requires 2 operands (rd, symbol), got {len(ops)}")
            parse_reg(ops[0], line_num)
            size = 12 if (use_milestone_a and low_mnem == "la") else 8
        elif low_mnem == "call":
            if len(ops) != 1:
                raise AsmError(line_num, f"'call' requires 1 target operand, got {len(ops)}")
            size = 4
        else:
            size = 4

        if (sec_addrs[cur_sec] & 0x3) != 0:
            raise AsmError(
                line_num,
                f"Instruction at address 0x{sec_addrs[cur_sec]:08x} is not 4-byte aligned",
            )

        items.append(
            {
                "kind": "inst",
                "sec": cur_sec,
                "addr": sec_addrs[cur_sec],
                "size": size,
                "mnem": low_mnem,
                "ops": ops,
                "milestone_a": use_milestone_a,
                "line_num": line_num,
                "orig": orig_line,
            }
        )
        sec_addrs[cur_sec] += size

    # Pass 2: Encode all instructions and data items into mem_bytes and listing
    mem_bytes: Dict[int, int] = {}
    listing: List[Tuple[int, bytes, int, str]] = []

    def write_bytes(addr: int, data: bytes, line_num: int, desc: str) -> None:
        if addr < 0 or (addr + len(data)) > MEM_LIMIT_BYTES:
            raise AsmError(
                line_num,
                f"Program exceeds 16 KiB memory limit [0x00000000, 0x00003fff] at address 0x{addr:08x}",
            )
        for i, b in enumerate(data):
            mem_bytes[addr + i] = b
        listing.append((addr, data, line_num, desc))

    for it in items:
        kind = it["kind"]
        addr = it["addr"]
        size = it["size"]
        line_num = it["line_num"]
        sec = it["sec"]
        orig = it["orig"]

        if kind in ("pad", "space"):
            if size > 0:
                write_bytes(addr, bytes(size), line_num, orig)
            continue

        if kind == "data":
            val = eval_expr(it["expr"], symbols, num_labels, sec, addr, line_num)
            assert val is not None
            if size == 1:
                if not (-128 <= val <= 255):
                    raise AsmError(line_num, f".byte value out of range [-128, 255]: {val}")
                raw = (val & 0xFF).to_bytes(1, "little")
            elif size == 2:
                if not (-32768 <= val <= 65535):
                    raise AsmError(line_num, f".half value out of range [-32768, 65535]: {val}")
                raw = (val & 0xFFFF).to_bytes(2, "little")
            elif size == 4:
                if not (-0x80000000 <= val <= 0xFFFFFFFF):
                    raise AsmError(line_num, f".word value out of 32-bit range: {val}")
                raw = (val & 0xFFFFFFFF).to_bytes(4, "little")
            else:
                raw = (val & 0xFFFFFFFFFFFFFFFF).to_bytes(8, "little")
            write_bytes(addr, raw, line_num, orig)
            continue

        # Instruction encoding
        mnem = it["mnem"]
        ops = it["ops"]
        ma_flag = it["milestone_a"]

        def emit_word(pc_addr: int, word: int, desc: str) -> None:
            write_bytes(pc_addr, (word & 0xFFFFFFFF).to_bytes(4, "little"), line_num, desc)

        # Pseudo-instructions
        if mnem == "nop":
            if ops:
                raise AsmError(line_num, f"'nop' takes no operands, got {len(ops)}")
            emit_word(addr, encode_i(0, 0, 0b000, 0, 0b0010011, line_num), orig)
        elif mnem == "ecall":
            if ops:
                raise AsmError(line_num, f"'ecall' takes no operands, got {len(ops)}")
            emit_word(addr, 0x00000073, orig)
        elif mnem == "li":
            rd = parse_reg(ops[0], line_num)
            val = eval_expr(ops[1], symbols, num_labels, sec, addr, line_num)
            assert val is not None
            exp = expand_li_words(rd, val, ma_flag, line_num)
            for idx_w, (w, exp_desc) in enumerate(exp):
                emit_word(addr + 4 * idx_w, w, f"{orig}  [{exp_desc}]" if len(exp) > 1 else orig)
        elif mnem in ("la", "lla"):
            rd = parse_reg(ops[0], line_num)
            target = eval_expr(ops[1], symbols, num_labels, sec, addr, line_num)
            assert target is not None
            if ma_flag and mnem == "la":
                hi_page = (target >> 12) & 0xFFF
                _, lo12 = split_hi_lo(target)
                if lo12 < 0:
                    hi_page = (hi_page + 1) & 0xFFF
                w0 = encode_i(hi_page, 0, 0b000, rd, 0b0010011, line_num)
                w1 = encode_r(0b0000000, 12, rd, 0b001, rd, 0b0010011)
                w2 = encode_i(lo12, rd, 0b000, rd, 0b0010011, line_num)
                emit_word(addr, w0, f"{orig}  [addi x{rd}, x0, {hi_page}]")
                emit_word(addr + 4, w1, f"{orig}  [slli x{rd}, x{rd}, 12]")
                emit_word(addr + 8, w2, f"{orig}  [addi x{rd}, x{rd}, {lo12}]")
            else:
                rel = target - addr
                hi20, lo12 = split_hi_lo(rel)
                w0 = encode_u(hi20, rd, 0b0010111, line_num)
                w1 = encode_i(lo12, rd, 0b000, rd, 0b0010011, line_num)
                emit_word(addr, w0, f"{orig}  [auipc x{rd}, 0x{hi20:x}]")
                emit_word(addr + 4, w1, f"{orig}  [addi x{rd}, x{rd}, {lo12}]")
        elif mnem == "mv":
            if len(ops) != 2:
                raise AsmError(line_num, f"'mv' requires 2 operands (rd, rs), got {len(ops)}")
            rd, rs = parse_reg(ops[0], line_num), parse_reg(ops[1], line_num)
            emit_word(addr, encode_i(0, rs, 0b000, rd, 0b0010011, line_num), orig)
        elif mnem == "not":
            if len(ops) != 2:
                raise AsmError(line_num, f"'not' requires 2 operands (rd, rs), got {len(ops)}")
            rd, rs = parse_reg(ops[0], line_num), parse_reg(ops[1], line_num)
            emit_word(addr, encode_i(-1, rs, 0b100, rd, 0b0010011, line_num), orig)
        elif mnem == "neg":
            if len(ops) != 2:
                raise AsmError(line_num, f"'neg' requires 2 operands (rd, rs), got {len(ops)}")
            rd, rs = parse_reg(ops[0], line_num), parse_reg(ops[1], line_num)
            emit_word(addr, encode_r(0b0100000, rs, 0, 0b000, rd), orig)
        elif mnem == "seqz":
            if len(ops) != 2:
                raise AsmError(line_num, f"'seqz' requires 2 operands (rd, rs), got {len(ops)}")
            rd, rs = parse_reg(ops[0], line_num), parse_reg(ops[1], line_num)
            emit_word(addr, encode_i(1, rs, 0b011, rd, 0b0010011, line_num), orig)
        elif mnem == "snez":
            if len(ops) != 2:
                raise AsmError(line_num, f"'snez' requires 2 operands (rd, rs), got {len(ops)}")
            rd, rs = parse_reg(ops[0], line_num), parse_reg(ops[1], line_num)
            emit_word(addr, encode_r(0b0000000, rs, 0, 0b011, rd), orig)
        elif mnem == "sltz":
            if len(ops) != 2:
                raise AsmError(line_num, f"'sltz' requires 2 operands (rd, rs), got {len(ops)}")
            rd, rs = parse_reg(ops[0], line_num), parse_reg(ops[1], line_num)
            emit_word(addr, encode_r(0b0000000, 0, rs, 0b010, rd), orig)
        elif mnem == "sgtz":
            if len(ops) != 2:
                raise AsmError(line_num, f"'sgtz' requires 2 operands (rd, rs), got {len(ops)}")
            rd, rs = parse_reg(ops[0], line_num), parse_reg(ops[1], line_num)
            emit_word(addr, encode_r(0b0000000, rs, 0, 0b010, rd), orig)
        elif mnem == "j":
            if len(ops) != 1:
                raise AsmError(line_num, f"'j' requires 1 target operand, got {len(ops)}")
            target = eval_expr(ops[0], symbols, num_labels, sec, addr, line_num)
            assert target is not None
            offset = target - addr if re.search(r"[a-zA-Z_.]|\d+[bfBF]", ops[0]) else target
            emit_word(addr, encode_j(offset, 0, line_num), orig)
        elif mnem == "jr":
            if len(ops) == 1:
                if "(" in ops[0]:
                    imm_s, rs1 = parse_mem_operand(ops[0], line_num)
                    imm_v = eval_expr(imm_s, symbols, num_labels, sec, addr, line_num)
                    assert imm_v is not None
                    emit_word(addr, encode_i(imm_v, rs1, 0b000, 0, 0b1100111, line_num), orig)
                else:
                    rs1 = parse_reg(ops[0], line_num)
                    emit_word(addr, encode_i(0, rs1, 0b000, 0, 0b1100111, line_num), orig)
            elif len(ops) == 2:
                rs1 = parse_reg(ops[0], line_num)
                imm_v = eval_expr(ops[1], symbols, num_labels, sec, addr, line_num)
                assert imm_v is not None
                emit_word(addr, encode_i(imm_v, rs1, 0b000, 0, 0b1100111, line_num), orig)
            else:
                raise AsmError(line_num, f"'jr' requires 1 or 2 operands, got {len(ops)}")
        elif mnem == "ret":
            if ops:
                raise AsmError(line_num, f"'ret' takes no operands, got {len(ops)}")
            emit_word(addr, encode_i(0, 1, 0b000, 0, 0b1100111, line_num), orig)
        elif mnem == "call":
            if len(ops) != 1:
                raise AsmError(line_num, f"'call' requires 1 target operand, got {len(ops)}")
            target = eval_expr(ops[0], symbols, num_labels, sec, addr, line_num)
            assert target is not None
            offset = target - addr if re.search(r"[a-zA-Z_.]|\d+[bfBF]", ops[0]) else target
            emit_word(addr, encode_j(offset, 1, line_num), orig)
        elif mnem in ("beqz", "bnez", "blez", "bgez", "bltz", "bgtz"):
            if len(ops) != 2:
                raise AsmError(line_num, f"'{mnem}' requires 2 operands (rs, target), got {len(ops)}")
            rs = parse_reg(ops[0], line_num)
            target = eval_expr(ops[1], symbols, num_labels, sec, addr, line_num)
            assert target is not None
            offset = target - addr if re.search(r"[a-zA-Z_.]|\d+[bfBF]", ops[1]) else target
            if mnem == "beqz":
                w = encode_b(offset, 0, rs, 0b000, line_num)
            elif mnem == "bnez":
                w = encode_b(offset, 0, rs, 0b001, line_num)
            elif mnem == "blez":
                w = encode_b(offset, rs, 0, 0b101, line_num)
            elif mnem == "bgez":
                w = encode_b(offset, 0, rs, 0b101, line_num)
            elif mnem == "bltz":
                w = encode_b(offset, 0, rs, 0b100, line_num)
            else:  # bgtz
                w = encode_b(offset, rs, 0, 0b100, line_num)
            emit_word(addr, w, orig)
        elif mnem in ("bgt", "ble", "bgtu", "bleu"):
            if len(ops) != 3:
                raise AsmError(line_num, f"'{mnem}' requires 3 operands (rs, rt, target), got {len(ops)}")
            rs, rt = parse_reg(ops[0], line_num), parse_reg(ops[1], line_num)
            target = eval_expr(ops[2], symbols, num_labels, sec, addr, line_num)
            assert target is not None
            offset = target - addr if re.search(r"[a-zA-Z_.]|\d+[bfBF]", ops[2]) else target
            if mnem == "bgt":
                w = encode_b(offset, rs, rt, 0b100, line_num)
            elif mnem == "ble":
                w = encode_b(offset, rs, rt, 0b101, line_num)
            elif mnem == "bgtu":
                w = encode_b(offset, rs, rt, 0b110, line_num)
            else:  # bleu
                w = encode_b(offset, rs, rt, 0b111, line_num)
            emit_word(addr, w, orig)
        elif mnem in R_OPS:
            if len(ops) != 3:
                raise AsmError(line_num, f"'{mnem}' requires 3 operands (rd, rs1, rs2), got {len(ops)}")
            rd = parse_reg(ops[0], line_num)
            rs1 = parse_reg(ops[1], line_num)
            if ops[2].strip().lower() in REG_MAP:
                rs2 = parse_reg(ops[2], line_num)
                f3, f7 = R_OPS[mnem]
                emit_word(addr, encode_r(f7, rs2, rs1, f3, rd), orig)
            elif mnem + "i" in I_ALU_OPS:
                imm = eval_expr(ops[2], symbols, num_labels, sec, addr, line_num)
                assert imm is not None
                emit_word(addr, encode_i(imm, rs1, I_ALU_OPS[mnem + "i"], rd, 0b0010011, line_num), orig)
            elif mnem + "i" in I_SHIFT_OPS:
                shamt = eval_expr(ops[2], symbols, num_labels, sec, addr, line_num)
                assert shamt is not None
                if not (0 <= shamt <= 31):
                    raise AsmError(line_num, f"Shift amount out of range [0, 31]: {shamt}")
                f3, f7 = I_SHIFT_OPS[mnem + "i"]
                emit_word(addr, encode_r(f7, shamt, rs1, f3, rd, 0b0010011), orig)
            else:
                rs2 = parse_reg(ops[2], line_num)
        elif mnem in I_ALU_OPS:
            if len(ops) != 3:
                raise AsmError(line_num, f"'{mnem}' requires 3 operands (rd, rs1, imm), got {len(ops)}")
            rd = parse_reg(ops[0], line_num)
            rs1 = parse_reg(ops[1], line_num)
            imm = eval_expr(ops[2], symbols, num_labels, sec, addr, line_num)
            assert imm is not None
            emit_word(addr, encode_i(imm, rs1, I_ALU_OPS[mnem], rd, 0b0010011, line_num), orig)
        elif mnem in I_SHIFT_OPS:
            if len(ops) != 3:
                raise AsmError(line_num, f"'{mnem}' requires 3 operands (rd, rs1, shamt), got {len(ops)}")
            rd = parse_reg(ops[0], line_num)
            rs1 = parse_reg(ops[1], line_num)
            shamt = eval_expr(ops[2], symbols, num_labels, sec, addr, line_num)
            assert shamt is not None
            if not (0 <= shamt <= 31):
                raise AsmError(line_num, f"Shift amount out of range [0, 31]: {shamt}")
            f3, f7 = I_SHIFT_OPS[mnem]
            emit_word(addr, encode_r(f7, shamt, rs1, f3, rd, 0b0010011), orig)
        elif mnem in LOAD_OPS:
            if len(ops) == 2:
                rd = parse_reg(ops[0], line_num)
                imm_s, rs1 = parse_mem_operand(ops[1], line_num)
                imm = eval_expr(imm_s, symbols, num_labels, sec, addr, line_num)
                assert imm is not None
            elif len(ops) == 3:
                rd = parse_reg(ops[0], line_num)
                rs1 = parse_reg(ops[1], line_num)
                imm = eval_expr(ops[2], symbols, num_labels, sec, addr, line_num)
                assert imm is not None
            else:
                raise AsmError(line_num, f"'{mnem}' requires 'rd, offset(rs1)', got {len(ops)} operands")
            emit_word(addr, encode_i(imm, rs1, LOAD_OPS[mnem], rd, 0b0000011, line_num), orig)
        elif mnem in STORE_OPS:
            if len(ops) == 2:
                rs2 = parse_reg(ops[0], line_num)
                imm_s, rs1 = parse_mem_operand(ops[1], line_num)
                imm = eval_expr(imm_s, symbols, num_labels, sec, addr, line_num)
                assert imm is not None
            elif len(ops) == 3:
                rs2 = parse_reg(ops[0], line_num)
                rs1 = parse_reg(ops[1], line_num)
                imm = eval_expr(ops[2], symbols, num_labels, sec, addr, line_num)
                assert imm is not None
            else:
                raise AsmError(line_num, f"'{mnem}' requires 'rs2, offset(rs1)', got {len(ops)} operands")
            emit_word(addr, encode_s(imm, rs2, rs1, STORE_OPS[mnem], line_num), orig)
        elif mnem in BRANCH_OPS:
            if len(ops) != 3:
                raise AsmError(line_num, f"'{mnem}' requires 3 operands (rs1, rs2, target), got {len(ops)}")
            rs1 = parse_reg(ops[0], line_num)
            rs2 = parse_reg(ops[1], line_num)
            target = eval_expr(ops[2], symbols, num_labels, sec, addr, line_num)
            assert target is not None
            offset = target - addr if re.search(r"[a-zA-Z_.]|\d+[bfBF]", ops[2]) else target
            emit_word(addr, encode_b(offset, rs2, rs1, BRANCH_OPS[mnem], line_num), orig)
        elif mnem in ("lui", "auipc"):
            if len(ops) != 2:
                raise AsmError(line_num, f"'{mnem}' requires 2 operands (rd, imm20), got {len(ops)}")
            rd = parse_reg(ops[0], line_num)
            imm20 = eval_expr(ops[1], symbols, num_labels, sec, addr, line_num)
            assert imm20 is not None
            opcode = 0b0110111 if mnem == "lui" else 0b0010111
            emit_word(addr, encode_u(imm20, rd, opcode, line_num), orig)
        elif mnem == "jal":
            if len(ops) == 1:
                rd = 1
                target_expr = ops[0]
            elif len(ops) == 2:
                rd = parse_reg(ops[0], line_num)
                target_expr = ops[1]
            else:
                raise AsmError(line_num, f"'jal' requires 1 or 2 operands ([rd,] target), got {len(ops)}")
            target = eval_expr(target_expr, symbols, num_labels, sec, addr, line_num)
            assert target is not None
            offset = target - addr if re.search(r"[a-zA-Z_.]|\d+[bfBF]", target_expr) else target
            emit_word(addr, encode_j(offset, rd, line_num), orig)
        elif mnem == "jalr":
            if len(ops) == 1:
                rd = 1
                if "(" in ops[0]:
                    imm_s, rs1 = parse_mem_operand(ops[0], line_num)
                    imm = eval_expr(imm_s, symbols, num_labels, sec, addr, line_num)
                    assert imm is not None
                else:
                    rs1 = parse_reg(ops[0], line_num)
                    imm = 0
            elif len(ops) == 2:
                rd = parse_reg(ops[0], line_num)
                if "(" in ops[1]:
                    imm_s, rs1 = parse_mem_operand(ops[1], line_num)
                    imm = eval_expr(imm_s, symbols, num_labels, sec, addr, line_num)
                    assert imm is not None
                else:
                    rs1 = parse_reg(ops[1], line_num)
                    imm = 0
            elif len(ops) == 3:
                rd = parse_reg(ops[0], line_num)
                rs1 = parse_reg(ops[1], line_num)
                imm = eval_expr(ops[2], symbols, num_labels, sec, addr, line_num)
                assert imm is not None
            else:
                raise AsmError(line_num, f"'jalr' requires 1, 2, or 3 operands, got {len(ops)}")
            emit_word(addr, encode_i(imm, rs1, 0b000, rd, 0b1100111, line_num), orig)
        else:
            raise AsmError(line_num, f"Unknown or unsupported instruction '{mnem}'")

    return mem_bytes, listing


def format_verilog_hex(mem_bytes: Dict[int, int]) -> str:
    """
    Format mem_bytes in Verilog $readmemh format matching `objcopy -O verilog`:
      @00000000
      XX XX XX ... (up to 16 bytes per line)
    """
    if not mem_bytes:
        return "@00000000\n"

    addrs = sorted(mem_bytes.keys())
    segments: List[Tuple[int, List[int]]] = []
    cur_start = addrs[0]
    cur_vals = [mem_bytes[cur_start]]
    prev_a = cur_start

    for a in addrs[1:]:
        if a == prev_a + 1:
            cur_vals.append(mem_bytes[a])
        else:
            segments.append((cur_start, cur_vals))
            cur_start = a
            cur_vals = [mem_bytes[a]]
        prev_a = a
    segments.append((cur_start, cur_vals))

    lines: List[str] = []
    for start_addr, vals in segments:
        lines.append(f"@{start_addr:08X}")
        for i in range(0, len(vals), 16):
            chunk = vals[i : i + 16]
            lines.append(" ".join(f"{b:02X}" for b in chunk) + " ")
    return "\n".join(lines) + "\n"


def format_listing(listing: List[Tuple[int, bytes, int, str]]) -> str:
    lines: List[str] = []
    lines.append(f"{'Address':10s}  {'Encoding':10s}  {'Line':>5s}  Source")
    lines.append("-" * 64)
    for addr, raw, line_num, desc in listing:
        if len(raw) == 4:
            word = int.from_bytes(raw, "little")
            enc_str = f"0x{word:08x}"
        elif len(raw) <= 4:
            enc_str = raw.hex()
        else:
            enc_str = f"({len(raw)} bytes)"
        lines.append(f"0x{addr:08x}  {enc_str:10s}  {line_num:5d}  {desc}")
    return "\n".join(lines) + "\n"


def assemble_file(
    src_path: str,
    out_hex_path: str = "mem_in.hex",
    listing_opt: Optional[str] = None,
    milestone_a: bool = False,
) -> Tuple[Dict[int, int], List[Tuple[int, bytes, int, str]]]:
    with open(src_path, "r", encoding="utf-8") as f:
        src_text = f.read()
    mem_bytes, listing = assemble(src_text, milestone_a=milestone_a)
    hex_str = format_verilog_hex(mem_bytes)
    with open(out_hex_path, "w", encoding="utf-8") as f:
        f.write(hex_str)
    if listing_opt is not None:
        list_str = format_listing(listing)
        if listing_opt == "-":
            print(list_str, end="")
        else:
            with open(listing_opt, "w", encoding="utf-8") as lf:
                lf.write(list_str)
    return mem_bytes, listing


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Assemble an RV32I assembly file (.s / .S) into a Verilog hex image (mem_in.hex)."
    )
    parser.add_argument("source", nargs="?", default=None, help="Input RV32I assembly file (.s or .S)")
    parser.add_argument(
        "-o",
        "--output",
        default="mem_in.hex",
        help="Output Verilog hex file (default: mem_in.hex)",
    )
    parser.add_argument(
        "-l",
        "--list",
        nargs="?",
        const="-",
        default=None,
        help="Print an address/word/source listing to stdout, or write it to the given file",
    )
    parser.add_argument(
        "--milestone-a",
        action="store_true",
        help="Expand 'li' and 'la' using only Milestone A instructions (addi + slli, no lui/auipc)",
    )
    args = parser.parse_args()

    # Allow `python3 rv32asm.py -l my_test.s` (where argparse assigns my_test.s to args.list)
    if args.source is None and args.list not in (None, "-"):
        args.source = args.list
        args.list = "-"
    if args.source is None:
        parser.error("the following arguments are required: source")

    if not os.path.exists(args.source):
        print(f"ERROR: Source file '{args.source}' not found.", file=sys.stderr)
        sys.exit(1)

    try:
        mem_bytes, listing = assemble_file(
            args.source,
            out_hex_path=args.output,
            listing_opt=args.list,
            milestone_a=args.milestone_a,
        )
    except AsmError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)

    inst_words = sum(1 for _, raw, _, _ in listing if len(raw) == 4)
    print(f"Assembled '{args.source}' -> '{args.output}' ({len(mem_bytes)} bytes, {inst_words} words).")


if __name__ == "__main__":
    main()
