module graphics (clock_50, video_on, pix_x, pix_y, graph_r, graph_g, graph_b, sprite, flags, robot_type);
input wire clock_50, video_on;
input wire [9:0] pix_x, pix_y;
input wire [3:0] sprite; //hexadecimal code of the current sprite
input wire [1:0] flags; // 1 é o flag do robô, 0 é o flag do cursor
input wire [4:0] robot_type;
output reg [7:0] graph_r, graph_g, graph_b;

// posições máximas dos pixels do display de gráfico
parameter MAX_X = 640;
parameter MAX_Y = 480;

// agora, os parâmetros da coluna 
parameter WALL_X_L = 30;
parameter WALL_X_R = 40;

// internal wires
reg robot_north_on, free_path_block_on, wall_block_on, black_block_on, trash_1_on, trash_2_on, trash_3_on, robot_south_on, robot_east_on, robot_west_on;
// 20x15 sprites map
// internal registers
reg [7:0] r_next, g_next, b_next, r_transparent, g_transparent, b_transparent;

// assignments
// map __________________________________________________________________
//wire [3:0] map_y; 
//wire [5:0] map_x;
//reg [0:59] map_data;
//always @(map_x or map_y) begin // mapa TEMPORÁRIO, não será com ROM no final. Apenas para fins de testes iniciais!!!
//	case(map_y)
//		4'd0: map_data =  60'o0000_0000_0111_1110_0000;
//		4'd1: map_data =  60'o0000_0000_0100_0010_0000;
//		4'd2: map_data =  60'o0000_0100_0300_0011_1111;
//		4'd3: map_data =  60'o0000_0111_1100_0000_0000;
//		4'd4: map_data =  60'o0000_0100_0100_0000_1111;
//		4'd5: map_data =  60'o0000_0100_0100_0111_1000;
//		4'd6: map_data =  60'o1111_1100_0411_1100_0000;
//		4'd7: map_data =  60'o1001_1100_0000_1011_1111;
//		4'd8: map_data =  60'o2000_0100_0000_1001_0000;
//		4'd9: map_data =  60'o6001_1111_1101_1511_0000;
//		4'd10: map_data = 60'o0000_0000_0000_0000_0000;
//		4'd11: map_data = 60'o0000_0000_0000_0000_0000;
//		4'd12: map_data = 60'o0000_0000_0000_0000_0000;
//		4'd13: map_data = 60'o0000_0000_0000_0000_0000;
//		4'd14: map_data = 60'o0000_0000_0000_0000_0000;
//		default: map_data = 60'o0000_0000_0000_0000_0000;
//	endcase
//
//always @* begin
//	case(map_data[map_x +: 3]) // Set the flags according to the current map position being drawn. Map_x is set accordingly to the current pixel.
//		3'd0: begin wall_block_on = 1'b1; free_path_block_on = 1'b0; robot_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0; end
//		3'd1: begin wall_block_on = 1'b0; free_path_block_on = 1'b1; robot_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0;end
//		3'd2: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_on = 1'b1; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0;end
//		3'd3: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_on = 1'b0; trash_1_on = 1'b1; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0;end
//		3'd4: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b1; trash_3_on = 1'b0; black_block_on = 1'b0;end
//		3'd5: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b1; black_block_on = 1'b0;end
//		3'd6: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b1;end
//		default: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0;end
//	endcase
//end
//// map x (0:19) and y (0:14) represent the coordinates of the map blocks
//assign map_y = pix_y / 32;
//assign map_x = (pix_x / 32) * 3; // (*3 is because each block is represented by 3 bits)
// map __________________________________________________________________
always @* begin
	case(sprite) // Set the flags according to the current map position being drawn. Map_x is set accordingly to the current pixel.
		4'd0: begin wall_block_on = 1'b1; free_path_block_on = 1'b0; robot_north_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0; robot_south_on = 1'b0; robot_east_on = 1'b0; robot_west_on = 1'b0; end //wall
		4'd1: begin wall_block_on = 1'b0; free_path_block_on = 1'b1; robot_north_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0; robot_south_on = 1'b0; robot_east_on = 1'b0; robot_west_on = 1'b0; end //free path
		4'd2: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_north_on = 1'b1; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0; robot_south_on = 1'b0; robot_east_on = 1'b0; robot_west_on = 1'b0; end //robot_north
		4'd3: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_north_on = 1'b0; trash_1_on = 1'b1; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0; robot_south_on = 1'b0; robot_east_on = 1'b0; robot_west_on = 1'b0; end //trash 1
		4'd4: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_north_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b1; trash_3_on = 1'b0; black_block_on = 1'b0; robot_south_on = 1'b0; robot_east_on = 1'b0; robot_west_on = 1'b0; end //trash 2
		4'd5: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_north_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b1; black_block_on = 1'b0; robot_south_on = 1'b0; robot_east_on = 1'b0; robot_west_on = 1'b0; end //trash 3
		4'd6: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_north_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b1; robot_south_on = 1'b0; robot_east_on = 1'b0; robot_west_on = 1'b0; end //black_block
		4'd7: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_north_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0; robot_south_on = 1'b1; robot_east_on = 1'b0; robot_west_on = 1'b0; end //robot_south 
		4'd8: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_north_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0; robot_south_on = 1'b0; robot_east_on = 1'b1; robot_west_on = 1'b0; end //robot_east
		4'd9: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_north_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0; robot_south_on = 1'b0; robot_east_on = 1'b0; robot_west_on = 1'b1; end //robot_west
		default: begin wall_block_on = 1'b0; free_path_block_on = 1'b0; robot_north_on = 1'b0; trash_1_on = 1'b0; trash_2_on = 1'b0; trash_3_on = 1'b0; black_block_on = 1'b0; robot_south_on = 1'b0; robot_east_on =1'b0; robot_west_on = 1'b0; end //nothing
	endcase
