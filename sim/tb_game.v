`timescale 1ns/1ps

module tb_game;
    // ---- Clock & reset ----
    reg clk = 0;
    reg reset = 1;
    always #5 clk = ~clk;   // 10 ns period = 100 MHz

    // ---- I/O wires ----
    wire        io_read_req;
    wire        io_write;
    wire [31:0] io_write_addr;
    wire [31:0] io_write_data;
    reg  [31:0] io_read_data = 0;

    // ---- DUT ----
    mips_cpu #(.HEX_FILE("asm/dino_game.hex")) uut (
        .clk(clk), .reset(reset),
        .io_read_data(io_read_data),
        .io_read_req(io_read_req),
        .io_write(io_write),
        .io_write_addr(io_write_addr),
        .io_write_data(io_write_data)
    );

    // ---- Auto-jump logic ----
    integer frame_count = 0;
    integer jump_timer  = 0;

    // Drive jump input when testbench wants the dino to jump
    always @(*) begin
        if (io_read_req && jump_timer > 0)
            io_read_data = 32'd1;
        else
            io_read_data = 32'd0;
    end

    // ---- Display helpers ----
    integer row, col;
    integer dino_y, cactus_x, score;
    integer dino_row;

    // Width of play field
    localparam W = 40;
    localparam H = 9;   // rows 0..8, ground at row 8

    task print_frame;
        integer r, c;
        integer d_row;
        begin
            dino_y   = uut.dmem.mem[0]; // 0x00 >> 2 = word 0
            cactus_x = uut.dmem.mem[2]; // 0x08 >> 2 = word 2
            score    = uut.dmem.mem[3]; // 0x0C >> 2 = word 3

            $display("--- Frame %0d   Score: %0d ---", frame_count, score);

            // dino occupies rows (8 - dino_y) and (7 - dino_y), clamped
            d_row = 8 - dino_y;
            if (d_row < 0) d_row = 0;

            for (r = 0; r <= H; r = r + 1) begin
                begin : row_print
                    reg [W*8-1:0] line;
                    integer ci;
                    // fill spaces
                    for (ci = 0; ci < W; ci = ci + 1)
                        line[ci*8 +: 8] = " ";

                    // dino: col 4, rows d_row and d_row+1
                    if (r == d_row || r == d_row + 1) begin
                        if (4 < W)
                            line[4*8 +: 8] = "D";
                    end

                    // cactus: col cactus_x, rows 6-8
                    if (r >= 6 && r <= 8) begin
                        if (cactus_x >= 0 && cactus_x < W)
                            line[cactus_x*8 +: 8] = "|";
                    end

                    // ground at row H
                    if (r == H) begin
                        for (ci = 0; ci < W; ci = ci + 1)
                            line[ci*8 +: 8] = "=";
                    end

                    $write("|");
                    for (ci = 0; ci < W; ci = ci + 1)
                        $write("%s", line[ci*8 +: 8]);
                    $display("|");
                end
            end
            $display("");
        end
    endtask

    // ---- Frame / game-over handling ----
    always @(posedge clk) begin
        if (io_write) begin
            if (io_write_data == 32'd1) begin
                // frame done
                frame_count = frame_count + 1;
                print_frame;

                // decrement jump timer
                if (jump_timer > 0)
                    jump_timer = jump_timer - 1;

                // trigger jump every 30 frames
                if (frame_count % 30 == 0)
                    jump_timer = 3;

                if (frame_count >= 300) begin
                    $display("Reached 300 frames — stopping simulation.");
                    $finish;
                end
            end else if (io_write_data == 32'd2) begin
                $display("GAME OVER after %0d frames", frame_count);
                $finish;
            end
        end
    end

    // ---- Stimulus ----
    initial begin
        // Release reset after 2 cycles
        @(posedge clk); @(posedge clk);
        reset = 0;

        // Safety timeout: 10 million clock edges
        #10_000_000;
        $display("Simulation timeout.");
        $finish;
    end

    initial begin
        $dumpfile("sim/tb_game.vcd");
        $dumpvars(0, tb_game);
    end
endmodule
