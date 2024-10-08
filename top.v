module top (CLOCK_50, KEY, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, VGA_CLK, LEDG, SW,
            Pino1, Pino2, Pino3, Pino4, Pino6, Pino9, Saidas, Select);

input wire CLOCK_50;
input wire [3:0] KEY;
input wire [17:0] SW;
input wire Pino1, Pino2, Pino3, Pino4, Pino6, Pino9; // buttons input
output wire VGA_HS, VGA_VS, VGA_CLK;
output wire [11:0] Saidas; // buttons output
output wire Select; // controller select output
output wire [7:0] VGA_R, VGA_G, VGA_B;
output wire [8:0] LEDG;

// internal wires
wire pll_clk_25;
wire video_on;
wire [3:0] sprite;
wire [4:0] robot_type;
wire [9:0] pixel_x, pixel_y;
wire [1:0] robot_cursor_flags;

// build PLL
pll pll (.inclk0(CLOCK_50), .c0(pll_clk_25));

// build world
world world (.clock_50(CLOCK_50), .reset_key(KEY[0]), .mode_toggle(SW[0]), .clock_toggle(KEY[3]), .mode(LEDG[7]), .pixel_x(pixel_x), .pixel_y(pixel_y), .sprite(sprite), .robot_cursor_flags(robot_cursor_flags), .robot_type(robot_type), .control_inputs(Saidas));

// build vga
vga_sync vga_sync(.clock_50(CLOCK_50), .clock_25(pll_clk_25), .reset_key(KEY[1]), .vga_hs(VGA_HS), .vga_vs(VGA_VS), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y));

// build the graphics
graphics graphics(.clock_50(CLOCK_50), .video_on(video_on), .pix_x(pixel_x), .pix_y(pixel_y), .graph_r(VGA_R), .graph_g(VGA_G), .graph_b(VGA_B), .sprite(sprite), .flags(robot_cursor_flags), .robot_type(robot_type));

// build controller
controller controller(.clock_50(CLOCK_50), .reset(KEY[0]), .Pino1(Pino1), .Pino2(Pino2), .Pino3(Pino3), .Pino4(Pino4), .Pino6(Pino6), .Pino9(Pino9), .Saidas(Saidas), .Select(Select), .vga_vs(VGA_VS));

assign LEDG[0] = 1'b1;
assign VGA_CLK = pll_clk_25;

endmodule