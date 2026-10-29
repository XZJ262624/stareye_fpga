`timescale 1ns/1ps
// CE-enabled M4 center alignment. All legacy slot values are retained explicitly.
// Input slot n -> n+2*H_TOTAL+17. Gradient outputs refer to THIS original slot.
module m5a_centered_sobel #(parameter WIDTH=1280,HEIGHT=720,H_TOTAL=1650)(
 input clk,ce,arst_n,input [7:0] in_gray,input in_de,in_hs,in_vs,in_sof,
 input [1:0] filter_request,input [7:0] threshold,input [2:0] mode,
 output [58:0] out_packet,output center_support,center_edge,
 output [11:0] center_magnitude,output [1:0] center_direction,output raster_fault);
 (* async_reg="true" *) reg [1:0] reset_release;
 always @(posedge clk or negedge arst_n)
  if(!arst_n)reset_release<=0;else reset_release<={reset_release[0],1'b1};
 wire rst_n=reset_release[1];
 wire [7:0] raw,mag,t;wire bin,valid,de,hs,vs;wire [1:0] filter;
 wire [2:0] m;wire [11:0] x,y,cx,cy,full_mag;wire [1:0] dir;
 m5a_m32_stream #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) u_m32(
  .clk(clk),.ce(ce),.arst_n(arst_n),.in_gray(in_gray),.in_de(in_de),.in_hs(in_hs),.in_vs(in_vs),.in_sof(in_sof),
  .filter_request(filter_request),.threshold(threshold),.mode(mode),.out_gray(),.raw_gray(raw),.edge_gray(mag),
  .edge_binary(bin),.out_valid(valid),.out_de(de),.out_hs(hs),.out_vs(vs),.out_filter_enable(filter),
  .out_threshold(t),.out_mode(m),.out_x(x),.out_y(y),.center_x(cx),.center_y(cy),
  .full_magnitude(full_mag),.out_direction(dir));
 wire [56:0] packet;wire ready;
 m5a_packet_delay #(.BITS(57),.DELAY(H_TOTAL)) u_display_packet(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_packet({raw,mag,bin,t,m,filter,de,hs,vs,x,y}),.out_packet(packet),.out_ready(ready));
 wire out_de=packet[26];
 wire out_hs=ready?packet[25]:1'b1,out_vs=ready?packet[24]:1'b1;
 wire [11:0] out_x=packet[23:12],out_y=packet[11:0];
 reg de_previous,vs_previous,seen_line,bad_frame;reg [11:0] run_length;
 localparam PW=$clog2(H_TOTAL+2);reg [PW-1:0] since_line;
 wire short_line=de_previous && !de && run_length!=WIDTH;
 wire long_line=de && de_previous && run_length>=WIDTH;
 wire bad_period=de && !de_previous && seen_line && since_line!=H_TOTAL-1;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin de_previous<=0;vs_previous<=1;seen_line<=0;bad_frame<=1;run_length<=0;since_line<=0;end
  else if(ce)begin
   de_previous<=de;vs_previous<=vs;
   if(vs_previous && !vs)begin seen_line<=0;bad_frame<=0;run_length<=0;since_line<=0;end
   else begin
    if(short_line || long_line || bad_period)bad_frame<=1;
    if(de && !de_previous)begin run_length<=1;since_line<=0;seen_line<=1;end
    else begin if(de && run_length<WIDTH+1)run_length<=run_length+1'b1;
     if(seen_line && since_line<H_TOTAL+1)since_line<=since_line+1'b1;end
   end
  end
 end
 assign raster_fault=bad_frame || short_line || long_line || bad_period;
 assign center_support=ready && out_de && de && valid && !raster_fault && cx==out_x && cy==out_y && filter==packet[28:27] && t==packet[39:32];
 assign center_edge=center_support && bin;
 assign center_magnitude=center_support?full_mag:12'd0;
 assign center_direction=center_support?dir:2'd0;
 // RAW8 MAG8 BIN1 support1 edge1 H8 mode3 filter1 DE/HS/VS3 x12 y12.
 assign out_packet={packet[56:40],center_support,center_edge,packet[39:26],out_hs,out_vs,packet[23:0]};
endmodule
