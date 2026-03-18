# dino-mips

Built this to practice Verilog and learn how MIPS processors work. Chrome dino game running on a single-cycle MIPS CPU — the CPU executes MIPS assembly that handles jumping, gravity, collision, and scoring. A testbench intercepts memory-mapped I/O and prints ASCII frames to the terminal. Simulation only, no FPGA required.

## Run

Requires [Icarus Verilog](http://iverilog.icarus.com/).

```bash
iverilog -o sim/tb_game sim/tb_game.v rtl/cpu/alu.v rtl/cpu/alu_control.v \
         rtl/cpu/control_unit.v rtl/cpu/register_file.v \
         rtl/cpu/instruction_mem.v rtl/cpu/data_mem.v rtl/cpu/mips_cpu.v
vvp sim/tb_game
```

## Future Improvements

**Real FPGA board:** Replace the testbench with actual hardware I/O — VGA controller for a sprite-rendered display (640x480), debounced push-button for jump input, and a seven-segment display for score. Target board: Basys 3 or Nexys A7.

**Pipelined CPU:** Implement a 5-stage pipeline (IF / ID / EX / MEM / WB) with a hazard detection unit, data forwarding paths, and branch flush logic.
