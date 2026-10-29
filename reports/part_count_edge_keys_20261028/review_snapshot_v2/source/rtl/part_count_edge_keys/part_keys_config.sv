`timescale 1ns/1ps
// Same-pixel-clock requests, committed only at source SOF. Effective bypass
// presents the new value on that very edge to all source consumers.
module part_keys_config(
 input clk,rst_n,ce,source_sof,event_valid,input [2:0] event_code,
 output [7:0] high_threshold,output [63:0] generation,output view,
 output changed,output reg config_fault
);
 reg [7:0] pending_high,active_high;
 reg pending_view,active_view;
 reg [63:0] active_generation;
 wire apply=source_sof&&ce;
 wire change=apply&&pending_high!=active_high;
 assign changed=change;
 assign high_threshold=apply?pending_high:active_high;
 assign view=apply?pending_view:active_view;
 assign generation=change&&active_generation!=64'hffffffffffffffff ?
                    active_generation+64'd1:active_generation;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin pending_high<=48;active_high<=48;pending_view<=0;active_view<=0;active_generation<=1;config_fault<=0;end
  else if(ce)begin
   if(source_sof)begin
    active_high<=pending_high;active_view<=pending_view;
    if(change)begin
     if(active_generation==64'hffffffffffffffff)config_fault<=1;
     else active_generation<=active_generation+64'd1;
    end
   end
   // A release arriving exactly on SOF is queued for the next source frame.
   if(event_valid)case(event_code)
    1:if(pending_high>8)pending_high<=pending_high-8'd8;
    2:if(pending_high<128)pending_high<=pending_high+8'd8;
    3:pending_view<=!pending_view;
    default:begin end
   endcase
  end
 end
endmodule
