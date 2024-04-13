`timescale 1ns/1ns

module Robo_Limpa_Tubos_TB;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

reg clock, reset, head, left, under, barrier;
wire front, turn, remove;

// map is a 11x20 matrix, but only 10x20 is used (map[0] is used for robot initial data)
// each cell is 3 bits long
reg [1:3] map [0:10][1:20];

// 20 cells * 3 bits/cell
reg [1:60] map_row;

// regs for robot initial data
reg [1:6] robot_row;
reg [1:6] robot_column;
reg [1:3] robot_orientation; 
reg [1:9] n_movements;
reg [1:48] robot_orientation_string;

integer i;

Robo_Limpa_Tubos DUV (.clock(clock), .reset(reset), .head(head), .left(left), .under(under), .barrier(barrier), .front(front), .turn(turn), .remove(remove));

always
	#1 clock = !clock;

initial
begin
	clock = 0;
	reset = 1;
	head = 0;
	left = 0;
    under = 0;
    barrier = 0;

    // TODO: Change to relative path
	$readmemb("/home/felipema/quartus_projects/Robo_Limpa_Tubos/Mapa.txt", map);
	robot_row = {map[0][1], map[0][2]};
	robot_column = {map[0][3], map[0][4]};
	robot_orientation = map[0][5];
	n_movements = {map[0][6], map[0][7], map[0][8]};
    get_robot_orientation_string;
    $display ("\nInitial data:\nRow = %d | Column =%d | Orientation =%s | Max_Movements = %d\n", robot_row, robot_column, robot_orientation_string, n_movements);

	if (check_anomalous_situations(0)) $stop;

	#2 @ (negedge clock) reset = 0; // sync with falling edge

	for (i = 0; i < n_movements; i = i + 1)
	begin
		@ (negedge clock);
		define_sensors_values;
		$display ("Head = %b | Left = %b | Under = %b | Barrier = %b", head, left, under, barrier);
		@ (negedge clock);
		update_robot_position;
        get_robot_orientation_string;
		$display ("Row = %d | Column =%d | Orientation = %s\n", robot_row, robot_column, robot_orientation_string);
		if (check_anomalous_situations(0)) $stop;
	end

	#1 $stop;
end

// Input is mandatory in Verilog
function automatic integer check_anomalous_situations(input X);
begin
    // Robot outside the map
    if ( (robot_row < 1) || (robot_row > 10) || (robot_column < 1) || (robot_column > 20) )
        begin
            $display ("Anomalous situation: Robot outside the map");
            check_anomalous_situations = 1;
        end
    else
        check_anomalous_situations = 0;
end
endfunction

task get_robot_orientation_string;
begin
    case (robot_orientation)
        north: robot_orientation_string = "North";
        south: robot_orientation_string = "South";
        east: robot_orientation_string = "East";
        west: robot_orientation_string = "West";
    endcase
end
endtask

task define_sensors_values;
begin
	case(robot_orientation)
        north: begin
            if (robot_row == 1 || map[robot_row - 1][robot_column] == 1)
                head = 1;
            else
                head = 0;
            if (robot_column == 1 || map[robot_row][robot_column - 1] == 1)
                left = 1;
            else
                left = 0;
            if (map[robot_row][robot_column] == 7)
                under = 1;
            else
                under = 0;
            if (map[robot_row - 1][robot_column] == 2 && robot_row != 1)
                barrier = 1;
            else
                barrier = 0;
        end
        south: begin
            if (robot_row == 10 || map[robot_row + 1][robot_column] == 1)
                head = 1;
            else
                head = 0;
            if (robot_column == 20 || map[robot_row][robot_column + 1] == 1)
                left = 1;
            else
                left = 0;
            if (map[robot_row][robot_column] == 7)
                under = 1;
            else
                under = 0;
            if (map[robot_row + 1][robot_column] == 2)
                barrier = 1;
            else
                barrier = 0;
        end
        east: begin
            if (robot_column == 20 || map[robot_row][robot_column + 1] == 1)
                head = 1;
            else
                head = 0;
            if (robot_row == 1 || map[robot_row - 1][robot_column] == 1)
                left = 1;
            else
                left = 0;
            if (map[robot_row][robot_column] == 7)
                under = 1;
            else
                under = 0;
            if (map[robot_row][robot_column + 1] == 2)
                barrier = 1;
            else
                barrier = 0;
        end
        west: begin
            if (robot_column == 1 || map[robot_row][robot_column - 1] == 1)
                head = 1;
            else
                head = 0;
            if (robot_row == 10 || map[robot_row + 1][robot_column] == 1)
                left = 1;
            else
                left = 0;
            if (map[robot_row][robot_column] == 7)
                under = 1;
            else
                under = 0;
            if (map[robot_row][robot_column - 1] == 2)
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
                robot_row = robot_row - 1;
            else if (turn == 1)
                robot_orientation = west;
        end
        south: begin
            if (front == 1)
                robot_row = robot_row + 1;
            else if (turn == 1)
                robot_orientation = east;
        end
        east: begin
            if (front == 1)
                robot_column = robot_column + 1;
            else if (turn == 1)
                robot_orientation = north;
        end
        west: begin
            if (front == 1)
                robot_column = robot_column - 1;
            else if (turn == 1)
                robot_orientation = south;
        end
    endcase
end
endtask

endmodule


