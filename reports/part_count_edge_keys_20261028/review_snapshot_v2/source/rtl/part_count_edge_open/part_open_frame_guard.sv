`timescale 1ns/1ps
// Every display frame, independently of job admission and CCL completion.
module part_open_frame_guard #(parameter RX=160,RY=90,RW=960,RH=540)(
 input clk,rst_n,ce,invalidate,sof,eof,active,qualified,edge_support,input [11:0] x,y,
 input [63:0] frame_id,epoch,config_id,display_seq,output complete_good,frame_bad
);
 reg opened,bad;reg [18:0] pixels;reg [9:0] nx,ny;reg [63:0] f,e,c,s;
 wire inside_roi=active&&x>=RX&&x<RX+RW&&y>=RY&&y<RY+RH;
 wire tuple_ok=frame_id==f&&epoch==e&&config_id==c&&display_seq==s;
 wire pixel_bad=inside_roi&&(!edge_support||x-RX!=nx||y-RY!=ny||pixels>=RW*RH);
 wire live_bad=opened&&(!qualified||!tuple_ok||pixel_bad||sof);
 assign complete_good=ce&&eof&&opened&&!bad&&!live_bad&&!sof&&!active&&qualified&&tuple_ok&&pixels==RW*RH&&nx==0&&ny==RH&&!invalidate;
 assign frame_bad=ce&&!invalidate&&(live_bad||(eof&&!complete_good)||(active&&!opened));
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin opened<=0;bad<=0;pixels<=0;nx<=0;ny<=0;f<=0;e<=0;c<=0;s<=0;end
  else if(ce)begin
   if(invalidate)begin opened<=0;bad<=0;pixels<=0;nx<=0;ny<=0;end
   else if(sof)begin opened<=1;bad<=opened||active||eof||!qualified;pixels<=0;nx<=0;ny<=0;f<=frame_id;e<=epoch;c<=config_id;s<=display_seq;end
   else if(opened)begin
    if(live_bad)bad<=1;
    if(inside_roi)begin pixels<=pixels+1'b1;if(nx==RW-1)begin nx<=0;ny<=ny+1'b1;end else nx<=nx+1'b1;end
    if(eof)opened<=0;
   end
  end
 end
endmodule
