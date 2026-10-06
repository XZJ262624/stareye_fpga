`timescale 1ns/1ps
// RGB888 boundary: bits [23:16]=R, [15:8]=G, [7:0]=B.
module m4_colorize(input de,input [1:0] mode,input [7:0] legacy_gray,
 input [7:0] aligned_raw,input edge_valid,input edge_binary,
 output [23:0] rgb);
 assign rgb=!de?24'd0:(mode!=2'd3)?{3{legacy_gray}}:
            (edge_valid && edge_binary)?24'hff0000:{3{aligned_raw}};
endmodule
