module graphics (clock_50, video_on, pix_x, pix_y, graph_r, graph_g, graph_b);
input wire clock_50, video_on;
input wire [9:0] pix_x, pix_y;
output reg [7:0] graph_r, graph_g, graph_b;

// posições máximas dos pixels do display de gráfico
parameter MAX_X = 640;
parameter MAX_Y = 480;

// agora, os parâmetros da coluna 
parameter WALL_X_L = 30;
parameter WALL_X_R = 40;

// internal wires
wire wall_on;

// internal registers
reg [7:0] r_next, g_next, b_next;

// assignments
assign wall_on = (WALL_X_L <= pix_x) && (WALL_X_R >= pix_x); 

always @(video_on or wall_on) begin
	if (~video_on) begin
        // vermelho
		r_next = 8'd128;
        g_next = 8'd0;
        b_next = 8'd0;
    end
	else
		if(wall_on) begin
            // azul
			r_next = 8'd0;
            g_next = 8'd0;
            b_next = 8'd129;
        end
		else begin
            // amarelo
			r_next = 8'd128;
            g_next = 8'd128;
            b_next = 8'd0;
        end
end

always @(posedge clock_50) begin
    graph_r <= r_next;
    graph_g <= g_next;
    graph_b <= b_next;
end

endmodule