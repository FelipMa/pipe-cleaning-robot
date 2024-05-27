`timescale 1ns/1ns

module Mundo_TB;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

reg clock = 0;
reg reset = 0;

wire [1:6] robot_row;
wire [1:6] robot_column;
wire [1:3] robot_orientation;

reg [1:48] robot_orientation_string;

integer i;

Mundo DUV (.clock(clock), .reset(reset), .robot_row(robot_row), .robot_column(robot_column), .robot_orientation(robot_orientation));

always
	#1 clock = !clock;

initial
begin
    $display ("Time = %0t", $time);
    $display ("Initial data: Row = %d | Column =%d | Orientation = %s | Clock = %b | Reset = %b", robot_row, robot_column, robot_orientation, clock, reset);

    $display ("Resetting...");
	reset = 1;

    // keep reset high for enough time for robot to do a syncronous reset
    #4 reset = 0;
    #1;

    get_robot_orientation_string;
    $display ("Data after reset: Row = %d | Column =%d | Orientation = %s", robot_row, robot_column, robot_orientation_string);

    // sensors are updated instantly when reset
	for (i = 0; i < 50; i = i + 1)
	begin
        get_robot_orientation_string;
        $display ("Time = %0t", $time);
        $display ("Data: Row = %d | Column =%d | Orientation =%s", robot_row, robot_column, robot_orientation_string);
		if (check_anomalous_situations(0)) $stop;
        // wait two posedge clock to check robot actions after sensors update
        @ (posedge clock);
        @ (posedge clock);
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

endmodule


