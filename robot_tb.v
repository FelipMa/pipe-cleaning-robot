`timescale 10ns/10ns // 50 MHz

module robot_tb;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

reg clock, reset, head, left, under, barrier;
wire front, turn, remove;

// map is a 11x20 matrix, but only 10x20 is used (map[0] is used for robot initial data)
// each cell is 3 bits long
reg [1:3] map [0:10][1:20];

// regs for robot initial data
reg [1:6] robot_row;
reg [1:6] robot_column;
reg [1:3] robot_orientation; 
reg [1:9] n_movements;

reg [1:48] robot_orientation_string;
reg [1:260] robot_state_string;
reg [1:260] robot_next_state_string;

reg [1:2] trash_removal_state;

integer i;
integer file; // File descriptor

robot DUV (.clock(clock), .reset(reset), .head(head), .left(left), .under(under), .barrier(barrier), .front(front), .turn(turn), .remove(remove));

always #1 clock = !clock;

initial
begin
    // Open file for writing
    file = $fopen("robot_output.txt", "w");

    // WARNING: On tb error, check if map.txt is in the same folder as the testbench
	$readmemb("map.txt", map);
	robot_row = {map[0][1], map[0][2]};
	robot_column = {map[0][3], map[0][4]};
	robot_orientation = map[0][5];
	n_movements = {map[0][6], map[0][7], map[0][8]};

	if (check_anomalous_situations(0)) $stop;

    trash_removal_state = 0;

    clock = 0;
	reset = 1;
    #1

    reset = 0;
    #2

    reset = 1;

    get_robot_states_strings;
    $display ("Initial state:%s", robot_state_string);
    $display ("Next state:%s\n", robot_next_state_string);
    
    // sensors are updated instantly when reset
	for (i = 0; i < n_movements; i = i + 1)
	begin
		define_sensors_values;
        get_robot_orientation_string;
        $display ("Time = %0t", $time);
		$display ("Row = %d | Column = %d | Orientation = %s | Removing trash = %d", robot_row, robot_column, robot_orientation_string, remove);
		$display ("Head = %b | Left = %b | Barrier = %b | Under = %b", head, left, barrier, under);
        $display ("Process sensors...");
        $fwrite(file, "Row = %d | Column = %d | Orientation = %s\n", robot_row, robot_column, robot_orientation_string);
        $fwrite(file, "Head = %b | Left = %b | Barrier = %b | Under = %b\n", head, left, barrier, under);
        
        // wait next posedge clock to check robot actions after sensors update
        @ (posedge clock);
        get_robot_states_strings;
        $display ("Actual state:%s", robot_state_string);
        $display ("Next state:%s", robot_next_state_string);
        $display ("Front = %b | Turn = %b | Remove = %b", front, turn, remove);
        
        update_robot_position;
        remove_trash;
        $display ("\n");
        $fwrite(file, "\n");
        
		if (check_anomalous_situations(0)) $stop;
	end

    // Close the file
	$fclose(file);
    
    #1 $stop;
end

// Input is mandatory in Verilog
function integer check_anomalous_situations(input X);
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

task get_robot_states_strings;
begin
    case (DUV.act_state)
        3'b000: robot_state_string = "searching trash or left      ";
        3'b001: robot_state_string = "rotating                     ";
        3'b010: robot_state_string = "removing trash or following left";
        3'b011: robot_state_string = "stand by                     ";
        3'b100: robot_state_string = "first move                   ";
        3'b101: robot_state_string = "reseting                     ";
    endcase
    case (DUV.next_state)
        3'b000: robot_next_state_string = "searching trash or left      ";
        3'b001: robot_next_state_string = "rotating                     ";
        3'b010: robot_next_state_string = "removing trash or following left";
        3'b011: robot_next_state_string = "stand by                     ";
        3'b100: robot_next_state_string = "first move                   ";
        3'b101: robot_next_state_string = "reseting                     ";
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

task remove_trash;
begin
    if (remove == 1)
        begin
        if (trash_removal_state == 0 || trash_removal_state == 1)
            trash_removal_state = trash_removal_state + 1;
        else
            begin
                trash_removal_state = 0;
                case(robot_orientation)
                    north: begin
                        map[robot_row - 1][robot_column] = 0;
                    end
                    south: begin
                        map[robot_row + 1][robot_column] = 0;
                    end
                    east: begin
                        map[robot_row][robot_column + 1] = 0;
                    end
                    west: begin
                        map[robot_row][robot_column - 1] = 0;
                    end
                endcase
            end
        end
end
endtask

endmodule

