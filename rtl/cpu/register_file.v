module register_file (
    input         clk,
    input  [4:0]  rs, rt, rd,
    input  [31:0] write_data,
    input         reg_write,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] regs [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    // $zero is always 0
    assign read_data1 = (rs == 5'b0) ? 32'b0 : regs[rs];
    assign read_data2 = (rt == 5'b0) ? 32'b0 : regs[rt];

    always @(posedge clk) begin
        if (reg_write && rd != 5'b0)
            regs[rd] <= write_data;
    end
endmodule
