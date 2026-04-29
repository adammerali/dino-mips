# dino-mips

Made this to practice Verilog and learn how MIPS processors work. 

Chrome dino game running on a single cycle MIPS CPU. The CPU executes MIPS assembly that handles jumping, gravity, collision, and scoring. A testbench intercepts memory mapped I/O and prints ASCII frames to the terminal.

## CPU Architecture

Single-cycle MIPS datapath. Supported instructions:

- **R-type:** `add`, `sub`, `and`, `or`, `slt`, `nor`, `jr`
- **I-type:** `addi`, `andi`, `ori`, `slti`, `lw`, `sw`, `beq`, `bne`, `lui`
- **J-type:** `j`, `jal`

## Memory Map

| Address | Purpose |
|---|---|
| `0x0000–0x00FC` | Data RAM — `dino_y`, `dino_vy`, `cactus_x`, `score` |
| `0x0100` | I/O read — jump input |
| `0x0104` | I/O write — frame done (1) / game over (2) |

## Run

Requires [Icarus Verilog](http://iverilog.icarus.com/).

```bash
iverilog -o sim/tb_game sim/tb_game.v rtl/cpu/alu.v rtl/cpu/alu_control.v \
         rtl/cpu/control_unit.v rtl/cpu/register_file.v \
         rtl/cpu/instruction_mem.v rtl/cpu/data_mem.v rtl/cpu/mips_cpu.v
vvp sim/tb_game
```

## Future Improvements

**Real FPGA board:** Basys 3 or Nexys A7 boards.

**Pipelined CPU:** Implement a 5 stage pipeline (IF / ID / EX / MEM / WB) with a hazard detection unit, data forwarding paths, and branch flush logic. (somewhat implemented just needs tweaks).
