module debouncer (
output reg debounced, // saída que já passou pelo processo de debouncing

input wire clk, // clock
reset, // reset
noisy // entrada ruidosa
);

reg [7:0] counter; // contador responsável por estabilizar o sinal
reg debounceState; // variável interna

always @ (posedge clk) begin
	if (!reset) begin
		debounceState <= 1'b1;
		counter <= 8'b0000_0000;
		debounced <= 1'b0;
	end
	else if (debounceState != noisy) begin
		counter <= counter + 1'b1;
		if (counter == 8'b1111_1111) begin
			debounced <= !noisy;
		end
	end
end

endmodule