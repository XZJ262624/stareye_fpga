`timescale 1ns/1ps
// Three sampling stages, n -> n+2. Strict negative-side comparison thins ties.
module reference_m5a_nms #(parameter WIDTH=1280,HEIGHT=720)(
 input clk,ce,rst_n,in_sof,in_de,in_support,input [11:0] magnitude,input [1:0] direction,
 output reg out_support,output reg [11:0] nms,out_x,out_y);
 wire v;wire [11:0] x,y;
 wire [14:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;
 reference_m5a_neighborhood #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.BITS(15)) u_window(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_sof(in_sof),.in_valid(in_de),
  .in_data({in_support,direction,magnitude}),.out_valid(v),.center_x(x),.center_y(y),
  .p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),.p12(p12),.p20(p20),.p21(p21),.p22(p22));
 wire support=v && p00[14] && p01[14] && p02[14] && p10[14] && p11[14] && p12[14] && p20[14] && p21[14] && p22[14];
 reg [11:0] negative_neighbor,positive_neighbor;
 always @* begin
  case(p11[13:12])
   0:begin negative_neighbor=p10[11:0];positive_neighbor=p12[11:0];end
   1:begin negative_neighbor=p02[11:0];positive_neighbor=p20[11:0];end
   2:begin negative_neighbor=p01[11:0];positive_neighbor=p21[11:0];end
   default:begin negative_neighbor=p00[11:0];positive_neighbor=p22[11:0];end
  endcase
 end
 always @(posedge clk or negedge rst_n)
  if(!rst_n)begin nms<=0;out_support<=0;out_x<=0;out_y<=0;end
  else if(ce)begin
   out_support<=support;out_x<=x;out_y<=y;
   nms<=(support && p11[11:0]>negative_neighbor && p11[11:0]>=positive_neighbor)?p11[11:0]:12'd0;
  end
endmodule
