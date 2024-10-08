`timescale 1ns/1ps

module controller_tb;
reg clk, reset, up_z, down_y, left_x, right, a_b, start_c, vga_vs;
wire [10:0] buttonsOut;
wire selectSignal;

controller DUT(.clk(clk), 
					.reset(reset), 
					.up_z(up_z),
					.down_y(down_y),
					.left_x(left_x),
					.right(right),
					.a_b(a_b),
					.selectSignal(selectSignal),
					.start_c(start_c),
					.vga_vs(vga_vs),
					.buttonsOut(buttonsOut));
					
always begin
	#10 clk = ~clk; 
end

initial begin
	clk = 0;
	reset = 0;
	up_z = 1;
	down_y = 1;
	left_x = 1;
	right = 1;
	a_b = 1;
	start_c = 1;
	
	#20 reset = 1;
	#20 vga_vs = 1;
	#20 vga_vs = 0;

	#10 up_z = 0;
	#10 up_z = 1;
	#10 up_z = 0;

	#10 a_b = 0;
	#10 a_b = 1;
	#10 a_b = 0;

	#10 down_y = 0;
	#10 down_y = 1;
	#10 down_y = 0;

	#10 left_x  = 0;
	#10 left_x  = 1;
	#10 left_x  = 0;

	#10 right = 0;
	#10 right = 1;
	#10 right = 0;

	// #20972000

	while(buttonsOut[0] == 1'b0) begin
		#10;
	end

	$display ("Time: %t, buttonsOut: %b", $realtime, buttonsOut);

	#20 $display ("Time: %t, buttonsOut: %b", $realtime, buttonsOut);

	// #20972000

	$finish;
end





endmodule