module vga_sync (clock_25, reset_key, vga_hs, vga_vs, video_on, p_tick, pixel_x, pixel_y);

input wire clock_25, reset_key;
output wire vga_hs, vga_vs, video_on, p_tick; // Hsync, vsync são para sincronizar; video_on é flag do vídeo, 
output wire [9:0] pixel_x, pixel_y; // 

/* declarações das constantes da vga. Isto é, o tamanho da barra preta, o tamanho horizontal, vertical, demora da volta do emissor de elétrons, etc;
TODO: VERIFICAR SE ESSSAS CONSTANTES VALEM PRO NOSSO VGA!!! */
//
parameter HD = 640; // Tamanho do display horizontal //// Nota: Todos são EM PIXELS!!
parameter HF = 48; // Tamanho da borda esquerda, (H)orizontal((F)ront)
parameter HB = 16; // Tamanho da borda direita, (H)orizontal ((B)ack)
parameter HR = 96 ; // Tamanho, em pixels, do retrace. Isto é, o tempo, em pixels, do retorno do feixe de elétrons da direita pro início;
parameter VD = 480; // Tamanho do display vertical;
parameter VF = 33; // Tamanho da borda vertical frontal, (topo)
parameter VB = 10; // Tamanho da borda vertical back, (de baixo)
parameter VR = 2; // Tamanho do deslocamento vertical 
//
reg mod2_reg; // Utilizaremos um MOD-2 para sincronizar o clock do VGA com o clock do FPGA. O FPGA:50MHz oscillator for clock sources (página 8), enquanto
wire mod2_next; // o VGA, com 640x480 tem pixel clock de 25MHZ 
reg [9:0] h_count_reg, h_count_next;// contadores de sincronização. ELE É IMPORTANTE E SERVE PARA SABERMOS 
reg [9:0] v_count_reg, v_count_next;// EXATAMENTE ONDE O FEIXE DE ELÉTRONS ESTÁ, PARA CONSEGUIR EXIBIR CORRETAMENTE OS GRÁFICOS!!!
//
reg v_sync_reg, h_sync_reg;
wire v_sync_next, h_sync_next;
//
wire h_end , v_end , pixel_tick; // Sinais de estado. end são os finais da zona de display, pixel_tick será o clock dos pixels.

always @(posedge clock_25 or negedge reset_key) begin
	if (~reset_key) begin // se reset estiver ativo, então os registradores resetarão, isto é, terão seus valores iguais a zero.
		mod2_reg <= 0;
		v_count_reg <= 0;
		h_count_reg <= 0;
		v_sync_reg <= 0;
		h_sync_reg <= 0;
	end
	else begin // caso contrário, ou seja, teve clock mas não teve reset, então os registradores assumirão seus novos valores, a fim de sincronização. 
		mod2_reg <= mod2_next;
		v_count_reg <= v_count_next;
		h_count_reg <= h_count_next;
		v_sync_reg <= v_sync_next;
		h_sync_reg <= h_sync_next;
	end
end

assign mod2_next = ~mod2_reg;
assign pixel_tick = mod2_reg; // divide o clock na metade para sincrozar o clock do vga com o clock do fpga.
//
assign h_end = (h_count_reg == (HD + HF + HB + HR - 1)); // Ou seja, se o pixel horizontal atual for igual a 799 (tamanho dos pixels), significa o fim.
assign v_end = (v_count_reg == (VD + VF + VB + VR - 1)); // similarmente para os pixels verticais;

always @* begin
	if (pixel_tick)begin
		if(h_end)
			h_count_next = 0;
		else
			h_count_next = h_count_reg + 1;
	end
	else
		h_count_next = h_count_reg;
end
//
always @* begin
	if (pixel_tick && h_end) begin
		if (v_end)
			v_count_next = 0;
		else
			v_count_next = v_count_reg + 1;
	end
	else
		v_count_next = v_count_reg;
end

assign h_sync_next = !(h_count_reg>=(HD+HB) && h_count_reg<=(HD+HB+HR-1));
assign v_sync_next = !(v_count_reg>=(VD+VB) && v_count_reg<=(VD+VB+VR-1)); 
assign video_on = (h_count_reg<HD) && (v_count_reg<VD);

//outputs
assign vga_hs = h_sync_reg;
assign vga_vs = v_sync_reg;
assign pixel_x = h_count_reg;
assign pixel_y = v_count_reg;
assign p_tick = pixel_tick;

endmodule