end				
// robot_north ________________________________________________________________
reg [0:95] robot_north_data;
wire [4:0] robot_north_block_y;
wire [6:0] robot_north_block_x;
always @(robot_north_block_y) begin
	case(robot_north_block_y) // ROM memory of Wall-e pixels
		5'd0: robot_north_data =  96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: robot_north_data =  96'o1555_5555_5555_5555_5555_5555_5555_5551;
		5'd2: robot_north_data =  96'o1555_5555_5555_5555_5555_5555_5555_5551;
		5'd3: robot_north_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: robot_north_data =  96'o1000_0000_0000_0100_0001_0000_0000_0001;
		5'd5: robot_north_data =  96'o1000_0000_0000_1110_0011_1000_0000_0001;
		5'd6: robot_north_data =  96'o1000_0000_0001_1211_1112_1100_0000_0001;
		5'd7: robot_north_data =  96'o1000_0000_0011_2221_1122_2110_0000_0001;
		5'd8: robot_north_data =  96'o1000_0000_0112_2221_1122_2211_0000_0001;
		5'd9: robot_north_data =  96'o1000_0000_1122_1122_1221_1221_1000_0001;
		5'd10: robot_north_data = 96'o1000_0001_1221_3212_1212_3122_1100_0001;
		5'd11: robot_north_data = 96'o1000_0011_2221_3312_1213_3122_2110_0001;
		5'd12: robot_north_data = 96'o1000_0012_2222_1122_1221_1222_2210_0001;
		5'd13: robot_north_data = 96'o1000_0012_2222_2221_6122_2222_2210_0001;
		5'd14: robot_north_data = 96'o1000_0012_2222_2221_6122_2222_2210_0001;
		5'd15: robot_north_data = 96'o1000_0001_2222_2211_6112_2222_2100_0001;
		5'd16: robot_north_data = 96'o1000_0000_1111_1111_6111_1111_1000_0001;
		5'd17: robot_north_data = 96'o1000_0000_0000_0001_6100_0000_0000_0001;
		5'd18: robot_north_data = 96'o1000_0000_0006_6666_6666_6600_0000_0001;
		5'd19: robot_north_data = 96'o1000_0000_6666_3333_3333_3666_6000_0001;
		5'd20: robot_north_data = 96'o1000_0000_6336_6666_6666_6633_6000_0001;
		5'd21: robot_north_data = 96'o1000_0000_6334_4111_1111_4433_6000_0001;
		5'd22: robot_north_data = 96'o1000_0000_6364_4144_4441_4463_6000_0001;
		5'd23: robot_north_data = 96'o1000_0000_0664_4144_4441_4466_0000_0001;
		5'd24: robot_north_data = 96'o1000_0000_0114_4144_4551_4411_0000_0001;
		5'd25: robot_north_data = 96'o1000_0000_0114_4444_4554_4411_0000_0001;
		5'd26: robot_north_data = 96'o1000_0000_0111_1100_0001_1111_0000_0001;
		5'd27: robot_north_data = 96'o1000_0000_0111_1100_0001_1111_0000_0001;
		5'd28: robot_north_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: robot_north_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd30: robot_north_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd31: robot_north_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		default: robot_north_data=96'o0000_0000_0000_0000_0000_0000_0000_0000;
	endcase
end

