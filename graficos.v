module graficos(video_on, pix_x, pix_y, graph_rgb);
input wire video_on;
input wire [9:0] pix_x, pix_y;
output reg [2:0] graph_rgb;

// posições máximas dos pixels do display de gráfico
parameter MAX_X = 640;
parameter MAX_Y = 480;

// agora, os parâmetros da coluna 
parameter WALL_X_L = 32;
parameter WALL_X_R = 35;

wire wall_on;
wire [2:0] wall_rgb;


assign wall_on = (WALL_X_L<=pix_x) && (pix_x<=WALL_X_R); 
assign wall_rgb = 3'b001; // azul

always @* begin
	if (~video_on)
		graph_rgb = 3'b000; // preto
	else
		if(wall_on)
			graph_rgb = wall_rgb;
		else
			graph_rgb = 3'b110; // fundo amarelo
end


endmodule