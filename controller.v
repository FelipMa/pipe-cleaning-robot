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
buttonsIn: Pin DB-9 do controle
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

always @(negedge clk) begin
	if (reset) begin
		buttonsOut <= 11'b000_000_000_00;
	end
	
	else begin
		case (selectSignal)
			1'b0: begin
				buttonsOut[0] <= up_z; // Up
				buttonsOut[1] <= down_y; // Down
				buttonsOut[2] <= left_x; // Left
				buttonsOut[3] <= right; // Rigth
				buttonsOut[4] <= a_b; // A
				buttonsOut[5] <= start_c; // Start
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
				buttonsOut[6] <= up_z; // Z
				buttonsOut[7] <= down_y; // Y
				buttonsOut[8] <= left_x; // X
				buttonsOut[9] <= a_b; // B
				buttonsOut[10] <= start_c; // C
			end
			
			default: buttonsOut <= 11'b000_000_000_00;
		endcase
	end
	
end

endmodule