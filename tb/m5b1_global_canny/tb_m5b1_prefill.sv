`timescale 1ns/1ps
module tb_m5b1_prefill;
 reg ui=0,cam=0,pix=0,rst=0,sof=0,request=0;
 always #5.20833 ui=~ui;always #5 cam=~cam;always #6.72043 pix=~pix;
 wire valid;wire [7:0] data;
 m5b1_video_dma dut(.ui_clk(ui),.cam_clk(cam),.pix_clk(pix),.arst_n(rst),.run(1'b1),.stop(1'b0),.epoch(64'd1),
 .cam_vs(1'b1),.cam_valid(1'b0),.cam_data(8'd0),.pix_sof(sof),.pix_request(request),.pix_data(data),.pix_qualified(),.replay_frame_id(),.display_valid(valid),.fault(),
 .avalid(),.aready(2'b0),.aaddr(),.alen(),.aid(),.atype(),.wvalid(),.wlast(),.wdata(),.wready(1'b0),.bvalid(1'b0),.bresp(2'b0),.bid(8'b0),
 .rvalid(1'b0),.rlast(1'b0),.rdata(128'b0),.rresp(2'b0),.rid(8'b0),.rready(),.rejected(2'b0),.write_permission(),.read_permission(),
 .camera_bytes(),.display_bytes(),.urgent(),.safe_window(),.fifo_ready(),.camera_max(),.display_min(),.fifo_faults());
 task first_pixel;
 begin @(negedge pix);sof=1;request=0;@(negedge pix);sof=0;request=1;@(posedge pix);#0.01;end endtask
 initial begin
  #23.17;rst=1;repeat(10)@(negedge pix);
  // Deliberately present a pending offer before data: this tests the consumer
  // prefill barrier independently of the producer's separate offer threshold.
  force dut.offer_valid=1;force dut.offer_id=64'd7;
  first_pixel();if(valid||data!=0)$fatal(1,"prefill barrier admitted an empty frame");
  @(negedge pix);request=0;
  force dut.display_rc=255;
  first_pixel();if(valid)$fatal(1,"prefill barrier admitted 4080B");
  @(negedge pix);request=0;force dut.display_rc=256;force dut.display_empty=0;force dut.display_head=128'h0707;
  first_pixel();if(!valid||data!=7)$fatal(1,"4096B prefill did not admit");
  $display("M5B1_PREFILL_PASS rejected_bytes=0,4080 accepted_bytes=4096");$finish;
 end
 initial begin #100000;$fatal(1,"prefill watchdog");end
endmodule
