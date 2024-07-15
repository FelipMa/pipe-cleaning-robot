module world (CLOCK_50, KEY, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B);

input wire CLOCK_50;
input wire [3:0] KEY;
output wire VGA_HS, VGA_VS;
output wire [7:0] VGA_R, VGA_G, VGA_B;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

// Internal regs
reg robot_clock = 0;
reg head, left, under, barrier; // Inputs for robot
reg [1:6] robot_row, robot_column;
reg [1:3] robot_orientation;
reg [1:2] trash_removal_state = 0;

// map is a 11x20 matrix, but only 10x20 is used (first line is used for robot initial data)
// each cell is 3 bits long
// memory must be linear, so every row is concatenated
reg [1:3] map [1:220];

// internal wires
wire front, turn, remove; // Outputs from robot
wire pll_clk_25;
wire [9:0] pixel_x, pixel_y;
wire video_on;

initial begin
    // WARNING: On tb error, check if map.txt is in the same folder as the testbench
	$readmemb("map.txt", map);
	robot_row = {map[1], map[2]};
	robot_column = {map[3], map[4]};
	robot_orientation = map[5];
end

// build PLL
pll	pll (.inclk0(CLOCK_50), .c0(pll_clk_25));

// build robot
robot robot (.clock(robot_clock), .reset(KEY[0]), .head(head), .left(left), .under(under), .barrier(barrier), .front(front), .turn(turn), .remove(remove));

// build vga
vga_sync vga_sync(.clock_25(pll_clk_25), .reset_key(KEY[1]), .vga_hs(VGA_HS), .vga_vs(VGA_VS), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y));

graphics graphics(.clock_25(pll_clk_25), .video_on(video_on), .pix_x(pixel_x), .pix_y(pixel_y), .graph_r(VGA_R), .graph_g(VGA_G), .graph_b(VGA_B));

// TODO: state machine for world with clock divider, reseting state, vga and robot

always @(posedge CLOCK_50)
begin
    robot_clock <= ~robot_clock;
end

always @(robot_clock) begin
    if (robot_clock == 0) // clock will go up
        begin
            update_robot_position;
            remove_trash;
        end
    else
        begin
            define_sensors_values;
        end
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
