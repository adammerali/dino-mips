module control_unit (
    input  [5:0] opcode,
    output reg   reg_dst,
    output reg   alu_src,
    output reg   mem_to_reg,
    output reg   reg_write,
    output reg   mem_read,
    output reg   mem_write,
    output reg   branch,
    output reg   bne,
    output reg   jump,
    output reg [1:0] alu_op
);
    always @(*) begin
        // defaults — all off
        reg_dst   = 0; alu_src   = 0; mem_to_reg = 0;
        reg_write = 0; mem_read  = 0; mem_write  = 0;
        branch    = 0; bne       = 0; jump       = 0;
        alu_op    = 2'b00;

        case (opcode)
            6'h00: begin // R-type
                reg_dst = 1; reg_write = 1; alu_op = 2'b10;
            end
            6'h08: begin // addi
                alu_src = 1; reg_write = 1; alu_op = 2'b00;
            end
            6'h0C: begin // andi
                alu_src = 1; reg_write = 1; alu_op = 2'b11;
            end
            6'h0D: begin // ori
                alu_src = 1; reg_write = 1; alu_op = 2'b11;
            end
            6'h0A: begin // slti
                alu_src = 1; reg_write = 1; alu_op = 2'b11;
            end
            6'h0F: begin // lui — alu_src selects imm, LUI override in cpu
                alu_src = 1; reg_write = 1; alu_op = 2'b00;
            end
            6'h23: begin // lw
                alu_src = 1; mem_read = 1; mem_to_reg = 1;
                reg_write = 1; alu_op = 2'b00;
            end
            6'h2B: begin // sw
                alu_src = 1; mem_write = 1; alu_op = 2'b00;
            end
            6'h04: begin // beq
                branch = 1; alu_op = 2'b01;
            end
            6'h05: begin // bne
                bne = 1; alu_op = 2'b01;
            end
            6'h02: begin // j
                jump = 1;
            end
            6'h03: begin // jal
                jump = 1; reg_write = 1;
            end
            default: begin end
        endcase
    end
endmodule
