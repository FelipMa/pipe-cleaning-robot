module world(clock_50, reset_key, mode_toggle, clock_toggle, mode, pixel_x, pixel_y, sprite, robot_cursor_flags, robot_type);
input wire clock_50, reset_key, mode_toggle, clock_toggle;
output reg mode;
input wire [9:0] pixel_x, pixel_y; 
output wire [3:0] sprite;
output reg [1:0] robot_cursor_flags; // robot_cursor_flags[1] = robot, robot_cursor_flags[0] = cursor
output reg [4:0] robot_type;

parameter north = 4'b0000, south = 4'b0001, east = 4'b0010, west = 4'b0011;
parameter wall = 4'b0000, free_path = 4'b0001, trash_1 = 4'b0011, trash_2 = 4'b0100, trash_3 = 4'b0101, black_block = 4'b0110;

// Internal regs
reg robot_clock;
reg head, left, under, barrier; // Inputs for robot
reg [1:8] robot_row, robot_column;
reg [1:4] robot_orientation;
reg [1:0] trash_removal_state;

// map is a 16x20 matrix, but only 15x20 is used (first line is used for robot initial data)
// each cell is 4 bits long
// memory must be linear, so every row is concatenated
reg [1:4] map [1:320];

reg next_mode, next_robot_clock;
reg [1:0] next_trash_removal_state;

reg reset_flag;

// internal wires
wire front, turn, remove; // Outputs from robot

initial begin
    // WARNING: On tb error, check if map.txt is in the same folder as the testbench
	$readmemb("map.txt", map);
	robot_row = {map[1], map[2]};
	robot_column = {map[3], map[4]};
	robot_orientation = map[5];
end
///////////////////////////////////
wire [6:0] sprite_x;
wire [3:0] sprite_y;
reg [1:0] next_robot_cursor_flags;

assign sprite_x = (pixel_x / 32) + 1; // 1-20
assign sprite_y = (pixel_y / 32) + 1; // 1-15
assign sprite = map[get_map_address(sprite_y, sprite_x)];

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
end

///////////////////////////////////
// build robot
robot robot (.clock(robot_clock), .reset(reset_key), .head(head), .left(left), .under(under), .barrier(barrier), .front(front), .turn(turn), .remove(remove));

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

always @(posedge robot_clock or posedge reset_flag) begin
    if (reset_flag) begin
        next_trash_removal_state = 2'b00;
        define_sensors_values;
    end

    else begin
        if (robot_clock == 1'b1) begin
            update_robot_position;
            remove_trash;
            define_sensors_values;
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
            if (map[get_map_address(robot_row - 1, robot_column)] == trash_1 && robot_row != 1)
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
            if (map[get_map_address(robot_row + 1, robot_column)] == trash_1)
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
            if (map[get_map_address(robot_row, robot_column + 1)] == trash_1)
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
            if (map[get_map_address(robot_row, robot_column - 1)] == trash_1)
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

task remove_trash;
    reg [9:0] current_pos;
begin
    if (remove == 1) begin
        if (trash_removal_state == 2'b00 || trash_removal_state == 2'b01) begin
            next_trash_removal_state = trash_removal_state + 1'b1;
        end else begin
            next_trash_removal_state = 2'b00;

            case(robot_orientation)
                north: begin
                    current_pos = get_map_address(robot_row - 1, robot_column);
                end
                south: begin
                    current_pos = get_map_address(robot_row + 1, robot_column);
                end
                east: begin
                    current_pos = get_map_address(robot_row, robot_column + 1);
                end
                west: begin
                    current_pos = get_map_address(robot_row, robot_column - 1);
                end
            endcase

            if (map[current_pos] == trash_3) begin
                map[current_pos] = trash_2;
            end else if (map[current_pos] == trash_2) begin
                map[current_pos] = trash_1;
            end else if (map[current_pos] == trash_1) begin
                map[current_pos] = free_path;
            end
        end
    end
end
endtask

function integer get_map_address(input [1:6] row, column);
begin
    get_map_address = (row * 20) + column;
end
endfunction


endmodule