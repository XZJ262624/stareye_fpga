`timescale 1ns/1ps
module tb_backend;
 reg clk=0,pix=0,rst=0,run=0;always #5 clk=~clk;always #7 pix=~pix;
 reg tv=0;reg [1:0] tc=0;reg [11:0] x=0,y=0;reg [63:0] fid=1;
 wire rv,slot,ack,deny,lf,uart;wire [767:0] desc;wire [3:0] leased;
 reg acquire=0,release_owner=0,retire=0,read_accept=0,read_done=0;
 reg held_slot=0;reg[319:0] identity=0;reg[63:0] token=1;
 wire av,at,ar,wv,wl,wr,bv,rr,rl,rvalid;wire[31:0] aa;wire[7:0] al,ai,bi,ri;wire[127:0] wd,rd;wire[1:0] br,rp;
 wire [31:0] accepts,completes,maxservice;
 canny_backend #(.REQUEST_CYCLES(10000),.CAPTURE_CYCLES(3000000)) dut(
 .ui_clk(clk),.pix_clk(pix),.rst_n(rst),.run(run),.stop(1'b0),.epoch(64'd1),
 .tap_valid(tv),.tap_class(tc),.tap_x(x),.tap_y(y),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(2'd2),
 .tap_frame_id(fid),.tap_epoch(64'd1),.tap_timestamp(64'd99),.tap_display_seq(64'd1),.tap_config_generation(64'd1),
 .fusion_acquire(acquire),.fusion_slot(held_slot),.fusion_identity(identity),.fusion_token(token),.fusion_release(release_owner),.fusion_retire(retire),.fusion_read_accept(read_accept),.fusion_read_done(read_done),
 .fusion_ack(ack),.fusion_denied(deny),.pair_leased(leased),.result_valid(rv),.result_slot(slot),.result_descriptor(desc),.export_exclusive(),.capture_priority(),.lease_fault(lf),.job_rejected_event(),
 .uart_tx(uart),.job_busy(),.publish_toggle(),.bg_fault(),.capture_reset_done(),
 .avalid(av),.aready(ar),.aaddr(aa),.alen(al),.aid(ai),.atype(at),.wvalid(wv),.wlast(wl),.wdata(wd),.wready(wr),.bvalid(bv),.bid(bi),.bresp(br),
 .rvalid(rvalid),.rlast(rl),.rdata(rd),.rid(ri),.rresp(rp),.rready(rr),.rejected(1'b0),.write_permission(),.read_permission());
 m5c1b_ddr_service_model #(.WORDS(32'h010e7000/16)) memory(.clk(clk),.rst_n(rst),.stall(1'b0),
 .aid(ai),.alen(al),.wid(ai),.aaddr(aa),.asize(3'd4),.aburst(2'd1),.alock(2'd0),.avalid(av),.atype(at),.aready(ar),
 .wdata(wd),.wstrb(16'hffff),.wlast(wl),.wvalid(wv),.wready(wr),.bid(bi),.bresp(br),.bvalid(bv),.bready(1'b1),
 .rid(ri),.rresp(rp),.rdata(rd),.rlast(rl),.rvalid(rvalid),.rready(rr),.service_delay(32'd384),.inject_b_error(1'b0),.inject_r_error(1'b0),.accepted(accepts),.completed(completes),.max_service(maxservice));
 integer pubs=0,bs=0,rs=0,i,px,py,ones=0;reg[31:0] base;reg expected;
 always @(posedge clk)if(rst)begin
  if(lf||uart!==1'b1)$fatal(1,"BACKEND_LEASE_OR_UART");
  if(bv)bs=bs+1;if(rvalid&&rr&&rl)rs=rs+1;
  if(dut.publication_accept)begin pubs=pubs+1;if(!dut.metadata_committed)$fatal(1,"PUBLICATION_WITHOUT_REAL_METADATA_B");end
 end
 task cycle;begin @(posedge clk);#1;@(negedge clk);end endtask
 initial begin
  repeat(10)cycle;rst=1;run=1;
  // A real pending arm, no SOF: exercise timeout, cancellation mailbox and
  // lease writer drain. No internal completion signal is forced.
  wait(dut.state==dut.HEADER);wait(dut.state==dut.DRAIN);wait(dut.state==dut.IDLE);
  if(dut.writer_owned||!dut.cap_empty||dut.arm_busy||dut.descriptor_valid||rv)$fatal(1,"CANCEL_DID_NOT_DRAIN");
  $display("BACKEND_CANCEL_DRAIN_PASS");
  wait(dut.capture.arm_valid);repeat(3)@(negedge pix);
  for(i=0;i<921600;i=i+1)begin
   @(negedge pix);tv=1;x=i%1280;y=i/1280;
   tc=(y==20&&x==20)?2:(y==20&&x>20&&x<=100)?1:(y==40&&x>=20&&x<=100)?1:0;
  end
  @(negedge pix);tv=0;
  wait(rv);@(negedge clk);run=0;
  if(pubs!=1||bs==0||rs==0||!dut.metadata_committed)$fatal(1,"FIRST_PUBLICATION_COVERAGE");
  base=slot?32'h010c9000:32'h010ac000;
  for(i=0;i<921600;i=i+1)begin
   expected=(i/1280==20&&i%1280>=20&&i%1280<=100);
   if(memory.mem[(base>>4)+(i>>7)][i%128]!==expected)$fatal(1,"GLOBAL_BFS_PIXEL pos=%0d slot=%b",i,slot);
   if(expected)ones=ones+1;
  end
  held_slot=slot;identity={desc[63:0],desc[191:128],desc[127:64],desc[447:384],desc[511:448]};acquire=1;cycle;acquire=0;
  if(!ack||deny)$fatal(1,"FIRST_RESULT_NOT_IMMEDIATELY_ACQUIRABLE");cycle;
  // Lease contract check: release/retire cannot recycle a slot while a
  // reader's accepted transaction is outstanding. Full reader is in SUT test.
  read_accept=1;cycle;read_accept=0;retire=1;release_owner=1;cycle;retire=0;release_owner=0;
  repeat(8)cycle;if(!leased[held_slot*2])$fatal(1,"LEASE_EARLY_RELEASE");
  read_done=1;cycle;read_done=0;repeat(5)cycle;
  if(leased[held_slot*2]||lf)$fatal(1,"LEASE_NOT_RELEASED_AFTER_DONE");
  $display("PASS_CANNY_BACKEND cancel_recovered=1 first_publication=1 real_B=%0d real_last_R=%0d BFS_pixels=921600 connected=81 isolated_rejected=81 lease_reader_fence=1",bs,rs);$finish;
 end
 initial begin #300000000;$fatal(1,"BACKEND_WATCHDOG state=%0d pubs=%0d",dut.state,pubs);end
endmodule
