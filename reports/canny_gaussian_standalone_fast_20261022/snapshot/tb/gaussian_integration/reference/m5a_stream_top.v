`timescale 1ns/1ps
// Fixed accepted-CE raster: blanking advances, ce=0 freezes the complete stream.
// Input n -> n+4*H_TOTAL+25 here; the OSD adds one more sampling edge.
module reference_m5a_stream_top #(parameter WIDTH=1280,HEIGHT=720,H_TOTAL=1650)(
 input clk,ce,arst_n,input [7:0] in_gray,input in_de,in_hs,in_vs,in_sof,
 input filter_request,input [7:0] threshold,input [2:0] mode,
 output [23:0] out_rgb,output out_de,out_hs,out_vs,
 output [7:0] out_raw,out_legacy_mag,out_threshold,out_nms,
 output out_legacy_bin,out_overlay_valid,out_overlay_edge,out_nms_valid,out_canny_valid,out_canny_edge,
 output [2:0] out_mode,output out_filter_enable,output [11:0] out_x,out_y,
 output raster_fault,
 input [63:0] tap_input_frame_id,tap_input_epoch,input tap_input_qualified,
 input [63:0] source_pixel_tick,source_display_seq,source_config_generation,
 output tap_valid,output [1:0] tap_class,output [11:0] tap_x,tap_y,
 output [7:0] tap_high,tap_low,output tap_filter,
 output [63:0] tap_frame_id,tap_epoch,tap_timestamp,tap_display_seq,tap_config_generation,
 output fusion_tap_valid,fusion_tap_qualified,fusion_tap_support);
 (* async_reg="true" *) reg [1:0] reset_release;
 always @(posedge clk or negedge arst_n)
  if(!arst_n)reset_release<=0;else reset_release<={reset_release[0],1'b1};
 wire rst_n=reset_release[1];
 wire [57:0] base_packet,nms_packet;wire center_valid,center_edge;
 wire [11:0] center_mag,nms,nms_x,nms_y;wire [1:0] center_dir;
 reference_m5a_centered_sobel #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) u_base(
  .clk(clk),.ce(ce),.arst_n(arst_n),.in_gray(in_gray),.in_de(in_de),.in_hs(in_hs),.in_vs(in_vs),.in_sof(in_sof),
  .filter_request(filter_request),.threshold(threshold),.mode(mode),.out_packet(base_packet),
  .center_support(center_valid),.center_edge(center_edge),.center_magnitude(center_mag),.center_direction(center_dir),.raster_fault(raster_fault));
 wire nms_support,nms_ready;
 reference_m5a_nms #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_nms(.clk(clk),.ce(ce),.rst_n(rst_n),.in_sof(!base_packet[24]),
  .in_de(base_packet[26]),.in_support(center_valid),.magnitude(center_mag),.direction(center_dir),
  .out_support(nms_support),.nms(nms),.out_x(nms_x),.out_y(nms_y));
 reference_m5a_packet_delay #(.BITS(58),.DELAY(H_TOTAL+3)) u_nms_packet(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_packet(base_packet),.out_packet(nms_packet),.out_ready(nms_ready));
 wire nms_good=nms_ready && nms_packet[26] && nms_support && nms_x==nms_packet[23:12] && nms_y==nms_packet[11:0];
 wire strong_edge,weak_edge;wire [7:0] low_threshold;
 reference_m5a_dual_threshold u_classify(.support(nms_good),.nms(nms),.high_threshold(nms_packet[38:31]),
  .low_threshold(low_threshold),.strong_edge(strong_edge),.weak_edge(weak_edge));
 // An eight-entry frame-tag queue follows accepted input/output frames.
 // This avoids an unsafe fixed assumption about vertical blanking or CE stalls.
 (* syn_ramstyle="block_ram" *) reg [63:0] frame_tags[0:39];
 reg [7:0] tag_committed;
 reg tag_write_busy;reg [2:0] tag_write_word,tag_write_slot;
 reg [319:0] tag_write_buffer;
 reg [7:0] tag_qualified;
 reg [319:0] tag_head;
 reg [63:0] source_sof_time,source_sof_seq;reg source_sof_d;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin source_sof_time<=0;source_sof_seq<=0;source_sof_d<=0;end
  else if(ce)begin source_sof_d<=in_sof;if(in_sof&&!source_sof_d)begin source_sof_time<=source_pixel_tick;source_sof_seq<=source_display_seq+1'b1;end end
 end
 reg [3:0] tag_write,tag_read;reg tag_armed;
 wire tags_empty=tag_write==tag_read;
 wire tags_full=(tag_write-tag_read)==8;
 wire tap_raster_valid=ce&&nms_ready&&nms_packet[26]&&!tags_empty;
 wire [2:0] last_source_tag=tag_write[2:0]-1'b1;
 wire consume_tag=tap_raster_valid&&tap_x==WIDTH-1&&tap_y==HEIGHT-1;
 wire reserve_tag=in_de&&tag_armed&&!tags_full;
 reg tag_head_valid,next_head_valid;reg [2:0] next_head_slot;
 reg [319:0] next_head,tag_assembly;
 reg [63:0] tag_ram_read;
 reg tag_fetch_busy;reg [2:0] tag_fetch_slot,tag_fetch_phase;
 wire [2:0] next_slot=tag_read[2:0]+3'd1;
 wire [319:0] assembled_tag={tag_ram_read,tag_assembly[255:0]};
 // One physical64-bit write and one physical64-bit synchronous read port.
 always @(posedge clk)if(ce)begin
  if(tag_write_busy)
   frame_tags[tag_write_slot*5+tag_write_word]<=tag_write_buffer[tag_write_word*64+:64];
  if(tag_fetch_busy&&tag_fetch_phase<5)
   tag_ram_read<=frame_tags[tag_fetch_slot*5+tag_fetch_phase];
 end
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   tag_committed<=0;tag_write_busy<=0;tag_write_word<=0;tag_write_slot<=0;tag_write_buffer<=0;
   tag_head<=0;tag_head_valid<=0;next_head<=0;next_head_valid<=0;next_head_slot<=0;
   tag_assembly<=0;tag_fetch_busy<=0;tag_fetch_slot<=0;tag_fetch_phase<=0;
  end else if(ce)begin
   if(reserve_tag)begin
    tag_write_busy<=1;tag_write_word<=0;tag_write_slot<=tag_write[2:0];
    tag_write_buffer<={source_sof_seq,source_config_generation,source_sof_time,tap_input_epoch,tap_input_frame_id};
    tag_committed[tag_write[2:0]]<=0;
   end
   if(tag_write_busy)begin
    if(tag_write_word==4)begin tag_write_busy<=0;tag_committed[tag_write_slot]<=1;end
    else tag_write_word<=tag_write_word+1'b1;
   end
   if(!tag_fetch_busy)begin
    if(!tags_empty&&!tag_head_valid&&tag_committed[tag_read[2:0]])begin
     tag_fetch_busy<=1;tag_fetch_slot<=tag_read[2:0];tag_fetch_phase<=0;
    end else if((tag_write-tag_read)>1&&(!next_head_valid||next_head_slot!=next_slot)&&tag_committed[next_slot])begin
     tag_fetch_busy<=1;tag_fetch_slot<=next_slot;tag_fetch_phase<=0;
    end
   end else begin
    if(tag_fetch_phase!=0)tag_assembly[(tag_fetch_phase-1)*64+:64]<=tag_ram_read;
    if(tag_fetch_phase==5)begin
     tag_fetch_busy<=0;
     if(tag_fetch_slot==tag_read[2:0])begin tag_head<=assembled_tag;tag_head_valid<=1;end
     else begin next_head<=assembled_tag;next_head_slot<=tag_fetch_slot;next_head_valid<=1;end
    end else tag_fetch_phase<=tag_fetch_phase+1'b1;
   end
   if(consume_tag)begin
    tag_committed[tag_read[2:0]]<=0;next_head_valid<=0;
    if(tag_fetch_busy&&tag_fetch_phase==5&&tag_fetch_slot==next_slot)begin
     tag_head<=assembled_tag;tag_head_valid<=1;
    end else if(next_head_valid&&next_head_slot==next_slot)begin tag_head<=next_head;tag_head_valid<=1;end
    else tag_head_valid<=0;
   end
  end
 end
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin tag_write<=0;tag_read<=0;tag_armed<=1;tag_qualified<=0;end
  else if(ce)begin
   if(in_sof)tag_armed<=1;
   if(in_de&&tag_armed&&!tags_full)begin
    tag_qualified[tag_write[2:0]]<=tap_input_qualified;
    tag_write<=tag_write+1'b1;tag_armed<=0;
   end
   // Invalidation is sticky for this source frame, even while older pixels
   // remain in the pipeline. The capture then fails/finishes by its wall clock.
   if(in_de&&!tag_armed&&!tap_input_qualified)tag_qualified[last_source_tag]<=0;
   // Consume every raw raster EOF, including unqualified/invalidated frames.
   if(tap_raster_valid&&tap_x==WIDTH-1&&tap_y==HEIGHT-1)tag_read<=tag_read+1'b1;
  end
 end
 assign tap_valid=tap_raster_valid&&tag_qualified[tag_read[2:0]];
 assign fusion_tap_valid=tap_raster_valid;
 assign fusion_tap_qualified=tag_qualified[tag_read[2:0]];
 assign fusion_tap_support=nms_good;
 assign tap_x=nms_packet[23:12];assign tap_y=nms_packet[11:0];
 assign tap_class=!nms_good?2'b00:strong_edge?2'b10:weak_edge?2'b01:2'b00;
 assign tap_high=nms_packet[38:31];assign tap_low=low_threshold;
 assign tap_filter=nms_packet[27];
 assign {tap_display_seq,tap_config_generation,tap_timestamp,tap_epoch,tap_frame_id}=tag_head;
 wire local_support,local_edge;wire [11:0] local_x,local_y;
 reference_m5a_local_hysteresis #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_hysteresis(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_sof(nms_ready?!nms_packet[24]:1'b0),.in_de(nms_packet[26]),
  .in_support(nms_good),.strong_edge(strong_edge),.weak_edge(weak_edge),
  .out_support(local_support),.canny_edge(local_edge),.out_x(local_x),.out_y(local_y));
 wire [66:0] final_packet;wire final_ready;
 wire [57:0] nms_display_packet={nms_packet[57:26],nms_ready?nms_packet[25]:1'b1,nms_ready?nms_packet[24]:1'b1,nms_packet[23:0]};
 wire [7:0] nms_gray=!nms_good?8'd0:(nms>255)?8'd255:nms[7:0];
 reference_m5a_packet_delay #(.BITS(67),.DELAY(H_TOTAL+3)) u_final_packet(
  .clk(clk),.ce(ce),.rst_n(rst_n),.in_packet({nms_good,nms_gray,nms_display_packet}),.out_packet(final_packet),.out_ready(final_ready));
 assign out_nms_valid=final_packet[66];assign out_nms=final_packet[65:58];
 assign {out_raw,out_legacy_mag,out_legacy_bin,out_overlay_valid,out_overlay_edge,out_threshold,
  out_mode,out_filter_enable,out_de}=final_packet[57:26];
 assign out_hs=final_ready?final_packet[25]:1'b1;assign out_vs=final_ready?final_packet[24]:1'b1;
 assign out_x=final_packet[23:12];assign out_y=final_packet[11:0];
 assign out_canny_valid=final_ready && out_de && local_support && local_x==out_x && local_y==out_y;
 assign out_canny_edge=out_canny_valid && local_edge;
 reference_m5a_colorize u_colorize(.de(out_de),.mode(out_mode),.raw(out_raw),.legacy_mag(out_legacy_mag),.legacy_bin(out_legacy_bin),
  .overlay_valid(out_overlay_valid),.overlay_edge(out_overlay_edge),.nms_gray(out_nms),
  .canny_valid(out_canny_valid),.canny_edge(out_canny_edge),.rgb(out_rgb));
 // synthesis translate_off
 always @(posedge clk) if(rst_n && ce)begin
  if(nms_support && nms_packet[26] && (nms_x!=nms_packet[23:12] || nms_y!=nms_packet[11:0]))$fatal(1,"M5A_NMS_COORDINATE_ALIGNMENT");
  if(local_support && out_de && (local_x!=out_x || local_y!=out_y))$fatal(1,"M5A_CANNY_COORDINATE_ALIGNMENT");
 end
 // synthesis translate_on
endmodule

