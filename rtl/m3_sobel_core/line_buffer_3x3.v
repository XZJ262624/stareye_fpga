`timescale 1ns/1ps
// Two synchronous row memories. Writes are deliberately delayed one clock:
// a simultaneous read targets the NEXT accepted coordinate, never the write.
// Supported protocol: WIDTH >= 3, HEIGHT >= 3, SOF has no accepted pixel.
module line_buffer_3x3 #(
    parameter WIDTH = 1280, parameter HEIGHT = 720
)(
    input clk, input rst_n, input in_sof, input in_valid,
    input [7:0] in_gray,
    output reg out_valid,
    output reg [7:0] top_pixel, middle_pixel, bottom_pixel,
    output reg [11:0] out_x, out_y
);
    (* syn_ramstyle = "block_ram" *) reg [7:0] row1 [0:WIDTH-1];
    (* syn_ramstyle = "block_ram" *) reg [7:0] row2 [0:WIDTH-1];
    reg [11:0] x, y, write_x;
    reg write_pending, frame_armed;
    // synthesis translate_off
    initial begin
        if (WIDTH < 3 || HEIGHT < 3 || WIDTH > 4096 || HEIGHT > 4096)
            $fatal(1,"M3 dimensions must be within 3..4096");
    end
    // synthesis translate_on
    // A reset in the middle of a raster must not relabel its remaining pixels.
    // Ignore algorithm input until SOF; also stop after a complete frame.
    wire accept = in_valid && !in_sof && rst_n && frame_armed;

    // No reset or initialization of memory/read registers is required.
    always @(posedge clk) begin
        if (rst_n && !in_sof) begin
            if (write_pending) begin
                row1[write_x] <= bottom_pixel;
                row2[write_x] <= middle_pixel;
            end
            if (accept) begin
                middle_pixel <= row1[x];
                top_pixel <= row2[x];
                bottom_pixel <= in_gray;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 0; y <= 0; write_x <= 0; write_pending <= 0; frame_armed<=0;
            out_valid <= 0; out_x <= 0; out_y <= 0;
        end else begin
            out_valid <= accept;
            write_pending <= accept;
            if (in_sof) begin
                x <= 0; y <= 0; frame_armed <= 1;
            end else if (accept) begin
                write_x <= x; out_x <= x; out_y <= y;
                if (x == WIDTH-1) begin
                    x <= 0;
                    if (y == HEIGHT-1) begin y <= 0; frame_armed <= 0; end
                    else y <= y + 1'b1;
                end else x <= x + 1'b1;
            end
        end
    end
endmodule
