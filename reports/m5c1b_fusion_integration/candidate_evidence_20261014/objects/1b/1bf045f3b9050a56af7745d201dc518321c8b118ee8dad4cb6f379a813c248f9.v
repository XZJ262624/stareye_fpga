`timescale 1ns/1ps
// All control state is in the pixel domain. Events occur on qualified release.
module m4_controls #(parameter DEBOUNCE_CYCLES=1488000)(
 input clk, input arst_n, input [1:0] key_n, input frame_start,
 output reg [7:0] threshold, output reg [1:0] mode,
 output reg [7:0] pending_threshold, output reg [1:0] pending_mode
);
 (* async_reg="true" *) reg [1:0] reset_release;
 always @(posedge clk or negedge arst_n)
  if(!arst_n) reset_release<=0; else reset_release<={reset_release[0],1'b1};
 wire rst_n=reset_release[1];
 (* async_reg="true" *) reg [1:0] key_meta, key_sync;
 localparam CW=(DEBOUNCE_CYCLES<2)?1:$clog2(DEBOUNCE_CYCLES);
 reg [CW-1:0] count0,count1,arm_count;
 reg [1:0] stable_n, seen;
 reg armed;
 reg [2:0] warmup;
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
   key_meta<=3;key_sync<=3;stable_n<=3;count0<=0;count1<=0;
   arm_count<=0;armed<=0;seen<=0;warmup<=0;
   threshold<=64;mode<=2;pending_threshold<=64;pending_mode<=2;
  end else begin
   key_meta<=key_n;key_sync<=key_meta;warmup<={warmup[1:0],1'b1};
   if(key_sync[0]==stable_n[0]) count0<=0;
   else if(count0==DEBOUNCE_CYCLES-1) begin stable_n[0]<=key_sync[0];count0<=0;end
   else count0<=count0+1'b1;
   if(key_sync[1]==stable_n[1]) count1<=0;
   else if(count1==DEBOUNCE_CYCLES-1) begin stable_n[1]<=key_sync[1];count1<=0;end
   else count1<=count1+1'b1;
   // Require a complete released qualification after synchronization/startup.
   if(!armed) begin
    seen<=0;
    if(warmup!=7 || key_sync!=3 || stable_n!=3) arm_count<=0;
    else if(arm_count==DEBOUNCE_CYCLES-1) begin armed<=1;arm_count<=0;end
    else arm_count<=arm_count+1'b1;
   end else if(stable_n!=3) seen<=seen|~stable_n;
   else if(seen!=0) begin
    case(seen)
     1: pending_threshold <= (pending_threshold>239)?8'd255:pending_threshold+8'd16;
     2: pending_threshold <= (pending_threshold<16)?8'd0:pending_threshold-8'd16;
     3: pending_mode <= (pending_mode==3)?2'd0:pending_mode+2'd1;
    endcase
    seen<=0;
   end
   // Nonblocking assignments deliberately defer a coincident event one frame.
   if(frame_start) begin threshold<=pending_threshold;mode<=pending_mode;end
  end
 end
endmodule
