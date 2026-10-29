`timescale 1ns/1ps
module part_open_capture #(parameter [63:0] ARM_TICKS=372000000)(
 input wire clk,rst_n,ce,input wire [63:0] ticks,epoch,config_id,
 input wire fault,rearm,event_valid,event_failure,input wire [767:0] live_record,
 output reg held,output wire have,armed,
 (* syn_preserve=1,syn_keep=1 *) output reg [767:0] record
);
 reg have_reg;
 reg initialized;reg [63:0] start_tick,last_tick,held_epoch,held_config;
 wire clear_now=!initialized||fault||rearm||epoch!=held_epoch||config_id!=held_config||ticks<last_tick||ticks<start_tick;
 assign have=have_reg&&!clear_now;
 assign armed=initialized&&!held&&!clear_now&&ticks-start_tick>=ARM_TICKS;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin initialized<=0;start_tick<=0;last_tick<=0;held_epoch<=0;held_config<=0;held<=0;have_reg<=0;record<=0;end
  else if(ce)begin
   last_tick<=ticks;
   if(clear_now)begin initialized<=1;start_tick<=ticks;held_epoch<=epoch;held_config<=config_id;held<=0;have_reg<=0;record<=0;end
   else if(!held&&event_valid&&(!event_failure||armed))begin have_reg<=1;held<=event_failure;record<=live_record;end
  end
 end
endmodule
