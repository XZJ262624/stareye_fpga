// UI-clock debounced physical keys. A long press emits once; release cannot
// subsequently emit short. Overlapping keys are suppressed until both release.
module shape_replay_controls #(parameter DEBOUNCE=1920000,LONG_PRESS=57600000)(
 input clk,rst_n,input [1:0] key_n,
 output reg command_valid,output reg [1:0] command,output reg [1:0] view_index);
 (* async_reg="true" *) reg [1:0] key_meta,key_sync;
 reg [1:0] stable,long_sent;reg [25:0] debounce[0:1],held[0:1];
 reg chord,armed;reg [25:0] release_count;integer i;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin key_meta<=3;key_sync<=3;stable<=3;long_sent<=0;chord<=0;armed<=0;release_count<=0;view_index<=2;command<=0;command_valid<=0;
   for(i=0;i<2;i=i+1)begin debounce[i]<=0;held[i]<=0;end
  end else begin
   key_meta<=key_n;key_sync<=key_meta;command_valid<=0;
   if(!armed)begin
    if(key_sync!=3)release_count<=0;
    else if(release_count==DEBOUNCE+3)armed<=1;
    else release_count<=release_count+1'b1;
   end
   if(key_sync==0)chord<=1;
   if(key_sync==3&&stable==3)chord<=0;
   for(i=0;i<2;i=i+1)begin
    if(key_sync[i]==stable[i])debounce[i]<=0;
    else if(debounce[i]==DEBOUNCE-1)begin
     debounce[i]<=0;stable[i]<=key_sync[i];
     if(key_sync[i])begin
      if(armed&&!long_sent[i]&&!chord&&key_sync[1-i])begin
       if(i==0)begin command_valid<=1;command<=0;end else view_index<=view_index==2?0:view_index+1'b1;
      end
      held[i]<=0;long_sent[i]<=0;
     end
    end else debounce[i]<=debounce[i]+1'b1;
    if(!stable[i]&&!long_sent[i])begin
     if(held[i]==LONG_PRESS-1)begin
      long_sent[i]<=1;
      if(armed&&!chord&&key_sync[1-i])begin command_valid<=1;command<=i==0?1:2;end
     end else held[i]<=held[i]+1'b1;
    end
   end
  end
 end
endmodule
