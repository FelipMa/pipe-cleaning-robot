`timescale 10ns/10ns // 50 MHz

module world_vga_tb;

reg clock;
reg [3:0] reset_key;

wire vga_hs, vga_vs;
wire [7:0] vga_r, vga_g, vga_b;

integer file;
event proximo;
 
world DUV (.CLOCK_50(clock), .KEY(reset_key), .VGA_HS(vga_hs), .VGA_VS(vga_vs), .VGA_R(vga_r), .VGA_G(vga_g), .VGA_B(vga_b));
 
initial begin
    clock = 1'b0;
    reset_key = 3'b1;
    #1
    reset_key = 3'b0;
    #4
    reset_key = 3'b1;
    file = $fopen("img.ppm");
    $fdisplay(file, "P3\n640 480\n255");
    $fwrite(file, "0   0   0 ");
end

always begin
    #1 clock = ~clock;
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
    $fwrite(file, "\n");
  end
  else begin
    $fwrite(file, "%d, %d, %d ", vga_r, vga_g, vga_b);
  end
end
 
endmodule