// robot x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign robot_north_block_y = pix_y % 32;
assign robot_north_block_x = (pix_x % 32) * 3; // (*3 is because each color is represented by 3 bits)
// robot_north ________________________________________________________________
// robot_south ________________________________________________________________
reg [0:95] robot_south_data;
wire [4:0] robot_south_block_y;
wire [6:0] robot_south_block_x;
always @(robot_south_block_y) begin
	case(robot_south_block_y) // ROM memory of Wall-e pixels
		5'd0: robot_south_data =  96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: robot_south_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd2: robot_south_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd3: robot_south_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: robot_south_data =  96'o1000_0000_0000_0100_0001_0000_0000_0001;
		5'd5: robot_south_data =  96'o1000_0000_0000_1110_0011_1000_0000_0001;
		5'd6: robot_south_data =  96'o1000_0000_0001_1211_1112_1100_0000_0001;
		5'd7: robot_south_data =  96'o1000_0000_0011_2221_1122_2110_0000_0001;
		5'd8: robot_south_data =  96'o1000_0000_0112_2221_1122_2211_0000_0001;
		5'd9: robot_south_data =  96'o1000_0000_1122_1122_1221_1221_1000_0001;
		5'd10: robot_south_data = 96'o1000_0001_1221_3212_1212_3122_1100_0001;
		5'd11: robot_south_data = 96'o1000_0011_2221_3312_1213_3122_2110_0001;
		5'd12: robot_south_data = 96'o1000_0012_2222_1122_1221_1222_2210_0001;
		5'd13: robot_south_data = 96'o1000_0012_2222_2221_6122_2222_2210_0001;
		5'd14: robot_south_data = 96'o1000_0012_2222_2221_6122_2222_2210_0001;
		5'd15: robot_south_data = 96'o1000_0001_2222_2211_6112_2222_2100_0001;
		5'd16: robot_south_data = 96'o1000_0000_1111_1111_6111_1111_1000_0001;
		5'd17: robot_south_data = 96'o1000_0000_0000_0001_6100_0000_0000_0001;
		5'd18: robot_south_data = 96'o1000_0000_0006_6666_6666_6600_0000_0001;
		5'd19: robot_south_data = 96'o1000_0000_6666_3333_3333_3666_6000_0001;
		5'd20: robot_south_data = 96'o1000_0000_6336_6666_6666_6633_6000_0001;
		5'd21: robot_south_data = 96'o1000_0000_6334_4111_1111_4433_6000_0001;
		5'd22: robot_south_data = 96'o1000_0000_6364_4144_4441_4463_6000_0001;
		5'd23: robot_south_data = 96'o1000_0000_0664_4144_4441_4466_0000_0001;
		5'd24: robot_south_data = 96'o1000_0000_0114_4144_4551_4411_0000_0001;
		5'd25: robot_south_data = 96'o1000_0000_0114_4444_4554_4411_0000_0001;
		5'd26: robot_south_data = 96'o1000_0000_0111_1100_0001_1111_0000_0001;
		5'd27: robot_south_data = 96'o1000_0000_0111_1100_0001_1111_0000_0001;
		5'd28: robot_south_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: robot_south_data = 96'o1555_5555_5555_5555_5555_5555_5555_5551;
		5'd30: robot_south_data = 96'o1555_5555_5555_5555_5555_5555_5555_5551;
		5'd31: robot_south_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		default: robot_south_data = 96'o0000_0000_0000_0000_0000_0000_0000_0000;
	endcase
end

// robot x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign robot_south_block_y = pix_y % 32;
assign robot_south_block_x = (pix_x % 32) * 3; // (*3 is because each color is represented by 3 bits)
// robot ________________________________________________________________
// robot ________________________________________________________________
reg [0:95] robot_east_data;
wire [4:0] robot_east_block_y;
wire [6:0] robot_east_block_x;
always @(robot_east_block_y) begin
	case(robot_east_block_y) // ROM memory of Wall-e pixels
		5'd0: robot_east_data =  96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: robot_east_data =  96'o1000_0000_0000_0000_0000_0000_0000_0551;
		5'd2: robot_east_data =  96'o1000_0000_0000_0000_0000_0000_0000_0551;
		5'd3: robot_east_data =  96'o1000_0000_0000_0000_0000_0000_0000_0551;
		5'd4: robot_east_data =  96'o1000_0000_0000_0100_0001_0000_0000_0551;
		5'd5: robot_east_data =  96'o1000_0000_0000_1110_0011_1000_0000_0551;
		5'd6: robot_east_data =  96'o1000_0000_0001_1211_1112_1100_0000_0551;
		5'd7: robot_east_data =  96'o1000_0000_0011_2221_1122_2110_0000_0551;
		5'd8: robot_east_data =  96'o1000_0000_0112_2221_1122_2211_0000_0551;
		5'd9: robot_east_data =  96'o1000_0000_1122_1122_1221_1221_1000_0551;
		5'd10: robot_east_data = 96'o1000_0001_1221_3212_1212_3122_1100_0551;
		5'd11: robot_east_data = 96'o1000_0011_2221_3312_1213_3122_2110_0551;
		5'd12: robot_east_data = 96'o1000_0012_2222_1122_1221_1222_2210_0551;
		5'd13: robot_east_data = 96'o1000_0012_2222_2221_6122_2222_2210_0551;
		5'd14: robot_east_data = 96'o1000_0012_2222_2221_6122_2222_2210_0551;
		5'd15: robot_east_data = 96'o1000_0001_2222_2211_6112_2222_2100_0551;
		5'd16: robot_east_data = 96'o1000_0000_1111_1111_6111_1111_1000_0551;
		5'd17: robot_east_data = 96'o1000_0000_0000_0001_6100_0000_0000_0551;
		5'd18: robot_east_data = 96'o1000_0000_0006_6666_6666_6600_0000_0551;
		5'd19: robot_east_data = 96'o1000_0000_6666_3333_3333_3666_6000_0551;
		5'd20: robot_east_data = 96'o1000_0000_6336_6666_6666_6633_6000_0551;
		5'd21: robot_east_data = 96'o1000_0000_6334_4111_1111_4433_6000_0551;
		5'd22: robot_east_data = 96'o1000_0000_6364_4144_4441_4463_6000_0551;
		5'd23: robot_east_data = 96'o1000_0000_0664_4144_4441_4466_0000_0551;
		5'd24: robot_east_data = 96'o1000_0000_0114_4144_4551_4411_0000_0551;
		5'd25: robot_east_data = 96'o1000_0000_0114_4444_4554_4411_0000_0551;
		5'd26: robot_east_data = 96'o1000_0000_0111_1100_0001_1111_0000_0551;
		5'd27: robot_east_data = 96'o1000_0000_0111_1100_0001_1111_0000_0551;
		5'd28: robot_east_data = 96'o1000_0000_0000_0000_0000_0000_0000_0551;
		5'd29: robot_east_data = 96'o1000_0000_0000_0000_0000_0000_0000_0551;
		5'd30: robot_east_data = 96'o1000_0000_0000_0000_0000_0000_0000_0551;
		5'd31: robot_east_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		default: robot_east_data = 96'o0000_0000_0000_0000_0000_0000_0000_0000;
	endcase
