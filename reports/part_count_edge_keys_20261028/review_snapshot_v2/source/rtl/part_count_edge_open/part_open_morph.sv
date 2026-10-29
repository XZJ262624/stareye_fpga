`timescale 1ns/1ps
// Compact RAW/sync delay; output raster coordinates are counted from delayed DE/VS.
module part_open_morph_stage #(parameter WIDTH=1280,HEIGHT=720,H_TOTAL=1650,ERODE=0)(
 input clk,rst_n,ce,input [7:0] in_raw,input in_de,in_hs,in_vs,in_edge,in_support,in_fault,
 output out_fault,output [7:0] out_raw,output out_de,out_hs,out_vs,output reg out_edge,out_support,output [11:0] out_x,out_y
);
 wire window_valid;wire [11:0] wx,wy;wire [1:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;
 m5a_neighborhood #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.BITS(2)) window(.clk(clk),.ce(ce),.rst_n(rst_n),.in_sof(!in_vs),.in_valid(in_de),.in_data({in_support,in_edge}),.out_valid(window_valid),.center_x(wx),.center_y(wy),.p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),.p12(p12),.p20(p20),.p21(p21),.p22(p22));
 wire support_all=p00[1]&p01[1]&p02[1]&p10[1]&p11[1]&p12[1]&p20[1]&p21[1]&p22[1];
 wire edge_all=p00[0]&p01[0]&p02[0]&p10[0]&p11[0]&p12[0]&p20[0]&p21[0]&p22[0];
 wire edge_any=p00[0]|p01[0]|p02[0]|p10[0]|p11[0]|p12[0]|p20[0]|p21[0]|p22[0];
 reg [11:0] cx,cy;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin out_edge<=0;out_support<=0;cx<=0;cy<=0;end
  else if(ce)begin out_support<=window_valid&&support_all;out_edge<=window_valid&&support_all&&(ERODE?edge_all:edge_any);cx<=wx;cy<=wy;end
 end
 wire [11:0] packet;wire ready;
 m5a_packet_delay #(.BITS(12),.DELAY(H_TOTAL+3)) raw_sync(.clk(clk),.ce(ce),.rst_n(rst_n),.in_packet({in_fault,in_raw,in_de,in_hs,in_vs}),.out_packet(packet),.out_ready(ready));
 assign out_fault=ready&&packet[11];assign out_raw=packet[10:3];assign out_de=ready&&packet[2];assign out_hs=ready?packet[1]:1'b1;assign out_vs=ready?packet[0]:1'b1;
 reg [11:0] raster_x,raster_y;reg vs_previous;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin raster_x<=0;raster_y<=0;vs_previous<=1;end
  else if(ce)begin
   vs_previous<=out_vs;
   if(vs_previous&&!out_vs)begin raster_x<=0;raster_y<=0;end
   else if(out_de)begin if(raster_x==WIDTH-1)begin raster_x<=0;if(raster_y==HEIGHT-1)raster_y<=0;else raster_y<=raster_y+1'b1;end else raster_x<=raster_x+1'b1;end
  end
 end
 assign out_x=raster_x;assign out_y=raster_y;
 // synthesis translate_off
 always @(posedge clk)if(rst_n&&ce&&out_support&&out_de&&(cx!=out_x||cy!=out_y))$fatal(1,"EDGE_MORPH_ALIGNMENT");
 // synthesis translate_on
endmodule
module part_open_morph #(parameter WIDTH=1280,HEIGHT=720,H_TOTAL=1650)(
 input clk,rst_n,ce,input [7:0] in_raw,input in_de,in_hs,in_vs,in_edge,in_support,in_fault,
 output out_fault,output [7:0] out_raw,output out_de,out_hs,out_vs,out_edge,out_support,output [11:0] out_x,out_y
);
 wire [7:0] raw;wire de,hs,vs,edge_pixel,support_pixel,fault_pixel;
 part_open_morph_stage #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL),.ERODE(0)) dilation(.clk(clk),.rst_n(rst_n),.ce(ce),.in_raw(in_raw),.in_de(in_de),.in_hs(in_hs),.in_vs(in_vs),.in_edge(in_edge),.in_support(in_support),.in_fault(in_fault),.out_fault(fault_pixel),.out_raw(raw),.out_de(de),.out_hs(hs),.out_vs(vs),.out_edge(edge_pixel),.out_support(support_pixel),.out_x(),.out_y());
 part_open_morph_stage #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL),.ERODE(1)) erosion(.clk(clk),.rst_n(rst_n),.ce(ce),.in_raw(raw),.in_de(de),.in_hs(hs),.in_vs(vs),.in_edge(edge_pixel),.in_support(support_pixel),.in_fault(fault_pixel),.out_fault(out_fault),.out_raw(out_raw),.out_de(out_de),.out_hs(out_hs),.out_vs(out_vs),.out_edge(out_edge),.out_support(out_support),.out_x(out_x),.out_y(out_y));
endmodule
