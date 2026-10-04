`timescale 1ns/1ps
module window_3x3 (
    input clk, input rst_n, input in_valid,
    input [11:0] in_x, in_y,
    input [7:0] top_pixel, middle_pixel, bottom_pixel,
    output reg out_valid,
    output reg [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid <= 0;
            p00<=0; p01<=0; p02<=0; p10<=0; p11<=0; p12<=0;
            p20<=0; p21<=0; p22<=0;
        end else begin
            out_valid <= in_valid && in_x >= 2 && in_y >= 2;
            if (in_valid) begin
                p00 <= (in_x==0) ? 8'd0 : p01;
                p01 <= (in_x==0) ? 8'd0 : p02;
                p02 <= top_pixel;
                p10 <= (in_x==0) ? 8'd0 : p11;
                p11 <= (in_x==0) ? 8'd0 : p12;
                p12 <= middle_pixel;
                p20 <= (in_x==0) ? 8'd0 : p21;
                p21 <= (in_x==0) ? 8'd0 : p22;
                p22 <= bottom_pixel;
            end
        end
    end
endmodule