end

// robot x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign robot_east_block_y = pix_y % 32;
assign robot_east_block_x = (pix_x % 32) * 3; // (*3 is because each color is represented by 3 bits)
// robot ________________________________________________________________

// robot ________________________________________________________________
//case(robot_east_data[robot_east_block_x +: 3])
//				3'd0: begin r_transparent = 8'd190; g_transparent = 8'd190; b_transparent = 8'd190; end //grey
//				3'd1: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end //black
//				3'd2: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end //white
//				3'd3: begin r_transparent = 8'd168; g_transparent = 8'd168; b_transparent = 8'd168; end //grey (darker)
//				3'd4: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd0; end //yellow
//				3'd5: begin r_transparent = 8'd255; g_transparent = 8'd0; b_transparent = 8'd0; end //red
//				3'd6: begin r_transparent = 8'd92; g_transparent = 8'd64; b_transparent = 8'd51; end //brown
//					default: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end // white
reg [0:95] robot_west_data;
wire [4:0] robot_west_block_y;
wire [6:0] robot_west_block_x;
always @(robot_west_block_y) begin
	case(robot_west_block_y) // ROM memory of Wall-e pixels
		5'd0: robot_west_data =  96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: robot_west_data =  96'o1550_0000_0000_0000_0000_0000_0000_0001;
		5'd2: robot_west_data =  96'o1550_0000_0000_0000_0000_0000_0000_0001;
		5'd3: robot_west_data =  96'o1550_0000_0000_0000_0000_0000_0000_0001;
		5'd4: robot_west_data =  96'o1550_0000_0000_0100_0001_0000_0000_0001;
		5'd5: robot_west_data =  96'o1550_0000_0000_1110_0011_1000_0000_0001;
		5'd6: robot_west_data =  96'o1550_0000_0001_1211_1112_1100_0000_0001;
		5'd7: robot_west_data =  96'o1550_0000_0011_2221_1122_2110_0000_0001;
		5'd8: robot_west_data =  96'o1550_0000_0112_2221_1122_2211_0000_0001;
		5'd9: robot_west_data =  96'o1550_0000_1122_1122_1221_1221_1000_0001;
		5'd10: robot_west_data = 96'o1550_0001_1221_3212_1212_3122_1100_0001;
		5'd11: robot_west_data = 96'o1550_0011_2221_3312_1213_3122_2110_0001;
		5'd12: robot_west_data = 96'o1550_0012_2222_1122_1221_1222_2210_0001;
		5'd13: robot_west_data = 96'o1550_0012_2222_2221_6122_2222_2210_0001;
		5'd14: robot_west_data = 96'o1550_0012_2222_2221_6122_2222_2210_0001;
		5'd15: robot_west_data = 96'o1550_0001_2222_2211_6112_2222_2100_0001;
		5'd16: robot_west_data = 96'o1550_0000_1111_1111_6111_1111_1000_0001;
		5'd17: robot_west_data = 96'o1550_0000_0000_0001_6100_0000_0000_0001;
		5'd18: robot_west_data = 96'o1550_0000_0006_6666_6666_6600_0000_0001;
		5'd19: robot_west_data = 96'o1550_0000_6666_3333_3333_3666_6000_0001;
		5'd20: robot_west_data = 96'o1550_0000_6336_6666_6666_6633_6000_0001;
		5'd21: robot_west_data = 96'o1550_0000_6334_4111_1111_4433_6000_0001;
		5'd22: robot_west_data = 96'o1550_0000_6364_4144_4441_4463_6000_0001;
		5'd23: robot_west_data = 96'o1550_0000_0664_4144_4441_4466_0000_0001;
		5'd24: robot_west_data = 96'o1550_0000_0114_4144_4551_4411_0000_0001;
		5'd25: robot_west_data = 96'o1550_0000_0114_4444_4554_4411_0000_0001;
		5'd26: robot_west_data = 96'o1550_0000_0111_1100_0001_1111_0000_0001;
		5'd27: robot_west_data = 96'o1550_0000_0111_1100_0001_1111_0000_0001;
		5'd28: robot_west_data = 96'o1550_0000_0000_0000_0000_0000_0000_0001;
		5'd29: robot_west_data = 96'o1550_0000_0000_0000_0000_0000_0000_0001;
		5'd30: robot_west_data = 96'o1550_0000_0000_0000_0000_0000_0000_0001;
		5'd31: robot_west_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		default: robot_west_data = 96'o0000_0000_0000_0000_0000_0000_0000_0000;
	endcase
