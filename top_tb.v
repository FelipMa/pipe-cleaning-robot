`timescale 10ns/10ns // 50 MHz

module top_tb;

parameter north = 4'b0000, south = 4'b0001, east = 4'b0010, west = 4'b0011;

reg start = 1'b0;
reg clock;
reg [3:0] key;
reg [17:0] switch;
reg [1:48] robot_orientation_string;
reg [1:260] robot_state_string;
reg [1:260] robot_next_state_string;

wire vga_hs, vga_vs, vga_clk;
wire [7:0] vga_r, vga_g, vga_b;
wire [8:0] ledg;
wire [10:0] buttonsOut;

integer file;
reg [2:0] frame_count;

top DUV (.CLOCK_50(clock), .KEY(key), .VGA_HS(vga_hs), .VGA_VS(vga_vs), .VGA_R(vga_r), .VGA_G(vga_g), .VGA_B(vga_b), .VGA_CLK(), .LEDG(), .SW(switch), .up_z(1'b0), .down_y(1'b0), .left_x(1'b0), .right(1'b0), .a_b(1'b0), .selectSignal(1'b0), .start_c(1'b0), .buttonsOut(buttonsOut));

always begin
	#1 clock = !clock;
end

initial begin
    clock = 1'b0;
    key = 4'b1111;
    frame_count = 3'b000;

    $display("Resetting...");
	key[0] = 1'b1;
    key[1] = 1'b1;
    #1

    key[0] = 1'b0;
    key[1] = 1'b0;
    #4
    
    key[0] = 1'b1;
    key[1] = 1'b1;
    #1

    $display("Mode = %b", DUV.world.mode);

    // Open file
    open_file;
    $fwrite(file, "  0   0   0 ");

    $display("Setting mode to 1...\n");
    switch[0] = 1'b1;
    #1

    switch[0] = 1'b0;
    #4

    switch[0] = 1'b1;
    #1

    start = 1'b1;

    $display("Initial data:");
    $display("Mode = %b", DUV.world.mode);
    get_robot_orientation_string;
    get_robot_states_strings;
    $display("Data: Row =%d | Column =%d | Orientation =%s", DUV.world.robot_row, DUV.world.robot_column, robot_orientation_string);
    $display("Head = %b | Left = %b | Barrier = %b | Under = %b", DUV.world.head, DUV.world.left, DUV.world.barrier, DUV.world.under);
    $display("Actual state:%s", robot_state_string);
    $display("Next state:%s", robot_next_state_string);

    robot_clock_toggle;
    
    $display("\nData after clock toggle:");
    get_robot_orientation_string;
    get_robot_states_strings;
    $display("Data: Row =%d | Column =%d | Orientation =%s", DUV.world.robot_row, DUV.world.robot_column, robot_orientation_string);
    $display("Head = %b | Left = %b | Barrier = %b | Under = %b", DUV.world.head, DUV.world.left, DUV.world.barrier, DUV.world.under);
    $display("Actual state:%s", robot_state_string);
    $display("Next state:%s", robot_next_state_string);
end

always @(DUV.pixel_x or DUV.pixel_y) begin
    if(DUV.pixel_x < 640 && DUV.pixel_y < 480) begin
        next;
    end
    else if (DUV.pixel_y == 480 && DUV.pixel_x == 0) begin
        frame_count = frame_count + 1'b1;
        $display("\nFrame count = %b", frame_count);
        $fclose(file);

        robot_clock_toggle;

        $display("\nData after clock toggle:");
        get_robot_orientation_string;
        get_robot_states_strings;
        $display("Data: Row =%d | Column =%d | Orientation =%s", DUV.world.robot_row, DUV.world.robot_column, robot_orientation_string);
        $display("Head = %b | Left = %b | Barrier = %b | Under = %b", DUV.world.head, DUV.world.left, DUV.world.barrier, DUV.world.under);
        $display("Actual state:%s", robot_state_string);
        $display("Next state:%s", robot_next_state_string);

        if (frame_count == 3'b011) begin
            $stop;
        end

        open_file;
    end
end

task next;
begin
  if (DUV.pixel_x == 10'd640) begin
    $fwrite(file, "\n");
  end
  else begin
    $fwrite(file, "%d %d %d ", DUV.VGA_R, DUV.VGA_G, DUV.VGA_B);
  end
end
endtask

task get_robot_orientation_string;
begin
    case (DUV.world.robot_orientation)
        north: robot_orientation_string = "North";
        south: robot_orientation_string = "South";
        east: robot_orientation_string = "East";
        west: robot_orientation_string = "West";
    endcase
end
endtask

task get_robot_states_strings;
begin
    case (DUV.world.robot.act_state)
        3'b000: robot_state_string = "searching trash or left      ";
        3'b001: robot_state_string = "rotating                     ";
        3'b010: robot_state_string = "removing trash or following left";
        3'b011: robot_state_string = "stand by                     ";
        3'b100: robot_state_string = "first move                   ";
        3'b101: robot_state_string = "reseting                     ";
    endcase
    case (DUV.world.robot.next_state)
        3'b000: robot_next_state_string = "searching trash or left      ";
        3'b001: robot_next_state_string = "rotating                     ";
        3'b010: robot_next_state_string = "removing trash or following left";
        3'b011: robot_next_state_string = "stand by                     ";
        3'b100: robot_next_state_string = "first move                   ";
        3'b101: robot_next_state_string = "reseting                     ";
    endcase
end
endtask

task robot_clock_toggle;
begin
    key[3] = 1'b0;
    #3
    key[3] = 1'b1;
    #3
    key[3] = 1'b0;
    #3
    key[3] = 1'b1;
end
endtask

task open_file;
begin
    if (frame_count == 3'b000) begin
        file = $fopen("frame1.ppm");
        $fwrite(file, "P3\n640 480\n255\n");
    end
    else if (frame_count == 3'b001) begin
        file = $fopen("frame2.ppm");
        $fwrite(file, "P3\n640 480\n255\n");
    end
    else if (frame_count == 3'b010) begin
        file = $fopen("frame3.ppm");
        $fwrite(file, "P3\n640 480\n255\n");
    end
end
endtask

endmodule
