// IF/ID pipeline register
module if_id_reg (
    input         clk,
    input         reset,
    input         stall,
    input         flush,
    input  [31:0] pc_plus4_in,
    input  [31:0] instruction_in,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] instruction_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            pc_plus4_out    <= 32'b0;
            instruction_out <= 32'b0; // NOP
        end else if (!stall) begin
            pc_plus4_out    <= pc_plus4_in;
            instruction_out <= instruction_in;
        end
    end
endmodule
