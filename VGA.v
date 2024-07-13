module VGA(CLOCK_50, KEY, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B);
input wire CLOCK_50;
input wire [3:0] KEY;
output wire VGA_HS, VGA_VS;
output wire [7:0] VGA_R;
output wire [7:0] VGA_G;
output wire [7:0] VGA_B;


wire [9:0] pixel_x, pixel_y;
wire video_on, pixel_tick;
reg [2:0] rgb_reg;
wire [2:0] rgb_next;

VGA_SYNC sync(.CLOCK_50(CLOCK_50), .KEY(KEY), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .video_on(video_on), .p_tick(pixel_tick), .pixel_x(pixel_x), .pixel_y(pixel_y));
graficos graf(.video_on(video_on), .pix_x(pixel_x), .pix_y(pixel_y), . graph_rgb(rgb_next));

always @(posedge CLOCK_50)
	if (pixel_tick)
		rgb_reg <= rgb_next;
		
		
assign VGA_R = {rgb_reg[2], 7'b0000000};
assign VGA_G = {rgb_reg[1], 7'b0000000};
assign VGA_B = {rgb_reg[0], 7'b0000000};


endmodule
