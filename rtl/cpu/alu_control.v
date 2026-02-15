module alu_control (
    input  [1:0] alu_op,
    input  [5:0] funct,
    input  [5:0] opcode,
    output reg [3:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0010; // ADD  (lw, sw, addi)
            2'b01: alu_ctrl = 4'b0110; // SUB  (beq, bne)
            2'b11: begin               // I-type special (andi, ori, slti)
                case (opcode)
                    6'h0C:   alu_ctrl = 4'b0000; // andi -> AND
                    6'h0D:   alu_ctrl = 4'b0001; // ori  -> OR
                    6'h0A:   alu_ctrl = 4'b0111; // slti -> SLT
                    default: alu_ctrl = 4'b0010;
                endcase
            end
            2'b10: begin               // R-type: use funct field
                case (funct)
                    6'h20: alu_ctrl = 4'b0010; // add
                    6'h22: alu_ctrl = 4'b0110; // sub
                    6'h24: alu_ctrl = 4'b0000; // and
                    6'h25: alu_ctrl = 4'b0001; // or
                    6'h2A: alu_ctrl = 4'b0111; // slt
                    6'h27: alu_ctrl = 4'b1100; // nor
                    default: alu_ctrl = 4'b0010;
                endcase
            end
            default: alu_ctrl = 4'b0010;
        endcase
    end
endmodule
