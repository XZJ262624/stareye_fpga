`timescale 1ns/1ps
// Thresholds use the original L1 units. Zero is NEVER an edge, including H=0.
module reference_m5a_dual_threshold(input support,input [11:0] nms,input [7:0] high_threshold,
 output [7:0] low_threshold,output strong_edge,weak_edge);
 assign low_threshold={1'b0,high_threshold[7:1]};
 assign strong_edge=support && nms!=0 && nms>={4'b0,high_threshold};
 assign weak_edge=support && nms!=0 && nms>={4'b0,low_threshold} && nms<{4'b0,high_threshold};
endmodule
