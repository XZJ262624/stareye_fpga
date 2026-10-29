`timescale 1ns/1ps
module part_keys_core #(
 parameter RX=160,RY=90,RW=960,RH=540,
 parameter [63:0] DIAG_ARM_TICKS=372000000,INTERVAL_TICKS=7440000,STALE_TICKS=37200000
)(
 input clk,rst_n,ce,source_sof,input [63:0] ticks,live_epoch,
 input event_valid,event_fault,input [2:0] event_code,
 input sof,eof,active,qualified,input [11:0] x,y,input edge_pixel,edge_support,
 input [63:0] frame_id,epoch,config_id,display_seq,
 input [63:0] generation,output count_valid,have_value,busy,
 output [3:0] count,error_code,output [1:0] confirmations,output [63:0] count_frame,count_seq,count_tick,
 output stale,output diag_held,diag_have,diag_armed,output [767:0] diag_record,
 output job_done,job_good,output [20:0] service_cycles
);
 reg [63:0] cfg,ep,observed_frame,observed_tick,last_job_frame;reg observed_valid,job_seen;reg fatal;
 wire context_change=ep!=live_epoch||cfg!=generation;wire context_ok=epoch==live_epoch&&config_id==generation;
 wire age_bad=observed_valid&&(ticks<observed_tick||ticks-observed_tick>=STALE_TICKS);
 wire complete_good,frame_bad;
 part_open_frame_guard #(.RX(RX),.RY(RY),.RW(RW),.RH(RH)) frame_guard(.clk(clk),.rst_n(rst_n),.ce(ce),.invalidate(context_change||event_fault||fatal),.sof(sof),.eof(eof),.active(active),.qualified(qualified&&context_ok),.edge_support(edge_support),.x(x),.y(y),.frame_id(frame_id),.epoch(epoch),.config_id(config_id),.display_seq(display_seq),.complete_good(complete_good),.frame_bad(frame_bad));
 wire source_bad=frame_bad||(ce&&eof&&observed_valid&&frame_id<observed_frame);
 assign stale=!observed_valid||age_bad||fatal;
 wire revoke=event_fault||fatal||context_change||!qualified||!context_ok||age_bad||source_bad;
 wire [3:0] job_count,job_error;wire [409:0] job_objects;
 wire [63:0] job_frame,job_epoch,job_config,job_seq,job_tick;
 wire job_begin,matching,confirmed_valid,ccl_busy,accept_now;
 wire candidate_new=(!observed_valid||frame_id>observed_frame)&&(!job_seen||frame_id>last_job_frame);
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin cfg<=0;ep<=0;observed_frame<=0;observed_tick<=0;observed_valid<=0;last_job_frame<=0;job_seen<=0;fatal<=0;end
  else if(ce)begin
   if(generation==64'hffffffffffffffff||ticks==64'hffffffffffffffff||live_epoch==64'hffffffffffffffff||frame_id==64'hffffffffffffffff)fatal<=1;
   if(context_change)begin cfg<=generation;ep<=live_epoch;observed_valid<=0;job_seen<=0;end
   else begin
    if(complete_good&&context_ok&&!event_fault&&(!observed_valid||frame_id>observed_frame))begin observed_valid<=1;observed_frame<=frame_id;observed_tick<=ticks;end
    if(job_begin)begin job_seen<=1;last_job_frame<=job_frame;end
   end
  end
 end
 wire diag_event;wire [255:0] diag_data;wire [63:0] diag_tick;wire [12:0] runs;
 part_open_ccl #(.RX(RX),.RY(RY),.RW(RW),.RH(RH),.INTERVAL_TICKS(INTERVAL_TICKS),.STALE_TICKS(STALE_TICKS)) ccl(
  .clk(clk),.rst_n(rst_n),.ce(ce),.invalidate(revoke),.ticks(ticks),.sof(sof),.eof(eof),.active(active),.qualified(qualified),.arm(!matching&&candidate_new),.x(x),.y(y),.edge_pixel(edge_pixel),.edge_support(edge_support),
  .frame_id(frame_id),.epoch(epoch),.config_id(config_id),.display_seq(display_seq),.busy(ccl_busy),.accept_now(accept_now),.accepted(job_begin),.done(job_done),.good(job_good),.error_code(job_error),.count(job_count),.objects(job_objects),
  .result_frame(job_frame),.result_epoch(job_epoch),.result_config(job_config),.result_seq(job_seq),.result_tick(job_tick),.service_cycles(service_cycles),.captured_runs(runs),.diag_event(diag_event),.diag_data(diag_data),.diag_tick(diag_tick));
 part_keys_confirm #(.STALE_TICKS(STALE_TICKS)) confirmation(
  .clk(clk),.rst_n(rst_n),.ce(ce),.invalidate(revoke),.job_begin(job_begin),.job_done(job_done),.job_good(job_good),.ticks(ticks),.epoch(live_epoch),.config_id(generation),
  .job_frame(job_frame),.job_epoch(job_epoch),.job_config(job_config),.job_seq(job_seq),.job_tick(job_tick),.job_count(job_count),.job_objects(job_objects),.valid(confirmed_valid),.have_value(have_value),.count(count),.confirmations(confirmations),.result_frame(count_frame),.result_seq(count_seq),.result_tick(count_tick),.matching(matching));
 assign busy=ccl_busy||accept_now||matching;
 assign count_valid=confirmed_valid&&!busy&&!revoke&&!stale;
 assign error_code=event_fault||fatal?4'd15:source_bad||!context_ok?4'd8:stale?4'd11:job_error;
 wire [767:0] live_record={32'h1,32'h454b5901,ticks,diag_tick,job_seq,job_config,job_epoch,job_frame,diag_data,28'd0,job_error,28'd0,job_error};
 part_open_capture #(.ARM_TICKS(DIAG_ARM_TICKS)) diagnosis(.clk(clk),.rst_n(rst_n),.ce(ce),.ticks(ticks),.epoch(live_epoch),.config_id(generation),.fault(event_fault||fatal),.rearm(event_valid&&event_code==4),.event_valid(diag_event),.event_failure(1'b1),.live_record(live_record),.held(diag_held),.have(diag_have),.armed(diag_armed),.record(diag_record));
endmodule
