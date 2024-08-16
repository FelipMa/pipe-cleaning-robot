module world(clock_50, reset_key, mode_toggle, clock_toggle, mode, pixel_x, pixel_y, sprite);
input wire clock_50, reset_key, mode_toggle, clock_toggle;
output reg mode;
input wire [9:0] pixel_x, pixel_y; 
output reg [3:0] sprite;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

// Internal regs
reg robot_clock;
reg head, left, under, barrier; // Inputs for robot
reg [1:6] robot_row, robot_column;
reg [1:3] robot_orientation;
reg [1:0] trash_removal_state;
// map is a 11x20 matrix, but only 10x20 is used (first line is used for robot initial data)
// each cell is 3 bits long
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
wire [3:0] map_coding;


assign sprite_x = (pixel_x / 32) * 4;
assign sprite_y = (pixel_y / 32);
assign map_coding = map[sprite_x][sprite_y];
always @(map_coding) begin
	if ((sprite_x == robot_column) && (sprite_y == robot_row)) begin
		case(robot_orientation)
			4'b0000: sprite = 4'd2;
			4'b0001: sprite = 4'd7;
			4'b0010: sprite = 4'd8;
			4'b0011: sprite = 4'd9;
			default: sprite = 4'd2;
		endcase
	end
//	else begin
//		case(map_coding)
//			4'b0000: sprite = 4'd1;    talvez não seja necessário 
//			4'b0001: sprite = 4'd0;
//			4'b0010: sprite = 4'd0;
//			4'b0111: sprite = 4'd6;
//		endcase
//	end
	else begin
		sprite = map_coding;
	end
end

///////////////////////////////////


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
            if (robot_row == 1 || map[get_map_address(robot_row - 1, robot_column)] == 1)
                head = 1;
            else
                head = 0;
            if (robot_column == 1 || map[get_map_address(robot_row, robot_column - 1)] == 1)
                left = 1;
            else
                left = 0;
            if (map[get_map_address(robot_row, robot_column)] == 7)
                under = 1;
            else
                under = 0;
            if (map[get_map_address(robot_row - 1, robot_column)] == 2 && robot_row != 1)
                barrier = 1;
            else
                barrier = 0;
        end
        south: begin
            if (robot_row == 10 || map[get_map_address(robot_row + 1, robot_column)] == 1)
                head = 1;
            else
                head = 0;
            if (robot_column == 20 || map[get_map_address(robot_row, robot_column + 1)] == 1)
                left = 1;
            else
                left = 0;
            if (map[get_map_address(robot_row, robot_column)] == 7)
                under = 1;
            else
                under = 0;
            if (map[get_map_address(robot_row + 1, robot_column)] == 2)
                barrier = 1;
            else
                barrier = 0;
        end
        east: begin
            if (robot_column == 20 || map[get_map_address(robot_row, robot_column + 1)] == 1)
                head = 1;
            else
                head = 0;
            if (robot_row == 1 || map[get_map_address(robot_row - 1, robot_column)] == 1)
                left = 1;
            else
                left = 0;
            if (map[get_map_address(robot_row, robot_column)] == 7)
                under = 1;
            else
                under = 0;
            if (map[get_map_address(robot_row, robot_column + 1)] == 2)
                barrier = 1;
            else
                barrier = 0;
        end
        west: begin
            if (robot_column == 1 || map[get_map_address(robot_row, robot_column - 1)] == 1)
                head = 1;
            else
                head = 0;
            if (robot_row == 10 || map[get_map_address(robot_row + 1, robot_column)] == 1)
                left = 1;
            else
                left = 0;
            if (map[get_map_address(robot_row, robot_column)] == 7)
                under = 1;
            else
                under = 0;
            if (map[get_map_address(robot_row, robot_column - 1)] == 2)
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
begin
    if (remove == 1)
        begin
        if (trash_removal_state == 2'b00 || trash_removal_state == 2'b01)
            next_trash_removal_state = trash_removal_state + 1'b1;
        else
            begin
                next_trash_removal_state = 2'b00;
                case(robot_orientation)
                    north: begin
                        map[get_map_address(robot_row - 1, robot_column)] = 0;
                    end
                    south: begin
                        map[get_map_address(robot_row + 1, robot_column)] = 0;
                    end
                    east: begin
                        map[get_map_address(robot_row, robot_column + 1)] = 0;
                    end
                    west: begin
                        map[get_map_address(robot_row, robot_column - 1)] = 0;
                    end
                endcase
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