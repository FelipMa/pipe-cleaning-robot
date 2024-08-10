module top (CLOCK_50, KEY, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, VGA_CLK, LEDG);

input wire CLOCK_50;
input wire [3:0] KEY;
output wire VGA_HS, VGA_VS, VGA_CLK;
output wire [7:0] VGA_R, VGA_G, VGA_B;
output wire [8:0] LEDG;

// internal wires
wire pll_clk_25;
wire [9:0] pixel_x, pixel_y;
wire video_on;

// build PLL
pll	pll (.inclk0(CLOCK_50), .areset(1'b0), .c0(pll_clk_25));

// build world
world world (.clock_50(CLOCK_50), .reset_key(KEY[0]));

// build vga
vga_sync vga_sync(.clock_50(CLOCK_50), .clock_25(pll_clk_25), .reset_key(KEY[1]), .vga_hs(VGA_HS), .vga_vs(VGA_VS), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y));

// build the graphics
graphics graphics(.clock_50(CLOCK_50), .video_on(video_on), .pix_x(pixel_x), .pix_y(pixel_y), .graph_r(VGA_R), .graph_g(VGA_G), .graph_b(VGA_B));

assign VGA_CLK = pll_clk_25;
assign LEDG[0] = 1'b1;

endmodule
