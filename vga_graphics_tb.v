`timescale 10ns/10ns // 50 MHz

module vga_graphics_tb;

reg clock;
reg [3:0] reset_key;

wire vga_hs, vga_vs;
wire [7:0] vga_r, vga_g, vga_b;

integer file;
event next;

wire [9:0] pixel_x, pixel_y;
wire video_on;
 
// build vga
vga_sync duv_vga_sync(.clock_25(clock), .reset_key(reset_key[0]), .vga_hs(vga_hs), .vga_vs(vga_vs), .video_on(video_on), .pixel_x(pixel_x), .pixel_y(pixel_y));

graphics duv_graphics(.clock_25(clock), .video_on(video_on), .pix_x(pixel_x), .pix_y(pixel_y), .graph_r(vga_r), .graph_g(vga_g), .graph_b(vga_b));
 
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
    #2 clock = ~clock;
end

always @(pixel_x or pixel_y) begin
    if(pixel_x < 640 && pixel_y < 480) begin
        ->next;
    end
    else if(pixel_y >= 480)
        $finish;
end

always @next begin
  if (pixel_x == 10'd640) begin
    $fwrite(file, "\n");
  end
  else begin
    $fwrite(file, "%d, %d, %d ", vga_r, vga_g, vga_b);
  end
end
 
endmodule