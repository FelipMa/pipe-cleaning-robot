module world (CLOCK_50, KEY, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B, robot_row, robot_column, robot_orientation);

input wire CLOCK_50;
input wire [3:0] KEY;
output wire VGA_HS, VGA_VS;
output wire [7:0] VGA_R, VGA_G, VGA_B;

// Inputs for robot
reg head, left, under, barrier;
// Outputs from robot
wire front, turn, remove;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

// Internal regs
reg robot_clock = 0;

output reg [1:6] robot_row, robot_column; // set to output for testing
output reg [1:3] robot_orientation; // set to output for testing

reg [1:5] map_draw [1:200];

reg [1:2] trash_removal_state = 0;

// map is a 11x20 matrix, but only 10x20 is used (map[0] is used for robot initial data)
// each cell is 3 bits long
// memory must be linear, so every row is concatenated
reg [1:3] map [1:220];

initial
begin
    // WARNING: On tb error, check if map.txt is in the same folder as the testbench
	$readmemb("map.txt", map);
	robot_row = {map[1], map[2]};
	robot_column = {map[3], map[4]};
	robot_orientation = map[5];
end

robot robot (.clock(robot_clock), .reset(KEY[0]), .head(head), .left(left), .under(under), .barrier(barrier), .front(front), .turn(turn), .remove(remove));

vga vga (.clock_50(CLOCK_50), .reset_key(KEY), .vga_hs(VGA_HS), .vga_vs(VGA_VS), .vga_r(VGA_R), .vga_g(VGA_G), .vga_b(VGA_B));

// TODO: state machine for world with clock divider, reseting state, vga and robot

always @(posedge CLOCK_50)
begin
    // update robot position when it is moving, update sensors when it is between clock cycles
    if (robot_clock == 0) // clock will go up
        begin
            update_robot_position;
            remove_trash;
        end
    else
        begin
            define_sensors_values;
        end
    robot_clock <= ~robot_clock;
end

task define_sensors_values;
begin
	case(robot_orientation)
        north: begin
            if (robot_row == 1 || map[get_map_address(robot_row - 1, robot_column)] == 1)
                head <= 1;
            else
                head <= 0;
            if (robot_column == 1 || map[get_map_address(robot_row, robot_column - 1)] == 1)
                left <= 1;
            else
                left <= 0;
            if (map[get_map_address(robot_row, robot_column)] == 7)
                under <= 1;
            else
                under <= 0;
            if (map[get_map_address(robot_row - 1, robot_column)] == 2 && robot_row != 1)
                barrier <= 1;
            else
                barrier <= 0;
        end
        south: begin
            if (robot_row == 10 || map[get_map_address(robot_row + 1, robot_column)] == 1)
                head <= 1;
            else
                head <= 0;
            if (robot_column == 20 || map[get_map_address(robot_row, robot_column + 1)] == 1)
                left <= 1;
            else
                left <= 0;
            if (map[get_map_address(robot_row, robot_column)] == 7)
                under <= 1;
            else
                under <= 0;
            if (map[get_map_address(robot_row + 1, robot_column)] == 2)
                barrier <= 1;
            else
                barrier <= 0;
        end
        east: begin
            if (robot_column == 20 || map[get_map_address(robot_row, robot_column + 1)] == 1)
                head <= 1;
            else
                head <= 0;
            if (robot_row == 1 || map[get_map_address(robot_row - 1, robot_column)] == 1)
                left <= 1;
            else
                left <= 0;
            if (map[get_map_address(robot_row, robot_column)] == 7)
                under <= 1;
            else
                under <= 0;
            if (map[get_map_address(robot_row, robot_column + 1)] == 2)
                barrier <= 1;
            else
                barrier <= 0;
        end
        west: begin
            if (robot_column == 1 || map[get_map_address(robot_row, robot_column - 1)] == 1)
                head <= 1;
            else
                head <= 0;
            if (robot_row == 10 || map[get_map_address(robot_row + 1, robot_column)] == 1)
                left <= 1;
            else
                left <= 0;
            if (map[get_map_address(robot_row, robot_column)] == 7)
                under <= 1;
            else
                under <= 0;
            if (map[get_map_address(robot_row, robot_column - 1)] == 2)
                barrier <= 1;
            else
                barrier <= 0;
        end
    endcase
end
endtask

task update_robot_position;
begin
    case(robot_orientation)
        north: begin
            if (front == 1)
                robot_row <= robot_row - 1'b1;
            else if (turn == 1)
                robot_orientation <= west;
        end
        south: begin
            if (front == 1)
                robot_row <= robot_row + 1'b1;
            else if (turn == 1)
                robot_orientation <= east;
        end
        east: begin
            if (front == 1)
                robot_column <= robot_column + 1'b1;
            else if (turn == 1)
                robot_orientation <= north;
        end
        west: begin
            if (front == 1)
                robot_column <= robot_column - 1'b1;
            else if (turn == 1)
                robot_orientation <= south;
        end
    endcase
end
endtask

task remove_trash;
begin
    if (remove == 1)
        begin
        if (trash_removal_state == 0 || trash_removal_state == 1)
            trash_removal_state <= trash_removal_state + 1'b1;
        else
            begin
                trash_removal_state <= 0;
                case(robot_orientation)
                    north: begin
                        map[get_map_address(robot_row - 1, robot_column)] <= 0;
                    end
                    south: begin
                        map[get_map_address(robot_row + 1, robot_column)] <= 0;
                    end
                    east: begin
                        map[get_map_address(robot_row, robot_column + 1)] <= 0;
                    end
                    west: begin
                        map[get_map_address(robot_row, robot_column - 1)] <= 0;
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
