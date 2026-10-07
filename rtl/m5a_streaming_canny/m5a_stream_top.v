`timescale 1ns/1ps
// Fixed accepted-CE raster: blanking advances, ce=0 freezes the complete stream.
// Input n -> n+4*H_TOTAL+25 here; the OSD adds one more sampling edge.
module m5a_stream_top #(parameter WIDTH=1280,HEIGHT=720,H_TOTAL=1650)(
 input clk,ce,arst_n,input [7:0] in_gray,input in_de,in_hs,in_vs,in_sof,
 input filter_request,input [7:0] threshold,input [2:0] mode,
 output [23:0] out_rgb,output out_de,out_hs,out_vs,
 output [7:0] out_raw,out_legacy_mag,out_threshold,out_nms,
 output out_legacy_bin,out_overlay_valid,out_overlay_edge,out_nms_valid,out_canny_valid,out_canny_edge,
 output [2:0] out_mode,output out_filter_enable,output [11:0] out_x,out_y,
 output raster_fault);
 (* async_reg="true" *) reg [1:0] reset_release;
 always @(posedge clk or negedge arst_n)
  if(!arst_n)reset_release<=0;else reset_release<={reset_release[0],1'b1};
 wire rst_n=reset_release[1];
 wire [57:0] base_packet,nms_packet;wire center_valid,center_edge;
 wire [11:0] center_mag,nms,nms_x,nms_y;wire [1:0] center_dir;
 m5a_centered_sobel #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) u_base(
  .clk(clk),.ce(ce),.arst_n(arst_n),.in_gray(in_gray),.in_de(in_de),.in_hs(in_hs),.in_vs(in_vs),.in_sof(in_sof),
  .filter_request(filter_request),.threshold(threshold),.mode(mode),.out_packet(base_packet),
  .center_support(center_valid),.center_edge(center_edge),.center_magnitude(center_mag),.center_direction(center_dir),.raster_fault(raster_fault));
 wire nms_support,nms_ready;
 m5a_nms #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_nms(.clk(clk),.ce(ce),.rst_n(rst_n),.in_sof(!base_packet[24]),
  .in_de(base_packet[26]),.in_support(center_valid),.magnitude(center_mag),.direction(center_dir),
  .out_support(nms_support),.nms(nms),.out_x(nms_x),.out_y(nms_y));
 m5a_packet_delay #(.BITS(58),.DELAY(H_TOTAL+3)) u_nms_packet(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_packet(base_packet),.out_packet(nms_packet),.out_ready(nms_ready));
 wire nms_good=nms_ready && nms_packet[26] && nms_support && nms_x==nms_packet[23:12] && nms_y==nms_packet[11:0];
 wire strong_edge,weak_edge;wire [7:0] low_threshold;
 m5a_dual_threshold u_classify(.support(nms_good),.nms(nms),.high_threshold(nms_packet[38:31]),
  .low_threshold(low_threshold),.strong_edge(strong_edge),.weak_edge(weak_edge));
 wire local_support,local_edge;wire [11:0] local_x,local_y;
 m5a_local_hysteresis #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_hysteresis(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_sof(nms_ready?!nms_packet[24]:1'b0),.in_de(nms_packet[26]),
  .in_support(nms_good),.strong_edge(strong_edge),.weak_edge(weak_edge),
  .out_support(local_support),.canny_edge(local_edge),.out_x(local_x),.out_y(local_y));
 wire [66:0] final_packet;wire final_ready;
 wire [57:0] nms_display_packet={nms_packet[57:26],nms_ready?nms_packet[25]:1'b1,nms_ready?nms_packet[24]:1'b1,nms_packet[23:0]};
 wire [7:0] nms_gray=!nms_good?8'd0:(nms>255)?8'd255:nms[7:0];
 m5a_packet_delay #(.BITS(67),.DELAY(H_TOTAL+3)) u_final_packet(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_packet({nms_good,nms_gray,nms_display_packet}),.out_packet(final_packet),.out_ready(final_ready));
 assign out_nms_valid=final_packet[66];assign out_nms=final_packet[65:58];
 assign {out_raw,out_legacy_mag,out_legacy_bin,out_overlay_valid,out_overlay_edge,out_threshold,
  out_mode,out_filter_enable,out_de}=final_packet[57:26];
 assign out_hs=final_ready?final_packet[25]:1'b1;assign out_vs=final_ready?final_packet[24]:1'b1;
 assign out_x=final_packet[23:12];assign out_y=final_packet[11:0];
 assign out_canny_valid=final_ready && out_de && local_support && local_x==out_x && local_y==out_y;
 assign out_canny_edge=out_canny_valid && local_edge;
 m5a_colorize u_colorize(.de(out_de),.mode(out_mode),.raw(out_raw),.legacy_mag(out_legacy_mag),.legacy_bin(out_legacy_bin),
  .overlay_valid(out_overlay_valid),.overlay_edge(out_overlay_edge),.nms_gray(out_nms),
  .canny_valid(out_canny_valid),.canny_edge(out_canny_edge),.rgb(out_rgb));
 // synthesis translate_off
 always @(posedge clk) if(rst_n && ce)begin
  if(nms_support && nms_packet[26] && (nms_x!=nms_packet[23:12] || nms_y!=nms_packet[11:0]))$fatal(1,"M5A_NMS_COORDINATE_ALIGNMENT");
  if(local_support && out_de && (local_x!=out_x || local_y!=out_y))$fatal(1,"M5A_CANNY_COORDINATE_ALIGNMENT");
 end
 // synthesis translate_on
endmodule
