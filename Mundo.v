module Mundo (clock, reset, robot_row, robot_column, robot_orientation);

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

output reg [1:6] robot_row, robot_column;
output reg [1:3] robot_orientation; 
input clock, reset;

// Inputs for robot
reg head, left, under, barrier;
// Outputs from robot
wire front, turn, remove;

reg [1:2] trash_removal_state = 0;
reg counter = 0;

// map is a 11x20 matrix, but only 10x20 is used (map[0] is used for robot initial data)
// each cell is 3 bits long
// memory must be linear, so every row is concatenated
reg [1:3] map [1:220];

initial
begin
    // TODO: Change to relative path (aperently, linux doesn't support relative paths)
	$readmemb("/home/felipema/quartus_projects/Robo_Limpa_Tubos/Mapa.txt", map);
	robot_row = {map[1], map[2]};
	robot_column = {map[3], map[4]};
	robot_orientation = map[5];
end

Robo_Limpa_Tubos robot (.clock(clock), .reset(reset), .head(head), .left(left), .under(under), .barrier(barrier), .front(front), .turn(turn), .remove(remove));

always @(posedge clock)
begin
    if (reset)
        begin
            define_sensors_values;
            counter <= 0;
        end
    else
        if (counter == 0)
            begin
                define_sensors_values;
                counter <= 1;
            end
        else
            begin
                update_robot_position;
                remove_trash;
                counter <= 0;
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
                robot_row <= robot_row - 1;
            else if (turn == 1)
                robot_orientation <= west;
        end
        south: begin
            if (front == 1)
                robot_row <= robot_row + 1;
            else if (turn == 1)
                robot_orientation <= east;
        end
        east: begin
            if (front == 1)
                robot_column <= robot_column + 1;
            else if (turn == 1)
                robot_orientation <= north;
        end
        west: begin
            if (front == 1)
                robot_column <= robot_column - 1;
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
            trash_removal_state <= trash_removal_state + 1;
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

function automatic integer get_map_address(input [1:6] row, column);
begin
    get_map_address = (row * 20) + column;
end
endfunction

endmodule
