`timescale 1ns/1ps

module controller_tb;
reg clk, reset, up_z, down_y, left_x, right,	a_b, selectSignal, start_c;
wire [10:0] buttonsOut;

controller DUT(.clk(clk), 
					.reset(reset), 
					.up_z(up_z),
					.down_y(down_y),
					.left_x(left_x),
					.right(right),
					.a_b(a_b),
					.selectSignal(selectSignal),
					.start_c(start_c),
					.buttonsOut(buttonsOut));
					
always begin
	#10 clk = ~clk; 
end

initial begin
	clk = 0;
	reset = 1;
	up_z = 0;
	down_y = 0;
	left_x = 0;
	right = 0;
	a_b = 0;
	selectSignal = 0;
	start_c = 0;
	
	#20 reset = 0;

	#10 up_z = 1;
	#10 up_z = 0;
	#10 up_z = 1;

	#20972000

	$display ("buttonsOut: %0b", buttonsOut);

	selectSignal = 1;

	#20972000
	
	$display ("buttonsOut: %0b", buttonsOut);

	$finish;
end





endmodule