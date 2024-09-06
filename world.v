module world(clock_50, reset_key, mode_toggle, clock_toggle, mode, pixel_x, pixel_y, sprite, robot_cursor_flags, robot_type, control_inputs);
input wire clock_50, reset_key, mode_toggle, clock_toggle;
output reg mode;
input wire [9:0] pixel_x, pixel_y; 
input [11:0] control_inputs;
output wire [3:0] sprite;
output reg [1:0] robot_cursor_flags; // robot_cursor_flags[1] = robot, robot_cursor_flags[0] = cursor
output reg [4:0] robot_type;

parameter north = 4'b0000, south = 4'b0001, east = 4'b0010, west = 4'b0011;
parameter wall = 4'b0000, free_path = 4'b0001, trash_1 = 4'b0011, trash_2 = 4'b0100, trash_3 = 4'b0101, black_block = 4'b0110;

// Internal regs
reg robot_clock;
reg head_next, head_reg, left_next, left_reg, under_next, under_reg, barrier_next, barrier_reg; // Inputs for robot
reg [1:8] robot_row_reg, robot_row_next, robot_column_reg, robot_column_next;
reg [1:4] robot_orientation_reg, robot_orientation_next;
reg [1:0] trash_removal_state_next, trash_removal_state_reg;


//
reg [1:8] cursor_row_next, cursor_row_reg, cursor_column_next, cursor_column_reg;
reg pause_flag_reg, pause_flag_next, map_change_flag_reg, map_change_flag_next;
reg [1:9] cursor_address_next, cursor_address_reg;
reg [3:0] sprite_temp_robot_reg, sprite_temp_robot_next;
//
reg  [3:0] sprite_temp_next, sprite_temp_reg;
reg  [3:0] surroundings_temp_next, surroundings_temp_reg;
reg signed [1:8] row_offset_next, row_offset_reg;
reg signed [1:8] column_offset_next, column_offset_reg;
//
// map is a 16x20 matrix, but only 15x20 is used (first line is used for robot initial data)
// each cell is 4 bits long
// memory must be linear, so every row is concatenated
//

reg [1:9] address_next, address_reg;

reg next_mode, next_robot_clock;


reg reset_flag;

// internal wires
wire front, turn, remove; // Outputs from robot

reg [1:4] map_reg[1:320]; 
reg [1:4] map_next [1:320];

initial begin
    // WARNING: On tb error, check if map.txt is in the same folder as the testbench
	$readmemb("map.txt", map_reg);
	robot_row_reg = {map_reg[1], map_reg[2]};
	robot_column_reg = {map_reg[3], map_reg[4]};
	robot_orientation_reg = map_reg[5];
end
///////////////////////////////////
wire [6:0] sprite_x;
wire [3:0] sprite_y;
reg [1:0] next_robot_cursor_flags;

assign sprite_x = (pixel_x / 32) + 1; // 1-20
assign sprite_y = (pixel_y / 32) + 1; // 1-15
assign sprite = map_reg[get_map_address(sprite_y, sprite_x)];

