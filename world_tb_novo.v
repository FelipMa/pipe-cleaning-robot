`timescale 10ns/10ns // 50 MHz

module world_tb_novo;

    parameter north = 4'b0000, south = 4'b0001, east = 4'b0010, west = 4'b0011;

    reg clock, reset_key, mode_toggle, clock_toggle;
    reg debounce_up, debounce_down, debounce_left, debounce_right, debounce_change_item, debounce_pause;
    reg start = 1'b0;

    wire mode;
    wire [3:0] sprite;
    wire [1:8] cursor_row_reg, cursor_column_reg; 
    wire [1:0] robot_cursor_flags;
    wire [4:0] robot_type;
    wire [9:0] pixel_x, pixel_y;

    reg [1:48] robot_orientation_string;
    reg [1:260] robot_state_string;
    reg [1:260] robot_next_state_string;
    
    integer i;

    world DUV (
        .clock_50(clock), 
        .reset_key(reset_key), 
        .mode_toggle(mode_toggle), 
        .clock_toggle(clock_toggle),  
        .mode(mode), 
        .pixel_x(pixel_x), 
        .pixel_y(pixel_y), 
        .sprite(sprite),
        .robot_cursor_flags(robot_cursor_flags),
        .robot_type(robot_type)
    );

    initial begin
        clock_toggle = 1'b1;
        wait (start == 1'b1);
        forever begin
            #2 clock_toggle = !clock_toggle;
        end
    end

    always #1 clock = !clock;

    initial begin

        clock = 1'b0;

        $display ("Resetting...");
        reset_key = 1'b1;
        #1

        reset_key = 1'b0;
        #1
        
        reset_key = 1'b1;
        #1

        $display("Pause Flag = %b", DUV.pause_flag_reg);

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
            $display ("Data: Row =%d | Column =%d | Orientation =%s", DUV.robot_row_reg, DUV.robot_column_reg, robot_orientation_string);
            $display ("Head = %b | Left = %b | Barrier = %b | Under = %b", DUV.head_reg, DUV.left_reg, DUV.barrier_reg, DUV.under_reg);
            $display ("Process sensors...");
            @ (posedge DUV.robot_clock);
            get_robot_states_strings;
            $display ("Actual state:%s", robot_state_string);
            $display ("Next state:%s", robot_next_state_string);
            $display ("Front = %b | Turn = %b | Remove = %b", DUV.front, DUV.turn, DUV.remove);
				$display ("Surroundings = %b | Sprite_temp_reg = %b", DUV.surroundings_temp_reg, DUV.sprite_temp_reg);
            if (check_anomalous_situations(0)) $stop;
            $display ("\n");
        end

        debounce_up = 1'b0;
        debounce_down = 1'b0;
        debounce_left = 1'b0;
        debounce_right = 1'b0;
        debounce_change_item = 1'b0;
        debounce_pause = 1'b0;

        // Applying reset
        $display ("Resetting...");
        #2 reset_key = 1'b0;
        #4 reset_key = 1'b1;

        $display("Pause Flag = %b", DUV.pause_flag_reg);

        // Pressing the pause button
        $display ("Pressing the pause button...");
        debounce_pause = 1'b1;
        #21_000_00; 
        debounce_pause = 1'b0;
        #21_000_00;
        $display ("Pause button pressed, switching to cursor mode");

        $display("Pause Flag = %b", DUV.pause_flag_reg);

        $display ("Moving the cursor...");

        // Displaying initial data
        $display ("Initial data:");
        $display ("Mode = %b", mode);
        $display ("Cursor Row = %d | Cursor Column = %d", DUV.cursor_row_reg, DUV.cursor_column_reg);

        // Simulating cursor movement
        // Simulate pressing the "up" button
        #10;
        debounce_up = 1'b1;
        #21_000_00; 
        debounce_up = 1'b0;
        #10;
        $display ("Cursor moved up: Row = %d | Column = %d", DUV.cursor_row_reg, DUV.cursor_column_reg);

        debounce_up = 1'b1;
        #1; 
        debounce_up = 1'b0;
        $display ("Pressing the up button");

        debounce_up = 1'b1;
        #1; 
        debounce_up = 1'b0;
        $display ("Pressing the up button");

        debounce_up = 1'b1;
        #1; 
        debounce_up = 1'b0;
        $display ("Pressing the up button");

        debounce_up = 1'b1;
        #1;  
        debounce_up = 1'b0;
        $display ("Pressing the up button");

        #21_000_00; 

        // Try to move the cursor again after more time
        debounce_up = 1'b1;
        #30_000_00; 
        debounce_up = 1'b0;
        #1;
        $display ("Cursor moved up (second press): Row = %d | Column = %d", DUV.cursor_row_reg, DUV.cursor_column_reg);

        // Move to the left
        #1;
        debounce_left = 1'b1;
        #21_000_00; 
        debounce_left = 1'b0;
        #1;
        $display ("Cursor moved left: Row = %d | Column = %d", DUV.cursor_row_reg, DUV.cursor_column_reg);

        #21_000_00;

        // Try to move to the left again
        debounce_left = 1'b1;
        #30_000_00; 
        debounce_left = 1'b0;
        #1;
        $display ("Cursor moved left (second press): Row = %d | Column = %d", DUV.cursor_row_reg, DUV.cursor_column_reg);

        // Move down
        #1;
        debounce_down = 1'b1;
        #21_000_00; 
        debounce_down = 1'b0;
        #10;
        $display ("Cursor moved down: Row = %d | Column = %d", DUV.cursor_row_reg, DUV.cursor_column_reg);

        // Move to the right
        #10;
        debounce_right = 1'b1;
        #21_000_00; 
        debounce_right = 1'b0;
        #10;
        $display ("Cursor moved right: Row = %d | Column = %d", DUV.cursor_row_reg, DUV.cursor_column_reg);
        #1 $stop;
    end

    // Input is mandatory in Verilog
    function integer check_anomalous_situations(input X);
    begin
        // Robot outside the map
        if ( (DUV.robot_row_reg < 1) || (DUV.robot_row_reg > 10) || (DUV.robot_column_reg < 1) || (DUV.robot_column_reg > 20) )
            begin
                $display ("Anomalous situation: Robot outside the map");
                $display ("Data: Row =%d | Column =%d | Orientation =%s", DUV.robot_row_reg, DUV.robot_column_reg, robot_orientation_string);
                check_anomalous_situations = 1;
            end
        else
            check_anomalous_situations = 0;
    end
    endfunction

    task get_robot_orientation_string;
    begin
        case (DUV.robot_orientation_reg)
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