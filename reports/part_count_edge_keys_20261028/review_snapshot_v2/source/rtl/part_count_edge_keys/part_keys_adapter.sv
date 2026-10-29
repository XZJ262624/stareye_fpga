`timescale 1ns/1ps
// Derived from the validated same-clock shape adapter; RAW qualification only.
module part_keys_adapter #(parameter WIDTH=1280,HEIGHT=720)(
 input wire clk,rst_n,ce,source_sof,source_de,source_qualified,
 input wire [63:0] source_frame_id,source_epoch,source_config,source_display_seq,
 input wire [7:0] source_high,input wire source_view,
 output wire [7:0] aligned_high,output wire aligned_view,
 input wire final_de,final_raster_fault,input wire [11:0] final_x,final_y,
 output reg adapter_fault,
 output wire recognition_sof,recognition_eof,recognition_active,
 output wire [63:0] aligned_frame_id,aligned_epoch,aligned_config,aligned_source_seq,
 output wire aligned_qualified
);
 reg [264:0] tags[0:1];
 reg [1:0] qualified;
 reg [1:0] wr,rd;
 reg source_armed,source_live,final_live;
 reg synchronized,discard_live;
 reg source_slot,final_slot;
 reg [264:0] current_tag;
 reg completed_qualified,eof_pending;
 wire empty=wr==rd;
 wire full=(wr[0]==rd[0])&&(wr[1]!=rd[1]);
 wire source_first=source_de&&source_armed&&!source_sof;
 wire final_first=final_de&&final_x==0&&final_y==0;
 wire final_last=final_de&&final_x==WIDTH-1&&final_y==HEIGHT-1;
 wire [264:0] incoming_tag={source_high,source_view,source_frame_id,source_epoch,source_config,source_display_seq};
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
 wire [264:0] selected_tag=start_frame?(bypass?incoming_tag:tags[rd[0]]):current_tag;
 assign {aligned_high,aligned_view,aligned_frame_id,aligned_epoch,aligned_config,aligned_source_seq}=selected_tag;
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
 assign recognition_active=final_de&&final_live&&!final_first&&!discard_live;
endmodule
