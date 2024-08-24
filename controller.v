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
// Outputs ==================
output reg [10:0] buttonsOut,
output reg selectSignal,
//===========================

// Inputs ===========
input wire clk,
		reset,
		up_z,
		down_y,
		left_x,
		right,
		a_b,
		start_c,
		vga_vs
//===================
);

// Internal Wires ================
wire 	up_z_debounced,
		down_y_debounced,
		left_x_debounced,
		right_debounced,
		a_b_debounced,
		start_c_debounced,
		Flag;
//================================
		
// Internal Regs ==================
reg 	vga_vs_primeiro_FF,
		vga_vs_segundo_FF;
		
reg [3:0] Estado_Atual, Estado_Futuro;

reg [12:0] Contador;
//================================
		
// Internal Parameters ============		
parameter AGUARDAR_ATIVACAO = 0,
				SELECT_0 = 1,
				SELECT_1 = 2,
				AGUARDAR_CONTADOR = 3;
//=================================

// Instatiation ================================================================================
debouncer db_up_z(.clk(clk), .reset(reset), .noisy(up_z), .debounced(up_z_debounced));
debouncer db_down_y(.clk(clk), .reset(reset), .noisy(down_y), .debounced(down_y_debounced));
debouncer db_left_x(.clk(clk), .reset(reset), .noisy(left_x), .debounced(left_x_debounced));
debouncer db_right(.clk(clk), .reset(reset), .noisy(right), .debounced(right_debounced));
debouncer db_a_b(.clk(clk), .reset(reset), .noisy(a_b), .debounced(a_b_debounced));
debouncer db_start_c(.clk(clk), .reset(reset), .noisy(start_c), .debounced(start_c_debounced));
//==============================================================================================

always @(negedge clk) begin
	vga_vs_primeiro_FF <= vga_vs;
	vga_vs_segundo_FF <= vga_vs_primeiro_FF;
end

assign Flag = ~vga_vs_primeiro_FF & vga_vs_segundo_FF;

always @(posedge clk) begin
	if (!reset) begin
		Estado_Atual <= AGUARDAR_ATIVACAO;
		Contador <= 0;
	end
	else begin
		Estado_Atual <= Estado_Futuro;
	end
	
	if (Estado_Futuro == AGUARDAR_ATIVACAO) begin
		Contador <= 0;
	end
	else begin
		Contador <= Contador + 1;
	end
	
	if (Estado_Futuro == SELECT_0) begin
		buttonsOut[0] <= up_z_debounced; // Up
		buttonsOut[1] <= down_y_debounced; // Down
		buttonsOut[2] <= left_x_debounced; // Left
		buttonsOut[3] <= right_debounced; // Right
		buttonsOut[4] <= a_b_debounced; // A
		buttonsOut[5] <= start_c_debounced;	// Start	
	end
	
	if (Estado_Futuro == SELECT_1) begin
		buttonsOut[6] <= up_z_debounced; // Z
		buttonsOut[7] <= down_y_debounced; // Y
		buttonsOut[8] <= left_x_debounced; // X
		buttonsOut[9] <= a_b_debounced; // B
		buttonsOut[10] <= start_c_debounced; // C		
	end
end

always @(*) begin
	case (Estado_Atual)
		AGUARDAR_ATIVACAO: 	if (Flag) Estado_Futuro = SELECT_0;
									else Estado_Futuro = AGUARDAR_ATIVACAO;

		SELECT_0: 	if (Contador < 3500) Estado_Futuro = SELECT_0;
						else Estado_Futuro = SELECT_1;
						
		SELECT_1:	if (Contador < 7000) Estado_Futuro = SELECT_1;
						else Estado_Futuro = AGUARDAR_CONTADOR;
		
		AGUARDAR_CONTADOR: 	if (Contador < 8000) Estado_Futuro = AGUARDAR_CONTADOR;
									else Estado_Futuro = AGUARDAR_ATIVACAO;
									
		default: Estado_Futuro = AGUARDAR_ATIVACAO;
	endcase
end


always @(*) begin
	selectSignal = 0;
	
	case(Estado_Atual)
		SELECT_0: selectSignal = 0;

		SELECT_1: selectSignal = 1;

		default: selectSignal = 0;
	endcase
end

endmodule