end

// robot x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign robot_west_block_y = pix_y % 32;
assign robot_west_block_x = (pix_x % 32) * 3; // (*3 is because each color is represented by 3 bits)
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
		default: wall_block_data = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
	endcase
end
// wall_block y and x go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign wall_block_y = pix_y % 32;
assign wall_block_x = pix_x % 32; // colors here are represented by 1 bit
// wall_block __________________________________________________________
// black_block __________________________________________________________
wire [4:0] black_block_y, black_block_x;
reg [0:31] black_block_data;
always @(black_block_y) begin
	case(black_block_y)
		5'd0: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd2: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd3: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd4: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd5: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd6: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd7: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd8: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd9: black_block_data =  32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd10: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd11: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd12: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd13: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd14: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd15: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd16: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd17: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd18: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd19: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd20: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd21: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd22: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd23: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd24: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd25: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd26: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd27: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd28: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd29: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd30: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		5'd31: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
		default: black_block_data = 32'b1111_1111_1111_1111_1111_1111_1111_1111;
	endcase
end
// wall_block y and x go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign black_block_y = pix_y % 32;
assign black_block_x = pix_x % 32; // colors here are represented by 1 bit
// black_block __________________________________________________________

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
		default: free_path_block_data = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
	endcase
end
// free_path_block x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign free_path_block_y = pix_y % 32;
assign free_path_block_x = pix_x % 32; // colors here are represented by 1 bit
// free_path_block ________________________________________________________________
// trash_1 ________________________________________________________________________
wire [4:0] trash_1_y;
wire [6:0] trash_1_x;
reg [0:95] trash_1_data;
always @(trash_1_y) begin
	case(trash_1_y)
		5'd0: trash_1_data =  96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: trash_1_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd2: trash_1_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd3: trash_1_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: trash_1_data =  96'o1000_0000_0000_1100_0000_0000_0000_0001;
		5'd5: trash_1_data =  96'o1000_0000_0001_3310_0000_0000_0000_0001;
		5'd6: trash_1_data =  96'o1000_0000_0001_3231_0000_0000_0000_0001;
		5'd7: trash_1_data =  96'o1000_0000_0001_3221_0000_0000_0000_0001;
		5'd8: trash_1_data =  96'o1000_0000_0001_2210_0000_0000_0000_0001;
		5'd9: trash_1_data =  96'o1000_0000_0001_1110_0000_0000_0000_0001;
		5'd10: trash_1_data = 96'o1000_0000_0112_2221_1000_0000_0000_0001;
		5'd11: trash_1_data = 96'o1000_0000_1333_3332_2100_0000_0000_0001;
		5'd12: trash_1_data = 96'o1000_0001_3333_3333_3211_0000_0000_0001;
		5'd13: trash_1_data = 96'o1000_0013_3333_3333_3322_1000_0000_0001;
		5'd14: trash_1_data = 96'o1000_0013_3333_3333_3322_2100_0000_0001;
		5'd15: trash_1_data = 96'o1000_0013_3333_4443_3322_2100_0000_0001;
		5'd16: trash_1_data = 96'o1000_0133_3333_4443_3322_2210_0000_0001;
		5'd17: trash_1_data = 96'o1000_0133_3333_4443_3222_2210_0000_0001;
		5'd18: trash_1_data = 96'o1000_0133_3333_4443_2222_2221_0000_0001;
		5'd19: trash_1_data = 96'o1000_0133_3333_4442_2222_2221_0000_0001;
		5'd20: trash_1_data = 96'o1000_1223_3333_4443_3222_2221_0000_0001;
		5'd21: trash_1_data = 96'o1000_1333_3333_4443_3322_2221_0000_0001;
		5'd22: trash_1_data = 96'o1000_1333_3333_3333_3322_2221_0000_0001;
		5'd23: trash_1_data = 96'o1000_1233_3333_3333_3222_2221_0000_0001;
		5'd24: trash_1_data = 96'o1000_0122_2333_3322_2222_2221_0000_0001;
		5'd25: trash_1_data = 96'o1000_0012_2222_2222_2222_2210_0000_0001;
		5'd26: trash_1_data = 96'o1000_0011_2222_2222_2211_1100_0000_0001;
		5'd27: trash_1_data = 96'o1000_0000_1111_1111_1100_0000_0000_0001;
		5'd28: trash_1_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: trash_1_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd30: trash_1_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd31: trash_1_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		default: trash_1_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
	endcase
end
// trash_1_data x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign trash_1_y = pix_y % 32;
assign trash_1_x = (pix_x % 32) * 3; // colors here are represented by 1 bit

