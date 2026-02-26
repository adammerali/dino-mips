// ID/EX pipeline register
module id_ex_reg (
    input         clk,
    input         reset,
    input         flush,
    // control signals
    input         reg_dst_in, alu_src_in, mem_to_reg_in,
    input         reg_write_in, mem_read_in, mem_write_in,
    input  [1:0]  alu_op_in,
    // data
    input  [31:0] pc_plus4_in,
    input  [31:0] read_data1_in,
    input  [31:0] read_data2_in,
    input  [31:0] sign_ext_in,
    input  [4:0]  rs_in, rt_in, rd_in,
    input  [5:0]  funct_in,
    // outputs
    output reg        reg_dst_out, alu_src_out, mem_to_reg_out,
    output reg        reg_write_out, mem_read_out, mem_write_out,
    output reg [1:0]  alu_op_out,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] sign_ext_out,
    output reg [4:0]  rs_out, rt_out, rd_out,
    output reg [5:0]  funct_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            reg_dst_out    <= 0; alu_src_out   <= 0; mem_to_reg_out <= 0;
            reg_write_out  <= 0; mem_read_out  <= 0; mem_write_out  <= 0;
            alu_op_out     <= 0; pc_plus4_out  <= 0;
            read_data1_out <= 0; read_data2_out <= 0; sign_ext_out  <= 0;
            rs_out <= 0; rt_out <= 0; rd_out <= 0; funct_out <= 0;
        end else begin
            reg_dst_out    <= reg_dst_in;    alu_src_out   <= alu_src_in;
            mem_to_reg_out <= mem_to_reg_in; reg_write_out <= reg_write_in;
            mem_read_out   <= mem_read_in;   mem_write_out <= mem_write_in;
            alu_op_out     <= alu_op_in;     pc_plus4_out  <= pc_plus4_in;
            read_data1_out <= read_data1_in; read_data2_out <= read_data2_in;
            sign_ext_out   <= sign_ext_in;
            rs_out <= rs_in; rt_out <= rt_in; rd_out <= rd_in;
            funct_out      <= funct_in;
        end
    end
endmodule
