`timescale 1ns/1ps
// Actual transfer + actual arbiter. Independent ownership and payload ledger.
module tb_m5b1_transfer_cancel;
 reg clk=0,rst_n=0,start=0,cancel=0,write_op=1,safe_window=1;
 always #5 clk=~clk;
 reg [31:0] address=32'h01000000;reg [7:0] length=3;
 wire tx_busy,done,error,cancelled,ta,tw,tl,tr,read_beat,write_beat;
 wire [31:0] taddr;wire [7:0] tlen,tid,index;wire tty;wire [127:0] td;
 wire [2:0] car,cwr,cb,cr,crl,rejected;wire [23:0] cbi,cri;wire [5:0] cbr,crp;wire [383:0] crd;
 wire [7:0] aid,alen,wid;wire [31:0] aaddr;wire [2:0] asize;wire [1:0] aburst,alock;
 wire avalid,atype,wlast,wvalid,bready,rready;wire [127:0] wdata;wire [15:0] wstrb;
 reg aready=0,wready=0,bvalid=0,rvalid=0,rlast=0;reg [7:0] bid=0,rid=0;reg [127:0] rdata=0;
 reg hold_a=0,hold_w=0,hold_b=0,hold_r=0,hold_last=0;
 wire arb_busy,quarantine,reset_request;wire [31:0] accepts,completes,rejects;
 function [127:0] token(input integer n);begin token={32'h01234567,32'h89abcdef,32'hfeedface,32'h13579bdf^n};end endfunction
 m5b1_transfer transfer(.clk(clk),.rst_n(rst_n),.stop(1'b0),.start(start),.cancel(cancel),.write_op(write_op),
  .address(address),.length(length),.busy(tx_busy),.done(done),.error(error),.cancelled(cancelled),.beat(index),.read_beat(read_beat),.write_beat(write_beat),
  .avalid(ta),.aready(car[2]),.aaddr(taddr),.alen(tlen),.aid(tid),.atype(tty),.source_data(token(index)),.wdata(td),.wvalid(tw),.wlast(tl),.wready(cwr[2]),
  .bvalid(cb[2]),.bid(cbi[23:16]),.bresp(cbr[5:4]),.rvalid(cr[2]),.rlast(crl[2]),.rid(cri[23:16]),.rresp(crp[5:4]),.rready(tr),.rejected(rejected[2]));
 m5b1_arbiter #(.BG_REFILL(2)) arbiter(.clk(clk),.rst_n(rst_n),.soft_reset(1'b0),.ddr_reset_ack(1'b0),.urgent(2'b0),.safe_window(safe_window),
  .emergency_stop(1'b0),.epoch(64'd1),.c_epoch({64'd1,64'd1,64'd1}),.video_write_permission(4'hf),.video_read_permission(4'hf),.bg_write_permission(7'h7f),.bg_read_permission(7'h7f),
  .max_wait(),.max_service(),.qos_exceeded(),.error_counts(),.accepts(accepts),.completes(completes),.rejects(rejects),
  .c_avalid({ta,2'b0}),.c_aready(car),.c_aaddr({taddr,64'b0}),.c_alen({tlen,16'b0}),.c_aid({tid,16'b0}),.c_atype({tty,2'b0}),
  .c_wvalid({tw,2'b0}),.c_wlast({tl,2'b0}),.c_wready(cwr),.c_wdata({td,256'b0}),.c_wstrb(48'hffffffffffff),
  .c_bvalid(cb),.c_bready(3'b111),.c_bid(cbi),.c_bresp(cbr),.c_rvalid(cr),.c_rlast(crl),.c_rready({tr,2'b11}),.c_rdata(crd),.c_rid(cri),.c_rresp(crp),
  .rejected(rejected),.quarantine(quarantine),.reset_request(reset_request),.error_reason(),.busy(arb_busy),
  .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),
  .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(2'b0),.bvalid(bvalid),.bready(bready),
  .rid(rid),.rresp(2'b0),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
 integer ms=0,mb=0,ml=0,logical_base=0,commands=0,finished_bus=0,owned=0,retired=0,rejected_count=0;
 integer terminals=0,cancel_terminals=0,started=0,cases=0,saved_commands,saved_accepts;
 reg [7:0] saved_id;reg astall=0,wstall=0;reg [52:0] aheld;reg [152:0] wheld;
 always @(negedge clk)if(rst_n)begin
  aready=ms==0&&!hold_a;wready=ms==1&&!hold_w;
  if(ms==2&&!rvalid&&!hold_r&&!(hold_last&&mb==ml))begin rid=saved_id;rdata=token(logical_base+mb);rlast=mb==ml;rvalid=1;end
  if(ms==3&&!bvalid&&!hold_b)begin bid=saved_id;bvalid=1;end
 end
 always @(posedge clk)if(rst_n)begin
  if(quarantine||reset_request)$fatal(1,"unexpected protocol quarantine");
  if(astall&&{aid,aaddr,alen,asize,atype,avalid}!==aheld)$fatal(1,"CANCEL_OWNED_A_CHANGED");
  if(wstall&&{wid,wstrb,wlast,wvalid,wdata}!==wheld)$fatal(1,"CANCEL_OWNED_W_CHANGED");
  astall=avalid&&!aready;aheld={aid,aaddr,alen,asize,atype,avalid};
  wstall=wvalid&&!wready;wheld={wid,wstrb,wlast,wvalid,wdata};
  if(ta&&car[2])owned=owned+1;
  if(rejected[2])rejected_count=rejected_count+1;
  if(cb[2]||(cr[2]&&tr&&crl[2]))retired=retired+1;
  if(cancel&&transfer.state<=1&&(ta||car[2]))$fatal(1,"CANCEL_NOT_ATOMIC");
  if(avalid&&aready)begin
   if(ms!=0||(aaddr&4095)+(alen+1)*16>4096)$fatal(1,"bad owned address");
   commands=commands+1;ms=atype?1:2;mb=0;ml=alen;saved_id=aid;logical_base=(aaddr-address)/16;
  end
  if(wvalid&&wready)begin
   if(ms!=1||wdata!==token(logical_base+mb)||wlast!=(mb==ml))$fatal(1,"CANCEL_OWNED_PAYLOAD_CORRUPT");
   if(mb==ml)ms=3;else mb=mb+1;
  end
  if(bvalid&&bready)begin bvalid<=0;ms=0;finished_bus=finished_bus+1;end
  if(rvalid&&rready)begin rvalid<=0;if(mb==ml)begin ms=0;finished_bus=finished_bus+1;end else mb=mb+1;end
  if(commands!=finished_bus+(ms!=0))$fatal(1,"DDR conservation");
  if(done)begin terminals=terminals+1;if(cancelled)cancel_terminals=cancel_terminals+1;end
  // Arbiter client response registers are sampled before its next NBA clear.
  #0.01;
  if(accepts!=completes+rejects+arb_busy)$fatal(1,"client conservation");
 end
 task launch(input wr,input [31:0] addr,input [7:0] len);
 begin
  @(negedge clk);write_op=wr;address=addr;length=len;start=1;started=started+1;
  @(negedge clk);start=0;
 end endtask
 task terminal(input expect_cancel,input expect_error);
 begin
  wait(done);#0.01;
  if(tx_busy||cancelled!==expect_cancel||error!==expect_error)$fatal(1,"CANCEL_TERMINAL_MISMATCH");
  @(negedge clk);cancel=0;repeat(6)@(negedge clk);
  if(terminals!=started)$fatal(1,"duplicate/lost terminal");cases=cases+1;
 end endtask
 initial begin
  repeat(4)@(negedge clk);rst_n=1;repeat(6)@(negedge clk);
  // launch/cancel same edge: no busy or downstream command is created.
  cancel=1;launch(1,32'h01000000,3);terminal(1,1);if(commands)$fatal(1,"cancelled start launched DDR");
  safe_window=0;launch(1,32'h01000000,3);repeat(20)@(negedge clk);
  saved_commands=commands;cancel=1;terminal(1,1);if(commands!=saved_commands)$fatal(1,"denied cancel launched DDR");
  // READY becomes available at the cancellation edge; cancellation wins.
  safe_window=0;launch(0,32'h01000000,3);repeat(4)@(negedge clk);safe_window=1;cancel=1;terminal(1,1);
  if(commands!=saved_commands)$fatal(1,"cancel/READY orphan");
  // Client accepted but DDR A still stalled: cancellation must retain A/W.
  hold_a=1;launch(1,32'h01000000,3);wait(avalid);@(negedge clk);cancel=1;
  repeat(12)@(negedge clk);if(!tx_busy||done||!avalid)$fatal(1,"accepted A discarded");hold_a=0;terminal(1,1);
  hold_w=1;launch(1,32'h01000000,3);wait(wvalid);@(negedge clk);cancel=1;
  repeat(12)@(negedge clk);if(!tx_busy||done)$fatal(1,"accepted W discarded");hold_w=0;terminal(1,1);
  hold_b=1;launch(1,32'h01000000,3);wait(ms==3);@(negedge clk);cancel=1;
  repeat(12)@(negedge clk);if(!tx_busy||done)$fatal(1,"pending B discarded");hold_b=0;terminal(1,1);
  hold_last=1;launch(0,32'h01000000,3);wait(ms==2&&mb==3);@(negedge clk);cancel=1;
  repeat(12)@(negedge clk);if(!tx_busy||done)$fatal(1,"last R discarded");hold_last=0;terminal(1,1);
  // Complete first 4KiB segment, then cancel the queued remainder.
  launch(1,32'h01000ff0,3);wait(ms==3);@(negedge clk);safe_window=0;
  wait(transfer.state==1);@(negedge clk);saved_commands=commands;cancel=1;terminal(1,1);
  if(commands!=saved_commands)$fatal(1,"cancelled second segment launched");
  // Illegal client request consumes one rejection; overlap cancel with it.
  safe_window=1;launch(1,32'h010e7000,0);wait(rejected[2]);@(negedge clk);cancel=1;terminal(0,1);
  // Recovery is a fresh real two-segment transfer with exact data and B fence.
  launch(1,32'h01000ff0,3);terminal(0,0);
  if(arb_busy||ms!=0||commands!=finished_bus||owned!=retired+rejected_count)$fatal(1,"final conservation");
  $display("REVIEW_PASS transfer_cancel cases=%0d logical=%0d terminals=%0d cancellations=%0d DDR=%0d completed=%0d rejected=%0d",cases,started,terminals,cancel_terminals,commands,finished_bus,rejected_count);$finish;
 end
 initial begin #200000;$fatal(1,"transfer cancel watchdog state=%0d ms=%0d cases=%0d",transfer.state,ms,cases);end
endmodule
