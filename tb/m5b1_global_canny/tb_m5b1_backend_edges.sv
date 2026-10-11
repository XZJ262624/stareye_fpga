`timescale 1ns/1ps
// Directed wall-boundary arbitration supplements the full system tests.
// Only the boundary's pre-state/descriptor arrival is injected; its next-state,
// transfer start and descriptor take are the real production logic.
module tb_m5b1_backend_edges;
 reg ui=0,pix=0,rst=0;always #5 ui=~ui;always #7 pix=~pix;
 wire avalid,wvalid,wlast,rready,uart_tx;wire [31:0] aaddr;wire [7:0] alen,aid;wire atype;wire [127:0] wdata;
 reg [319:0] desc=0;integer cases=0;
 m5b1_backend #(.REQUEST_CYCLES(1000000),.CAPTURE_CYCLES(8),.EXPORT_CYCLES(8)) dut(
 .ui_clk(ui),.pix_clk(pix),.rst_n(rst),.run(1'b1),.stop(1'b0),.epoch(64'd1),
 .tap_valid(1'b0),.tap_class(2'b0),.tap_x(12'b0),.tap_y(12'b0),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),
 .tap_frame_id(64'd7),.tap_epoch(64'd1),.tap_timestamp(64'd10),.max_wait(96'b0),.max_service(96'b0),.camera_max(14'b0),.display_min(14'b0),
 .system_status(32'b0),.error_counts(224'b0),.video_fifo_faults(4'b0),.uart_tx(uart_tx),.job_busy(),.publish_toggle(),.bg_fault(),.capture_reset_done(),
 .avalid(avalid),.aready(1'b0),.aaddr(aaddr),.alen(alen),.aid(aid),.atype(atype),.wvalid(wvalid),.wlast(wlast),.wdata(wdata),.wready(1'b0),
 .bvalid(1'b0),.bid(8'b0),.bresp(2'b0),.rvalid(1'b0),.rlast(1'b0),.rdata(128'b0),.rid(8'b0),.rresp(2'b0),.rready(rready),.rejected(1'b0),.write_permission(),.read_permission());
 defparam dut.packet.uart.CLOCK=460800;
 task reset_case;
 begin rst=0;repeat(4)@(negedge ui);rst=1;repeat(12)@(negedge ui);end endtask
 initial begin
  desc[63:0]=1;desc[127:64]=7;desc[191:128]=1;desc[308]=1;desc[295:284]=1280;desc[307:296]=720;
  reset_case();
  // FREEZE + successful descriptor + deadline, all on the same edge.
  force dut.state=4;force dut.capture_age=8;force dut.descriptor_valid=1;force dut.cap_descriptor=desc;force dut.cap_empty=1;
  @(negedge ui);release dut.state;release dut.capture_age;
  @(posedge ui);#0.01;
  if(dut.state!=14||dut.descriptor_take||dut.transfer_start)$fatal(1,"FREEZE_TIMEOUT_CONSUMED_DESCRIPTOR");
  @(posedge ui);#0.01;
  if(dut.state!=7||!dut.descriptor_take||dut.frozen[308]||!dut.job_failed)$fatal(1,"FREEZE_TIMEOUT_DRAIN_HUNG");
  release dut.descriptor_valid;release dut.cap_descriptor;release dut.cap_empty;cases=cases+1;
  reset_case();
  // CAPTURE could launch a full FIFO burst, but deadline wins atomically.
  force dut.state=2;force dut.capture_age=8;force dut.cap_count=32;
  @(negedge ui);release dut.state;release dut.capture_age;
  if(dut.transfer_start)$fatal(1,"CAPTURE_DEADLINE_LAUNCH");
  @(posedge ui);#0.01;
  if(dut.state!=14||dut.tx_busy||avalid)$fatal(1,"CAPTURE_DEADLINE_ORPHAN");
  release dut.cap_count;cases=cases+1;
  reset_case();
  // Failed FREEZE must not export a previous successful slot under new class ID.
  desc[308]=0;force dut.state=4;force dut.capture_age=0;force dut.descriptor_valid=1;force dut.cap_descriptor=desc;force dut.latest_valid=1;
  @(negedge ui);release dut.state;
  @(posedge ui);#0.01;
  if(dut.state!=7||!dut.job_failed)$fatal(1,"FREEZE_FAILURE_NOT_MARKED");
  release dut.descriptor_valid;release dut.cap_descriptor;release dut.capture_age;
  wait(dut.state==0);if(dut.export_active||dut.tx_busy)$fatal(1,"FAILED_JOB_EXPORTED_OLD_RESULT");
  release dut.latest_valid;cases=cases+1;
  $display("REVIEW_PASS backend_edges cases=%0d freeze_deadline_descriptor=1 capture_deadline_no_launch=1 failed_no_old_export=1",cases);$finish;
 end
 initial begin #100000;$fatal(1,"backend edge watchdog state=%0d",dut.state);end
endmodule
