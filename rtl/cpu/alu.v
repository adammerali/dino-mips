module alu (
    input  signed [31:0] a,
    input  signed [31:0] b,
    input         [3:0]  alu_ctrl,
    output reg    [31:0] result,
    output               zero
);
    assign zero = (result == 32'b0);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a & b;                          // AND
            4'b0001: result = a | b;                          // OR
            4'b0010: result = a + b;                          // ADD
            4'b0110: result = a - b;                          // SUB
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'b1100: result = ~(a | b);                       // NOR
            default: result = 32'b0;
        endcase
    end
endmodule
