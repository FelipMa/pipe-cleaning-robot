`timescale 10ns/10ns // 50 MHz

module top_tb;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

reg clock;
reg [3:0] reset_key;

wire vga_hs, vga_vs;
wire [7:0] vga_r, vga_g, vga_b;

top DUV (.CLOCK_50(clock), .KEY(reset_key), .VGA_HS(vga_hs), .VGA_VS(vga_vs), .VGA_R(vga_r), .VGA_G(vga_g), .VGA_B(vga_b));

always
	#1 clock = !clock;

initial
begin
    $display ("TO-DO");
end

endmodule