// trash_1 ________________________________________________________________________
// trash_2 ________________________________________________________________________
wire [4:0] trash_2_y;
wire [6:0] trash_2_x;
reg [0:95] trash_2_data;
always @(trash_2_y) begin
	case(trash_2_y)
		5'd0: trash_2_data =  96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: trash_2_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd2: trash_2_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd3: trash_2_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: trash_2_data =  96'o1000_0000_0000_1100_0000_0000_0000_0001;
		5'd5: trash_2_data =  96'o1000_0000_0001_3310_0000_0000_0000_0001;
		5'd6: trash_2_data =  96'o1000_0000_0001_3231_0000_0000_0000_0001;
		5'd7: trash_2_data =  96'o1000_0000_0001_3221_0000_0000_0000_0001;
		5'd8: trash_2_data =  96'o1000_0000_0001_2210_0000_0000_0000_0001;
		5'd9: trash_2_data =  96'o1000_0000_0001_1110_0000_0000_0000_0001;
		5'd10: trash_2_data = 96'o1000_0000_0112_2221_1000_0000_0000_0001;
		5'd11: trash_2_data = 96'o1000_0000_1333_3332_2100_0000_0000_0001;
		5'd12: trash_2_data = 96'o1000_0001_3333_3333_3211_0000_0000_0001;
		5'd13: trash_2_data = 96'o1000_0013_3333_3333_3322_1000_0000_0001;
		5'd14: trash_2_data = 96'o1000_0013_3333_3333_3322_2100_0000_0001;
		5'd15: trash_2_data = 96'o1000_0013_3344_4443_3322_2100_0000_0001;
		5'd16: trash_2_data = 96'o1000_0133_3344_4443_3322_2210_0000_0001;
		5'd17: trash_2_data = 96'o1000_0133_3333_3443_3222_2210_0000_0001;
		5'd18: trash_2_data = 96'o1000_0133_3333_3443_2222_2221_0000_0001;
		5'd19: trash_2_data = 96'o1000_0133_3344_4442_2222_2221_0000_0001;
		5'd20: trash_2_data = 96'o1000_1223_3344_4443_3222_2221_0000_0001;
		5'd21: trash_2_data = 96'o1000_1333_3344_3333_3322_2221_0000_0001;
		5'd22: trash_2_data = 96'o1000_1333_3344_3333_3322_2221_0000_0001;
		5'd23: trash_2_data = 96'o1000_1233_3344_4443_3222_2221_0000_0001;
		5'd24: trash_2_data = 96'o1000_0122_2344_4442_2222_2221_0000_0001;
		5'd25: trash_2_data = 96'o1000_0012_2222_2222_2222_2210_0000_0001;
		5'd26: trash_2_data = 96'o1000_0011_2222_2222_2211_1100_0000_0001;
		5'd27: trash_2_data = 96'o1000_0000_1111_1111_1100_0000_0000_0001;
		5'd28: trash_2_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: trash_2_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd30: trash_2_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd31: trash_2_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		default: trash_2_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
	endcase
end
// trash_2_data x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign trash_2_y = pix_y % 32;
assign trash_2_x = (pix_x % 32) * 3; // colors here are represented by 1 bit

// trash_2 ________________________________________________________________________
// trash_3 ________________________________________________________________________
wire [4:0] trash_3_y; 
wire [6:0] trash_3_x;
reg [0:95] trash_3_data;
always @(trash_3_y) begin
	case(trash_3_y)
		5'd0: trash_3_data =  96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: trash_3_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd2: trash_3_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd3: trash_3_data =  96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd4: trash_3_data =  96'o1000_0000_0000_1100_0000_0000_0000_0001;
		5'd5: trash_3_data =  96'o1000_0000_0001_3310_0000_0000_0000_0001;
		5'd6: trash_3_data =  96'o1000_0000_0001_3231_0000_0000_0000_0001;
		5'd7: trash_3_data =  96'o1000_0000_0001_3221_0000_0000_0000_0001;
		5'd8: trash_3_data =  96'o1000_0000_0001_2210_0000_0000_0000_0001;
		5'd9: trash_3_data =  96'o1000_0000_0001_1110_0000_0000_0000_0001;
		5'd10: trash_3_data = 96'o1000_0000_0112_2221_1000_0000_0000_0001;
		5'd11: trash_3_data = 96'o1000_0000_1333_3332_2100_0000_0000_0001;
		5'd12: trash_3_data = 96'o1000_0001_3333_3333_3211_0000_0000_0001;
		5'd13: trash_3_data = 96'o1000_0013_3333_3333_3322_1000_0000_0001;
		5'd14: trash_3_data = 96'o1000_0013_3333_3333_3322_2100_0000_0001;
		5'd15: trash_3_data = 96'o1000_0013_3344_4443_3322_2100_0000_0001;
		5'd16: trash_3_data = 96'o1000_0133_3344_4443_3322_2210_0000_0001;
		5'd17: trash_3_data = 96'o1000_0133_3333_3443_3222_2210_0000_0001;
		5'd18: trash_3_data = 96'o1000_0133_3333_3443_2222_2221_0000_0001;
		5'd19: trash_3_data = 96'o1000_0133_3344_4442_2222_2221_0000_0001;
		5'd20: trash_3_data = 96'o1000_1223_3344_4443_3222_2221_0000_0001;
		5'd21: trash_3_data = 96'o1000_1333_3333_3443_3322_2221_0000_0001;
		5'd22: trash_3_data = 96'o1000_1333_3333_3443_3322_2221_0000_0001;
		5'd23: trash_3_data = 96'o1000_1233_3344_4443_3222_2221_0000_0001;
		5'd24: trash_3_data = 96'o1000_0122_2344_4442_2222_2221_0000_0001;
		5'd25: trash_3_data = 96'o1000_0012_2222_2222_2222_2210_0000_0001;
		5'd26: trash_3_data = 96'o1000_0011_2222_2222_2211_1100_0000_0001;
		5'd27: trash_3_data = 96'o1000_0000_1111_1111_1100_0000_0000_0001;
		5'd28: trash_3_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd29: trash_3_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd30: trash_3_data = 96'o1000_0000_0000_0000_0000_0000_0000_0001;
		5'd31: trash_3_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		default: trash_3_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
	endcase
