module mips_cpu #(
    parameter HEX_FILE = "asm/dino_game.hex"
)(
    input         clk,
    input         reset,
    // I/O wired to testbench
    input  [31:0] io_read_data,
    output        io_read_req,
    output        io_write,
    output [31:0] io_write_addr,
    output [31:0] io_write_data
);
    // ---- Program Counter ----
    reg [31:0] pc;

    // ---- Instruction fetch ----
    wire [31:0] instruction;
    instruction_mem #(.HEX_FILE(HEX_FILE)) imem (
        .addr(pc),
        .instruction(instruction)
    );

    // ---- Instruction fields ----
    wire [5:0]  opcode = instruction[31:26];
    wire [4:0]  rs     = instruction[25:21];
    wire [4:0]  rt     = instruction[20:16];
    wire [4:0]  rd     = instruction[15:11];
    wire [5:0]  funct  = instruction[5:0];
    wire [15:0] imm16  = instruction[15:0];
    wire [25:0] j_addr = instruction[25:0];

    // ---- Sign/zero extend ----
    wire [31:0] sign_ext = {{16{imm16[15]}}, imm16};

    // ---- Control signals ----
    wire        reg_dst, alu_src, mem_to_reg, reg_write;
    wire        mem_read, mem_write, branch, bne, jump;
    wire [1:0]  alu_op;

    control_unit cu (
        .opcode(opcode),
        .reg_dst(reg_dst), .alu_src(alu_src), .mem_to_reg(mem_to_reg),
        .reg_write(reg_write), .mem_read(mem_read), .mem_write(mem_write),
        .branch(branch), .bne(bne), .jump(jump), .alu_op(alu_op)
    );

    // ---- Register file ----
    wire [4:0]  write_reg  = reg_dst ? rd : rt;
    wire [31:0] read_data1, read_data2;
    wire [31:0] reg_write_data;

    register_file rf (
        .clk(clk),
        .rs(rs), .rt(rt), .rd(write_reg),
        .write_data(reg_write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ---- ALU ----
    wire [3:0]  alu_ctrl;
    wire [31:0] alu_b     = alu_src ? sign_ext : read_data2;
    wire [31:0] alu_result;
    wire        alu_zero;

    alu_control aluc (
        .alu_op(alu_op), .funct(funct), .opcode(opcode),
        .alu_ctrl(alu_ctrl)
    );

    // LUI: bypass ALU entirely
    wire        is_lui     = (opcode == 6'h0F);
    wire [31:0] lui_result = {imm16, 16'b0};

    alu alu0 (
        .a(read_data1), .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result), .zero(alu_zero)
    );

    wire [31:0] eff_result = is_lui ? lui_result : alu_result;

    // ---- Data memory ----
    wire [31:0] mem_read_data;

    data_mem dmem (
        .clk(clk),
        .addr(eff_result), .write_data(read_data2),
        .mem_read(mem_read), .mem_write(mem_write),
        .io_read_data(io_read_data),
        .io_read_req(io_read_req),
        .io_write(io_write),
        .io_write_addr(io_write_addr),
        .io_write_data(io_write_data),
        .read_data(mem_read_data)
    );

    // ---- Writeback ----
    wire [31:0] pc_plus4   = pc + 32'd4;
    wire [31:0] wb_normal  = mem_to_reg ? mem_read_data : eff_result;
    // jal writes PC+4 to $ra (rd=31)
    wire        is_jal     = (opcode == 6'h03);
    assign reg_write_data  = is_jal ? pc_plus4 : wb_normal;

    // ---- Next PC ----
    wire        is_jr          = (opcode == 6'h00) && (funct == 6'h08);
    wire        branch_taken   = (branch && alu_zero) || (bne && !alu_zero);
    wire [31:0] branch_target  = pc_plus4 + {sign_ext[29:0], 2'b00};
    wire [31:0] jump_target    = {pc_plus4[31:28], j_addr, 2'b00};

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else if (is_jr)
            pc <= read_data1;
        else if (jump)
            pc <= jump_target;
        else if (branch_taken)
            pc <= branch_target;
        else
            pc <= pc_plus4;
    end
endmodule
