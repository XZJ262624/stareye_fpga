`timescale 1ns/1ps
// Real mux transactions: pending selection, permission rejection and last-R.
module tb_m5c1b_c2;
 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,stop=0,capture_priority=0;
 reg [1:0] s_avalid=0,s_wvalid=0,s_wlast=0,s_atype=0,s_rready=3;
 reg [63:0] s_aaddr={32'h2000,32'h1000};reg [15:0] s_alen=0,s_aid=16'h2222;
 reg [255:0] s_wdata=0;
 wire [1:0] s_aready,s_wready,s_bvalid,s_rvalid,s_rejected;
 wire [7:0] s_bid,s_rid;wire [1:0] s_bresp,s_rresp;
 wire s_rlast;wire [127:0] s_rdata;wire busy,owner;
 wire avalid,wvalid,wlast,rready,atype;wire [31:0] aaddr;wire [7:0] alen,aid;
 wire [127:0] wdata;
 reg aready=0,wready=0,bvalid=0,rvalid=0,rlast=0,rejected=0;
 reg [7:0] bid=8'h22,rid=8'h22;reg [1:0] bresp=0,rresp=0;reg [127:0] rdata=0;
 m5c_bg_mux dut(.*);
 integer checks=0,k;
 task tick;begin @(posedge clk);#1;end endtask
 task idle;begin @(negedge clk);s_avalid=0;aready=0;rvalid=0;rlast=0;rejected=0;bvalid=0;end endtask
 task check(input bit condition,input [255:0] labeltext);
 begin checks=checks+1;if(!condition)$fatal(1,"C2_ORACLE %0s",labeltext);end endtask
 initial begin
  repeat(3)tick();@(negedge clk);rst_n=1;
  // A late capture request must not replace an already stalled display A.
  @(negedge clk);s_avalid=2;tick();
  @(negedge clk);s_avalid=3;capture_priority=1;
  for(k=0;k<17;k=k+1)begin tick();check(avalid&&aaddr==32'h2000&&!busy,"pending stable");end
  @(negedge clk);aready=1;tick();check(busy&&owner,"display accepted");idle();
  // Intermediate R is not completion; response remains with its owner.
  @(negedge clk);rvalid=1;rdata=128'h123;tick();
  check(busy&&s_rvalid==2&&s_rdata==128'h123,"intermediate R");
  @(negedge clk);rlast=1;s_rready=1;tick();check(busy&&!rready,"last R stalled");
  @(negedge clk);s_rready=3;tick();check(!busy,"real last R drains");idle();
  // Capture wins only at a new selection point.
  @(negedge clk);s_avalid=3;aready=1;tick();check(busy&&!owner,"capture priority");idle();
  @(negedge clk);rejected=1;#1;check(s_rejected==1,"local reject owner");tick();check(!busy,"local reject releases mux");idle();
  // Withdrawing an unaccepted request while READY rises must not create owner.
  @(negedge clk);s_avalid=2;tick();
  @(negedge clk);s_avalid=1;aready=1;#1;check(!avalid,"cancel beats ready");tick();check(!busy,"no orphan acquire");
  tick();check(busy&&!owner,"next capture acquired");idle();
  @(negedge clk);bvalid=1;tick();check(!busy,"actual B drains");idle();
  // Hard stop freezes an accepted owner, never pretends to drain it.
  @(negedge clk);s_avalid=2;aready=1;tick();idle();
  @(negedge clk);stop=1;rvalid=1;rlast=1;tick();
  check(busy&&!rready&&s_rvalid==0&&!avalid,"hard stop retains owner");
  $display("M5C1B_PASS C2 checks=%0d",checks);$finish;
 end
 initial begin #100000;$fatal(1,"C2_TIMEOUT");end
endmodule

// Physical-interface fence test: production reader/transfer plus production
// outer permission arbiter. DDR response beats are driven only on bus pins.
module tb_m5c1b_reader_fences;
 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,stop=0,start=0,abort=0;reg [6:0] permission=0;
 wire busy,drained,fault,commit,sa,sd,rv,rr,ra,rt;wire [31:0] raddr;wire [7:0] rlen,rid_local;
 wire [2:0] car,crv,crlast,crejected;wire [383:0] crdata;wire [23:0] crid;wire [5:0] crresp;
 wire pav,pat,prready;wire [31:0] pa;wire [7:0] plen,pid;
 reg paready=1,prvalid=0,prlast=0;reg [127:0] pdata=0;reg [7:0] prid=0;
 wire arb_busy;integer accepted=0,done_count=0,physical=0,commits=0,i;
 m5c_mask_reader reader(.clk(clk),.rst_n(rst_n),.stop(stop),.start(start),.abort(abort),.slot(1'b0),.session(64'd73),
  .free_banks(8'hff),.busy(busy),.drained(drained),.fault(fault),.commit(commit),
  .segment_accept(sa),.segment_done(sd),.avalid(rv),.aready(car[2]),.aaddr(raddr),.alen(rlen),.aid(rid_local),.atype(rt),
  .rvalid(crv[2]),.rlast(crlast[2]),.rdata(crdata[383:256]),.rid(crid[23:16]),.rresp(crresp[5:4]),.rready(rr),.rejected(crejected[2]));
 m5b1_arbiter arb(.clk(clk),.rst_n(rst_n),.soft_reset(1'b0),.ddr_reset_ack(1'b0),.urgent(2'd0),.safe_window(1'b1),
  .emergency_stop(stop),.epoch(64'd1),.c_epoch({3{64'd1}}),.video_write_permission(4'd0),.video_read_permission(4'd0),
  .bg_write_permission(7'd0),.bg_read_permission(permission),.c_avalid({rv,2'd0}),.c_aready(car),.c_aaddr({raddr,64'd0}),
  .c_alen({rlen,16'd0}),.c_aid({rid_local,16'd0}),.c_atype({rt,2'd0}),.c_wvalid(3'd0),.c_wlast(3'd0),.c_wdata(384'd0),.c_wstrb(48'd0),
  .c_bready(3'b111),.c_rvalid(crv),.c_rlast(crlast),.c_rready({rr,2'd0}),.c_rdata(crdata),.c_rid(crid),.c_rresp(crresp),
  .rejected(crejected),.busy(arb_busy),.aid(pid),.alen(plen),.aaddr(pa),.avalid(pav),.atype(pat),.aready(paready),
  .wready(1'b0),.bid(8'd0),.bresp(2'd0),.bvalid(1'b0),.rid(prid),.rresp(2'd0),.rdata(pdata),.rlast(prlast),.rvalid(prvalid),.rready(prready));
 always @(posedge clk)if(rst_n)begin
  if(sa)accepted=accepted+1;if(sd)done_count=done_count+1;if(pav&&paready)physical=physical+1;if(commit)commits=commits+1;
 end
 task reset_case;begin
  @(negedge clk);rst_n=0;stop=0;abort=0;start=0;prvalid=0;prlast=0;
  repeat(4)@(negedge clk);accepted=0;done_count=0;physical=0;commits=0;rst_n=1;repeat(4)@(negedge clk);
 end endtask
 task launch;begin start=1;@(negedge clk);start=0;end endtask
 initial begin
  reset_case;permission=0;launch;wait(fault);repeat(6)@(negedge clk);
  if(accepted!=0||done_count!=0||physical!=0||commits!=0||!drained)$fatal(1,"READER_PERMISSION_IS_NOT_ACCEPT");
  reset_case;permission=7'b0010001;launch;wait(pav);@(posedge clk);#1;prid=pid;
  for(i=0;i<20;i=i+1)begin
   @(negedge clk);prvalid=1;prlast=i==19;pdata=i;if(i==4)abort=1;
   @(posedge clk);if(!prready)$fatal(1,"READER_REAL_R_READY");#1;
   if(i<19&&(done_count!=0||drained))$fatal(1,"READER_FINAL_R_FENCE");
  end
  @(negedge clk);prvalid=0;prlast=0;repeat(10)@(negedge clk);
  if(accepted!=1||done_count!=1||physical!=1||commits!=0||!drained||fault)$fatal(1,"READER_ABORT_DRAIN");
  reset_case;permission=7'b0010001;launch;wait(pav);@(posedge clk);#1;prid=pid;
  @(negedge clk);stop=1;prvalid=1;prlast=1;repeat(8)@(negedge clk);
  if(!arb_busy||!busy||drained||done_count||!accepted||prready)$fatal(1,"READER_HARD_STOP_OWNER");
  $display("M5C1B_PASS reader physical permission reject finalR abort hardstop fences");$finish;
 end
 initial begin #100000;$fatal(1,"READER_FENCE_TIMEOUT");end
endmodule
