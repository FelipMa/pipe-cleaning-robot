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
reg robot_on, block_on, empty_block_on;

// internal registers
reg [7:0] r_next, g_next, b_next;
// assignments
// map __________________________________________________________________
wire [3:0] map_mem; 
wire [5:0] map_index;
reg [0:59] map_data;
always @* begin
	case(map_mem)
		4'd0: map_data =  60'o0000_0000_0111_1110_0000;
		4'd1: map_data =  60'o0000_0000_0100_0010_0000;
		4'd2: map_data =  60'o0000_0100_0100_0011_1111;
		4'd3: map_data =  60'o0000_0111_1100_0000_0000;
		4'd4: map_data =  60'o0000_0100_0100_0000_1111;
		4'd5: map_data =  60'o0000_0100_0100_0111_1000;
		4'd6: map_data =  60'o1111_1100_0111_1100_0000;
		4'd7: map_data =  60'o1001_1100_0000_1011_1111;
		4'd8: map_data =  60'o1000_0100_0000_1001_0000;
		4'd9: map_data =  60'o2001_1111_1101_1111_0000;
		4'd10: map_data = 60'o0000_0000_0000_0000_0000;
		4'd11: map_data = 60'o0000_0000_0000_0000_0000;
		4'd12: map_data = 60'o0000_0000_0000_0000_0000;
		4'd13: map_data = 60'o0000_0000_0000_0000_0000;
		4'd14: map_data = 60'o0000_0000_0000_0000_0000;
		4'd15: map_data = 60'o0000_0000_0000_0000_0000;
		endcase
	case(map_data[map_index +: 3])
		3'd0: begin empty_block_on = 1'b1; block_on = 1'b0; robot_on = 1'b0; end
		3'd1: begin empty_block_on = 1'b0; block_on = 1'b1; robot_on = 1'b0; end
		3'd2: begin empty_block_on = 1'b0; block_on = 1'b0; robot_on = 1'b1; end
		3'd3, 3'd4, 3'd5, 3'd6, 3'd7: begin empty_block_on = 1'b0; block_on = 1'b0; robot_on = 1'b0; end
		default: begin empty_block_on = 1'b0; block_on = 1'b0; robot_on = 1'b0; end
	endcase
end
assign map_mem = pix_y / 32;
assign map_index = (pix_x / 32)* 3;
// map __________________________________________________________________
// robot ________________________________________________________________
reg [0:95] robot_data;
wire [4:0] robot_mem;
wire [6:0] robot_index;
always @* begin
	case(robot_mem) // ROM memory of Wall-e pixels
		5'd0: robot_data =  96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: robot_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd2: robot_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd3: robot_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: robot_data =  96'o1000_0000_0000_0100_0001_0000_0000_0001;
		5'd5: robot_data =  96'o1000_0000_0000_1110_0011_1000_0000_0001;
		5'd6: robot_data =  96'o1000_0000_0001_1211_1112_1100_0000_0001;
		5'd7: robot_data =  96'o1000_0000_0011_2221_1122_2110_0000_0001;
		5'd8: robot_data =  96'o1000_0000_0112_2221_1122_2211_0000_0001;
		5'd9: robot_data =  96'o1000_0000_1122_1122_1221_1221_1000_0001;
		5'd10: robot_data = 96'o1000_0001_1221_3212_1212_3122_1100_0001;
		5'd11: robot_data = 96'o1000_0011_2221_3312_1213_3122_2110_0001;
		5'd12: robot_data = 96'o1000_0012_2222_1122_1221_1222_2210_0001;
		5'd13: robot_data = 96'o1000_0012_2222_2221_6122_2222_2210_0001;
		5'd14: robot_data = 96'o1000_0012_2222_2221_6122_2222_2210_0001;
		5'd15: robot_data = 96'o1000_0001_2222_2211_6112_2222_2100_0001;
		5'd16: robot_data = 96'o1000_0000_1111_1111_6111_1111_1000_0001;
		5'd17: robot_data = 96'o1000_0000_0000_0001_6100_0000_0000_0001;
		5'd18: robot_data = 96'o1000_0000_0006_6666_6666_6600_0000_0001;
		5'd19: robot_data = 96'o1000_0000_6666_3333_3333_3666_6000_0001;
		5'd20: robot_data = 96'o1000_0000_6336_6666_6666_6633_6000_0001;
		5'd21: robot_data = 96'o1000_0000_6334_4111_1111_4433_6000_0001;
		5'd22: robot_data = 96'o1000_0000_6364_4144_4441_4463_6000_0001;
		5'd23: robot_data = 96'o1000_0000_0664_4144_4441_4466_0000_0001;
		5'd24: robot_data = 96'o1000_0000_0114_4144_4551_4411_0000_0001;
		5'd25: robot_data = 96'o1000_0000_0114_4444_4554_4411_0000_0001;
		5'd26: robot_data = 96'o1000_0000_0111_1100_0001_1111_0000_0001;
		5'd27: robot_data = 96'o1000_0000_0111_1100_0001_1111_0000_0001;
		5'd28: robot_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: robot_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd30: robot_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd31: robot_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
	endcase
