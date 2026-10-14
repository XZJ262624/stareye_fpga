`timescale 1ns/1ps
module tb_m5c1b_reset_faults;
 reg bind_valid=0,bind_slot=0;reg [319:0] bind_identity=0;wire bind_ack;
 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,stop=0,export_exclusive=1;
 reg reserve_valid=0,publish_valid=0,publish_slot=0,metadata_b_done=0,cancel_valid=0,cancel_slot=0,write_drained=0;
 reg acquire_valid=0,acquire_slot=0,acquire_uart=0,release_valid=0,release_slot=0,release_uart=0;
 reg read_accept=0,read_slot=0,read_uart=0,read_done=0,retire_valid=0,retire_slot=0,retire_uart=0;
 reg done_slot=0,done_uart=0;
 reg [319:0] reserve_identity=0,acquire_identity=0,read_identity=0;
 reg [319:0] publish_identity=0,cancel_identity=0,release_identity=0,retire_identity=0,done_identity=0;
 reg [63:0] acquire_token=1,release_token=1,retire_token=1,read_token=1,done_token=1;
 wire reserve_ack,reserve_denied,reserve_slot,acquire_ack,acquire_denied,latest_valid,latest_slot,protocol_fault;
 wire [1:0] reserved,committed;wire [3:0] leased;
 wire event_rejected;
 m5c_pair_lease dut(.*);
 localparam [319:0] A={64'd1,64'd1,64'd0,64'd0,64'd1},B={64'd1,64'd2,64'd11,64'd5,64'd2},C={64'd1,64'd3,64'd12,64'd5,64'd3};
 integer checks=0,identity_bit;
 task tick;begin @(posedge clk);#1;checks=checks+1;end endtask
 task clear;begin @(negedge clk);reserve_valid=0;bind_valid=0;publish_valid=0;metadata_b_done=0;cancel_valid=0;write_drained=0;acquire_valid=0;release_valid=0;read_accept=0;read_done=0;retire_valid=0;end endtask
 initial begin
  tick;clear;rst_n=1;reserve_valid=1;reserve_identity=A;tick;
  if(!reserve_ack||reserve_slot!=0||reserved!=1)$fatal(1,"RESERVE_BEFORE_CAPTURE");
  clear;publish_valid=1;publish_identity=A;metadata_b_done=1;tick;
  if(latest_valid||!event_rejected)$fatal(1,"UNBOUND_PUBLISH");
  clear;bind_valid=1;bind_identity=B;tick;if(bind_ack||!event_rejected)$fatal(1,"BIND_WRONG_JOB_GENERATION");
  clear;bind_valid=1;bind_identity=A;tick;if(!bind_ack)$fatal(1,"BIND_ZERO_SOURCE_CONFIG");
  clear;bind_valid=1;bind_identity=A;tick;if(bind_ack||!event_rejected)$fatal(1,"BIND_TWICE");
  clear;publish_valid=1;publish_identity=A;tick;if(latest_valid||committed!=0)$fatal(1,"METADATA_B_FENCE");
  clear;publish_valid=1;metadata_b_done=1;acquire_valid=1;acquire_identity=A;tick;
  if(!latest_valid||latest_slot!=0||!acquire_ack||leased!=1)$fatal(1,"PUBLISH_ACQUIRE_SAME_EDGE");
  clear;acquire_valid=1;acquire_uart=1;acquire_identity=A;tick;if(!acquire_denied||leased!=1)$fatal(1,"EXPORT_EXCLUSION");
  clear;export_exclusive=0;acquire_valid=1;acquire_uart=1;tick;if(!acquire_ack||leased!=3)$fatal(1,"INDEPENDENT_CONSUMERS");
  clear;read_accept=1;read_identity=A;tick;
  clear;read_accept=1;read_done=1;done_identity=A;tick;
  if(protocol_fault||dut.reads[0][0]!=1)$fatal(1,"EXISTING_READ_DONE_PLUS_ACCEPT");
  clear;read_accept=1;read_uart=1;read_identity=A;read_done=1;done_uart=0;done_identity=A;tick;
  if(dut.reads[0][0]!=0||dut.reads[0][1]!=1)$fatal(1,"INDEPENDENT_READ_RESPONSE_TAGS");
  clear;read_accept=1;read_uart=0;read_done=1;done_uart=1;tick;
  if(dut.reads[0][0]!=1||dut.reads[0][1]!=0)$fatal(1,"INDEPENDENT_READ_RESPONSE_REVERSE");
  clear;release_valid=1;release_identity=A;retire_identity=A;retire_valid=1;tick;if(leased!=3)$fatal(1,"FINAL_R_FENCE");
  clear;release_valid=1;release_uart=1;retire_valid=1;retire_uart=1;tick;
  if(leased!=1)$fatal(1,"OTHER_CONSUMER_RELEASE");
  clear;reserve_valid=1;reserve_identity=B;tick;if(!reserve_ack||!reserve_slot)$fatal(1,"SECOND_PAIR_PROGRESS");
  clear;bind_valid=1;bind_slot=1;bind_identity=B;tick;if(!bind_ack)$fatal(1,"BIND_SECOND_SLOT");
  clear;publish_valid=1;publish_slot=1;publish_identity=B;metadata_b_done=1;tick;if(!latest_slot)$fatal(1,"LATEST_TRANSFER");
  clear;reserve_valid=1;reserve_identity=C;tick;if(!reserve_denied)$fatal(1,"THIRD_JOB_MUST_WAIT");
  clear;read_done=1;done_uart=0;done_identity=A;tick;if(leased!=0)$fatal(1,"DRAIN_RELEASE");
  clear;reserve_valid=1;reserve_identity=C;tick;if(!reserve_ack||reserve_slot)$fatal(1,"RECOVER_AFTER_DRAIN");
  clear;cancel_valid=1;cancel_slot=0;cancel_identity=C;publish_valid=1;publish_slot=0;publish_identity=C;metadata_b_done=1;tick;
  if(!reserved[0]||!latest_slot||committed[0])$fatal(1,"CANCEL_WINS_AND_WAITS_REAL_WRITE");
  clear;write_drained=1;cancel_slot=0;tick;if(reserved[0])$fatal(1,"CANCEL_DRAIN");
  clear;acquire_valid=1;acquire_slot=1;acquire_uart=0;acquire_identity=A;tick;if(!acquire_denied)$fatal(1,"CROSS_GENERATION_ACQUIRE");
  clear;acquire_valid=1;acquire_identity=B;tick;if(!acquire_ack)$fatal(1,"NEW_PAIR_ACQUIRE");
  // Complete one lease, then reacquire the SAME immutable pair under token 2.
  clear;release_valid=1;release_slot=1;release_uart=0;release_identity=B;
  retire_valid=1;retire_slot=1;retire_uart=0;retire_identity=B;tick;if(leased!=0)$fatal(1,"FIRST_LEASE_RETIRE");
  clear;acquire_valid=1;acquire_token=2;tick;if(!acquire_ack||leased!=4)$fatal(1,"SAME_PAIR_REACQUIRE");
  clear;release_valid=1;retire_valid=1;release_identity=B;retire_identity=B;release_token=1;retire_token=1;tick;
  if(!event_rejected||leased!=4||dut.pending[1][0]||!dut.cache[1][0])$fatal(1,"STALE_SAME_PAIR_LEASE_TOKEN");
  release_token=2;retire_token=2;
  clear;release_valid=1;release_slot=1;release_uart=0;release_identity=B;acquire_valid=1;acquire_identity=B;tick;
  if(!acquire_denied||leased!=4)$fatal(1,"RELEASE_ACQUIRE_PRIORITY");
  // Stale events cannot retire/cache-release a current lease or invalidate latest.
  clear;retire_valid=1;retire_slot=1;retire_uart=0;retire_identity=A;cancel_valid=1;cancel_slot=1;cancel_identity=A;
  release_valid=1;release_slot=1;release_identity=A;tick;
  if(!event_rejected||leased!=4||!committed[1]||!latest_slot)$fatal(1,"STALE_RELEASE_RETIRE_CANCEL");
  clear;cancel_valid=1;cancel_slot=1;cancel_identity=B;write_drained=1;tick;
  if(!event_rejected||!committed[1]||!latest_slot)$fatal(1,"CANCEL_NONWRITING_LATEST");
  clear;stop=1;retire_valid=1;retire_slot=1;retire_uart=0;tick;if(leased!=4)$fatal(1,"STOP_PRESERVES_OWNER");
  clear;stop=0;tick;if(leased!=4)$fatal(1,"NO_FAKE_RETIRE");
  clear;retire_valid=1;retire_slot=1;retire_uart=0;retire_identity=B;tick;if(leased!=4)$fatal(1,"STOP_IS_STICKY_UNTIL_COLD_RESET");
  clear;rst_n=0;tick;clear;rst_n=1;acquire_token=1;reserve_valid=1;reserve_identity=A;tick;
  clear;bind_valid=1;bind_slot=0;bind_identity=A;tick;if(!bind_ack)$fatal(1,"BIND_RESET_SLOT");
  clear;publish_valid=1;publish_slot=0;publish_identity=A;metadata_b_done=1;acquire_valid=1;acquire_slot=0;acquire_identity=A;tick;
  clear;read_accept=1;read_slot=0;read_identity=A;read_done=1;done_slot=0;done_uart=0;done_identity=A;tick;
  if(!protocol_fault)$fatal(1,"UNSOLICITED_DONE_FIRST_ACCEPT");
  clear;rst_n=0;tick;clear;rst_n=1;reserve_valid=1;reserve_identity=A;tick;
  clear;bind_valid=1;bind_slot=0;bind_identity=A;tick;if(!bind_ack)$fatal(1,"BIND_RESET_SLOT");
  clear;publish_valid=1;publish_slot=0;publish_identity=A;metadata_b_done=1;acquire_valid=1;acquire_slot=0;acquire_identity=A;tick;
  clear;read_accept=1;read_slot=0;read_identity=B;tick;if(!protocol_fault)$fatal(1,"STALE_READ_IDENTITY");
  // Bind can update next identity, but WRITING still excludes acquisition.
  clear;rst_n=0;tick;clear;rst_n=1;reserve_valid=1;reserve_identity=A;tick;
  clear;bind_valid=1;bind_identity=A;bind_identity[191:128]=64'h8000000000000001;
  bind_identity[127:64]=64'h8000000000000002;acquire_valid=1;acquire_identity=bind_identity;tick;
  if(!bind_ack||!acquire_denied||leased!=0||dut.identity[0]!=bind_identity)$fatal(1,"BIND_ACQUIRE_WRITING_PRIORITY");
  clear;publish_valid=1;metadata_b_done=1;publish_identity=bind_identity;acquire_valid=1;acquire_identity=bind_identity;tick;
  if(!acquire_ack||leased!=1)$fatal(1,"BOUND_FULL_TUPLE_PUBLISH_ACQUIRE");
  clear;acquire_valid=1;acquire_slot=1'bx;acquire_uart=1;acquire_token=2;tick;
  if(!acquire_denied||leased!=1)$fatal(1,"UNKNOWN_SLOT_NOT_ADMITTED");
  clear;read_accept=1;read_slot=1'bx;read_uart=0;read_identity=bind_identity;tick;
  if(!protocol_fault)$fatal(1,"UNKNOWN_SLOT_READ_NOT_ADMITTED");
  for(identity_bit=0;identity_bit<384;identity_bit=identity_bit+1)begin
   clear;rst_n=0;tick;clear;rst_n=1;reserve_valid=1;reserve_identity=A;tick;
   clear;bind_valid=1;bind_slot=0;bind_identity=A;tick;
   clear;publish_valid=1;publish_slot=0;publish_identity=A;metadata_b_done=1;
   acquire_valid=1;acquire_slot=0;acquire_uart=0;acquire_identity=A;acquire_token=1;tick;
   if(!acquire_ack)$fatal(1,"FULL_WIDTH_TEST_ACQUIRE");
   clear;read_accept=1;read_slot=0;read_uart=0;read_identity=A;read_token=1;
   if(identity_bit<320)read_identity=A^(320'd1<<identity_bit);
   else read_token=64'd1^(64'd1<<(identity_bit-320));
   tick;if(!protocol_fault)$fatal(1,"FULL_IDENTITY_TOKEN_WIDTH bit=%0d",identity_bit);
  end
  $display("M5C1B_PASS pair_lease checks=%0d metadata_B_model=1 read_drain_model=1",checks);$finish;
 end
 initial begin #100000;$fatal(1,"WATCHDOG");end
endmodule

// Production backend startup adapter; no synthetic capture/DDR completion.
module tb_m5c1b_backend_startup;
 reg clk=0,pix=0,rst_n=0,run=0,stop=1;
 always #5 clk=~clk;always #7 pix=~pix;
 m5b1_backend #(.REQUEST_CYCLES(8)) dut(.ui_clk(clk),.pix_clk(pix),.rst_n(rst_n),.run(run),.stop(stop),.epoch(64'd1),
  .tap_valid(1'b0),.tap_class(2'd0),.tap_x(12'd0),.tap_y(12'd0),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),
  .tap_frame_id(64'd0),.tap_epoch(64'd1),.tap_timestamp(64'd0),.tap_display_seq(64'd0),.tap_config_generation(64'd0),
  .fusion_acquire(1'b0),.fusion_slot(1'b0),.fusion_identity(320'd0),.fusion_token(64'd0),.fusion_release(1'b0),.fusion_retire(1'b0),.fusion_read_accept(1'b0),.fusion_read_done(1'b0),
  .telemetry_ready(1'b0),.telemetry_descriptor(320'd0),.telemetry_byte(8'd0),.max_wait(96'd0),.max_service(96'd0),.camera_max(14'd0),.display_min(14'd0),
  .system_status(32'd0),.error_counts(224'd0),.video_fifo_faults(4'd0),.aready(1'b0),.wready(1'b0),.bvalid(1'b0),.bid(8'd0),.bresp(2'd0),
  .rvalid(1'b0),.rlast(1'b0),.rdata(128'd0),.rid(8'd0),.rresp(2'd0),.rejected(1'b0));
 task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
 integer k;reg [319:0] saved_identity;
 initial begin
  repeat(3)tick();rst_n=1;
  for(k=0;k<20;k=k+1)begin stop=k%3!=0;tick();
   if(dut.lease.halted||dut.lease.reserved||dut.lease.leased||dut.lease.reserve_ack||dut.lease.acquire_ack||dut.lease.read_accept||dut.lease.publish_valid)$fatal(1,"STARTUP_STOP_OWNERSHIP");
  end
  stop=0;run=1;
  for(k=0;k<20&&!dut.writer_owned;k=k+1)tick();
  if(!dut.writer_owned||dut.lease.halted||dut.accepted!=1)$fatal(1,"STARTUP_FIRST_RESERVE");
  saved_identity=dut.lease.identity[0];stop=1;tick();stop=0;
  repeat(20)tick();
  if(!dut.lease.halted||!dut.lease.reserved[0]||dut.lease.identity[0]!==saved_identity||dut.lease.latest_valid)$fatal(1,"RUN_STOP_REUSE");
  rst_n=0;run=0;stop=0;repeat(3)tick();rst_n=1;repeat(4)tick();
  run=1;stop=1;tick();stop=0;repeat(20)tick();
  if(!dut.lease.halted||dut.lease.reserve_ack||dut.lease.reserved||dut.lease.latest_valid)$fatal(1,"FIRST_RUN_STOP_SAME_EDGE");
  $display("M5C1B_PASS BACKEND_STARTUP no_pre_run_owner=1 first_reserve=1 runtime_sticky=1 first_run_stop=1");$finish;
 end
 initial begin #100000;$fatal(1,"BACKEND_STARTUP_TIMEOUT");end
endmodule

// Actual row completion and CE delay; local and newly-added weak pixels alternate.
module tb_m5c1b_added_only;
 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,ce=1,sof=0,tap_valid=0;reg [11:0] tap_x=0,tap_y=0;
 wire [24:0] final_packet;wire ready;
 wire final_de=final_packet[0];wire [11:0] final_x=final_packet[24:13],final_y=final_packet[12:1];
 wire local_edge=final_x[0];wire promoted,fused_edge,frame_ok,row_retire;wire [11:0] retired_y;
 m5a_packet_delay #(.BITS(25),.DELAY(15)) raster(.clk(clk),.rst_n(rst_n),.ce(ce),
  .in_packet({tap_x,tap_y,tap_valid}),.out_packet(final_packet),.out_ready(ready));
 m5c_row_fusion #(.WIDTH(8),.HEIGHT(8),.H_TOTAL(12),.REF_STAGE(0)) dut(
  .clk(clk),.rst_n(rst_n),.ce(ce),.sof(sof),.admit(1'b1),.invalidate(1'b0),.identity_in(320'd1),
  .tap_valid(tap_valid),.tap_qualified(1'b1),.tap_x(tap_x),.tap_y(tap_y),.current_class(2'd1),.current_support(1'b1),
  .ref_ready(1'b1),.ref_class(2'd1),.ref_global(1'b1),.ref_identity(320'd1),.ref_x(tap_x),.ref_y(tap_y),
  .support_radius(4'd0),.final_de(final_de),.final_x(final_x),.final_y(final_y),.local_edge(local_edge),
  .fused_edge(fused_edge),.promoted(promoted),.frame_ok(frame_ok),.row_retire(row_retire),.retired_y(retired_y));
 integer n,checked=0,added=0,already_local=0;
 always @(posedge clk)if(rst_n&&ce&&final_de)begin
  if(!frame_ok||!fused_edge)$fatal(1,"ADDED_ONLY_EDGE_SET");
  if(promoted!==!local_edge)$fatal(1,"ADDED_ONLY_ORACLE x=%0d y=%0d local=%b promoted=%b weak=%b support=%b global=%b",final_x,final_y,local_edge,promoted,dut.delayed[2],dut.delayed[1],dut.delayed[0]);
  checked=checked+1;if(promoted)added=added+1;else already_local=already_local+1;
 end
 initial begin
  repeat(3)@(negedge clk);rst_n=1;
  for(n=0;n<116;n=n+1)begin
   @(negedge clk);tap_valid=n<96&&n%12<8;tap_x=n%12;tap_y=n/12;sof=n==0;
  end
  @(negedge clk);if(checked!=64||added!=32||already_local!=32)$fatal(1,"ADDED_ONLY_COUNTS");
  $display("M5C1B_PASS ADDED_ONLY pixels=%0d added=%0d local=%0d",checked,added,already_local);$finish;
 end
endmodule

// Isolated production counter/event unit. Forced scheduling/fault inputs model
// event boundaries only; this is not a physical DDR or whole-system test.
module tb_m5c1b_counter_events;
 reg clk=0;always #5 clk=~clk;reg rst_n=0;
 m5b1_system dut(.ui_clk(clk),.rst_n(rst_n));
 task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
 task request_reject;begin force dut.background.tick=95999999;tick;force dut.background.tick=0;tick;end endtask
 initial begin
  force dut.run=0;force dut.stop=0;force dut.lease_fault=0;force dut.session_fault=0;
  force dut.telemetry_fault=0;force dut.quarantine=0;force dut.reset_request=0;
  force dut.background.state=0;force dut.background.tick=0;force dut.background.arm_busy=0;
  force dut.background.writer_owned=0;force dut.background.reserve_denied=0;
  tick;tick;rst_n=1;tick;force dut.run=1;
  // An eligible scheduling edge requests a slot, without rejecting the job.
  request_reject;if(dut.rejected_job_count!=0)$fatal(1,"COUNTER_ADMITTED_REQUEST");
  force dut.background.state=6;request_reject;
  if(dut.rejected_job_count!=1)$fatal(1,"COUNTER_BUSY_ONCE");
  force dut.background.state=18;force dut.background.reserve_denied=1;tick;
  force dut.background.reserve_denied=0;tick;
  if(dut.rejected_job_count!=2)$fatal(1,"COUNTER_SLOT_DENIED_ONCE");
  force dut.background.state=0;force dut.background.arm_busy=1;request_reject;
  if(dut.rejected_job_count!=3)$fatal(1,"COUNTER_ARM_BUSY_ONCE");
  force dut.background.arm_busy=0;force dut.background.writer_owned=1;request_reject;
  if(dut.rejected_job_count!=4)$fatal(1,"COUNTER_OWNER_BUSY_ONCE");
  dut.rejected_job_count=64'hffffffff;request_reject;
  if(dut.rejected_job_count!=64'h100000000)$fatal(1,"COUNTER_JOB_64_CARRY");
  dut.rejected_job_count=64'hfffffffffffffffe;request_reject;request_reject;
  if(dut.rejected_job_count!==64'hffffffffffffffff)$fatal(1,"COUNTER_JOB_SATURATION");
  force dut.lease_fault=1;force dut.session_fault=1;tick;repeat(3)tick;
  if(dut.protocol_fault_count!=1)$fatal(1,"COUNTER_COALESCED_STICKY");
  force dut.lease_fault=0;force dut.session_fault=0;tick;force dut.lease_fault=1;tick;
  if(dut.protocol_fault_count!=2)$fatal(1,"COUNTER_REASSERT");
  dut.protocol_fault_count=64'hffffffff;force dut.telemetry_fault=1;tick;
  if(dut.protocol_fault_count!=64'h100000000)$fatal(1,"COUNTER_FAULT_64_CARRY");
  dut.protocol_fault_count=64'hfffffffffffffffe;force dut.quarantine=1;tick;
  force dut.reset_request=1;tick;
  if(dut.protocol_fault_count!==64'hffffffffffffffff)$fatal(1,"COUNTER_FAULT_SATURATION");
  $display("M5C1B_PASS production counter events: admission/rejection,coalesced edges,hold,reassert,64carry,saturation");$finish;
 end
 initial begin #100000;$fatal(1,"COUNTER_TIMEOUT");end
endmodule

// Isolated status/reason admission boundaries; complete raster is tested separately.
module tb_m5c1b_reason_events;
 reg clk=0;always #5 clk=~clk;reg rst_n=0,enable=0,exp=0,ddr=0,hard=0;
 reg [767:0] descriptor=0;reg [159:0] cfg;reg ref_ready=0;reg [63:0] ref_session=1;
 wire [479:0] snapshot;
 m5c_fusion_display dut(.clk(clk),.rst_n(rst_n),.ce(1'b1),.raw_sof(1'b0),.stop(1'b0),.enable(enable),
  .export_status(exp),.ddr_error_status(ddr),.hardstop_status(hard),.epoch(64'd1),.config_generation(64'd1),
  .high_threshold(8'd64),.filter_enable(1'b1),.tap_valid(1'b0),.tap_qualified(1'b1),.tap_support(1'b1),
  .tap_class(2'd1),.tap_x(12'd0),.tap_y(12'd0),.final_de(1'b0),.final_x(12'd0),.final_y(12'd0),.local_edge(1'b0),
  .raw_gray(8'd0),.mode(3'd6),.base_rgb(24'd0),.offer_valid(1'b0),.offer_descriptor(768'd0),.offer_session(64'd0),
  .release_ready(1'b1),.prefilled(1'b1),.ref_ready(ref_ready),.ref_class(2'd1),.ref_mask(1'b1),
  .ref_x(12'd0),.ref_y(12'd0),.ref_session(ref_session),.telemetry_snapshot(snapshot));
 task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
 initial begin
  tick;tick;rst_n=1;tick;cfg=dut.config_signature;
  descriptor[63:0]=1;descriptor[751:744]=1;descriptor[743:736]=1;descriptor[735:576]=cfg;
  force dut.descriptor=descriptor;force dut.dvalid=1;force dut.dqualified=1;force dut.dx=0;
  force dut.have_offer=0;force dut.broken=0;force dut.frame_admitted=0;
  repeat(4)tick;if(dut.underflows!=0)$fatal(1,"REASON_OFF_UNDERFLOW");
  enable=1;repeat(4)tick;if(dut.underflows!=0)$fatal(1,"REASON_NO_OFFER_UNDERFLOW");
  force dut.have_offer=1;repeat(2)tick;if(dut.underflows!=0)$fatal(1,"REASON_UNADMITTED_UNDERFLOW");
  force dut.frame_admitted=1;#1;if(dut.reason_events!=32'h20)$fatal(1,"REASON_MISSING_ONLY %h",dut.reason_events);
  tick;force dut.dvalid=0;if(dut.underflows!=1)$fatal(1,"REASON_ADMITTED_UNDERFLOW");
  descriptor[576]=!descriptor[576];#1;
  if(dut.reason_events!=8)$fatal(1,"REASON_CONFIG_DISTINCT");tick;descriptor[735:576]=cfg;
  descriptor[383:320]=64'hffffffffffffffff;#1;
  if(dut.reason_events!=4)$fatal(1,"REASON_AGE_DISTINCT");tick;descriptor[383:320]=0;
  ref_ready=1;force dut.session=1;force dut.dsession=1;
  force dut.dvalid=1;force dut.dqualified=0;#1;
  if(dut.reason_events!=16)$fatal(1,"REASON_QUALIFICATION");tick;force dut.dqualified=1;
  ref_session=2;#1;if(dut.reason_events!=64)$fatal(1,"REASON_TAG");tick;ref_session=1;
  force dut.dx=1279;force dut.row_match=0;#1;
  if(dut.reason_events!=128)$fatal(1,"REASON_CLASS_MISMATCH bits=%h tag=%b attempt=%b valid=%b",dut.reason_events,dut.ref_tag_good,dut.row_attempt,dut.dvalid);tick;force dut.dvalid=0;
  exp=1;ddr=1;hard=1;#1;
  if(dut.reason_events!=32'h302)$fatal(1,"REASON_SIMULTANEOUS");tick;
  if((snapshot[351:320]&32'h3fe)!=32'h3fe||snapshot[291:290]!=2'b11)$fatal(1,"REASON_STICKY_OR_FLAGS");
  exp=0;ddr=0;hard=0;tick;
  if((snapshot[351:320]&32'h3fe)!=32'h3fe)$fatal(1,"REASON_STICKY_LOST");
  $display("M5C1B_PASS distinct reasons,simultaneous OR,flags,admitted-only underflow");$finish;
 end
 initial begin #100000;$fatal(1,"REASON_TIMEOUT");end
endmodule

// Directed offer transport test; forced source tuple models the lifecycle-held
// registers. Full lifecycle/drain protection is checked in integrated tests.
module tb_m5c1b_offer_atomic;
 reg ui=0,pix=0,rst=0,send=0,take=0,ce=0;
 always #5 ui=~ui;always #7 pix=~pix;
 reg [831:0] tuple=0;wire valid;wire [767:0] desc;wire [63:0] session;
 m5c_display_session dut(.ui_clk(ui),.pix_clk(pix),.rst_n(rst),.stop(1'b1),
  .offer_valid(valid),.offer_take(take),.offer_descriptor(desc),.offer_session(session),.ce(ce));
 integer k,captures=0;reg old_valid=0;
 always @(posedge pix)if(rst&&dut.offer_control_valid&&!valid&&dut.offer_box.take)
  $fatal(1,"OFFER_EARLY_ACK");
 always @(posedge pix)begin #1;if(rst&&valid&&!old_valid)captures=captures+1;old_valid=valid;end
 task transfer;
 input [831:0] value;input early_take;
 integer before_count;
 begin
  wait(!dut.offer_busy);@(negedge ui);tuple=value;send=1;take=early_take;before_count=captures;
  @(negedge ui);send=0;
  wait(valid);#2;
  if({session,desc}!==value)$fatal(1,"OFFER_ATOMIC_TUPLE");
  if(!dut.offer_busy)$fatal(1,"OFFER_EARLY_ACK");
  if(!early_take)begin
   // Deliberate source stability violation after capture: destination must
   // still sample once, never follow later source changes while valid.
   tuple=~value;repeat(4)@(negedge pix);
   if(!valid||{session,desc}!==value)$fatal(1,"OFFER_CE_PAUSE");
   tuple=value;take=1;
  end
  wait(!valid);wait(!dut.offer_busy);repeat(5)@(negedge pix);take=0;
  if(valid||captures!=before_count+1)$fatal(1,"OFFER_DUPLICATE_CAPTURE");
 end endtask
 initial begin
  force dut.active_descriptor=tuple[767:0];force dut.active_session=tuple[831:768];force dut.offer_send=send;
  repeat(4)@(negedge pix);rst=1;repeat(6)@(negedge pix);
  transfer({64'd11,{768{1'b1}}},1);
  transfer({64'd12,768'h123456789abcdef},0);
  for(k=0;k<832;k=k+1)transfer(832'd1<<k,k%2);
  @(negedge pix);rst=0;send=0;take=1;repeat(3)@(negedge pix);rst=1;
  repeat(6)@(negedge pix);if(valid||{session,desc}!==0)$fatal(1,"OFFER_RESET_RELEASE");
  transfer({64'd99,768'hfedcba987654321},1);
  $display("M5C1B_PASS offer atomic832bits earlytake CEpause old/new reset captures%0d",captures);$finish;
 end
 initial begin #2000000;$fatal(1,"OFFER_TIMEOUT");end
endmodule

// Session lifecycle unit: real request/offer/release mailboxes; reader drain,
// cache-empty and lease acknowledgment inputs are explicitly unit models.
module tb_m5c1b_offer_lifecycle;
 reg ui=0,pix=0,rst=0,request=0,take=0,rel=0,ack=0,tele_pending=0;
 always #5 ui=~ui;always #7 pix=~pix;
 reg [63:0] seq=1;reg [767:0] descriptor=0;reg [3:0] leased=0;
 wire acquire,release_lease,valid,fault;wire [63:0] session;wire [767:0] offered;
 m5c_display_session dut(.ui_clk(ui),.pix_clk(pix),.rst_n(rst),.stop(1'b0),
  .request_frame(request),.request_seq(seq),.request_config(160'h1234),
  .pixel_release(rel),.pixel_release_final(1'b1),.pixel_release_session(64'd1),
  .result_valid(1'b1),.result_slot(1'b0),.result_descriptor(descriptor),.export_exclusive(1'b0),
  .acquire(acquire),.acquire_ack(ack),.acquire_denied(1'b0),.pair_leased(leased),
  .lease_release(release_lease),.session_fault(fault),.telemetry_pending(tele_pending),
  .offer_valid(valid),.offer_take(take),.offer_descriptor(offered),.offer_session(session),
  .ce(1'b0),.read_valid(1'b0),.retire(1'b0),.flush(1'b0),.aready(1'b0),.rvalid(1'b0),.rejected(1'b0));
 initial begin
  force dut.reader_drained=1;force dut.cache_empty=1;force dut.cache_fault=0;force dut.reader_fault=0;
  descriptor[735:576]=160'h1234;descriptor[63:0]=64'hfeed;
  repeat(4)@(negedge pix);rst=1;repeat(8)@(negedge pix);
  request=1;@(negedge pix);request=0;wait(acquire);@(negedge ui);leased=1;ack=1;
  @(negedge ui);ack=0;wait(valid);#1;
  if(session!=1||offered!==descriptor)$fatal(1,"OFFER_LIFECYCLE_IDENTITY");
  // A pending next request cannot replace the active pair during offer hold.
  seq=2;@(negedge pix);request=1;@(negedge pix);request=0;
  repeat(8)@(negedge ui);if(dut.active_session!=1||!dut.offer_busy)$fatal(1,"OFFER_LIFECYCLE_ACTIVE");
  tele_pending=1;@(negedge pix);take=1;rel=1;@(negedge pix);rel=0;
  wait(dut.state==3);repeat(12)@(negedge ui);
  if(dut.state!=3||release_lease||dut.active_session!=1)$fatal(1,"OFFER_LIFECYCLE_TELEMETRY_FENCE");
  tele_pending=0;wait(release_lease);repeat(5)@(negedge ui);
  if(dut.state!=4||dut.active_session!=1)$fatal(1,"OFFER_LIFECYCLE_LEASE_FENCE");
  leased=0;wait(acquire);#1;
  if(dut.active_session!=2||fault)$fatal(1,"OFFER_LIFECYCLE_NEXT_SESSION");
  $display("M5C1B_PASS offer lifecycle queued request telemetry/drain/lease fences");$finish;
 end
 initial begin #100000;$fatal(1,"OFFER_LIFECYCLE_TIMEOUT");end
endmodule

// Real production backend default capture wall. DDR denies every address;
// actual capture FIFO supplies a queued transaction, never a fabricated ACK.
module tb_m5c1b_backend_default_wall;
 reg clk=0,pix=0,rst_n=0,run=0,stop=0;
 always #5 clk=~clk;always #7 pix=~pix;
 reg tv=0;reg [11:0] tx=0,ty=0;
 m5b1_backend #(.REQUEST_CYCLES(1000000)) dut(.ui_clk(clk),.pix_clk(pix),.rst_n(rst_n),.run(run),.stop(stop),.epoch(64'd1),
  .tap_valid(tv),.tap_class(2'd0),.tap_x(tx),.tap_y(ty),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),
  .tap_frame_id(64'd0),.tap_epoch(64'd1),.tap_timestamp(64'd0),.tap_display_seq(64'd0),.tap_config_generation(64'd0),
  .fusion_acquire(1'b0),.fusion_slot(1'b0),.fusion_identity(320'd0),.fusion_token(64'd0),.fusion_release(1'b0),.fusion_retire(1'b0),.fusion_read_accept(1'b0),.fusion_read_done(1'b0),
  .telemetry_ready(1'b0),.telemetry_descriptor(320'd0),.telemetry_byte(8'd0),.max_wait(96'd0),.max_service(96'd0),.camera_max(14'd0),.display_min(14'd0),
  .system_status(32'd0),.error_counts(224'd0),.video_fifo_faults(4'd0),.aready(1'b0),.wready(1'b0),.bvalid(1'b0),.bid(8'd0),.bresp(2'd0),
  .rvalid(1'b0),.rlast(1'b0),.rdata(128'd0),.rid(8'd0),.rresp(2'd0),.rejected(1'b0));

 integer cycles=0,n;reg started=0;
 always @(posedge clk) if(rst_n)begin
  if(dut.state>=dut.HEADER&&dut.state<=dut.FREEZE)begin cycles=cycles+1;started=1;end
  if(started&&cycles<96000000&&(dut.capture_timeout||dut.local_cancels!=0))$fatal(1,"BACKEND_DEFAULT_WALL_EARLY cycles=%0d",cycles);
  if(dut.transfer_segment_accept||dut.transfer_segment_done||dut.metadata_committed||dut.lease.latest_valid)$fatal(1,"BACKEND_STARVATION_FAKE_TRANSACTION");
 end
 initial begin
  repeat(4)@(negedge clk);rst_n=1;run=1;
  wait(dut.capture.arm_valid);@(negedge pix);
  for(n=0;n<2048;n=n+1)begin tv=1;tx=n%1280;ty=n/1280;@(negedge pix);end
  tv=0;
  wait(dut.avalid);if(dut.capture_age>=96000000)$fatal(1,"BACKEND_NO_PENDING_REQUEST");
  wait(dut.capture_timeout);#1;
  if(cycles!=96000000||dut.CAPTURE_CYCLES!=96000000)$fatal(1,"BACKEND_DEFAULT_WALL_BOUND cycles=%0d",cycles);
  repeat(500)@(negedge clk);
  if(dut.tx_busy||dut.local_cancels!=1||!dut.job_failed||dut.capture_drop!=1||dut.writer_owned||dut.lease.reserved!=0)$fatal(1,"BACKEND_DEFAULT_WALL_DRAIN");
  $display("M5C1B_PASS BACKEND_DEFAULT_WALL cycles=%0d queued_cancel=%0d accepted=0 synthetic_done=0 owner_released=1",cycles,dut.local_cancels);$finish;
 end
 initial begin #1020000000;$fatal(1,"BACKEND_DEFAULT_WALL_WATCHDOG");end
endmodule
