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
reg robot_on, free_path_block_on, wall_block_on;

// internal registers
reg [7:0] r_next, g_next, b_next;

// assignments
// map __________________________________________________________________
wire [3:0] map_y; 
wire [5:0] map_x;
reg [0:59] map_data;
always @(map_x or map_y) begin
	case(map_y)
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
		default: map_data = 60'o0000_0000_0000_0000_0000;
	endcase

	case(map_data[map_x +: 3]) // set flags on according to current map position being drawn
		3'd0: begin wall_block_on = 1'b1; free_path_block_on = 1'b0; robot_on = 1'b0; end
		3'd1: begin wall_block_on = 1'b0; free_path_block_on = 1'b1; robot_on = 1'b0; end
		3'd2: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_on = 1'b1; end
		default: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_on = 1'b0; end
	endcase
end
// map x (0:19) and y (0:14) represent the coordinates of the map blocks
assign map_y = pix_y / 32;
assign map_x = (pix_x / 32) * 3; // (*3 is because each block is represented by 3 bits)
// map __________________________________________________________________

// robot ________________________________________________________________
reg [0:95] robot_data;
wire [4:0] robot_block_y;
wire [6:0] robot_block_x;
always @(robot_block_y) begin
	case(robot_block_y) // ROM memory of Wall-e pixels
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

// robot x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign robot_block_y = pix_y % 32;
assign robot_block_x = (pix_x % 32) * 3; // (*3 is because each color is represented by 3 bits)
// robot ________________________________________________________________

// wall_block __________________________________________________________
wire [4:0] wall_block_y, wall_block_x;
reg [0:31] wall_block_data;
always @(wall_block_y) begin
	case(wall_block_y)
		5'd0: wall_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: wall_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd2: wall_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd3: wall_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: wall_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd5: wall_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd6: wall_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd7: wall_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd8: wall_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd9: wall_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd10: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd11: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd12: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd13: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd14: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd15: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd16: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd17: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd18: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd19: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd20: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd21: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd22: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd23: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd24: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd25: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd26: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd27: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd28: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd30: wall_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd31: wall_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
	endcase
end
// wall_block y and x go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign wall_block_y = pix_y % 32;
assign wall_block_x = pix_x % 32; // colors here are represented by 1 bit
// wall_block __________________________________________________________

// free_path_block ________________________________________________________________
wire [4:0] free_path_block_y, free_path_block_x;
reg [0:31] free_path_block_data;
always @(free_path_block_y) begin
	case(free_path_block_y)
		5'd0: free_path_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: free_path_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd2: free_path_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd3: free_path_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: free_path_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd5: free_path_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd6: free_path_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd7: free_path_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd8: free_path_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd9: free_path_block_data =  32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd10: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd11: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd12: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd13: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd14: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd15: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd16: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd17: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd18: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd19: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd20: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd21: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd22: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd23: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd24: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd25: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd26: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd27: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd28: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd30: free_path_block_data = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
		5'd31: free_path_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
	endcase
end
// free_path_block x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign free_path_block_y = pix_y % 32;
assign free_path_block_x = pix_x % 32; // colors here are represented by 1 bit
// free_path_block ________________________________________________________________

always @* begin
	if (~video_on) begin
        // emit pink when not in video_on
		r_next = 8'd255;
		g_next = 8'd0;
		b_next = 8'd255;
		end
	else if(robot_on) begin
		case(robot_data[robot_block_x +: 3]) 
            3'd0: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end //grey
            3'd1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
            3'd2: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end //white
            3'd3: begin r_next = 8'd168; g_next = 8'd168; b_next = 8'd168; end //grey (darker)
            3'd4: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd0; end //yellow
            3'd5: begin r_next = 8'd255; g_next = 8'd0; b_next = 8'd0; end //red
            3'd6: begin r_next = 8'd92; g_next = 8'd64; b_next = 8'd51; end //brown
            default: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
		endcase
	end
	else if(free_path_block_on) begin
		case(free_path_block_data[free_path_block_x])
            1'b0: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end // grey
            1'b1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
            default: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end //white
		endcase
	end
	else if(wall_block_on) begin
		case(wall_block_data[wall_block_x])
            1'b0: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
            1'b1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
            default: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end //white
		endcase
	end
	else begin
        // emit red when not in any block
		r_next = 8'd255;
		g_next = 8'd0;
		b_next = 8'd0;
	end
end

always @(posedge clock_50) begin
    graph_r <= r_next;
    graph_g <= g_next;
    graph_b <= b_next;
end

endmodule