end

assign robot_mem = pix_y % 32;
assign robot_index = (pix_x % 32)* 3; //& {robot_on, robot_on, robot_on, robot_on, robot_on, robot_on, robot_on};

// robot ________________________________________________________________
// empty_block __________________________________________________________
wire [4:0] empty_block_mem, empty_block_index;
reg [0:31] empty_block_data;
always @* begin
	case(empty_block_mem)
		5'd0: empty_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: empty_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd2: empty_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd3: empty_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: empty_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd5: empty_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd6: empty_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd7: empty_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd8: empty_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd9: empty_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd10: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd11: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd12: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd13: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd14: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd15: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd16: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd17: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd18: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd19: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd20: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd21: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd22: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd23: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd24: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd25: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd26: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd27: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd28: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd30: empty_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd31: empty_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		endcase
end
assign empty_block_mem = pix_y % 32;
assign empty_block_index = pix_x % 32;
// empty_block __________________________________________________________
// block ________________________________________________________________
wire [4:0] block_mem, block_index;
reg [0:31] block_data;
always @* begin
	case(block_mem)
		5'd0: block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd2: block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd3: block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd5: block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd6: block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd7: block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd8: block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd9: block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd10: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd11: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd12: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd13: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd14: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd15: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd16: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd17: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd18: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd19: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd20: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd21: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd22: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd23: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd24: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd25: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd26: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd27: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd28: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd30: block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd31: block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		endcase
end
assign block_mem = pix_y % 32;
assign block_index = pix_x % 32;
// block ________________________________________________________________


always @(video_on or robot_on or robot_index or robot_data or block_on or empty_block_on or block_data or empty_block_data or block_index or empty_block_index) begin
	if (~video_on) begin
		r_next = 8'd0;
		g_next = 8'd0;
		b_next = 8'd0;
		end
	else if(robot_on) begin
		case(robot_data[robot_index +: 3]) 
		3'd0: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end //grey
		3'd1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
		3'd2: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end //white
		3'd3: begin r_next = 8'd168; g_next = 8'd168; b_next = 8'd168; end //grey(darker)
		3'd4: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd0; end //yellow
		3'd5: begin r_next = 8'd255; g_next = 8'd0; b_next = 8'd0; end //red
		3'd6: begin r_next = 8'd92; g_next = 8'd64; b_next = 8'd51; end //brown
		default: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end// white
		endcase
	end
	else if(block_on) begin
		case(block_data[block_index])
		1'b0: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end // grey
		1'b1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
		default: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end //white
		endcase
	end
	else if(empty_block_on) begin
		case(empty_block_data[empty_block_index])
		1'b0: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
		1'b1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
		default: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end //white
		endcase
	end
	else begin
		r_next = 8'd255;
		g_next = 8'd255;
		b_next = 8'd255;
	end
	
end

always @(posedge clock_50) begin
    graph_r <= r_next;
    graph_g <= g_next;
    graph_b <= b_next;
end

endmodule