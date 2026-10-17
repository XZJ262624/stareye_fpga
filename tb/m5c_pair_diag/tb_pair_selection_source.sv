`timescale 1ns/1ps
module tb_pair_selection_source;
 reg clk=0,rst=0,sof=0;always #6 clk=~clk;
 reg [1:0] keys=3;wire [2:0] mode;wire [7:0] threshold;wire enable;wire [63:0] gen,seq;wire request;
 wire [159:0] cfg;
 m5a_controls #(.DEBOUNCE_CYCLES(4),.LONG_CYCLES(64)) controls(.clk(clk),.ce(1'b1),.arst_n(rst),.key_n(keys),.frame_start(sof),.threshold(threshold),.mode(mode),.fusion_enable(enable),.config_generation(gen));
 m5c_fusion_display display(.clk(clk),.rst_n(rst),.ce(1'b1),.raw_sof(sof),.stop(1'b0),.enable(enable),.context_block(1'b1),.export_status(1'b0),.ddr_error_status(1'b0),.hardstop_status(1'b0),.epoch(64'd1),.config_generation(gen),.high_threshold(threshold),.filter_enable(1'b1),
 .tap_valid(1'b0),.tap_qualified(1'b0),.tap_support(1'b0),.tap_class(2'd0),.tap_x(12'd0),.tap_y(12'd0),.final_de(1'b0),.final_x(12'd0),.final_y(12'd0),.local_edge(1'b0),.raw_gray(8'd0),.mode(mode),.base_rgb(24'd0),
 .request_frame(request),.request_seq(seq),.config_signature(cfg),.offer_valid(1'b0),.offer_descriptor(768'd0),.offer_session(64'd0),.release_ready(1'b1),.prefilled(1'b0),.ref_ready(1'b0),.ref_class(2'd0),.ref_mask(1'b0),.ref_x(12'd0),.ref_y(12'd0),.ref_session(64'd0));
 integer frame=0,requests=0,covs=0,i;integer modes[0:6];reg [2:0] expected_mode;
 initial begin
  for(i=0;i<7;i=i+1)modes[i]=0;
  repeat(5)@(negedge clk);rst=1;repeat(80)@(negedge clk);keys=0;repeat(100)@(negedge clk);keys=3;repeat(40)@(negedge clk);
  for(frame=0;frame<14;frame=frame+1)begin
   @(negedge clk);expected_mode=controls.pending_mode;sof=1;
   @(negedge clk);sof=0;
   repeat(99)@(negedge clk);keys=0;repeat(20)@(negedge clk);keys=3;repeat(100)@(negedge clk);
  end
  if(requests!=14||covs!=2)$fatal(1,"SOURCE_REQUEST_COUNTS");
  for(i=0;i<7;i=i+1)if(modes[i]!=2)$fatal(1,"SOURCE_MODE_COVERAGE");
  $display("SOURCE_PHASE_PASS requests=%0d cov=%0d all7=2 request_after_sof_current_mode",requests,covs);$finish;
 end
 always @(posedge clk)if(rst&&request)begin
  if(!enable||mode!==expected_mode||seq!==frame+1)$fatal(1,"SOURCE_OLD_MODE_OR_SID");
  requests=requests+1;modes[mode]=modes[mode]+1;if(mode==6)covs=covs+1;
  $display("SOURCE_REQUEST frame=%0d seq=%0d mode=%0d pending=%0d cov=%b t=%0t",frame,seq,mode,controls.pending_mode,mode==6,$time);
 end
 initial begin #1000000;$fatal(1,"SOURCE_WATCHDOG");end
endmodule
