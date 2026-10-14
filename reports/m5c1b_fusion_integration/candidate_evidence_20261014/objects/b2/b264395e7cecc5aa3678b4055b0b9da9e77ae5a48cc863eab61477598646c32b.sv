`timescale 1ns/1ps
module tb_counter_priority;
 reg clk=0,rst=0,ce=1,block=0,tap=0,stop=0;always #7 clk=~clk;
 wire promoted;
 m5c_fusion_display dut(.clk(clk),.rst_n(rst),.ce(ce),.context_block(block),.raw_sof(1'b0),.stop(stop),.enable(1'b0),.export_status(1'b0),.ddr_error_status(1'b0),.hardstop_status(1'b0),.epoch(64'd1),.config_generation(64'd1),.high_threshold(8'd64),.filter_enable(1'b1),.tap_valid(tap),.tap_qualified(1'b1),.tap_support(1'b0),.tap_class(2'd0),.tap_x(12'd0),.tap_y(12'd0),.final_de(1'b0),.final_x(12'd0),.final_y(12'd0),.local_edge(1'b0),.raw_gray(8'd0),.mode(3'd6),.base_rgb(24'd0),.offer_valid(1'b0),.offer_descriptor(768'd0),.offer_session(64'd0),.release_ready(1'b1),.prefilled(1'b0),.ref_ready(1'b0),.ref_class(2'd0),.ref_mask(1'b0),.ref_x(12'd0),.ref_y(12'd0),.ref_session(64'd0),.promoted(promoted));
 task edge_check(input [31:0] n);begin @(posedge clk);#0.001;if(dut.promotion_count!==n)$fatal(1,"COUNTER_PRIORITY got=%0d expected=%0d",dut.promotion_count,n);@(negedge clk);end endtask
 initial begin
  repeat(3)@(negedge clk);rst=1;force dut.promoted=1'b1;edge_check(1);edge_check(2);edge_check(3);release dut.promoted;
  block=1;stop=1;ce=0;tap=1;edge_check(3);edge_check(3);
  ce=1;edge_check(0);if(dut.equal_rows||dut.rejected_rows)$fatal(1,"BLOCKED_FIRST_TAP_COUNTER_RESET");
  tap=0;stop=0;block=0;force dut.promoted=1'b1;edge_check(1);edge_check(2);edge_check(3);release dut.promoted;
  block=1;edge_check(3);edge_check(3);
  block=0;tap=1;force dut.promoted=1'b1;edge_check(0);release dut.promoted;tap=0;ce=0;rst=0;#0.001;
  if(dut.promotion_count||dut.equal_rows||dut.rejected_rows)$fatal(1,"ASYNC_RESET_COUNTER_PRIORITY");
  $display("CACHE_CONTEXT_PASS counter_boundary_priority synthetic_promoted_event=1 CE0hold=1 midkillpreserve=1 blocked_stop_firsttap=1");$finish;
 end
 initial begin #10000;$fatal(1,"UNIT_WATCHDOG");end
endmodule
