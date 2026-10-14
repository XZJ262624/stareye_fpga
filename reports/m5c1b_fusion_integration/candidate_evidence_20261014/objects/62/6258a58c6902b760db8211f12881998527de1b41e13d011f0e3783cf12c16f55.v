`timescale 1ns/1ps
// One common raster for all four modes. Original input slot n appears after
// n+2*H_TOTAL+17 here; the RGB OSD adds one further sampling edge.
// Legacy modes preserve M32 slot semantics. OVR reanchors the CURRENT M32
// center edge to the DELAYED original slot, including its original RAW.
module m4_stream_top #(
 parameter WIDTH=1280,parameter HEIGHT=720,parameter H_TOTAL=1650
)(input clk,input arst_n,input [7:0] in_gray,input in_de,in_hs,in_vs,in_sof,
 input filter_request,input [7:0] threshold,input [1:0] mode,
 output [23:0] out_rgb,output out_de,out_hs,out_vs,
 output [7:0] out_raw,out_legacy,out_threshold,output [1:0] out_mode,
 output out_filter_enable,overlay_valid,overlay_edge,
 output [11:0] out_x,out_y,output raster_fault);
 (* async_reg="true" *) reg [1:0] reset_release;
 always @(posedge clk or negedge arst_n)
  if(!arst_n)reset_release<=0;else reset_release<={reset_release[0],1'b1};
 wire rst_n=reset_release[1];
 wire [7:0] legacy,raw,mag,t;
 wire bin,valid,de,hs,vs,filter;
 wire [1:0] m;
 wire [11:0] x,y,cx,cy;
 m32_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) u_m32(
  .clk(clk),.arst_n(arst_n),.in_gray(in_gray),.in_de(in_de),.in_hs(in_hs),
  .in_vs(in_vs),.in_sof(in_sof),.filter_request(filter_request),
  .threshold(threshold),.mode(mode),.out_gray(legacy),.raw_gray(raw),.edge_gray(mag),
  .edge_binary(bin),.out_valid(valid),.out_de(de),.out_hs(hs),.out_vs(vs),
  .out_filter_enable(filter),.out_threshold(t),.out_mode(m),
  .out_x(x),.out_y(y),.center_x(cx),.center_y(cy));
 wire [53:0] packet;
 wire ready;
 // This module samples the preceding M32 edge: DELAY+1 effective edges.
 raster_packet_delay #(.BITS(54),.DELAY(H_TOTAL)) u_display_packet(
  .clk(clk),.rst_n(rst_n),.in_packet({raw,legacy,t,m,filter,de,hs,vs,x,y}),
  .out_packet(packet),.out_ready(ready));
 assign {out_raw,out_legacy,out_threshold,out_mode,out_filter_enable,
         out_de}=packet[53:26];
 assign out_hs=ready?packet[25]:1'b1;
 assign out_vs=ready?packet[24]:1'b1;
 assign out_x=packet[23:12];assign out_y=packet[11:0];

 // M32 is a fixed-raster engine. Fail closed for red after a malformed DE
 // run or line period. Ordinary horizontal/vertical blanking is legal.
 // The next VS boundary resets the fault; all original modes stay untouched.
 reg de_previous,vs_previous,seen_line,bad_frame;
 reg [11:0] run_length;
 localparam PW=$clog2(H_TOTAL+2);
 reg [PW-1:0] since_line;
 wire short_line=de_previous && !de && run_length!=WIDTH;
 wire long_line=de && de_previous && run_length>=WIDTH;
 wire bad_period=de && !de_previous && seen_line && since_line!=H_TOTAL-1;
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n)begin de_previous<=0;vs_previous<=1;seen_line<=0;
   bad_frame<=1;run_length<=0;since_line<=0;end
  else begin
   de_previous<=de;vs_previous<=vs;
   if(vs_previous && !vs)begin seen_line<=0;bad_frame<=0;run_length<=0;since_line<=0;end
   else begin
    if(short_line || long_line || bad_period)bad_frame<=1;
    if(de && !de_previous)begin run_length<=1;since_line<=0;seen_line<=1;end
    else begin
     if(de && run_length<WIDTH+1)run_length<=run_length+1'b1;
     if(seen_line && since_line<H_TOTAL+1)since_line<=since_line+1'b1;
    end
   end
  end
 end
 assign raster_fault=bad_frame || short_line || long_line || bad_period;
 assign overlay_valid=ready && out_de && de && valid && !raster_fault &&
                       (cx==out_x) && (cy==out_y) &&
                       (filter==out_filter_enable) && (t==out_threshold);
 assign overlay_edge=overlay_valid && bin;
 m4_colorize u_colorize(.de(out_de),.mode(out_mode),.legacy_gray(out_legacy),
  .aligned_raw(out_raw),.edge_valid(overlay_valid),.edge_binary(bin),.rgb(out_rgb));
endmodule
