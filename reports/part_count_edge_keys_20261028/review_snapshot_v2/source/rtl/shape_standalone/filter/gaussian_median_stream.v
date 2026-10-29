`timescale 1ns/1ps
// Standalone prototype only. Shared two-line RAM/window, parallel MED/GAU.
// Raw/sync/frame/filter tags and data: input n -> output n+10 enabled ticks.
module gaussian_median_stream #(parameter WIDTH=1280,HEIGHT=720)(
 input clk,ce,arst_n,input [7:0] in_gray,
 input in_valid,in_de,in_hs,in_vs,in_sof,
 input [1:0] filter_request,input [63:0] in_frame_id,
 output [7:0] out_gray,median_gray,gaussian_gray,raw_gray,
 output out_support,window_support,out_de,out_hs,out_vs,out_sof,
 output [1:0] out_filter_id,output [63:0] out_frame_id,
 output [11:0] out_x,out_y,center_x,center_y,selected_x,selected_y
);
 localparam NONE=2'd0,MED=2'd1,GAU=2'd2;
 (* async_reg="true" *) reg[1:0] reset_release;
 always @(posedge clk or negedge arst_n)
  if(!arst_n)reset_release<=0;else reset_release<={reset_release[0],1'b1};
 wire rst_n=reset_release[1];
 reg sof_d;reg[1:0] frame_filter;reg[63:0] frame_id;
 wire frame_start=in_sof&&!sof_d;
 wire[1:0] source_filter=frame_start?filter_request:frame_filter;
 wire[63:0] source_frame=frame_start?in_frame_id:frame_id;
 always @(posedge clk or negedge rst_n)
  if(!rst_n)begin sof_d<=0;frame_filter<=NONE;frame_id<=0;end
  else if(ce)begin sof_d<=in_sof;if(frame_start)begin frame_filter<=filter_request;frame_id<=in_frame_id;end end
 wire lb_valid,win_valid,med_valid,gau_valid;
 wire[11:0] lb_x,lb_y;wire[7:0] top_pixel,middle_pixel,bottom_pixel;
 wire[7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;
 m5a_line_buffer #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_lines(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_sof(in_sof),.in_valid(in_valid),.in_gray(in_gray),
  .out_valid(lb_valid),.top_pixel(top_pixel),.middle_pixel(middle_pixel),.bottom_pixel(bottom_pixel),.out_x(lb_x),.out_y(lb_y));
 m5a_window u_window(.clk(clk),.ce(ce),.rst_n(rst_n),.in_valid(lb_valid),.in_x(lb_x),.in_y(lb_y),
  .top_pixel(top_pixel),.middle_pixel(middle_pixel),.bottom_pixel(bottom_pixel),.out_valid(win_valid),
  .p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),.p12(p12),.p20(p20),.p21(p21),.p22(p22));
 m5a_median u_median(.clk(clk),.ce(ce),.rst_n(rst_n),.in_valid(win_valid),
  .p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),.p12(p12),.p20(p20),.p21(p21),.p22(p22),
  .out_valid(med_valid),.median_gray(median_gray));
 gaussian_3x3 u_gaussian(.clk(clk),.ce(ce),.rst_n(rst_n),.in_valid(win_valid),
  .p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),.p12(p12),.p20(p20),.p21(p21),.p22(p22),
  .in_tag(64'd0),.out_valid(gau_valid),.gaussian_gray(gaussian_gray),.out_tag());
 reg[10:0] de_pipe,hs_pipe,vs_pipe,sof_pipe;reg[9:0] accepted_pipe;
 reg[7:0] gray_pipe[0:10];reg[1:0] filter_pipe[0:10];reg[63:0] frame_pipe[0:10];
 reg[11:0] x_pipe[0:9],y_pipe[0:9];integer i;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   de_pipe<=0;hs_pipe<=11'h7ff;vs_pipe<=11'h7ff;sof_pipe<=0;accepted_pipe<=0;
   for(i=0;i<11;i=i+1)begin gray_pipe[i]<=0;filter_pipe[i]<=NONE;frame_pipe[i]<=0;end
   for(i=0;i<10;i=i+1)begin x_pipe[i]<=0;y_pipe[i]<=0;end
  end else if(ce)begin
   de_pipe<={de_pipe[9:0],in_de};hs_pipe<={hs_pipe[9:0],in_hs};vs_pipe<={vs_pipe[9:0],in_vs};sof_pipe<={sof_pipe[9:0],in_sof};
   gray_pipe[0]<=in_gray;filter_pipe[0]<=source_filter;frame_pipe[0]<=source_frame;x_pipe[0]<=lb_x;y_pipe[0]<=lb_y;
   accepted_pipe<={accepted_pipe[8:0],lb_valid};
   for(i=1;i<11;i=i+1)begin gray_pipe[i]<=gray_pipe[i-1];filter_pipe[i]<=filter_pipe[i-1];frame_pipe[i]<=frame_pipe[i-1];end
   for(i=1;i<10;i=i+1)begin x_pipe[i]<=x_pipe[i-1];y_pipe[i]<=y_pipe[i-1];end
  end
 end
 assign out_de=de_pipe[10];assign out_hs=hs_pipe[10];assign out_vs=vs_pipe[10];assign out_sof=sof_pipe[10];
 assign out_filter_id=filter_pipe[10];assign out_frame_id=frame_pipe[10];assign raw_gray=out_de?gray_pipe[10]:8'd0;
 assign out_x=x_pipe[9];assign out_y=y_pipe[9];
 assign window_support=med_valid&&gau_valid;
 assign out_support=(out_filter_id==NONE)?(out_de&&accepted_pipe[9]):
  ((out_filter_id==MED)||(out_filter_id==GAU))?window_support:1'b0;
 assign center_x=window_support?out_x-12'd1:12'd0;assign center_y=window_support?out_y-12'd1:12'd0;
 assign selected_x=out_support?((out_filter_id==NONE)?out_x:center_x):12'd0;
 assign selected_y=out_support?((out_filter_id==NONE)?out_y:center_y):12'd0;
 assign out_gray=!out_de?8'd0:(out_filter_id==NONE)?raw_gray:
  (out_filter_id==MED)?median_gray:(out_filter_id==GAU)?gaussian_gray:8'd0;
endmodule
