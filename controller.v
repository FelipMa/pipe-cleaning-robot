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
input wire clock_50,
		reset_key,
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
		
reg 	prev_up_z_debounced,
		prev_down_y_debounced,
		prev_left_x_debounced,
		prev_right_debounced,
		prev_a_b_debounced,
		prev_start_c_debounced;
		
debouncer db_up_z(.clock_50(clock_50), .reset_key(reset_key), .noisy(up_z), .debounced(up_z_debounced));
debouncer db_down_y(.clock_50(clock_50), .reset_key(reset_key), .noisy(down_y), .debounced(down_y_debounced));
debouncer db_left_x(.clock_50(clock_50), .reset_key(reset_key), .noisy(left_x), .debounced(left_x_debounced));
debouncer db_right(.clock_50(clock_50), .reset_key(reset_key), .noisy(right), .debounced(right_debounced));
debouncer db_a_b(.clock_50(clock_50), .reset_key(reset_key), .noisy(a_b), .debounced(a_b_debounced));
debouncer db_start_c(.clock_50(clock_50), .reset_key(reset_key), .noisy(start_c), .debounced(start_c_debounced));

always @(posedge clock_50) begin
	if (!reset_key) begin
		buttonsOut <= 11'b000_000_000_00;
		prev_up_z_debounced <= 1'b0;
		prev_down_y_debounced <= 1'b0;
		prev_left_x_debounced <= 1'b0;
		prev_right_debounced <= 1'b0;
		prev_a_b_debounced <= 1'b0;
		prev_start_c_debounced <= 1'b0;
	end
	
	else begin
		case (selectSignal)
			1'b0: begin
				buttonsOut[0] <= up_z_debounced & ~prev_up_z_debounced; // UP só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_up_z_debounced <= up_z_debounced;
				
				buttonsOut[1] <= down_y_debounced & ~prev_down_y_debounced; // DOWN só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_down_y_debounced <= down_y_debounced;

				buttonsOut[2] <= left_x_debounced & ~prev_left_x_debounced; // LEFT só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_left_x_debounced <= left_x_debounced;

				buttonsOut[3] <= right_debounced & ~prev_right_debounced; // RIGHT só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_right_debounced <= right_debounced;

				buttonsOut[4] <= a_b_debounced & ~prev_a_b_debounced; // A só vai ser positiva quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_a_b_debounced <= a_b_debounced;

				buttonsOut[5] <= start_c_debounced & ~prev_start_c_debounced; // START só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_start_c_debounced <= start_c_debounced;

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

				buttonsOut[6] <= up_z_debounced & ~prev_up_z_debounced; // Z só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_up_z_debounced <= up_z_debounced;

				buttonsOut[7] <= down_y_debounced & ~prev_down_y_debounced; // Y  só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_down_y_debounced <= down_y_debounced;

				buttonsOut[8] <= left_x_debounced & ~prev_left_x_debounced; // X só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_left_x_debounced <= left_x_debounced;

				buttonsOut[9] <= a_b_debounced & ~prev_a_b_debounced; // B só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_a_b_debounced <= a_b_debounced;

				buttonsOut[10] <= start_c_debounced & ~prev_start_c_debounced; // C só vai ser positivo quando o sinal de entrada for alto e o sinal anterior for baixo
				prev_start_c_debounced <= start_c_debounced;

			end
			
			default: buttonsOut <= 11'b000_000_000_00;
		endcase
	end
	
end

endmodule