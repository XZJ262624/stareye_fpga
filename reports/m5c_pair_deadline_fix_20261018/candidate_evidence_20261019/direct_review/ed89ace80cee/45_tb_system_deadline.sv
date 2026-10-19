`timescale 1ns/1ps
module tb_system_deadline;
reg ui=0,pix=0,rst=0,sof=0,cov=0;always #5.208333 ui=~ui;always #6.720430 pix=~pix;
m5c_pair_system dut(.pair_source_tap_valid('0),.pair_source_tap_qualified('0),.pair_cov(cov),.pair_sof('0),.pair_admit('0),.pair_kill('0),.pair_identity_ok('0),.pair_capture_eligible('0),.pair_pixel_session('0),.pair_pixel_source('0),.pair_pixel_ticks('0),.pair_pixel_seq('0),.pair_de('0),.pair_x('0),.pair_y('0),.pair_class('0),.pair_support('0),.pair_local('0),.pair_domain('0),.pair_row_complete('0),.pair_row_tag('0),.ui_clk(ui),.cam_clk(pix),.pix_clk(pix),.rst_n(rst),.pll_locked(1'b1),.cal_done(1'b1),.cal_pass(1'b1),.cam_vs('0),.cam_valid('0),.cam_data('0),.pix_sof(sof),.pix_request('0),.tap_valid('0),.tap_class('0),.tap_x('0),.tap_y('0),.tap_high('0),.tap_low('0),.tap_filter('0),.tap_frame_id('0),.tap_epoch('0),.tap_timestamp('0),.tap_display_seq('0),.tap_config_generation('0),.fusion_request('0),.fusion_request_seq('0),.fusion_config('0),.fusion_release('0),.fusion_release_final('0),.fusion_release_session('0),.fusion_offer_take('0),.fusion_ce(1'b1),.fusion_read('0),.fusion_x('0),.fusion_y('0),.fusion_read_session('0),.fusion_context_quiet('0),.fusion_context_tail_fault('0),.fusion_retire('0),.fusion_retire_row('0),.fusion_flush('0),.diag_ready('0),.diag_window('0),.diag_byte('0),.diag_byte_valid('0),.fusion_frame_done('0),.fusion_telemetry_snapshot('0),.aready('0),.wready('0),.bid('0),.bresp('0),.bvalid('0),.rid('0),.rresp('0),.rdata('0),.rlast('0),.rvalid('0));
integer k;reg [1:0] expected=0;
always @(posedge ui)begin
 if(!dut.pair_ui_rst_n)expected=0;else expected={expected[0],dut.pair_wait_expired_pix};
 #0.001;if(dut.pair_wait_expired_ui!==expected)$fatal(1,"DEADLINE_TWO_FF_MISMATCH");
end
initial begin
 repeat(8)@(negedge ui);rst=1;wait(dut.pair_pix_rst_n&&dut.pair_ui_rst_n);repeat(10)@(negedge pix);
 // Ordinary SOFs before user COV do not consume the waiting budget.
 repeat(20)begin sof=1;@(negedge pix);sof=0;@(negedge pix);end
 if(dut.pair_wait_started||dut.pair_wait_frames||dut.pair_wait_expired_pix)$fatal(1,"PRE_COV_WAIT_CONSUMED");
 cov=1;
 for(k=0;k<7201;k=k+1)begin
 sof=1;@(negedge pix);sof=0;
 if(k<7200&&dut.pair_wait_expired_pix)$fatal(1,"DEADLINE_EARLY");
 if(k==7200&&!dut.pair_wait_expired_pix)$fatal(1,"DEADLINE_LATE");
 @(negedge pix);
 end
 repeat(6)@(negedge ui);
 if(!dut.background.pair_wait_expired||dut.background.pair_request||dut.pair_send)$fatal(1,"SYSTEM_DEADLINE_PORT_MASK_FAILED");
 $display("SYSTEM_DEADLINE_PASS sof=7201 frames=%0d pix=%b ui=%b backend=%b",dut.pair_wait_frames,dut.pair_wait_expired_pix,dut.pair_wait_expired_ui,dut.background.pair_wait_expired);$finish;
end
initial begin #1000000;$fatal(1,"SYSTEM_DEADLINE_WATCHDOG");end
endmodule
