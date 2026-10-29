`timescale 1ns/1ps
// K1=N2=key_n[0] decrement; K2=M2=key_n[1] increment.
// A single long hold emits exactly one single event on release, no autorepeat.
// Any overlapping debounced gesture suppresses single events. SOF is unused.
// event_valid/event_code are held through CE stalls and consumed once on CE.
module part_keys_controls #(parameter DEBOUNCE_CYCLES=1488000,LONG_CYCLES=148500000)(
 input wire clk,arst_n,ce,sof,input wire [1:0] key_n,
 output reg event_valid,output reg [2:0] event_code,output reg event_fault
);
 localparam KEY0=1,KEY1=2,BOTH_SHORT=3,BOTH_LONG=4;
 localparam CW=DEBOUNCE_CYCLES<2?1:$clog2(DEBOUNCE_CYCLES+1);
 localparam LW=LONG_CYCLES<2?1:$clog2(LONG_CYCLES+1);
 (* async_reg="true" *) reg [1:0] release_sync,key_meta,key_sync;
 wire rst_n=release_sync[1];
 reg [1:0] stable,seen;reg [CW-1:0] c0,c1,released;
 reg [LW-1:0] held;reg armed,long_seen;
 always @(posedge clk or negedge arst_n)
  if(!arst_n)release_sync<=0;else release_sync<={release_sync[0],1'b1};
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   key_meta<=3;key_sync<=3;stable<=3;seen<=0;c0<=0;c1<=0;released<=0;
   held<=0;armed<=0;long_seen<=0;event_valid<=0;event_code<=0;event_fault<=0;
  end else begin
   key_meta<=key_n;key_sync<=key_meta;
   if(ce)begin
    event_valid<=0;
    if(key_sync[0]==stable[0])c0<=0;
    else if(c0>=DEBOUNCE_CYCLES-1)begin stable[0]<=key_sync[0];c0<=0;end else c0<=c0+1'b1;
    if(key_sync[1]==stable[1])c1<=0;
    else if(c1>=DEBOUNCE_CYCLES-1)begin stable[1]<=key_sync[1];c1<=0;end else c1<=c1+1'b1;
    if(!armed)begin
     seen<=0;held<=0;long_seen<=0;
     if(stable!=3||key_sync!=3)released<=0;
     else if(released>=DEBOUNCE_CYCLES-1)armed<=1;else released<=released+1'b1;
    end else begin
     if(stable!=3)seen<=seen|~stable;
     else if(seen!=0)begin
      event_valid<=1;event_code<=long_seen?BOTH_LONG:seen==1?KEY0:seen==2?KEY1:BOTH_SHORT;
      seen<=0;long_seen<=0;
     end
     if(stable==0)begin
      if(held<LONG_CYCLES)held<=held+1'b1;
      if(held>=LONG_CYCLES-1)long_seen<=1;
     end else held<=0;
    end
   end
  end
 end
endmodule
