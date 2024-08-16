`timescale 1ns/1ps

module controller_tb;
reg clock_50, reset_key, up_z, down_y, left_x, right,	a_b, selectSignal, start_c;
wire [10:0] buttonsOut;

controller DUT(.clock_50(clock_50), 
					.reset_key(reset_key), 
					.up_z(up_z),
					.down_y(down_y),
					.left_x(left_x),
					.right(right),
					.a_b(a_b),
					.selectSignal(selectSignal),
					.start_c(start_c),
					.buttonsOut(buttonsOut));
					
always begin
	#10 clock_50 = ~clock_50; 
end

initial begin
	clock_50 = 0;
	reset_key = 0;
	up_z = 0;
	down_y = 0;
	left_x = 0;
	right = 0;
	a_b = 0;
	selectSignal = 0;
	start_c = 0;
	
	#20 reset_key = 1;

	#10 right = 1;
	#10 right = 0;
	#10 right = 1;

	// #20972000

	while(buttonsOut[3] == 1'b0) begin
		#10;
	end

	$display ("Time: %t, buttonsOut: %b", $realtime, buttonsOut);

	//selectSignal = 1;

	#20 $display ("Time: %t, buttonsOut: %b", $realtime, buttonsOut);

	// #20972000

	$finish;
end





endmodule