module data_mem (
    input         clk,
    input  [31:0] addr,
    input  [31:0] write_data,
    input         mem_read,
    input         mem_write,
    // I/O port (wired to testbench)
    input  [31:0] io_read_data,
    output reg    io_read_req,
    output reg    io_write,
    output reg [31:0] io_write_addr,
    output reg [31:0] io_write_data,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:63]; // 256 bytes of RAM (word-addressed 0..63)
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'b0;
    end

    wire is_io = (addr >= 32'h100);

    // Combinational read
    always @(*) begin
        io_read_req = 1'b0;
        read_data   = 32'b0;
        if (mem_read) begin
            if (is_io) begin
                io_read_req = 1'b1;
                read_data   = io_read_data;
            end else begin
                read_data = mem[addr[7:2]];
            end
        end
    end

    // Sequential write
    always @(posedge clk) begin
        io_write      <= 1'b0;
        io_write_addr <= 32'b0;
        io_write_data <= 32'b0;
        if (mem_write) begin
            if (is_io) begin
                io_write      <= 1'b1;
                io_write_addr <= addr;
                io_write_data <= write_data;
            end else begin
                mem[addr[7:2]] <= write_data;
            end
        end
    end
endmodule
