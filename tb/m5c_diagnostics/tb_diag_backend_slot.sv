`timescale 1ns/1ps
module tb_diag_backend_slot;
 parameter CASE=0;
 localparam PERIOD=CASE==1?1000000:CASE==3?3000000:1500000;
 reg clk=0,pix=0,rst=0,run=0;always #5 clk=~clk;always #6.7205 pix=~pix;
 reg telemetry_ready=0,diag_ready=1,frame_done=0,stop=0;
 wire take0,take1,diag_done,diag_cancel,uart0,uart1;wire [8:0] ti0,ti1,di;
 wire a0,a1,w0,w1,job0,job1;wire [31:0] addr0,addr1;wire [3:0] leased0,leased1;
 wire window_open;wire [7:0] diag_byte=di<4?(di==0?8'h53:di==1?8'h4d:di==2?8'h35:8'h42):di==4?8'd1:di==5?8'd5:di==6?8'd64:di==9?8'd1:di>=64?di[7:0]:8'd0;
 integer cycle=0,start_cycle=0,end_cycle=0,starts=0,done_count=0,old_done=0,cancels=0;
 wire [7:0] tb0=ti0[7:0],tb1=ti1[7:0];
 m5c_diag_slot_guard guard(.pix_clk(pix),.ui_clk(clk),.pix_rst_n(rst),.ui_rst_n(rst),.frame_done(frame_done),.window_open(window_open));
 m5b1_backend #(.REQUEST_CYCLES(PERIOD),.DIAGNOSTICS(0)) control(.ui_clk(clk),.pix_clk(pix),.rst_n(rst),.run(run),.stop(stop),.epoch(64'd1),
 .tap_valid(1'b0),.tap_class(2'd0),.tap_x(12'd0),.tap_y(12'd0),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),.tap_frame_id(64'd1),.tap_epoch(64'd1),.tap_timestamp(64'd0),.tap_display_seq(64'd1),.tap_config_generation(64'd1),
 .fusion_acquire(1'b0),.fusion_slot(1'b0),.fusion_identity(320'd0),.fusion_token(64'd0),.fusion_release(1'b0),.fusion_retire(1'b0),.fusion_read_accept(1'b0),.fusion_read_done(1'b0),.pair_leased(leased0),
 .diag_ready(diag_ready),.diag_window(window_open&&(CASE!=2)),.diag_byte(diag_byte),.diag_byte_valid(1'b1),.diag_index(),.diag_done(),.diag_cancel(),
 .telemetry_ready(telemetry_ready),.telemetry_descriptor(320'd0),.telemetry_byte(tb0),.telemetry_index(ti0),.telemetry_take(take0),
 .max_wait(96'd0),.max_service(96'd0),.camera_max(14'd0),.display_min(14'd0),.system_status(32'd3),.error_counts(224'd0),.video_fifo_faults(4'd0),.uart_tx(uart0),.job_busy(job0),
 .avalid(a0),.aready(1'b0),.aaddr(addr0),.wvalid(w0),.wready(1'b0),.bvalid(1'b0),.bid(8'd0),.bresp(2'd0),.rvalid(1'b0),.rlast(1'b0),.rdata(128'd0),.rid(8'd0),.rresp(2'd0),.rejected(1'b0));
 m5b1_backend #(.REQUEST_CYCLES(PERIOD),.DIAGNOSTICS(1)) variant(.ui_clk(clk),.pix_clk(pix),.rst_n(rst),.run(run),.stop(stop),.epoch(64'd1),
 .tap_valid(1'b0),.tap_class(2'd0),.tap_x(12'd0),.tap_y(12'd0),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),.tap_frame_id(64'd1),.tap_epoch(64'd1),.tap_timestamp(64'd0),.tap_display_seq(64'd1),.tap_config_generation(64'd1),
 .fusion_acquire(1'b0),.fusion_slot(1'b0),.fusion_identity(320'd0),.fusion_token(64'd0),.fusion_release(1'b0),.fusion_retire(1'b0),.fusion_read_accept(1'b0),.fusion_read_done(1'b0),.pair_leased(leased1),
 .diag_ready(diag_ready),.diag_window(window_open&&(CASE!=2)),.diag_byte(diag_byte),.diag_byte_valid(1'b1),.diag_index(di),.diag_done(diag_done),.diag_cancel(diag_cancel),
 .telemetry_ready(telemetry_ready),.telemetry_descriptor(320'd0),.telemetry_byte(tb1),.telemetry_index(ti1),.telemetry_take(take1),
 .max_wait(96'd0),.max_service(96'd0),.camera_max(14'd0),.display_min(14'd0),.system_status(32'd3),.error_counts(224'd0),.video_fifo_faults(4'd0),.uart_tx(uart1),.job_busy(job1),
 .avalid(a1),.aready(1'b0),.aaddr(addr1),.wvalid(w1),.wready(1'b0),.bvalid(1'b0),.bid(8'd0),.bresp(2'd0),.rvalid(1'b0),.rlast(1'b0),.rdata(128'd0),.rid(8'd0),.rresp(2'd0),.rejected(1'b0));
 always @(posedge clk)if(rst)begin
  cycle=cycle+1;
  if(take0!==take1||a0!==a1||w0!==w1||job0!==job1||leased0!==leased1||control.state!==variant.state||control.requests!==variant.requests||control.accepted!==variant.accepted||control.busy_rejected!==variant.busy_rejected)$fatal(1,"DIAG_ORIGINAL_BACKEND_CHANGED cycle=%0d",cycle);
  if(take0)begin telemetry_ready<=0;old_done=old_done+1;end
  if(variant.diag_grant)begin starts=starts+1;start_cycle=cycle;if(!window_open||variant.state!=0||variant.tick>=PERIOD-700000)$fatal(1,"DIAG_UNSAFE_GRANT");end
  if(variant.diag_busy&&(variant.want_reserve||variant.uart_owned||variant.writer_owned))$fatal(1,"DIAG_OWNERSHIP_COLLISION");
  if(diag_done)begin done_count=done_count+1;end_cycle=cycle;diag_ready<=0;if(end_cycle-start_cycle>=700000)$fatal(1,"DIAG_WIRE_EXCEEDS_SLOT");end
  if(diag_cancel)begin cancels=cancels+1;if(CASE!=4)$fatal(1,"DIAG_UNEXPECTED_CANCEL");end
  if(CASE==4&&variant.state==17&&control.state==17)begin if(cancels!=1||starts!=1||done_count!=0)$fatal(1,"DIAG_CANCEL_COVERAGE");$display("DIAG_BACKEND_SLOT_PASS case=4 cold_cancel=1 original_fault_report_done=1");$finish;end
  if(variant.accepted==1)begin
   if(control.accepted!=1||old_done!=(CASE==3?2:1)||((CASE==0||CASE==3)&&(starts!=1||done_count!=1))||((CASE==1||CASE==2)&&(starts!=0||done_count!=0)))$fatal(1,"DIAG_SLOT_COVERAGE");
   $display("DIAG_BACKEND_SLOT_PASS case=%0d cycles=%0d duration=%0d oldtake=%0d requests=%0d accepted=%0d starts=%0d done=%0d",CASE,cycle,end_cycle-start_cycle,old_done,variant.requests,variant.accepted,starts,done_count);$finish;
  end
 end
 initial begin repeat(10)@(negedge clk);rst=1;repeat(30)@(negedge clk);run=1;@(negedge pix);frame_done=1;@(negedge pix);frame_done=0;
  if(CASE==3)repeat(500000)@(negedge clk);telemetry_ready=1;
  if(CASE==3)begin wait(cycle>=1596800);@(negedge pix);frame_done=1;@(negedge pix);frame_done=0;@(negedge clk);telemetry_ready=1;end
  if(CASE==4)begin wait(variant.diag_busy);repeat(100)@(negedge clk);stop=1;end
 end
 initial begin #40000000;$fatal(1,"DIAG_SLOT_WATCHDOG");end
endmodule
