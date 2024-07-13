`timescale 10ns / 1ns;
module ppm;

reg CLOCK_50;
reg [3:0] KEY;
wire VGA_VS, VGA_HS;
wire [7:0] VGA_R, VGA_G, VGA_B;
integer handle1;
event proximo;
 
wire [9:0] pixel_x, pixel_y;
wire video_on, pixel_tick;
reg [2:0] rgb_reg;
wire [2:0] rgb_next;
 
initial begin
CLOCK_50 = 1'b0;
KEY = 4'b0000;
end
initial begin
  KEY[0] = 1'b0;
  #2 KEY[0] = 1'b1;
  handle1 = $fopen("ppm.txt");
  $fdisplay(handle1, "P3\n640 480\n255");
  $fwrite(handle1, "0   0   0 ");
end
always begin
  #1 CLOCK_50 = ~CLOCK_50;
end
always @(vga_test.pixel_x or vga_test.pixel_y) begin
  if(vga_test.pixel_x < 640 && vga_test.pixel_y < 480) begin
    ->proximo;
  end
  else if(vga_test.pixel_y >= 480)
    $finish;
end
always @proximo begin
  if (vga_test.pixel_x == 10'd640) begin
    $fwrite(handle1, "\n");
  end
  else begin
    $fwrite(handle1, "%d, %d, %d ", VGA_R, VGA_G, VGA_B);
  end
end
 
  VGA vga_test(.CLOCK_50(CLOCK_50), .KEY(KEY), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));
 

endmodule