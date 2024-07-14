`timescale 10ns/10ns // 50 MHz

module vga_tb;

reg clock_25, reset_key;
wire vga_vs, vga_hs;
wire [7:0] vga_r, vga_g, vga_b;
integer handle1;
event proximo;
 
wire [9:0] pixel_x, pixel_y;
wire video_on, pixel_tick;
reg [2:0] rgb_reg;
wire [2:0] rgb_next;
 
initial begin
    clock_25 = 1'b0;
    reset_key = 1'b0;

    reset_key = 1'b0;
    #2 reset_key = 1'b1;
    handle1 = $fopen("img.ppm");
    $fdisplay(handle1, "P3\n640 480\n255");
    $fwrite(handle1, "0   0   0 ");
end

always begin
    #2 clock_25 = ~clock_25; // 25 MHz
end

always @(DUV.pixel_x or DUV.pixel_y) begin
    if(DUV.pixel_x < 640 && DUV.pixel_y < 480) begin
        ->proximo;
    end
    else if(DUV.pixel_y >= 480)
        $finish;
end

always @proximo begin
  if (DUV.pixel_x == 10'd640) begin
    $fwrite(handle1, "\n");
  end
  else begin
    $fwrite(handle1, "%d, %d, %d ", vga_r, vga_g, vga_b);
  end
end
 
vga DUV(.clock_25(clock_25), .reset_key(reset_key), .vga_hs(vga_hs), .vga_vs(vga_vs), .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b));
 
endmodule