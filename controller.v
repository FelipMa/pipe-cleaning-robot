// SEGA Genesis Controller PinOut
// 1 - Up/Z
// 2 - Down/Y
// 3 - Left/X
// 4 - Right
// 5 - +5V
// 6 - A/B
// 7 - Select Signal
// 8 - Ground
// 9 - Start/C

/*
buttonsIn: Pin DB -9 do controle
buttonsOut: Saída que o módulo top-level vai receber
*/


module controller (
output reg [10:0] buttonsOut,

//buttonsIn
input wire clk,
		reset,
		up_z,
		down_y,
		left_x,
		right,
		a_b,
		selectSignal,
		start_c
);

wire 	up_z_debounced,
		down_y_debounced,
		left_x_debounced,
		right_debounced,
		a_b_debounced,
		selectSignal_debounced,
		start_c_debounced;
		
debouncer db_up_z(.clk(clk), .reset(reset), .noisy(up_z), .debounced(up_z_debounced));
debouncer db_down_y(.clk(clk), .reset(reset), .noisy(down_y), .debounced(down_y_debounced));
debouncer db_left_x(.clk(clk), .reset(reset), .noisy(left_x), .debounced(left_x_debounced));
debouncer db_right(.clk(clk), .reset(reset), .noisy(right), .debounced(right_debounced));
debouncer db_a_b(.clk(clk), .reset(reset), .noisy(a_b), .debounced(a_b_debounced));
debouncer db_start_c(.clk(clk), .reset(reset), .noisy(start_c), .debounced(start_c_debounced));

always @(negedge clk) begin
	if (reset) begin
		buttonsOut <= 11'b000_000_000_00;
	end
	
	else begin
		case (selectSignal)
			1'b0: begin
				buttonsOut[0] <= up_z_debounced; // Up
				buttonsOut[1] <= down_y_debounced; // Down
				buttonsOut[2] <= left_x_debounced; // Left
				buttonsOut[3] <= right_debounced; // Rigth
				buttonsOut[4] <= a_b_debounced; // A
				buttonsOut[5] <= start_c_debounced; // Start
				buttonsOut[6] <= 0; // Z
				buttonsOut[7] <= 0; // Y
				buttonsOut[8] <= 0; // X
				buttonsOut[9] <= 0; // B
				buttonsOut[10] <= 0; // C
			end
			
			1'b1: begin
				buttonsOut[0] <= 0; // Up
				buttonsOut[1] <= 0; // Down
				buttonsOut[2] <= 0; // Left
				buttonsOut[3] <= 0; // Rigth
				buttonsOut[4] <= 0; // A
				buttonsOut[5] <= 0; // Start
				buttonsOut[6] <= up_z_debounced; // Z
				buttonsOut[7] <= down_y_debounced; // Y
				buttonsOut[8] <= left_x_debounced; // X
				buttonsOut[9] <= a_b_debounced; // B
				buttonsOut[10] <= start_c_debounced; // C
			end
			
			default: buttonsOut <= 11'b000_000_000_00;
		endcase
	end
	
end

endmodule