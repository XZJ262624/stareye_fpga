`timescale 1ns/1ps
// Exactly one hop in the original strong classification; output never feeds back.
module reference_m5a_local_hysteresis #(parameter WIDTH=1280,HEIGHT=720)(
 input clk,ce,rst_n,in_sof,in_de,in_support,strong_edge,weak_edge,
 output reg out_support,output reg canny_edge,output reg [11:0] out_x,out_y);
 wire v;wire [11:0] x,y;
 wire [2:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;
 reference_m5a_neighborhood #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.BITS(3)) u_window(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_sof(in_sof),.in_valid(in_de),
  .in_data({in_support,strong_edge,weak_edge}),.out_valid(v),.center_x(x),.center_y(y),
  .p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),.p12(p12),.p20(p20),.p21(p21),.p22(p22));
 wire support=v && p00[2] && p01[2] && p02[2] && p10[2] && p11[2] && p12[2] && p20[2] && p21[2] && p22[2];
 wire nearby=p00[1] || p01[1] || p02[1] || p10[1] || p12[1] || p20[1] || p21[1] || p22[1];
 always @(posedge clk or negedge rst_n)
  if(!rst_n)begin out_support<=0;canny_edge<=0;out_x<=0;out_y<=0;end
  else if(ce)begin out_support<=support;out_x<=x;out_y<=y;canny_edge<=support && (p11[1] || (p11[0] && nearby));end
endmodule
