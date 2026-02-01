#!/usr/bin/env python3
"""
Simple two-pass MIPS assembler for dino_game.asm.
Supports: add, sub, and, or, slt, nor, jr,
          addi, andi, ori, slti, lw, sw, beq, bne, lui,
          j, jal, nop
"""

import sys
import re

REGS = {
    '$zero':0,'$at':1,'$v0':2,'$v1':3,
    '$a0':4,'$a1':5,'$a2':6,'$a3':7,
    '$t0':8,'$t1':9,'$t2':10,'$t3':11,
    '$t4':12,'$t5':13,'$t6':14,'$t7':15,
    '$s0':16,'$s1':17,'$s2':18,'$s3':19,
    '$s4':20,'$s5':21,'$s6':22,'$s7':23,
    '$t8':24,'$t9':25,'$k0':26,'$k1':27,
    '$gp':28,'$sp':29,'$fp':30,'$ra':31,
}

def reg(name):
    name = name.strip()
    if name in REGS:
        return REGS[name]
    if name.startswith('$') and name[1:].isdigit():
        return int(name[1:])
    raise ValueError(f"Unknown register: {name}")

def to_int(s):
    s = s.strip()
    return int(s, 0)

def r_type(rs, rt, rd, shamt, funct):
    return (0 << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | funct

def i_type(opcode, rs, rt, imm):
    return (opcode << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)

def j_type(opcode, target):
    return (opcode << 26) | (target & 0x3FFFFFF)

def parse_lw_sw(operands):
    """Parse 'rt, offset(base)' or 'rt, offset, base'."""
    rt_str = operands[0]
    rest = operands[1]
    m = re.match(r'(-?(?:0x[\da-fA-F]+|\d+))\((\$\w+)\)', rest)
    if m:
        return reg(rt_str), to_int(m.group(1)), reg(m.group(2))
    # fallback: rt, imm, base
    return reg(rt_str), to_int(operands[1]), reg(operands[2])

def assemble(src):
    lines = src.splitlines()

    # ── Pass 1: collect labels ──────────────────────────────────────────────
    labels = {}
    instructions = []  # list of (byte_addr, stripped_line)
    pc = 0

    for raw in lines:
        line = raw.split('#')[0].strip()
        if not line or line.startswith('.'):
            continue
        if line.endswith(':'):
            labels[line[:-1].strip()] = pc
        elif ':' in line:
            label, rest = line.split(':', 1)
            labels[label.strip()] = pc
            rest = rest.strip()
            if rest:
                instructions.append((pc, rest))
                pc += 4
        else:
            instructions.append((pc, line))
            pc += 4

    # ── Pass 2: encode ──────────────────────────────────────────────────────
    encoded = []

    for addr, line in instructions:
        parts = re.split(r'[\s,]+', line.strip())
        parts = [p for p in parts if p]
        op = parts[0].lower()

        if op == 'nop':
            encoded.append(0)

        # ── R-type ──────────────────────────────────────────────────────────
        elif op == 'add':
            rd,rs,rt = reg(parts[1]),reg(parts[2]),reg(parts[3])
            encoded.append(r_type(rs, rt, rd, 0, 0x20))
        elif op == 'sub':
            rd,rs,rt = reg(parts[1]),reg(parts[2]),reg(parts[3])
            encoded.append(r_type(rs, rt, rd, 0, 0x22))
        elif op == 'and':
            rd,rs,rt = reg(parts[1]),reg(parts[2]),reg(parts[3])
            encoded.append(r_type(rs, rt, rd, 0, 0x24))
        elif op == 'or':
            rd,rs,rt = reg(parts[1]),reg(parts[2]),reg(parts[3])
            encoded.append(r_type(rs, rt, rd, 0, 0x25))
        elif op == 'slt':
            rd,rs,rt = reg(parts[1]),reg(parts[2]),reg(parts[3])
            encoded.append(r_type(rs, rt, rd, 0, 0x2A))
        elif op == 'nor':
            rd,rs,rt = reg(parts[1]),reg(parts[2]),reg(parts[3])
            encoded.append(r_type(rs, rt, rd, 0, 0x27))
        elif op == 'jr':
            rs = reg(parts[1])
            encoded.append(r_type(rs, 0, 0, 0, 0x08))

        # ── I-type ──────────────────────────────────────────────────────────
        elif op == 'addi':
            rt,rs,imm = reg(parts[1]),reg(parts[2]),to_int(parts[3])
            encoded.append(i_type(0x08, rs, rt, imm))
        elif op == 'andi':
            rt,rs,imm = reg(parts[1]),reg(parts[2]),to_int(parts[3])
            encoded.append(i_type(0x0C, rs, rt, imm))
        elif op == 'ori':
            rt,rs,imm = reg(parts[1]),reg(parts[2]),to_int(parts[3])
            encoded.append(i_type(0x0D, rs, rt, imm))
        elif op == 'slti':
            rt,rs,imm = reg(parts[1]),reg(parts[2]),to_int(parts[3])
            encoded.append(i_type(0x0A, rs, rt, imm))
        elif op == 'lui':
            rt,imm = reg(parts[1]),to_int(parts[2])
            encoded.append(i_type(0x0F, 0, rt, imm))
        elif op == 'lw':
            rt, offset, base = parse_lw_sw(parts[1:])
            encoded.append(i_type(0x23, base, rt, offset))
        elif op == 'sw':
            rt, offset, base = parse_lw_sw(parts[1:])
            encoded.append(i_type(0x2B, base, rt, offset))
        elif op == 'beq':
            rs,rt = reg(parts[1]),reg(parts[2])
            tgt = parts[3]
            offset = (labels[tgt] - (addr + 4)) >> 2 if tgt in labels else to_int(tgt)
            encoded.append(i_type(0x04, rs, rt, offset))
        elif op == 'bne':
            rs,rt = reg(parts[1]),reg(parts[2])
            tgt = parts[3]
            offset = (labels[tgt] - (addr + 4)) >> 2 if tgt in labels else to_int(tgt)
            encoded.append(i_type(0x05, rs, rt, offset))

        # ── J-type ──────────────────────────────────────────────────────────
        elif op == 'j':
            tgt = parts[1]
            t = (labels[tgt] >> 2) if tgt in labels else to_int(tgt)
            encoded.append(j_type(0x02, t))
        elif op == 'jal':
            tgt = parts[1]
            t = (labels[tgt] >> 2) if tgt in labels else to_int(tgt)
            encoded.append(j_type(0x03, t))

        else:
            print(f"WARNING: unknown instruction '{op}' at byte {addr}", file=sys.stderr)
            encoded.append(0)

    return encoded


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("usage: assembler.py <input.asm> [output.hex]")
        sys.exit(1)

    src_path = sys.argv[1]
    out_path = sys.argv[2] if len(sys.argv) > 2 else src_path.replace('.asm', '.hex')

    with open(src_path) as f:
        src = f.read()

    words = assemble(src)

    with open(out_path, 'w') as f:
        for w in words:
            f.write(f'{w:08X}\n')

    print(f"assembled {len(words)} instructions -> {out_path}")
