module instruction_mem #(
    parameter HEX_FILE = "asm/dino_game.hex"
)(
    input  [31:0] addr,
    output [31:0] instruction
);
    reg [31:0] mem [0:1023]; // 4KB, 1024 words

    initial begin
        $readmemh(HEX_FILE, mem);
    end

    // Word-aligned: PC is byte address, divide by 4 to index
    assign instruction = mem[addr[11:2]];
endmodule
