`timescale 1ns/1ps
// Same-clock source-frame metadata FIFO. No assumed NMS/final fixed delay.
// Corrupt queue association fails closed until reset; never guesses a new label.
module shape_stream_adapter_contract_v2(
 input wire clk,rst_n,ce,
 input wire source_sof,source_de,source_qualified,
 input wire [63:0] source_frame_id,source_epoch,source_config,source_display_seq,
 input wire final_de,final_support,final_edge,final_raster_fault,
 input wire [11:0] final_x,final_y,
 output wire [1:0] display_class,output wire display_valid,
 output wire [63:0] display_frame_id,display_epoch,display_config,display_source_seq,
 output wire result_done,result_valid,output wire [1:0] result_class,
 output wire [63:0] result_frame_id,result_epoch,result_config,result_source_seq,
 output reg adapter_fault,
 output wire recognition_sof,recognition_eof,
 output wire [63:0] aligned_frame_id,aligned_epoch,aligned_config,aligned_source_seq,
 output wire aligned_qualified
);
 reg [255:0] tags[0:1];
 reg [1:0] qualified;
 reg [1:0] wr,rd;
 reg source_armed,source_live,final_live;
 reg synchronized,discard_live;
 reg source_slot,final_slot;
 reg [255:0] current_tag;
 reg completed_qualified,eof_pending;
 wire empty=wr==rd;
 wire full=(wr[0]==rd[0])&&(wr[1]!=rd[1]);
 wire source_first=source_de&&source_armed&&!source_sof;
 wire final_first=final_de&&final_x==0&&final_y==0;
 wire final_last=final_de&&final_x==1279&&final_y==719;
 wire [255:0] incoming_tag={source_frame_id,source_epoch,source_config,source_display_seq};
 // DMA qualification and frame ID are pixel-associated. Epoch/config/seq
 // remain valid control fields in blanking, until the next explicit source SOF.
 wire source_bad_now=source_live&&!source_sof&&
  ((source_de&&(!source_qualified||source_frame_id!=tags[source_slot][255:192]))||
   {source_epoch,source_config,source_display_seq}!=tags[source_slot][191:0]);
 // Same-edge enqueue/final-first is unambiguous only for an empty queue.
 wire bypass=empty&&source_first&&!full;
 wire have_head=!empty||bypass;
 wire start_frame=final_first&&have_head&&!final_live&&!discard_live&&!eof_pending;
 wire head_qualified=bypass?source_qualified:!empty&&qualified[rd[0]]&&!(source_bad_now&&source_slot==rd[0]);
 wire live_qualified=qualified[final_slot]&&!(source_bad_now&&source_slot==final_slot);
 assign recognition_sof=start_frame;
 assign recognition_eof=eof_pending;
 wire [255:0] selected_tag=start_frame?(bypass?incoming_tag:tags[rd[0]]):current_tag;
 assign {aligned_frame_id,aligned_epoch,aligned_config,aligned_source_seq}=selected_tag;
 assign aligned_qualified=!adapter_fault&&!final_raster_fault&&
  (discard_live?1'b0:final_first?start_frame&&head_qualified:final_live?live_qualified:
   completed_qualified&&!(source_bad_now&&source_slot==final_slot));
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   synchronized<=0;discard_live<=0;qualified<=0;wr<=0;rd<=0;source_armed<=0;source_live<=0;final_live<=0;
   source_slot<=0;final_slot<=0;current_tag<=0;completed_qualified<=0;eof_pending<=0;adapter_fault<=0;
  end else if(ce)begin
   eof_pending<=final_last&&final_live;
   if(source_bad_now)qualified[source_slot]<=0;
   if(source_sof)begin
    source_armed<=1;source_live<=0;
    if(source_de)adapter_fault<=1;
   end
   if(source_first)begin
    source_armed<=0;source_live<=1;source_slot<=wr[0];
    if(full)begin adapter_fault<=1;source_live<=0;end
    else begin tags[wr[0]]<=incoming_tag;qualified[wr[0]]<=source_qualified;wr<=wr+1'b1;end
   end
   if(final_first)begin
    if(start_frame)begin
     synchronized<=1;current_tag<=bypass?incoming_tag:tags[rd[0]];
     final_slot<=rd[0];final_live<=1;completed_qualified<=0;
    end else if(!synchronized&&!have_head&&!final_live&&!discard_live&&!eof_pending)begin
     // Startup-only untagged raster: no recognition SOF and no queue pop.
     discard_live<=1;completed_qualified<=0;
    end else begin adapter_fault<=1;completed_qualified<=0;end
   end
   if(final_last)begin
    if(discard_live)begin discard_live<=0;completed_qualified<=0;end
    else if(!final_live||empty)begin adapter_fault<=1;completed_qualified<=0;end
    else begin
     completed_qualified<=live_qualified&&!adapter_fault&&!final_raster_fault;
     rd<=rd+1'b1;
    end
    final_live<=0;
   end
   if(synchronized&&final_de&&!final_first&&!final_live&&!discard_live)
    begin adapter_fault<=1;completed_qualified<=0;end

  end
 end
 shape_recognizer_epoch recognize(
  .clk(clk),.rst_n(rst_n),.ce(ce),.sof(recognition_sof),.eof(recognition_eof),
  // (0,0) alone is consumed as control, outside the frozen ROI.
  .active(final_de&&final_live&&!final_first&&!discard_live),.support(final_support),.edge_pixel(final_edge),
  .source_valid(aligned_qualified),.x(final_x),.y(final_y),
  .frame_id(aligned_frame_id),.epoch(aligned_epoch),.config_generation(aligned_config),.source_display_seq(aligned_source_seq),
  .result_done(result_done),.result_valid(result_valid),.result_class(result_class),
  .result_frame_id(result_frame_id),.result_epoch(result_epoch),.result_config_generation(result_config),.result_source_display_seq(result_source_seq),
  .display_class(display_class),.display_valid(display_valid),.display_frame_id(display_frame_id),.display_epoch(display_epoch),.display_config_generation(display_config),.display_source_display_seq(display_source_seq),.busy());
endmodule