end
// trash_3_data x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign trash_3_y = pix_y % 32;
assign trash_3_x = (pix_x % 32) * 3; // colors here are represented by 1 bit

// trash_3 ________________________________________________________________________
// cursor ________________________________________________________________________
wire [4:0] cursor_y; 
wire [6:0] cursor_x;
reg [0:95] cursor_data;
always @(cursor_y) begin
	case(cursor_y)
		5'd0: cursor_data =  96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd1: cursor_data =  96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd2: cursor_data =  96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd3: cursor_data =  96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd4: cursor_data =  96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd5: cursor_data =  96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd6: cursor_data =  96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd7: cursor_data =  96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd8: cursor_data =  96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd9: cursor_data =  96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd10: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd11: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd12: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd13: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd14: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd15: cursor_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd16: cursor_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		5'd17: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd18: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd19: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd20: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd21: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd22: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd23: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd24: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd25: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd26: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd27: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd28: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd29: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd30: cursor_data = 96'o1000_0000_0000_0001_1000_0000_0000_0001;
		5'd31: cursor_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
		default: cursor_data = 96'o1111_1111_1111_1111_1111_1111_1111_1111;
	endcase
end
// cursor_data x and y go from 0 to 31 and represent relative position of the pixel on the 32x32 block
assign cursor_y = pix_y % 32;
assign cursor_x = (pix_x % 32) * 3; // colors here are represented by 1 bit

// trash_3 ________________________________________________________________________

always @* begin
	if (~video_on) begin
		r_next = 8'd0; g_next = 8'd0; b_next = 8'd0;
    end
	else if(black_block_on) begin
		case(black_block_data[black_block_x +: 3]) 
            3'd0: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //grey
            3'd1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
            3'd2: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //white
            3'd3: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //grey (darker)
            3'd4: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //yellow
            3'd5: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //red
            3'd6: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //brown
            default: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end // white
		endcase
	end
	else if(trash_1_on) begin
		case(trash_1_data[trash_1_x +: 3]) 
            3'd0: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end //grey
            3'd1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
            3'd2: begin r_next = 8'd168; g_next = 8'd168; b_next = 8'd168; end //grey (darker)
            3'd3: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end //grey
            3'd4: begin r_next = 8'd255; g_next = 8'd0; b_next = 8'd0; end //red
            3'd5: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
            3'd6: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
            default: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
		endcase
	end
	else if(trash_2_on) begin
		case(trash_2_data[trash_2_x +: 3]) 
            3'd0: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end //grey
            3'd1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
            3'd2: begin r_next = 8'd168; g_next = 8'd168; b_next = 8'd168; end //grey (darker)
            3'd3: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end //grey
            3'd4: begin r_next = 8'd255; g_next = 8'd0; b_next = 8'd0; end //red
            3'd5: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
            3'd6: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
            default: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
		endcase
	end
	else if(trash_3_on) begin
		case(trash_3_data[trash_3_x +: 3]) 
            3'd0: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end //grey
            3'd1: begin r_next = 8'd0; g_next = 8'd0; b_next = 8'd0; end //black
            3'd2: begin r_next = 8'd168; g_next = 8'd168; b_next = 8'd168; end //grey (darker)
            3'd3: begin r_next = 8'd190; g_next = 8'd190; b_next = 8'd190; end //grey
            3'd4: begin r_next = 8'd255; g_next = 8'd0; b_next = 8'd0; end //red
            3'd5: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
            3'd6: begin r_next = 8'd255; g_next = 8'd255; b_next = 8'd255; end // white
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


