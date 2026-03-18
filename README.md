# dino-mips

Chrome dino game running on a single-cycle MIPS CPU written in Verilog. The CPU executes a MIPS assembly program that handles game logic (jumping, gravity, collision detection, scoring). A testbench intercepts memory-mapped I/O and prints ASCII art frames to the terminal.

Simulation only — no FPGA required.

## Project Structure

```
dino-mips/
├── rtl/cpu/
│   ├── alu.v              — ALU (ADD, SUB, AND, OR, SLT, NOR)
│   ├── alu_control.v      — maps ALUOp + funct/opcode to ALU op
│   ├── control_unit.v     — decodes opcode to control signals
│   ├── register_file.v    — 32x32-bit register file
│   ├── instruction_mem.v  — ROM loaded from hex file
│   ├── data_mem.v         — RAM + memory-mapped I/O
│   └── mips_cpu.v         — top-level single-cycle datapath
├── sim/
│   └── tb_game.v          — testbench: drives jump input, prints ASCII frames
├── asm/
│   ├── dino_game.asm      — MIPS assembly source
│   ├── dino_game.hex      — assembled output
│   └── assembler.py       — two-pass Python MIPS assembler
└── README.md
```

## CPU Architecture

Single-cycle MIPS datapath with the following supported instructions:

- **R-type:** `add`, `sub`, `and`, `or`, `slt`, `nor`, `jr`
- **I-type:** `addi`, `andi`, `ori`, `slti`, `lw`, `sw`, `beq`, `bne`, `lui`
- **J-type:** `j`, `jal`

## Memory Map

| Address | Purpose |
|---|---|
| `0x0000–0x00FC` | Data RAM (game state) |
| `0x0100` | I/O read — jump input (1 = jump pressed) |
| `0x0104` | I/O write — frame signal (1 = frame done, 2 = game over) |

Game state in RAM: `dino_y` (0x00), `dino_vy` (0x04), `cactus_x` (0x08), `score` (0x0C).

## Running the Simulation

Requires [Icarus Verilog](http://iverilog.icarus.com/).

```bash
# Assemble (only needed if you modify the .asm)
python asm/assembler.py asm/dino_game.asm asm/dino_game.hex

# Compile and run (from repo root)
iverilog -o sim/tb_game sim/tb_game.v rtl/cpu/alu.v rtl/cpu/alu_control.v \
         rtl/cpu/control_unit.v rtl/cpu/register_file.v \
         rtl/cpu/instruction_mem.v rtl/cpu/data_mem.v rtl/cpu/mips_cpu.v
vvp sim/tb_game
```

The testbench prints one ASCII frame per game tick and auto-jumps every 30 frames. Stops at 300 frames or on game over.

## Future Improvements

**Real FPGA board:** Replace the testbench with actual hardware I/O — VGA controller for a sprite-rendered display (640x480), debounced push-button for jump input, and a seven-segment display for score. Target board: Basys 3 or Nexys A7.

**Pipelined CPU:** Implement a 5-stage pipeline (IF / ID / EX / MEM / WB) with a hazard detection unit, data forwarding paths, and branch flush logic to eliminate stalls where possible.
