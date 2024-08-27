module top (CLOCK_50, KEY, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, VGA_CLK, LEDG, SW,
            up_z, down_y, left_x, right, a_b, selectSignal,	start_c, buttonsOut); //GPIO - Flat IDE de 40 fios. OBS: Ainda não sabemos como são as conexões', então por enquanto vamos deixar assim

input wire CLOCK_50;
input wire [3:0] KEY;
input wire [17:0] SW;
// input wire [35:0] GPIO; // input controller
input wire up_z, down_y, left_x, right, a_b, selectSignal, start_c; // delete after discovering GPIO's connection.
output wire VGA_HS, VGA_VS, VGA_CLK;
output wire [10:0] buttonsOut; // change after integration with robot
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
world world (.clock_50(CLOCK_50), .reset_key(KEY[0]), .mode_toggle(SW[0]), .clock_toggle(KEY[3]), .mode(LEDG[7]), .pixel_x(pixel_x), .pixel_y(pixel_y), .sprite(sprite), .robot_cursor_flags(robot_cursor_flags), .robot_type(robot_type));

// build vga
vga_sync vga_sync(.clock_50(CLOCK_50), .clock_25(pll_clk_25), .reset_key(KEY[1]), .vga_hs(VGA_HS), .vga_vs(VGA_VS), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y));

// build the graphics
graphics graphics(.clock_50(CLOCK_50), .video_on(video_on), .pix_x(pixel_x), .pix_y(pixel_y), .graph_r(VGA_R), .graph_g(VGA_G), .graph_b(VGA_B), .sprite(sprite), .flags(robot_cursor_flags), .robot_type(robot_type));

// build controller
controller controller(.clk(CLOCK_50), .reset(KEY[0]), .up_z(up_z), .down_y(down_y), .left_x(left_x), .right(right), .a_b(a_b), .selectSignal(selectSignal), .start_c(start_c), .buttonsOut(buttonsOut), .vga_vs(VGA_VS));

assign LEDG[0] = 1'b1;
assign VGA_CLK = pll_clk_25;

endmodule
