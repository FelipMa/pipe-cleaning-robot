`timescale 10ns/10ns // 50 MHz

module world_tb;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

reg clock, reset_key, mode_toggle, clock_toggle;
reg start = 1'b0;

wire mode;

reg [1:48] robot_orientation_string;
reg [1:260] robot_state_string;
reg [1:260] robot_next_state_string;

integer i;

world DUV (.clock_50(clock), .reset_key(reset_key), .mode_toggle(mode_toggle), .clock_toggle(clock_toggle), .mode(mode));

always #1 clock = !clock;

initial begin
    clock_toggle = 1'b1;
    wait (start == 1'b1);
    forever begin
        #2 clock_toggle = !clock_toggle;
    end
end

initial
begin
    clock = 1'b0;

    $display ("Resetting...");
	reset_key = 1'b1;
    #1

    reset_key = 1'b0;
    #4
    
    reset_key = 1'b1;
    #1
    $display ("Mode = %b", mode);

    $display ("Setting mode to 1...\n");
    mode_toggle = 1'b1;
    #1

    mode_toggle = 1'b0;
    #4

    mode_toggle = 1'b1;
    #1

    start = 1'b1;

    $display ("Initial data:");
    $display ("Mode = %b", mode);

    // sensors are updated instantly when reset
	for (i = 0; i < 100; i = i + 1)
	begin
        get_robot_orientation_string;
        $display ("Time = %0t", $time);
        $display ("Data: Row =%d | Column =%d | Orientation =%s", DUV.robot_row, DUV.robot_column, robot_orientation_string);
        $display ("Head = %b | Left = %b | Barrier = %b | Under = %b", DUV.head, DUV.left, DUV.barrier, DUV.under);
        $display ("Process sensors...");
        @ (posedge DUV.robot_clock);
        get_robot_states_strings;
        $display ("Actual state:%s", robot_state_string);
        $display ("Next state:%s", robot_next_state_string);
        $display ("Front = %b | Turn = %b | Remove = %b", DUV.front, DUV.turn, DUV.remove);
		if (check_anomalous_situations(0)) $stop;
        $display ("\n");
	end

	#1 $stop;
end

// Input is mandatory in Verilog
function integer check_anomalous_situations(input X);
begin
    // Robot outside the map
    if ( (DUV.robot_row < 1) || (DUV.robot_row > 10) || (DUV.robot_column < 1) || (DUV.robot_column > 20) )
        begin
            $display ("Anomalous situation: Robot outside the map");
            $display ("Data: Row =%d | Column =%d | Orientation =%s", DUV.robot_row, DUV.robot_column, robot_orientation_string);
            check_anomalous_situations = 1;
        end
    else
        check_anomalous_situations = 0;
end
endfunction

task get_robot_orientation_string;
begin
    case (DUV.robot_orientation)
        north: robot_orientation_string = "North";
        south: robot_orientation_string = "South";
        east: robot_orientation_string = "East";
        west: robot_orientation_string = "West";
    endcase
end
endtask

task get_robot_states_strings;
begin
    case (DUV.robot.act_state)
        3'b000: robot_state_string = "searching trash or left      ";
        3'b001: robot_state_string = "rotating                     ";
        3'b010: robot_state_string = "removing trash or following left";
        3'b011: robot_state_string = "stand by                     ";
        3'b100: robot_state_string = "first move                   ";
        3'b101: robot_state_string = "reseting                     ";
    endcase
    case (DUV.robot.next_state)
        3'b000: robot_next_state_string = "searching trash or left      ";
        3'b001: robot_next_state_string = "rotating                     ";
        3'b010: robot_next_state_string = "removing trash or following left";
        3'b011: robot_next_state_string = "stand by                     ";
        3'b100: robot_next_state_string = "first move                   ";
        3'b101: robot_next_state_string = "reseting                     ";
    endcase
end
endtask

endmodule
