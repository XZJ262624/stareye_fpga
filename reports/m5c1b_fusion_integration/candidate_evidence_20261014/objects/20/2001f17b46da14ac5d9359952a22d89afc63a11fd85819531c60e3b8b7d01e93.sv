// Pixel-domain adapter: one synchronous-reference stage, fixed final raster.
module m5c_fusion_display(
 input context_block,output context_quiet,context_tail_fault,
 input clk,rst_n,ce,raw_sof,stop,enable,export_status,ddr_error_status,hardstop_status,input [63:0] epoch,config_generation,
 input [7:0] high_threshold,input filter_enable,
 input tap_valid,tap_qualified,tap_support,input [1:0] tap_class,input [11:0] tap_x,tap_y,
 input final_de,input [11:0] final_x,final_y,input local_edge,input [7:0] raw_gray,
 input [2:0] mode,input [23:0] base_rgb,output [23:0] fused_rgb,
 output [63:0] pixel_ticks,display_seq,output [159:0] config_signature,
 output request_frame,output [63:0] request_seq,
 input offer_valid,output offer_take,input [767:0] offer_descriptor,input [63:0] offer_session,
 output reg pixel_release,output reg release_final,output reg [63:0] release_session,input release_ready,
 output [63:0] read_session,input prefilled,ref_ready,input [1:0] ref_class,input ref_mask,
 input [11:0] ref_x,ref_y,input [63:0] ref_session,output retire,output [11:0] retire_row,output flush,
 output eligible,output [31:0] age_frames,age_ticks,output promoted,output frame_ok,
 output frame_done,output [479:0] telemetry_snapshot);
 wire [767:0] descriptor=offer_descriptor;reg [63:0] session;reg have_offer,released,tap_seen,broken;
 reg request_pending,sof_seen;wire sof_edge=ce&&raw_sof&&!sof_seen;
 assign config_signature={config_generation,8'd1,8'd1,12'd1280,12'd720,high_threshold,{1'b0,high_threshold[7:1]},filter_enable,(filter_enable?3'd3:3'd2),8'd1,28'd0};
 wire time_fault;
 m5c_age_guard age(.clk(clk),.rst_n(rst_n),.ce(ce),.display_sof(raw_sof),.stop(stop),.enable(enable&&config_generation!=64'hffffffffffffffff),
  .descriptor_valid(have_offer),.age_valid(descriptor[751:744]==1&&descriptor[743:736]==1),
  .current_epoch(epoch),.descriptor_epoch(descriptor[63:0]),.capture_seq(descriptor[383:320]),.capture_tick(descriptor[575:512]),
  .current_config(config_signature),.descriptor_config(descriptor[735:576]),
  .pixel_ticks(pixel_ticks),.display_seq(display_seq),.time_fault(time_fault),.eligible(eligible),.age_frames(age_frames),.age_ticks(age_ticks));
 assign request_frame=request_pending&&enable&&!stop;
 assign request_seq=display_seq;
 assign offer_take=offer_valid;
 assign read_session=have_offer?session:offer_session;
 assign flush=context_block||context_tail_fault||broken||(!have_offer&&!offer_valid);
 wire first_tap=tap_valid&&tap_x==0&&tap_y==0;
 reg dvalid,dqualified,dsupport,dsof,dadmit;reg [1:0] dclass;reg [11:0] dx,dy;reg [63:0] dsession;
 wire row_context_quiet;
 wire ref_tag_good=!context_block&&!context_tail_fault&&ref_ready&&ref_session==dsession&&dsession==session;
 wire [319:0] identity={descriptor[63:0],descriptor[191:128],descriptor[127:64],descriptor[447:384],descriptor[511:448]};
 wire invalidate=context_block||context_tail_fault||stop||broken||(tap_seen&&!eligible);
 wire fused_edge;
 reg [31:0] promotion_count,rejected_rows,equal_rows,reason_bits;
 reg [63:0] late_rows,underflows;
 reg row_match,frame_admitted;
 assign context_quiet=!have_offer&&!dvalid&&!dsof&&!dadmit&&!frame_admitted&&!row_match&&row_context_quiet;
 wire config_bad=descriptor[735:576]!=config_signature||config_generation==64'hffffffffffffffff;
 wire age_bad=time_fault||descriptor[751:744]!=1||descriptor[743:736]!=1||
  descriptor[63:0]!=epoch||age_frames>120||age_ticks>148500000;
 wire row_attempt=frame_admitted&&have_offer&&!broken&&enable;
 reg [31:0] reason_events;
 // One OR reduction prevents simultaneous reasons from overwriting each other.
 always @*begin
  reason_events=0;
  if(enable)begin
   if(first_tap&&!have_offer)reason_events[0]=1;
   if(export_status)reason_events[1]=1;
   if(have_offer&&age_bad)reason_events[2]=1;
   if(have_offer&&config_bad)reason_events[3]=1;
   if((first_tap&&!tap_qualified)||(dvalid&&!dqualified))reason_events[4]=1;
   if((first_tap&&have_offer&&eligible&&!prefilled)||(row_attempt&&dvalid&&!ref_ready))reason_events[5]=1;
   if(row_attempt&&dvalid&&ref_ready&&!ref_tag_good)reason_events[6]=1;
   if(row_attempt&&dvalid&&dx==1279&&ref_tag_good&&!(row_match&&dclass==ref_class&&dclass!=3))reason_events[7]=1;
  end
  if(ddr_error_status)reason_events[8]=1;
  if(hardstop_status)reason_events[9]=1;
 end
 assign frame_done=ce&&final_de&&final_x==1279&&final_y==719;
 assign telemetry_snapshot={underflows,late_rows,(reason_bits|reason_events),28'd0,export_status,hardstop_status,eligible,enable,
  promotion_count+{31'd0,promoted},rejected_rows,equal_rows,(session==display_seq?session:64'd0),pixel_ticks,display_seq};
 m5c_row_fusion #(.REF_STAGE(1)) fusion(.context_block(context_block),.context_quiet(row_context_quiet),.context_tail_fault(context_tail_fault),.clk(clk),.rst_n(rst_n),.ce(ce),.sof(dsof),.admit(dadmit),.invalidate(invalidate),.identity_in(identity),
  .tap_valid(dvalid),.tap_qualified(dqualified),.tap_x(dx),.tap_y(dy),.current_class(dclass),.current_support(dsupport),
  .ref_ready(ref_tag_good),.ref_class(ref_class),.ref_global(ref_mask),.ref_identity(identity),.ref_x(ref_x),.ref_y(ref_y),
  .support_radius(descriptor[272]?4'd3:4'd2),.final_de(final_de),.final_x(final_x),.final_y(final_y),.local_edge(local_edge),
  .fused_edge(fused_edge),.promoted(promoted),.frame_ok(frame_ok),.row_retire(retire),.retired_y(retire_row));
 assign fused_rgb=!final_de?24'd0:mode==6&&enable?(local_edge?24'hff0000:promoted?24'h00ffff:{raw_gray,raw_gray,raw_gray}):base_rgb;
 // Raster owns per-frame statistics even while the fusion context is blocked.
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin promotion_count<=0;equal_rows<=0;rejected_rows<=0;end
  else if(ce&&first_tap)begin promotion_count<=0;equal_rows<=0;rejected_rows<=0;end
  else if(ce&&!context_block&&!context_tail_fault)begin
   if(promoted)promotion_count<=promotion_count+1'b1;
   if(dvalid&&row_attempt&&dx==1279)begin
    if(row_match&&ref_tag_good&&dclass==ref_class&&dclass!=3)equal_rows<=equal_rows+1'b1;
    else rejected_rows<=rejected_rows+1'b1;
   end
  end
 end
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin session<=0;have_offer<=0;released<=1;tap_seen<=0;broken<=1;
   request_pending<=0;sof_seen<=0;dsession<=0;pixel_release<=0;release_final<=0;release_session<=0;dvalid<=0;dqualified<=0;dsupport<=0;dsof<=0;dadmit<=0;dclass<=0;dx<=0;dy<=0;
   reason_bits<=0;late_rows<=0;underflows<=0;row_match<=0;frame_admitted<=0;end
  else begin
   request_pending<=sof_edge;if(pixel_release&&release_ready)pixel_release<=0;if(ce)sof_seen<=raw_sof;
   if(stop)broken<=1;
   reason_bits<=(ce&&first_tap?32'd0:reason_bits)|reason_events;
   if(sof_edge)tap_seen<=0;
   // Raster progress survives context kill; a current first tap is already late.
   if(ce&&first_tap)tap_seen<=1;
   if(!context_block&&!context_tail_fault&&offer_valid)begin
    if(offer_session==display_seq&&!tap_seen&&!(ce&&first_tap)&&!have_offer)begin
     session<=offer_session;have_offer<=1;released<=0;broken<=0;
    end else begin pixel_release<=1;release_final<=1;release_session<=offer_session;broken<=1;if(late_rows!=64'hffffffffffffffff)late_rows<=late_rows+1'b1;end
   end
   if(context_block||context_tail_fault)begin
    have_offer<=0;dvalid<=0;dsof<=0;dadmit<=0;frame_admitted<=0;row_match<=0;broken<=1;
   end else if(ce)begin
    dvalid<=tap_valid;dqualified<=tap_qualified;dsupport<=tap_support;dclass<=tap_class;dx<=tap_x;dy<=tap_y;dsession<=read_session;
    dsof<=first_tap;dadmit<=eligible&&prefilled&&have_offer&&!broken;
    if(first_tap)begin
     frame_admitted<=eligible&&prefilled&&have_offer&&!broken;
     if(!eligible||!prefilled||!have_offer)broken<=1;
    end
    if(dvalid&&row_attempt)begin
     if(dx==0)row_match<=ref_tag_good&&dclass==ref_class&&dclass!=3;
     else row_match<=row_match&&ref_tag_good&&dclass==ref_class&&dclass!=3;
     if(!ref_ready)begin
      if(underflows!=64'hffffffffffffffff)underflows<=underflows+1'b1;
     end
    end
    if(tap_seen&&(!eligible||(dvalid&&!ref_tag_good)))broken<=1;
    if(final_de&&final_x==1279&&final_y==719)broken<=1;
   end
   if(have_offer&&!released&&(broken||(ce&&final_de&&final_x==1279&&final_y==719)))begin
    pixel_release<=1;release_final<=0;release_session<=session;released<=1;have_offer<=0;
   end
   // Early fallback requests cancellation; only the final-frame message
   // permits metadata replacement after the same-edge snapshot crosses.
   if(frame_done&&session==display_seq&&session!=0)begin
    pixel_release<=1;release_final<=1;release_session<=session;
   end
  end
 end
endmodule
