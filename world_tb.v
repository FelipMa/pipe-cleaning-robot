`timescale 10ns/10ns // 50 MHz

module world_tb;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

reg clock, reset_key;

wire [1:6] robot_row;
wire [1:6] robot_column;
wire [1:3] robot_orientation;

reg [1:48] robot_orientation_string;

integer i;

world DUV (.clock_50(clock), .reset_key(reset_key));

assign robot_row = DUV.robot_row;
assign robot_column = DUV.robot_column;
assign robot_orientation = DUV.robot_orientation;

always
	#1 clock = !clock;

initial
begin
    clock = 1'b0;

    $display ("Resetting...");
	reset_key = 1'b1;

    #2 reset_key = 1'b0;
    
    #2 reset_key = 1'b1;

    get_robot_orientation_string;
    $display ("Data after reset: Row =%d | Column =%d | Orientation =%s", robot_row, robot_column, robot_orientation_string);

    // sensors are updated instantly when reset
	for (i = 0; i < 100; i = i + 1)
	begin
        get_robot_orientation_string;
        $display ("Time = %0t", $time);
        $display ("Data: Row =%d | Column =%d | Orientation =%s", robot_row, robot_column, robot_orientation_string);
		if (check_anomalous_situations(0)) $stop;
        // wait for robot to move
        await_4s;
	end

	#1 $stop;
end

task await_4s;
begin
    #400000000;
end
endtask

// Input is mandatory in Verilog
function integer check_anomalous_situations(input X);
begin
    // Robot outside the map
    if ( (robot_row < 1) || (robot_row > 10) || (robot_column < 1) || (robot_column > 20) )
        begin
            $display ("Anomalous situation: Robot outside the map");
            $display ("Data: Row =%d | Column =%d | Orientation =%s", robot_row, robot_column, robot_orientation_string);
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