always @* begin
	if (~video_on) begin
		r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0;
    end
	else if(flags == 2'b00) begin
		r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0;
	end
	else if(flags == 2'b01) begin
		case(cursor_data[cursor_x +: 3]) 
            3'd0: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end //transparent!
            3'd1: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end //black
            3'd2: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end //white
            3'd3: begin r_transparent = 8'd168; g_transparent = 8'd168; b_transparent = 8'd168; end //grey (darker)
            3'd4: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd0; end //yellow
            3'd5: begin r_transparent = 8'd255; g_transparent = 8'd0; b_transparent = 8'd0; end //red
            3'd6: begin r_transparent = 8'd92; g_transparent = 8'd64; b_transparent = 8'd51; end //brown
            default: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end // white
		endcase
		end
	else if(flags == 2'b10) begin
		robot_rgb();
	end
	else if(flags == 2'b11) begin
		if (cursor_data[cursor_x +: 3] == 3'd0) begin
			robot_rgb();
		end
		else begin
		case(cursor_data[cursor_x +: 3]) 
            3'd0: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end //transparent!
            3'd1: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end //black
            3'd2: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end //white
            3'd3: begin r_transparent = 8'd168; g_transparent = 8'd168; b_transparent = 8'd168; end //grey (darker)
            3'd4: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd0; end //yellow
            3'd5: begin r_transparent = 8'd255; g_transparent = 8'd0; b_transparent = 8'd0; end //red
            3'd6: begin r_transparent = 8'd92; g_transparent = 8'd64; b_transparent = 8'd51; end //brown
            default: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end // white
		endcase
		end
	end
end

task robot_rgb;
	case (robot_type)
		5'b00010: begin
            case(robot_north_data[robot_north_block_x +: 3])
				3'd0: begin r_transparent = 8'd190; g_transparent = 8'd190; b_transparent = 8'd190; end //grey
				3'd1: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end //black
				3'd2: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end //white
				3'd3: begin r_transparent = 8'd168; g_transparent = 8'd168; b_transparent = 8'd168; end //grey (darker)
				3'd4: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd0; end //yellow
				3'd5: begin r_transparent = 8'd255; g_transparent = 8'd0; b_transparent = 8'd0; end //red
				3'd6: begin r_transparent = 8'd92; g_transparent = 8'd64; b_transparent = 8'd51; end //brown
				default: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end // white
			endcase
		end
		5'b00100: begin
            case(robot_south_data[robot_south_block_x +: 3])
				3'd0: begin r_transparent = 8'd190; g_transparent = 8'd190; b_transparent = 8'd190; end //grey
				3'd1: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end //black
				3'd2: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end //white
				3'd3: begin r_transparent = 8'd168; g_transparent = 8'd168; b_transparent = 8'd168; end //grey (darker)
				3'd4: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd0; end //yellow
				3'd5: begin r_transparent = 8'd255; g_transparent = 8'd0; b_transparent = 8'd0; end //red
				3'd6: begin r_transparent = 8'd92; g_transparent = 8'd64; b_transparent = 8'd51; end //brown
				default: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end // white
			endcase
		end
		5'b01000: begin
            case(robot_east_data[robot_east_block_x +: 3])
				3'd0: begin r_transparent = 8'd190; g_transparent = 8'd190; b_transparent = 8'd190; end //grey
				3'd1: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end //black
				3'd2: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end //white
				3'd3: begin r_transparent = 8'd168; g_transparent = 8'd168; b_transparent = 8'd168; end //grey (darker)
				3'd4: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd0; end //yellow
				3'd5: begin r_transparent = 8'd255; g_transparent = 8'd0; b_transparent = 8'd0; end //red
				3'd6: begin r_transparent = 8'd92; g_transparent = 8'd64; b_transparent = 8'd51; end //brown
					default: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end // white
			endcase
		end
		5'b10000: begin
            case(robot_west_data[robot_west_block_x +: 3])
				3'd0: begin r_transparent = 8'd190; g_transparent = 8'd190; b_transparent = 8'd190; end //grey
				3'd1: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end //black
				3'd2: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end //white
				3'd3: begin r_transparent = 8'd168; g_transparent = 8'd168; b_transparent = 8'd168; end //grey (darker)
				3'd4: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd0; end //yellow
				3'd5: begin r_transparent = 8'd255; g_transparent = 8'd0; b_transparent = 8'd0; end //red
				3'd6: begin r_transparent = 8'd92; g_transparent = 8'd64; b_transparent = 8'd51; end //brown
				default: begin r_transparent = 8'd255; g_transparent = 8'd255; b_transparent = 8'd255; end // white
			endcase
		end
		default: begin r_transparent = 8'd0; g_transparent = 8'd0; b_transparent = 8'd0; end
	endcase
endtask

wire [4:0] robots_data;
wire transparency;
assign robots_data = {|robot_west_data[robot_west_block_x +: 3], |robot_east_data[robot_east_block_x +: 3], |robot_south_data[robot_south_block_x +: 3], |robot_north_data[robot_north_block_x +: 3], 1'b0};
assign transparency = |(~robots_data & robot_type);
always @(posedge clock_50) begin
	if (flags) begin
		if(transparency) begin
			graph_r <= r_next;
			graph_g <= g_next;
			graph_b <= b_next;
		end
		else begin
			graph_r <= r_transparent;
			graph_g <= g_transparent;
			graph_b <= b_transparent;
		end
	end
	else begin
		graph_r <= r_next;
		graph_g <= g_next;
		graph_b <= b_next;
	end
end


endmodule