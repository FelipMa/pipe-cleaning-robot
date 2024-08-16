module debouncer (
output reg debounced, // saída que já passou pelo processo de debouncing

input wire clock_50, // clock
reset_key, // reset
noisy // entrada ruidosa
);

reg [19:0] counter; // contador responsável por estabilizar o sinal
reg debounceState; // variável interna

always @ (posedge clock_50) begin
	if (!reset_key) begin
		debounceState <= 1'b0;
		counter <= 20'b0000_0000_0000_0000_0000;
		debounced <= 1'b0;
	end
	else if (debounceState != noisy) begin
		counter <= counter + 1'b1;
		if (counter == 20'hFFFFF) begin
			debounced <= noisy;
		end
	end
end

endmodule