always @(sprite_x or reset_flag) begin
    if (reset_flag == 1'b1) begin
        next_robot_cursor_flags = 2'b00;
		  robot_type = 5'b00000;
    end
	if ((sprite_x == robot_column_reg) && (sprite_y == robot_row_reg)) begin 
        next_robot_cursor_flags[1] = 1'b1;
		case(robot_orientation_reg)
			north: robot_type = 5'b00010; 
			south: robot_type = 5'b00100;
			east: robot_type = 5'b01000;
			west: robot_type = 5'b10000;
			default: robot_type = 5'b00010;
		endcase
	end
	else begin
      next_robot_cursor_flags[1] = 1'b0;
		robot_type = 5'b00000;
	end
	if ((sprite_x == cursor_column_reg) && (sprite_y == cursor_row_reg)) begin
        next_robot_cursor_flags[0] = 1'b1;
    end
    else 
        next_robot_cursor_flags[0] = 1'b0;
end

///////////////////////////////////
// build robot
robot robot (.clock(robot_clock), .reset(reset_key), .head(head_reg), .left(left_reg), .under(under_reg), .barrier(barrier_reg), .front(front), .turn(turn), .remove(remove));

// TODO control world with remote controller

parameter DIV_FACTOR = 28'd200000000; // Divide by 200Mhz for 0.25hz (1 cycle every 4 seconds)

reg [27:0] counter = 28'b0;

always @(posedge clock_50) begin
    if (reset_key == 1'b0) begin
        counter <= 0;
        robot_clock <= 1'b0;
        mode <= 1'b0;
        reset_flag <= 1'b1;
        robot_cursor_flags <= 2'b00;
    end

    else begin
        reset_flag <= 1'b0;

        if (mode == 1'b0) begin
            count_robot_clock;
        end
        else if (mode == 1'b1) begin
            robot_clock <= next_robot_clock;
        end
        mode <= next_mode;
        robot_cursor_flags <= next_robot_cursor_flags;
    end
end

task count_robot_clock;
    if (counter == DIV_FACTOR - 1'b1) begin
        counter <= 0;
        robot_clock <= 1'b1;
    end
    else begin
        counter <= counter + 1'b1;
        robot_clock <= 1'b0;
    end
endtask

always @(negedge mode_toggle or negedge clock_toggle or posedge reset_flag) begin
    if (reset_flag) begin
        next_mode = 1'b0;
        next_robot_clock = 1'b0;
    end

    else begin
        if (mode_toggle == 1'b0) begin
            next_mode = ~mode;
        end

        if (clock_toggle == 1'b0) begin
            next_robot_clock = ~robot_clock;
        end
    end
end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TODO: VERIFICAR DPS SE ESSE TAMANHO DE BIT DE COLUMN E ROW N VAI DAR PROBLEMA, É O MESMO DO ROBOT


// Saidas[11] = Saida_Mode
// Saidas[10] = Saida_Start
// Saidas[9] = Saida_Z
// Saidas[8] = Saida_Y
// Saidas[7] = Saida_X
// Saidas[6] = Saida_C
// Saidas[5] = Saida_B
// Saidas[4] = Saida_A
// Saidas[3] = Saida_Right
// Saidas[2] = Saida_Left
// Saidas[1] = Saida_Down
// Saidas[0] = Saida_Up

always @(robot_clock or reset_flag) begin
	if (reset_flag) begin
		robot_row_reg = {map_reg[1], map_reg[2]};
		robot_column_reg = {map_reg[3], map_reg[4]};
		robot_orientation_reg = map_reg[5];
		
		
	end
	else begin
		robot_row_reg <= robot_row_next;
		robot_column_reg <= robot_column_next;
		robot_orientation_reg <= robot_orientation_next;
		
	end
end
always @(negedge robot_clock or posedge reset_flag) begin
	if (reset_flag) begin
		trash_removal_state_reg <= 0;
	end
	else begin
		trash_removal_state_reg <= trash_removal_state_next;
	end
end
always @(posedge clock_50 or posedge reset_flag) begin
	head_reg <= head_next;
	left_reg <= left_next;
	under_reg <= under_next;
	barrier_reg <= barrier_next;
end


integer i;

initial begin
    // WARNING: On tb error, check if map.txt is in the same folder as the testbench
	$readmemb("map.txt", map_reg);
end

always @(posedge clock_50 or posedge reset_flag) begin // ------------------------> @(posedge clock_50 or negedge reset_key)
	if (reset_flag) begin 
		$readmemb("map.txt", map_reg);
		cursor_row_reg = 8'b11111110; // out of range;
		cursor_column_reg = 8'b11111110; // out of range;
		pause_flag_reg = 0;
		map_change_flag_reg = 0;
		sprite_temp_robot_reg = free_path;
	end
	else begin 
		cursor_row_reg <= cursor_row_next;
		cursor_column_reg <= cursor_column_next;
		pause_flag_reg <= pause_flag_next;
		map_change_flag_reg <= map_change_flag_next;
		sprite_temp_robot_reg <= sprite_temp_robot_next;
		cursor_address_reg <= cursor_address_next;
		address_reg <= address_next;
		column_offset_reg <= column_offset_next;
		row_offset_reg <= row_offset_next;
		surroundings_temp_reg <= surroundings_temp_next;
		sprite_temp_reg <= sprite_temp_next;
		for (i = 1; i <= 320; i = i + 1) begin
        map_reg[i] = map_next[i];
		end
	end
end
always @(*) begin
    // Atribuições padrão para evitar latch
	 row_offset_next = row_offset_reg;
	 column_offset_next = column_offset_reg;
	 address_next = address_reg;
	 surroundings_temp_next = surroundings_temp_reg;
	 sprite_temp_next = sprite_temp_reg;
    cursor_row_next = cursor_row_reg;
    cursor_column_next = cursor_column_reg;
    pause_flag_next = pause_flag_reg;
    map_change_flag_next = map_change_flag_reg;
    sprite_temp_robot_next = sprite_temp_robot_reg;
    cursor_address_next = cursor_address_reg;
	 head_next = head_reg;
	 left_next = left_reg;
	 under_next = under_reg;
	 barrier_next = barrier_reg;
	 robot_row_next = robot_row_reg;
	 robot_column_next = robot_column_reg;
	 robot_orientation_next = robot_orientation_reg;
	 trash_removal_state_next = trash_removal_state_reg;
	 define_sensors_values;
	for (i = 1; i <= 320; i = i + 1) begin
	    map_next[i] = map_reg[i];
	end
    if (reset_flag) begin
        trash_removal_state_next = 2'b00;
    end
	else begin // robot movement and updates
        if (control_inputs[10]) begin // pause flag!
            pause_flag_next = ~pause_flag_reg;
				cursor_column_next = 8'd1;
            cursor_row_next = 8'd1;
        end  
        if (pause_flag_reg == 0) begin 
            cursor_column_next = 8'd21; // out of display range
            cursor_row_next = 8'd16; // out of display range
            if (robot_clock == 1'b1) begin
                update_robot_position;
                remove_trash;
            end
        end 
        else begin
        // up-down movement
            if (control_inputs[3]) begin //cursor right movement and updates
                if (cursor_column_reg == 20) 
                    cursor_column_next = 8'd1;
                else 
                    cursor_column_next = cursor_column_reg + 8'd1;
            end
            else if (control_inputs[2]) begin //cursor left movement and updates
                if (cursor_column_reg == 1)
                    cursor_column_next = 8'd20;
                else
                    cursor_column_next = cursor_column_reg - 8'd1;
            end
            // right-left movement 
            if (control_inputs[1]) begin //cursor down movement and updates
                if (cursor_row_reg == 15) 
                    cursor_row_next = 8'd1;
                else
                    cursor_row_next = cursor_row_reg + 8'd1;
            end
            else if (control_inputs[0]) begin //cursor up movement and updates
                if (cursor_row_reg == 1)
                    cursor_row_next = 8'd15;
                else
                    cursor_row_next = cursor_row_reg - 8'd1;
            end
            if (control_inputs[9]) begin
                sprite_temp_robot_next = free_path;
                map_change_flag_next = 1;
            end
            else if(control_inputs[8]) begin
                sprite_temp_robot_next = trash_1;
                map_change_flag_next = 1;
            end
            else if(control_inputs[7]) begin
                sprite_temp_robot_next = trash_2;
                map_change_flag_next = 1;
            end
            else if(control_inputs[6]) begin
                sprite_temp_robot_next = trash_3;
                map_change_flag_next = 1;
            end
            else if(control_inputs[5]) begin
                sprite_temp_robot_next = wall;
                map_change_flag_next = 1;
            end
            else if(control_inputs[4]) begin
                sprite_temp_robot_next = black_block;
                map_change_flag_next = 1;
            end
            if (map_change_flag_reg) begin
					 cursor_address_next = get_map_address(cursor_row_reg, cursor_column_reg);
                map_next[cursor_address_reg] = sprite_temp_robot_next;
                map_change_flag_next = 0;
            end
        end
    end
end

task define_sensors_values;
begin
	case(robot_orientation_reg)
        north: begin
            if (robot_row_reg == 1 || map_reg[get_map_address(robot_row_reg - 1, robot_column_reg)] == wall)
                head_next = 1;
            else
                head_next = 0;
            if (robot_column_reg == 1 || map_reg[get_map_address(robot_row_reg, robot_column_reg - 1)] == wall)
                left_next = 1;
            else
                left_next = 0;
            if (map_reg[get_map_address(robot_row_reg, robot_column_reg)] == black_block)
                under_next = 1;
            else
                under_next = 0;
            if ((map_reg[get_map_address(robot_row_reg - 1, robot_column_reg)] == trash_1 || map_reg[get_map_address(robot_row_reg - 1, robot_column_reg)] == trash_2 || map_reg[get_map_address(robot_row_reg - 1, robot_column_reg)] == trash_3) && robot_row_reg != 1)
                barrier_next = 1;
            else
                barrier_next = 0;
        end
        south: begin
            if (robot_row_reg == 10 || map_reg[get_map_address(robot_row_reg + 1, robot_column_reg)] == wall)
                head_next = 1;
            else
                head_next = 0;
            if (robot_column_reg == 20 || map_reg[get_map_address(robot_row_reg, robot_column_reg + 1)] == wall)
                left_next = 1;
            else
                left_next = 0;
            if (map_reg[get_map_address(robot_row_reg, robot_column_reg)] == black_block)
                under_next = 1;
            else
                under_next = 0;
            if (map_reg[get_map_address(robot_row_reg + 1, robot_column_reg)] == trash_1  || map_reg[get_map_address(robot_row_reg + 1, robot_column_reg)] == trash_2 || map_reg[get_map_address(robot_row_reg + 1, robot_column_reg)] == trash_3)
                barrier_next = 1;
            else
                barrier_next = 0;
        end
        east: begin
            if (robot_column_reg == 20 || map_reg[get_map_address(robot_row_reg, robot_column_reg + 1)] == wall)
                head_next = 1;
            else
                head_next = 0;
            if (robot_row_reg == 1 || map_reg[get_map_address(robot_row_reg - 1, robot_column_reg)] == wall)
                left_next = 1;
            else
                left_next = 0;
            if (map_reg[get_map_address(robot_row_reg, robot_column_reg)] == black_block)
                under_next = 1;
            else
                under_next = 0;
            if (map_reg[get_map_address(robot_row_reg, robot_column_reg + 1)] == trash_1 || map_reg[get_map_address(robot_row_reg, robot_column_reg + 1)] == trash_2 || map_reg[get_map_address(robot_row_reg, robot_column_reg + 1)] == trash_3)
                barrier_next = 1;
            else
                barrier_next = 0;
        end
        west: begin
            if (robot_column_reg == 1 || map_reg[get_map_address(robot_row_reg, robot_column_reg - 1)] == wall)
                head_next = 1;
            else
                head_next = 0;
            if (robot_row_reg == 10 || map_reg[get_map_address(robot_row_reg + 1, robot_column_reg)] == wall)
                left_next = 1;
            else
                left_next = 0;
            if (map_reg[get_map_address(robot_row_reg, robot_column_reg)] == black_block)
                under_next = 1;
            else
                under_next = 0;
            if (map_reg[get_map_address(robot_row_reg, robot_column_reg - 1)] == trash_1 || map_reg[get_map_address(robot_row_reg, robot_column_reg - 1)] == trash_2 || map_reg[get_map_address(robot_row_reg, robot_column_reg - 1)] == trash_3)
                barrier_next = 1;
            else
                barrier_next = 0;
        end
    endcase
end
endtask

task update_robot_position;
begin
    case(robot_orientation_reg)
        north: begin
            if (front == 1)
                robot_row_next = robot_row_reg - 1'b1;
            else if (turn == 1)
                robot_orientation_next = west;
        end
        south: begin
            if (front == 1)
                robot_row_next = robot_row_reg + 1'b1;
            else if (turn == 1)
                robot_orientation_next = east;
        end
        east: begin
            if (front == 1)
                robot_column_next = robot_column_reg + 1'b1;
            else if (turn == 1)
                robot_orientation_next = north;
        end
        west: begin
            if (front == 1)
                robot_column_next = robot_column_reg - 1'b1;
            else if (turn == 1)
                robot_orientation_next = south;
        end
    endcase
end
endtask



task remove_trash;
begin
    if (remove == 1) begin
		case (robot_orientation_reg)
				 north:  begin row_offset_next = -1; column_offset_next = 0;  end
				 south:  begin row_offset_next = 1;  column_offset_next = 0;  end
				 east:   begin row_offset_next = 0;  column_offset_next = 1;  end
				 west:   begin row_offset_next = 0;  column_offset_next = -1; end
				 default:begin row_offset_next = 0;  column_offset_next = 0;  end // default case
			endcase
		address_next = get_map_address(robot_row_reg + row_offset_reg, robot_column_reg + column_offset_reg);
		surroundings_temp_next = map_reg[get_map_address(robot_row_reg + row_offset_reg, robot_column_reg + column_offset_reg)];
		if (trash_removal_state_reg == 2'b00 || trash_removal_state_reg == 2'b01 || trash_removal_state_reg == 2'b10) begin
			trash_removal_state_next = trash_removal_state_reg + 1'b1;
		end
		else begin
			trash_removal_state_next = 2'b00;    
			case (surroundings_temp_next)
				 trash_1: begin sprite_temp_next = free_path; trash_removal_state_next = 2'b00; end
				 trash_2: begin sprite_temp_next = trash_1; trash_removal_state_next = 2'b00; end
				 trash_3: begin sprite_temp_next = trash_2; trash_removal_state_next = 2'b00; end
				 default: begin sprite_temp_next = sprite_temp_reg; trash_removal_state_next = 2'b00; end
			endcase 
			map_next[address_next] = sprite_temp_next;
	  end
    end
end
endtask


function integer get_map_address(input [1:8] row, column);
begin
    get_map_address = (row * 20) + column;
end
endfunction


endmodule