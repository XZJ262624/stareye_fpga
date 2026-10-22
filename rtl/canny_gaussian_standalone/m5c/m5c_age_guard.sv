// Pixel-domain only. Configuration tuple is opaque but compared bit-exactly.
// cfg[159:96]=generation; remaining bits include schema/algorithm/geometry/H/L/filter/support.
module m5c_age_guard #(parameter [63:0] MAX_FRAMES=120, MAX_TICKS=148500000)(
 input clk,rst_n,ce,display_sof,stop,enable,descriptor_valid,age_valid,
 input [63:0] current_epoch,descriptor_epoch,capture_seq,capture_tick,
 input [159:0] current_config,descriptor_config,
 output reg [63:0] pixel_ticks,display_seq,
 output reg time_fault,output eligible,output [31:0] age_frames,age_ticks);
 reg sof_seen;
 wire order_ok=capture_seq<=display_seq && capture_tick<=pixel_ticks;
 wire [63:0] frame_delta=display_seq-capture_seq;
 wire [63:0] tick_delta=pixel_ticks-capture_tick;
 assign age_frames=!order_ok||(|frame_delta[63:32])?32'hffffffff:frame_delta[31:0];
 assign age_ticks=!order_ok||(|tick_delta[63:32])?32'hffffffff:tick_delta[31:0];
 assign eligible=enable && descriptor_valid && age_valid && !stop && !time_fault && order_ok &&
  current_epoch==descriptor_epoch && current_config==descriptor_config &&
  frame_delta <= MAX_FRAMES && tick_delta <= MAX_TICKS;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin pixel_ticks<=0;display_seq<=0;time_fault<=0;sof_seen<=0;end
  else begin
   // Wall clock runs even when the accepted-CE raster is paused.
   if(pixel_ticks==64'hffffffffffffffff)time_fault<=1;
   else pixel_ticks<=pixel_ticks+1'b1;
   if(ce)sof_seen<=display_sof;
   if(ce&&display_sof&&!sof_seen)begin
    if(display_seq==64'hffffffffffffffff)time_fault<=1;
    else display_seq<=display_seq+1'b1;
   end
  end
 end
endmodule
