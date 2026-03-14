// VGA sync signal generator — 640x480 @ 60Hz
// Pixel clock: 25.175 MHz (use 25 MHz in sim)
module vga_sync (
    input  clk_25mhz,
    input  reset,
    output reg h_sync,
    output reg v_sync,
    output reg display_on,
    output reg [9:0] pixel_x,
    output reg [9:0] pixel_y
);
    // Horizontal timing (pixels)
    localparam H_DISPLAY    = 640;
    localparam H_FRONT      = 16;
    localparam H_SYNC_W     = 96;
    localparam H_BACK       = 48;
    localparam H_TOTAL      = 800; // 640+16+96+48

    // Vertical timing (lines)
    localparam V_DISPLAY    = 480;
    localparam V_FRONT      = 10;
    localparam V_SYNC_W     = 2;
    localparam V_BACK       = 33;
    localparam V_TOTAL      = 525; // 480+10+2+33

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk_25mhz or posedge reset) begin
        if (reset) begin
            h_count <= 0; v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                v_count <= (v_count == V_TOTAL - 1) ? 0 : v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    always @(*) begin
        h_sync     = ~(h_count >= H_DISPLAY + H_FRONT &&
                       h_count <  H_DISPLAY + H_FRONT + H_SYNC_W);
        v_sync     = ~(v_count >= V_DISPLAY + V_FRONT &&
                       v_count <  V_DISPLAY + V_FRONT + V_SYNC_W);
        display_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
        pixel_x    = h_count;
        pixel_y    = v_count;
    end
endmodule
