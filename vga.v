module vga (clock_25, reset_key, vga_hs, vga_vs, vga_r, vga_g, vga_b);

input wire clock_25, reset_key;
output wire vga_hs, vga_vs;
output wire [7:0] vga_r;
output wire [7:0] vga_g;
output wire [7:0] vga_b;

wire [9:0] pixel_x, pixel_y;
wire video_on, pixel_tick;
reg [2:0] rgb_reg;
wire [2:0] rgb_next;

vga_sync sync(.clock_25(clock_25), .reset_key(reset_key), .vga_hs(vga_hs), .vga_vs(vga_vs), .video_on(video_on), .p_tick(pixel_tick), .pixel_x(pixel_x), .pixel_y(pixel_y));

graphics graf(.video_on(video_on), .pix_x(pixel_x), .pix_y(pixel_y), .graph_rgb(rgb_next));

always @(posedge clock_25)
	rgb_reg <= rgb_next;
		
assign vga_r = {rgb_reg[2], 7'b0000000};
assign vga_g = {rgb_reg[1], 7'b0000000};
assign vga_b = {rgb_reg[0], 7'b0000000};

endmodule
