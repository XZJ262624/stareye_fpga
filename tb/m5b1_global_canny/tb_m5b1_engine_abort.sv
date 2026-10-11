`timescale 1ns/1ps
// Actual transfer + actual arbiter. Independent ownership and payload ledger.
module tb_m5b1_engine_abort;
 reg clk=0,rst_n=0,safe_window=1,eng_start=0;wire start,cancel,write_op;
 always #5 clk=~clk;
 wire [31:0] address;wire [7:0] length;wire [127:0] source_data;wire eng_busy,eng_finished,eng_failed,eng_published;reg [319:0] desc;
 wire tx_busy,done,error,cancelled,ta,tw,tl,tr,read_beat,write_beat;
 wire [31:0] taddr;wire [7:0] tlen,tid,index;wire tty;wire [127:0] td;
 wire [2:0] car,cwr,cb,cr,crl,rejected;wire [23:0] cbi,cri;wire [5:0] cbr,crp;wire [383:0] crd;
 wire [7:0] aid,alen,wid;wire [31:0] aaddr;wire [2:0] asize;wire [1:0] aburst,alock;
 wire avalid,atype,wlast,wvalid,bready,rready;wire [127:0] wdata;wire [15:0] wstrb;
 reg aready=0,wready=0,bvalid=0,rvalid=0,rlast=0;reg [7:0] bid=0,rid=0;reg [127:0] rdata=0;
 reg hold_a=0,hold_w=0,hold_b=0,hold_r=0,hold_last=0;
 wire arb_busy,quarantine,reset_request;wire [31:0] accepts,completes,rejects;
 function [127:0] token(input integer n);begin token={32'h01234567,32'h89abcdef,32'hfeedface,32'h13579bdf^n};end endfunction
 m5b1_global_engine #(.WIDTH(128),.HEIGHT(32),.WALL_CYCLES(1000000)) engine(
 .clk(clk),.rst_n(rst_n),.stop(1'b0),.start(eng_start),.descriptor(desc),.class_base(32'h01000000),.result_available(2'b11),
 .busy(eng_busy),.finished(eng_finished),.failed(eng_failed),.published(eng_published),.result_reserved(),.result_slot(),.published_descriptor(),
 .pairs(),.scans(),.elapsed(),.changed_pixels(),.tx_start(start),.tx_write(write_op),.tx_cancel(cancel),.tx_address(address),.tx_length(length),
 .tx_busy(tx_busy),.tx_done(done),.tx_error(error),.tx_beat(index),.tx_read_beat(read_beat),.tx_write_beat(write_beat),.tx_rdata(crd[383:256]),.tx_wdata(source_data));
 m5b1_transfer transfer(.clk(clk),.rst_n(rst_n),.stop(1'b0),.start(start),.cancel(cancel),.write_op(write_op),
  .address(address),.length(length),.busy(tx_busy),.done(done),.error(error),.cancelled(cancelled),.beat(index),.read_beat(read_beat),.write_beat(write_beat),
  .avalid(ta),.aready(car[2]),.aaddr(taddr),.alen(tlen),.aid(tid),.atype(tty),.source_data(source_data),.wdata(td),.wvalid(tw),.wlast(tl),.wready(cwr[2]),
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
 reg read_class;reg [31:0] bus_address;reg [7:0] saved_id;reg astall=0,wstall=0;reg [52:0] aheld;reg [152:0] wheld;
 always @(negedge clk)if(rst_n)begin
  aready=ms==0&&!hold_a;wready=ms==1&&!hold_w;
  if(ms==2&&!rvalid&&!hold_r&&!(hold_last&&mb==ml))begin rid=saved_id;rdata=read_class?{64{2'b10}}:{128{1'b1}};rlast=mb==ml;rvalid=1;end
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
   commands=commands+1;bus_address=aaddr;read_class=aaddr<32'h01039000;ms=atype?1:2;mb=0;ml=alen;saved_id=aid;logical_base=(aaddr-address)/16;
  end
  if(wvalid&&wready)begin
   if(ms!=1||wlast!=(mb==ml)||(bus_address<32'h010e6000&&wdata!=={128{1'b1}})||(bus_address==32'h010e6000&&mb==0&&wdata!==desc[127:0])||(bus_address==32'h010e6000&&mb==1&&wdata!==desc[255:128]))$fatal(1,"CANCEL_OWNED_PAYLOAD_CORRUPT");
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
 integer target,k;
 initial begin
  desc=320'h0123456789abcdef_fedcba9876543210_8877665544332211_1122334455667788_9988776655443322;
  for(k=0;k<4;k=k+1)begin
   rst_n=0;repeat(4)@(negedge clk);rst_n=1;repeat(8)@(negedge clk);
   case(k)0:target=5;1:target=15;2:target=21;3:target=23;endcase
   eng_start=1;@(negedge clk);eng_start=0;
   wait(engine.state==target&&avalid);#0.02;hold_w=k!=3;
   if(k==3)begin wait(index==2&&wvalid);#0.02;hold_w=1;end
   else wait(wvalid);
   // Metadata elapsed must be frozen even BEFORE timeout occurs.
   repeat(20)@(negedge clk);
   force engine.elapsed=1000000;
   @(posedge clk);#0.02;release engine.elapsed;
   repeat(20)@(negedge clk);
   if(!eng_busy||!tx_busy||eng_finished||eng_published||engine.state!=24)$fatal(1,"ABORT_DID_NOT_RETAIN_OWNED_WRITE");
   hold_w=0;wait(eng_finished);#0.02;
   if(!eng_failed||eng_published||tx_busy||arb_busy||ms!=0)$fatal(1,"ABORT_BEFORE_REAL_B");
   cases=cases+1;repeat(6)@(negedge clk);
  end
  $display("REVIEW_PASS engine_abort write_sources=%0d metadata_stall=1 abort_payload_preserved=1 DDR=%0d completed=%0d",cases,commands,finished_bus);$finish;
 end
 initial begin #10000000;$fatal(1,"engine abort watchdog state=%0d transfer=%0d ms=%0d cases=%0d",engine.state,transfer.state,ms,cases);end
endmodule
