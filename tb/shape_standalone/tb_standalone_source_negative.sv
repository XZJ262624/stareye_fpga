`timescale 1ns/1ps
module tb_standalone_source_negative;
 reg ui_clk=0,cam_clk=0,pix_clk=0,rst_n=0;always #5.208333 ui_clk=~ui_clk;always #5 cam_clk=~cam_clk;always #6.720430 pix_clk=~pix_clk;
 reg[1:0]key_n=3;reg cam_vs=1,cam_valid=0;reg[7:0]cam_data=0;reg inject_b_error=0,pll_ok=0;
 wire[23:0]rgb;wire de,hs,vs,uart;wire[5:0]led;
 wire[7:0]aid,alen,wid,bid,rid;wire[31:0]aaddr;wire[2:0]asize;wire[1:0]aburst,alock,bresp,rresp;
 wire avalid,atype,aready,wlast,wvalid,wready,bvalid,bready,rlast,rvalid,rready;wire[127:0]wdata,rdata;wire[15:0]wstrb;wire[31:0]accepted,completed,max_service;
 shape_standalone_system #(.DEBOUNCE_CYCLES(4),.LONG_CYCLES(64)) dut(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.rst_n(rst_n),.pix_rst_n(rst_n),.pll_locked(pll_ok),.cal_done(rst_n),.cal_pass(rst_n),.key_n(key_n),.cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.display_rgb_out(rgb),.display_de_out(de),.display_hs_out(hs),.display_vs_out(vs),.uart_tx(uart),.led(led),.aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),.wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),.rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
 m5c1b_ddr_service_model memory(.clk(ui_clk),.rst_n(rst_n),.stall(1'b0),.service_delay(32'd0),.inject_b_error(inject_b_error),.inject_r_error(1'b0),.accepted(accepted),.completed(completed),.max_service(max_service),.aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),.wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),.rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));

 integer which=2,i;
 initial begin
  if($value$plusargs("CASE=%d",which))begin end
  #1000;rst_n=1;pll_ok=1;wait(dut.u_m5b1.run);#100000;
  if(which==2)begin
   @(negedge cam_clk);cam_vs=0;repeat(20)@(negedge cam_clk);cam_vs=1;
   for(i=0;i<32;i=i+1)begin cam_valid=1;cam_data=i;@(negedge cam_clk);end cam_valid=0;cam_vs=0;
   wait(dut.u_m5b1.stop);repeat(100)@(negedge pix_clk);
   if(!dut.u_m5b1.video_fault||dut.u_m5b1.video.complete!=0||accepted!=0||completed!=0||dut.u_m5b1.ack||dut.shape_visible)$fatal(1,"TRUNCATED_CAMERA_FALSE_QUALIFICATION");
   $display("PASS_STANDALONE_BAD_CAMERA_EOF real_pixels=32 complete=%b A=%0d stop=%b class_visible=%b",dut.u_m5b1.video.complete,accepted,dut.u_m5b1.stop,dut.shape_visible);$finish;
  end
  if(which!=3)$fatal(1,"BAD_CASE");
  pll_ok=0;#10000;pll_ok=1;#100000;
  if(!dut.u_m5b1.stop||dut.u_m5b1.run||dut.u_m5b1.ack||accepted!=0||completed!=0||dut.shape_visible)$fatal(1,"PLL_COLD_FAILSTOP_NOT_STICKY");
  $display("PASS_STANDALONE_IDLE_PLL_COLD_FAILSTOP restored_PLL=1 sticky_stop=%b no_fake_ACK=%b no_busA=%0d",dut.u_m5b1.stop,!dut.u_m5b1.ack,accepted);$finish;
 end
 initial begin #1000000;$fatal(1,"NEGATIVE_WATCHDOG");end
endmodule
