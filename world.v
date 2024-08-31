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
reg head, left, under, barrier; // Inputs for robot
reg [3:0] robot_row;
reg [4:0] cursor_row;
reg [4:0] robot_column;
reg [5:0] cursor_column;
reg [1:4] robot_orientation;
reg [1:0] trash_removal_state;

// map is a 16x20 matrix, but only 15x20 is used (first line is used for robot initial data)
// each cell is 4 bits long
// memory must be linear, so every row is concatenated
reg [1:4] map [1:320];

reg next_mode, next_robot_clock;
reg [1:0] next_trash_removal_state;
reg [1:9] address;

reg reset_flag;
reg pause_flag;

// internal wires
wire front, turn, remove; // Outputs from robot
reg map_change_flag;
reg [3:0] sprite_temp_robot;
reg [1:9] cursor_address;
// map and robot initialization and resetting;
always @(*) begin
	if (reset_flag) begin // map and robot initialization or resetting
		// WARNING: On tb error, check if map.txt is in the same folder as the testbench
		$readmemb("map.txt", map);
		robot_row = {map[1], map[2]};
		robot_column = {map[3], map[4]};
		robot_orientation = map[5];
		cursor_row = 5'b10000; // 16 
		cursor_column = 6'b100000; // 21
		next_trash_removal_state = 2'b00;
      pause_flag = 0;
      define_sensors_values;
	end
	else begin // robot movement and updates
        if (control_inputs[10]) begin // pause flag!
            pause_flag = ~pause_flag;
				cursor_column = 6'd1;
            cursor_row = 5'd1;
        end 
		  else 
        if (pause_flag == 0) begin 
            cursor_column = 6'd21; // out of display range
            cursor_row = 5'd16; // out of display range
            if (robot_clock == 1'b1) begin
                update_robot_position;
                remove_trash;
                define_sensors_values;
            end
        end 
        else begin
        // up-down movement
            if (control_inputs[3]) begin //cursor right movement and updates
                if (cursor_column == 20) 
                    cursor_column = 6'd1;
                else 
                    cursor_column = cursor_column + 6'd1;
            end
            else if (control_inputs[2]) begin //cursor left movement and updates
                if (cursor_column == 1)
                    cursor_column = 6'd20;
                else
                    cursor_column = cursor_column - 6'd1;
            end
            // right-left movement 
            if (control_inputs[1]) begin //cursor down movement and updates
                if (cursor_row == 15) 
                    cursor_row = 5'd1;
                else
                    cursor_row = cursor_row + 5'd1;
            end
            else if (control_inputs[0]) begin //cursor up movement and updates
                if (cursor_row == 1)
                    cursor_row = 5'd15;
                else
                    cursor_row = cursor_row - 5'd1;
            end
            if (control_inputs[9]) begin
                sprite_temp_robot = free_path;
                map_change_flag = 1;
            end
            else if(control_inputs[8]) begin
                sprite_temp_robot = trash_1;
                map_change_flag = 1;
            end
            else if(control_inputs[7]) begin
                sprite_temp_robot = trash_2;
                map_change_flag = 1;
            end
            else if(control_inputs[6]) begin
                sprite_temp_robot = trash_3;
                map_change_flag = 1;
            end
            else if(control_inputs[5]) begin
                sprite_temp_robot = wall;
                map_change_flag = 1;
            end
            else if(control_inputs[4]) begin
                sprite_temp_robot = black_block;
                map_change_flag = 1;
            end
            if (map_change_flag) begin
					 cursor_address = get_map_address(cursor_row, cursor_column);
                map[cursor_address] = sprite_temp_robot;
                map_change_flag = 0;
            end
        end
    end
end
// block to control the control's inputs. 
// control_inputs[0] = Saida_Mode
// control_inputs[1] = Saida_Start
// control_inputs[2] = Saida_Z
// control_inputs[3] = Saida_Y
// control_inputs[4] = Saida_X
// control_inputs[5] = Saida_C
// control_inputs[6] = Saida_B
// control_inputs[7] = Saida_A
// control_inputs[8] = Saida_Right
// control_inputs[9] = Saida_Left
// control_inputs[10] = Saida_Down
// control_inputs[11] = Saida_Up
//always @* begin
//	if (control_inputs[8]) begin
//		if (cursor_row == 
//	end
//end

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
///////////////////////////////////
wire [4:0] sprite_x;
wire [3:0] sprite_y;
reg [1:0] next_robot_cursor_flags;

assign sprite_x = (pixel_x / 32) + 1; // 1-20
assign sprite_y = (pixel_y / 32) + 1; // 1-15
assign sprite = map[get_map_address(sprite_y, sprite_x)];

// block to control the robot sprite. It changes its type and flags.
always @(sprite_x or reset_flag) begin
    if (reset_flag == 1'b1) begin
        next_robot_cursor_flags = 2'b00;
		  robot_type = 5'b00000;
    end
	if ((sprite_x == robot_column) && (sprite_y == robot_row)) begin 
        next_robot_cursor_flags[1] = 1'b1;
		case(robot_orientation)
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
    if ((sprite_x == cursor_column) && (sprite_y == cursor_row)) begin
        next_robot_cursor_flags[0] = 1'b1;
    end
    else 
        next_robot_cursor_flags[0] = 1'b0;
end

///////////////////////////////////
// build robot
robot robot (.clock(robot_clock), .reset(reset_key), .head(head), .left(left), .under(under), .barrier(barrier), .front(front), .turn(turn), .remove(remove));

// TODO control world with remote controller

parameter DIV_FACTOR = 28'd50000000; // Divide by 50Mhz for 1hz

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

        trash_removal_state <= next_trash_removal_state;
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



task define_sensors_values;
begin
	case(robot_orientation)
        north: begin
            if (robot_row == 1 || map[get_map_address(robot_row - 1, robot_column)] == wall)
                head = 1;
            else
                head = 0;
            if (robot_column == 1 || map[get_map_address(robot_row, robot_column - 1)] == wall)
                left = 1;
            else
                left = 0;
            if (map[get_map_address(robot_row, robot_column)] == black_block)
                under = 1;
            else
                under = 0;
            if ((map[get_map_address(robot_row - 1, robot_column)] == trash_1 || map[get_map_address(robot_row - 1, robot_column)] == trash_2 || map[get_map_address(robot_row - 1, robot_column)] == trash_3) && robot_row != 1)
                barrier = 1;
            else
                barrier = 0;
        end
        south: begin
            if (robot_row == 10 || map[get_map_address(robot_row + 1, robot_column)] == wall)
                head = 1;
            else
                head = 0;
            if (robot_column == 20 || map[get_map_address(robot_row, robot_column + 1)] == wall)
                left = 1;
            else
                left = 0;
            if (map[get_map_address(robot_row, robot_column)] == black_block)
                under = 1;
            else
                under = 0;
            if (map[get_map_address(robot_row + 1, robot_column)] == trash_1  || map[get_map_address(robot_row + 1, robot_column)] == trash_2 || map[get_map_address(robot_row + 1, robot_column)] == trash_3)
                barrier = 1;
            else
                barrier = 0;
        end
        east: begin
            if (robot_column == 20 || map[get_map_address(robot_row, robot_column + 1)] == wall)
                head = 1;
            else
                head = 0;
            if (robot_row == 1 || map[get_map_address(robot_row - 1, robot_column)] == wall)
                left = 1;
            else
                left = 0;
            if (map[get_map_address(robot_row, robot_column)] == black_block)
                under = 1;
            else
                under = 0;
            if (map[get_map_address(robot_row, robot_column + 1)] == trash_1 || map[get_map_address(robot_row, robot_column + 1)] == trash_2 || map[get_map_address(robot_row, robot_column + 1)] == trash_3)
                barrier = 1;
            else
                barrier = 0;
        end
        west: begin
            if (robot_column == 1 || map[get_map_address(robot_row, robot_column - 1)] == wall)
                head = 1;
            else
                head = 0;
            if (robot_row == 10 || map[get_map_address(robot_row + 1, robot_column)] == wall)
                left = 1;
            else
                left = 0;
            if (map[get_map_address(robot_row, robot_column)] == black_block)
                under = 1;
            else
                under = 0;
            if (map[get_map_address(robot_row, robot_column - 1)] == trash_1 || map[get_map_address(robot_row, robot_column - 1)] == trash_2 || map[get_map_address(robot_row, robot_column - 1)] == trash_3)
                barrier = 1;
            else
                barrier = 0;
        end
    endcase
end
endtask

task update_robot_position;
begin
    case(robot_orientation)
        north: begin
            if (front == 1)
                robot_row = robot_row - 1'b1;
            else if (turn == 1)
                robot_orientation = west;
        end
        south: begin
            if (front == 1)
                robot_row = robot_row + 1'b1;
            else if (turn == 1)
                robot_orientation = east;
        end
        east: begin
            if (front == 1)
                robot_column = robot_column + 1'b1;
            else if (turn == 1)
                robot_orientation = north;
        end
        west: begin
            if (front == 1)
                robot_column = robot_column - 1'b1;
            else if (turn == 1)
                robot_orientation = south;
        end
    endcase
end
endtask
reg  [3:0] sprite_temp;
reg  [3:0] surroundings_temp;
reg signed [1:8] row_offset;
reg signed [1:8] column_offset;
task remove_trash;
begin
    if (remove == 1)
    begin
        if (trash_removal_state == 2'b00 || trash_removal_state == 2'b01)
            next_trash_removal_state = trash_removal_state + 1'b1;
        else
        begin
            next_trash_removal_state = 2'b00;    
            case (robot_orientation)
                north:  begin row_offset = -1; column_offset = 0;  end
                south:  begin row_offset = 1;  column_offset = 0;  end
                east:   begin row_offset = 0;  column_offset = 1;  end
                west:   begin row_offset = 0;  column_offset = -1; end
                default:begin row_offset = 0;  column_offset = 0;  end // default case
            endcase
				address = get_map_address(robot_row + row_offset, robot_column + column_offset);
            surroundings_temp = map[get_map_address(robot_row + row_offset, robot_column + column_offset)];
            case (surroundings_temp)
                trash_1: begin sprite_temp = free_path; next_trash_removal_state = 2'b00; end
                trash_2: begin sprite_temp = trash_1; next_trash_removal_state = 2'b00; end
                trash_3: begin sprite_temp = trash_2; next_trash_removal_state = 2'b00; end
                default: begin sprite_temp = free_path; next_trash_removal_state = 2'b00; end
            endcase
            map[address] = sprite_temp;
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