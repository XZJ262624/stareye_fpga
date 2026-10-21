`timescale 1ns/1ps
// Exact unsigned 3x3 Gaussian; nine enabled sampling stages, n -> n+8.
module gaussian_3x3 #(parameter TAG_BITS=64)(
 input clk,ce,rst_n,in_valid,
 input [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22,
 input [TAG_BITS-1:0] in_tag,
 output out_valid,output [7:0] gaussian_gray,
 output [TAG_BITS-1:0] out_tag
);
 reg[9:0] row_top,row_mid,row_bottom;
 reg[11:0] weighted_sum;
 wire [12:0] rounded_sum={1'b0,weighted_sum}+13'd8;
 reg [7:0] pixel_pipe[0:8];
 reg [TAG_BITS-1:0] tag_pipe[0:8];reg[8:0] valid_pipe;
 integer i;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   valid_pipe<=0;row_top<=0;row_mid<=0;row_bottom<=0;weighted_sum<=0;
   for(i=0;i<9;i=i+1)begin pixel_pipe[i]<=0;tag_pipe[i]<=0;end
  end else if(ce)begin
   // n: exact horizontal sums (maximum 1020), no intermediate rounding.
   row_top<={2'b0,p00}+{1'b0,p01,1'b0}+{2'b0,p02};
   row_mid<={2'b0,p10}+{1'b0,p11,1'b0}+{2'b0,p12};
   row_bottom<={2'b0,p20}+{1'b0,p21,1'b0}+{2'b0,p22};
   // n+1: exact vertical sum (maximum 4080).
   weighted_sum<={2'b0,row_top}+{1'b0,row_mid,1'b0}+{2'b0,row_bottom};
   // n+2: one final round, then six alignment registers through n+8.
   pixel_pipe[0]<=0;pixel_pipe[1]<=0;
   pixel_pipe[2]<=valid_pipe[1]?rounded_sum[11:4]:8'd0;
   tag_pipe[0]<=in_tag;valid_pipe<={valid_pipe[7:0],in_valid};
   for(i=1;i<9;i=i+1)tag_pipe[i]<=tag_pipe[i-1];
   for(i=3;i<9;i=i+1)pixel_pipe[i]<=pixel_pipe[i-1];
  end
 end
 assign out_valid=valid_pipe[8];
 assign gaussian_gray=out_valid?pixel_pipe[8]:8'd0;
 assign out_tag=tag_pipe[8];
endmodule
