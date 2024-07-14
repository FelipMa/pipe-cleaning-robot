`timescale 10ns/10ns // 50 MHz

module world_tb;

parameter north = 2'b00, south = 2'b01, east = 2'b10, west = 2'b11;

reg clock = 0;
reg [3:0] reset = 0;

wire [1:6] robot_row;
wire [1:6] robot_column;
wire [1:3] robot_orientation;
wire vga_hs, vga_vs;
wire [7:0] vga_r, vga_g, vga_b;

reg [1:48] robot_orientation_string;

integer i;

world DUV (.CLOCK_50(clock), .KEY(reset), .VGA_HS(vga_hs), .VGA_VS(vga_vs), .VGA_R(vga_r), .VGA_G(vga_g), .VGA_B(vga_b), .robot_row(robot_row), .robot_column(robot_column), .robot_orientation(robot_orientation));

always
	#1 clock = !clock;

initial
begin
    $display ("Resetting...");
	reset = 0;

    // keep reset key pressed enough time for robot to do a syncronous reset
    #4 reset = 1;

    get_robot_orientation_string;
    $display ("Data after reset: Row = %d | Column =%d | Orientation = %s", robot_row, robot_column, robot_orientation_string);

    // sensors are updated instantly when reset
	for (i = 0; i < 100; i = i + 1)
	begin
        get_robot_orientation_string;
        $display ("Time = %0t", $time);
        $display ("Data: Row = %d | Column =%d | Orientation =%s", robot_row, robot_column, robot_orientation_string);
		if (check_anomalous_situations(0)) $stop;
        // wait for robot to move
        #4;
	end

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

endmodule


