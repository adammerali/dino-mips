// Simple sprite renderer — draws dino and cactus from game state memory
// Reads dino_y and cactus_x from a small register interface
module sprite_renderer (
    input  [9:0] pixel_x,
    input  [9:0] pixel_y,
    input         display_on,
    // game state (from CPU memory-mapped outputs)
    input  [31:0] dino_y,
    input  [31:0] cactus_x,
    output reg [2:0] rgb   // 3-bit color: R G B
);
    // Scale: 1 game unit = 16 pixels
    localparam SCALE      = 16;
    localparam DINO_COL   = 4 * SCALE;  // game col 4
    localparam GROUND_ROW = 400;        // y pixel where ground starts

    wire [9:0] dino_px_y  = GROUND_ROW - (dino_y * SCALE) - SCALE;
    wire [9:0] cactus_px_x = cactus_x * SCALE;

    wire in_dino   = display_on &&
                     (pixel_x >= DINO_COL)    && (pixel_x < DINO_COL + SCALE) &&
                     (pixel_y >= dino_px_y)   && (pixel_y < dino_px_y + SCALE * 2);

    wire in_cactus = display_on &&
                     (pixel_x >= cactus_px_x) && (pixel_x < cactus_px_x + SCALE/2) &&
                     (pixel_y >= GROUND_ROW - SCALE * 3) && (pixel_y < GROUND_ROW);

    wire in_ground = display_on && (pixel_y == GROUND_ROW);

    always @(*) begin
        if (in_dino)        rgb = 3'b010; // green dino
        else if (in_cactus) rgb = 3'b100; // red cactus
        else if (in_ground) rgb = 3'b111; // white ground
        else                rgb = 3'b000; // black background
    end
endmodule
