`timescale 1ns/1ps
// Bounded service diagnosis. Real datapath modules; synthetic, explicitly labelled RT demand.
module tb_pair_fifo_service;
 parameter CASE=0;
 reg ui=0,pix=0,rst=0;always #5.208333 ui=~ui;always #6.720430 pix=~pix;
 reg select_pair=0,ack=0,reader_start=0,sof=0,de=0;reg [11:0] x=0,y=0;reg [63:0] ticks=0;
 integer cycles=0,pixels=0,produced=0,popped=0,max_wc=0,consumed_rows=0,fd;
 integer cA=0,cB=0,cW=0,rA=0,rDone=0,rt0A=0,rt1A=0,rt0D=0,rt1D=0,maxwait=0,waitage=0;
 integer blocked_safe=0,blocked_busy=0,blocked_mux=0;reg diagnosed=0;
 wire arm,cancel,armbusy,done,take,empty,pop;wire [31:0] reason;wire [9:0] count;wire [127:0] cap_data;wire [1:0] resetdone,ffault;
 wire ts,tw,tc,tbusy,tdone,terr,trb,twb;wire [31:0] ta;wire [7:0] tl,tbeat;wire [127:0] tdata;
 wire cw,mw,cr,mr,rr,hold;wire [31:0] failure;
 wire bw;wire [4:0] bwa,bra;wire [127:0] bwd;reg [127:0] brd,bufmem[0:31];
 wire [1:0] sa,sar,sw,swl,swr,sbv,srv,srej,srr;wire [63:0] saa;wire [15:0] sal,sai;wire [1:0] sat;wire [255:0] swd;
 wire [7:0] sbid,srid;wire [1:0] sbr,srp;wire srl;wire [127:0] srd;
 wire ba,bar,bwvalid,bwlast,bwready,bbvalid,brvalid,brlast,brready,brejected,bat;wire [31:0] baa;wire [7:0] bal,bai,bbid,brid;wire [1:0] bbr,brp;wire [127:0] bwdout,brdata;
 wire reader_busy,reader_drained,reader_fault,reader_commit;wire [11:0] reader_row;wire [7:0] free_banks=(reader.row<consumed_rows+8)?8'hff:0;
 reg [2:0] rt0state=0,rt1state=0;reg [7:0] rt0beat=0;reg rt_enabled=0;
 wire [2:0] ca,car,cwvalid,cwlast,cwready,cbvalid,crvalid,crlast,crready,rejected;
 wire [95:0] cad;wire [23:0] cal,cai,cbid,crid;wire [5:0] cbresp,crresp;wire [383:0] cwd,crd;
 wire avalid,aready,atype,wvalid,wready,wlast,bvalid,bready,rvalid,rready,rlast;wire [31:0] aaddr;wire [7:0] aid,alen,wid,bid,rid;wire [2:0] asize;wire [1:0] aburst,alock,bresp,rresp;wire [127:0] wdata,rdata;wire [15:0] wstrb;
 wire quarantine,reset_request,arb_busy;wire [31:0] accepted,completed,maxservice;wire [223:0] errors;
 reg [31:0] physical_address=0;reg physical_write=0;reg [1:0] physical_owner=0;integer starts=0,physical_age=0;
 m5c_pair_capture capture(.ui_clk(ui),.pix_clk(pix),.arst_n(rst),.arm(arm),.arm_session(64'd75),.cancel(cancel),.arm_busy(armbusy),.done_valid(done),.done_reason(reason),.done_take(take),
 .source_tap_valid(sof||de),.source_tap_qualified(1'b1),.ce(1'b1),.frame_sof(sof),.frame_admit(1'b1),.mode_cov(1'b1),.fusion_enabled(1'b1),.kill(1'b0),.identity_ok(1'b1),.session(64'd75),.current_source_frame(64'd59),.display_seq(64'd75),.pixel_ticks(ticks),
 .final_de(de),.final_x(x),.final_y(y),.final_class(2'd0),.support(1'b1),.local_edge(1'b0),.accepted_domain(1'b0),.row_complete(1'b1),.row_tag(1'b1),.data(cap_data),.empty(empty),.pop(pop),.count(count),.reset_done(resetdone),.fifo_faults(ffault));
 m5c_pair_controller controller(.clk(ui),.rst_n(rst),.stop(1'b0),.select(select_pair),.wait_expired(1'b0),.acquire_ack(ack),.acquire_denied(1'b0),.descriptor(768'd0),.identity(320'd0),.session(64'd75),.token(64'd1),.slot(1'b0),.fusion_release(1'b0),.fusion_retire(1'b0),.held(1'b1),.hold(hold),.arm(arm),.cancel_capture(cancel),.cap_arm_busy(armbusy),.cap_done(done),.cap_reason(reason),.cap_take(take),.cap_empty(empty),.cap_count(count),.cap_data(cap_data),.cap_pop(pop),
 .tx_start(ts),.tx_write(tw),.tx_cancel(tc),.tx_addr(ta),.tx_len(tl),.tx_data(tdata),.tx_busy(tbusy),.tx_done(tdone),.tx_error(terr),.tx_read_beat(trb),.tx_write_beat(twb),.tx_beat(tbeat),.rdata(srd),.buffer_write(bw),.buffer_write_address(bwa),.buffer_read_address(bra),.buffer_write_data(bwd),.buffer_read_data(brd),.payload_ready(1'b0),.packet_done(1'b0),.packet_busy(1'b0),.current_write(cw),.metadata_write(mw),.current_read(cr),.metadata_read(mr),.reference_read(rr),.failure(failure));
 always @(posedge ui)begin if(bw)bufmem[bwa]<=bwd;brd<=bufmem[bra];end
 m5b1_transfer transfer(.clk(ui),.rst_n(rst),.stop(1'b0),.start(ts),.cancel(tc),.write_op(tw),.address(ta),.length(tl),.busy(tbusy),.done(tdone),.error(terr),.beat(tbeat),.read_beat(trb),.write_beat(twb),.avalid(sa[0]),.aready(sar[0]),.aaddr(saa[31:0]),.alen(sal[7:0]),.aid(sai[7:0]),.atype(sat[0]),.source_data(tdata),.wdata(swd[127:0]),.wvalid(sw[0]),.wlast(swl[0]),.wready(swr[0]),.bvalid(sbv[0]),.bid(sbid),.bresp(sbr),.rvalid(srv[0]),.rlast(srl),.rid(srid),.rresp(srp),.rready(srr[0]),.rejected(srej[0]));
 m5c_mask_reader reader(.clk(ui),.rst_n(rst),.stop(1'b0),.start(reader_start),.abort(1'b0),.slot(1'b0),.session(64'd75),.free_banks(free_banks),.busy(reader_busy),.drained(reader_drained),.fault(reader_fault),.commit(reader_commit),.commit_row(reader_row),.avalid(sa[1]),.aready(sar[1]),.aaddr(saa[63:32]),.alen(sal[15:8]),.aid(sai[15:8]),.atype(sat[1]),.rvalid(srv[1]),.rlast(srl),.rdata(srd),.rid(srid),.rresp(srp),.rready(srr[1]),.rejected(srej[1]));
 assign sw[1]=0;assign swl[1]=0;assign swd[255:128]=0;
 m5c_bg_mux mux(.clk(ui),.rst_n(rst),.stop(1'b0),.capture_priority(1'b0),.s_avalid(sa),.s_aready(sar),.s_aaddr(saa),.s_alen(sal),.s_aid(sai),.s_atype(sat),.s_wvalid(sw),.s_wlast(swl),.s_wdata(swd),.s_wready(swr),.s_bvalid(sbv),.s_bid(sbid),.s_bresp(sbr),.s_rvalid(srv),.s_rlast(srl),.s_rdata(srd),.s_rid(srid),.s_rresp(srp),.s_rready(srr),.s_rejected(srej),.avalid(ba),.aready(bar),.aaddr(baa),.alen(bal),.aid(bai),.atype(bat),.wvalid(bwvalid),.wlast(bwlast),.wdata(bwdout),.wready(bwready),.bvalid(bbvalid),.bid(bbid),.bresp(bbr),.rvalid(brvalid),.rlast(brlast),.rdata(brdata),.rid(brid),.rresp(brp),.rready(brready),.rejected(brejected));
 assign ca={ba,rt1state==1,rt0state==1};assign cad={baa,32'h00400000,32'h00000000};assign cal={bal,8'd127,8'd127};assign cai={bai,8'h11,8'h01};assign cwvalid={bwvalid,1'b0,rt0state==2};assign cwlast={bwlast,1'b0,rt0beat==127};assign cwd={bwdout,128'd0,128'h01010101010101010101010101010101};assign crready={brready,2'b11};
 assign bar=car[2];assign bwready=cwready[2];assign bbvalid=cbvalid[2];assign bbid=cbid[23:16];assign bbr=cbresp[5:4];assign brvalid=crvalid[2];assign brlast=crlast[2];assign brdata=crd[383:256];assign brid=crid[23:16];assign brp=crresp[5:4];assign brejected=rejected[2];
 m5c_pair_arbiter arb(.clk(ui),.rst_n(rst),.soft_reset(1'b0),.ddr_reset_ack(1'b0),.urgent(2'd0),.safe_window(1'b1),.emergency_stop(1'b0),.epoch(64'd1),.c_epoch({64'd1,64'd1,64'd1}),.video_write_permission(4'hf),.video_read_permission(4'hf),.bg_write_permission(7'h7f),.bg_read_permission(7'h7f),.pair_write_permission({mw,cw}),.pair_read_permission({mr,cr}),.error_counts(errors),.quarantine(quarantine),.reset_request(reset_request),.busy(arb_busy),
 .c_avalid(ca),.c_aready(car),.c_aaddr(cad),.c_alen(cal),.c_aid(cai),.c_atype({bat,2'b01}),.c_wvalid(cwvalid),.c_wlast(cwlast),.c_wready(cwready),.c_wdata(cwd),.c_wstrb({48{1'b1}}),.c_bvalid(cbvalid),.c_bready(3'b111),.c_bid(cbid),.c_bresp(cbresp),.c_rvalid(crvalid),.c_rlast(crlast),.c_rready(crready),.c_rdata(crd),.c_rid(crid),.c_rresp(crresp),.rejected(rejected),
 .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),.wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),.rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
 m5c1b_ddr_service_model #(.WORDS(32'h011e2000/16)) mem(.clk(ui),.rst_n(rst),.stall(1'b0),.aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),.wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),.rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready),.service_delay(32'd384),.inject_b_error(1'b0),.inject_r_error(1'b0),.accepted(accepted),.completed(completed),.max_service(maxservice));
 always @(posedge ui)if(rst)begin
  cycles=cycles+1;
  if(rt_enabled&&CASE>=2&&rt0state==0&&cycles%2987==0)rt0state<=1;
  if(rt_enabled&&CASE>=2&&rt1state==0&&cycles%3548==0)rt1state<=1;
  if(ca[0]&&car[0])begin rt0state<=2;rt0beat<=0;rt0A=rt0A+1;end
  if(cwvalid[0]&&cwready[0])begin if(rt0beat==127)rt0state<=3;else rt0beat<=rt0beat+1'b1;end
  if(cbvalid[0])begin rt0state<=0;rt0D=rt0D+1;end
  if(ca[1]&&car[1])begin rt1state<=2;rt1A=rt1A+1;end
  if(crvalid[1]&&crlast[1])begin rt1state<=0;rt1D=rt1D+1;end
  if(sa[0]&&!sar[0])begin waitage=waitage+1;if(waitage>maxwait)maxwait=waitage;if(mux.busy||mux.pending&&mux.pending_owner)blocked_mux=blocked_mux+1;if(arb_busy)blocked_busy=blocked_busy+1;end else waitage=0;
  if(pop)begin if(empty)$fatal(1,"SERVICE_FIFO_UNDERFLOW");popped=popped+1;end
  if(sar[0]&&sa[0])cA=cA+1;if(sbv[0])cB=cB+1;
  if(sa[1]&&sar[1])rA=rA+1;if(srv[1]&&srr[1]&&srl)rDone=rDone+1;
  if(avalid&&aready)begin physical_address=aaddr;physical_write=atype;physical_owner=arb.owner;physical_age=0;starts=starts+1;$fdisplay(fd,"A %0d owner=%0d addr=%h len=%0d write=%b wc=%0d rc=%0d row=%0d",cycles,arb.owner,aaddr,alen,atype,capture.wc,count,y);end
  if(arb_busy)physical_age=physical_age+1;
  if(wvalid&&wready&&physical_address>=32'h01100000&&physical_address<32'h011e1000)begin cW=cW+1;if(wdata!=={16{8'h04}})$fatal(1,"SERVICE_CAPTURE_PAYLOAD_CORRUPT");end
  if(bvalid&&bready||rvalid&&rready&&rlast)$fdisplay(fd,"T %0d owner=%0d write=%b age=%0d wc=%0d rc=%0d",cycles,physical_owner,physical_write,physical_age,capture.wc,count);
  if(quarantine||reset_request||errors!=0||ffault!=0||reader_fault||terr)$fatal(1,"SERVICE_PROTOCOL_ERROR");
 end
 always @(posedge pix)if(rst)begin
  ticks<=ticks+1;
  if(capture.push)produced=produced+1;
  if(capture.wc>max_wc)max_wc=capture.wc;
  if(de&&capture.state==capture.CAPTURE)pixels=pixels+1;
  if(de&&x==1279)consumed_rows=y+1;
  if(capture.state==capture.CAPTURE&&de&&capture.position[3:0]==15&&!capture.can_push)begin
   $fdisplay(fd,"FULL t=%0t cycle=%0d pixels=%0d x=%0d y=%0d wc=%0d rc=%0d produced=%0d popped=%0d cA=%0d cB=%0d cW=%0d rA=%0d rt0=%0d rt1=%0d muxbusy=%b muxowner=%b pending=%b pendingowner=%b arbstate=%0d arbowner=%0d",$time,cycles,pixels,x,y,capture.wc,count,produced,popped,cA,cB,cW,rA,rt0A,rt1A,mux.busy,mux.owner,mux.pending,mux.pending_owner,arb.state,arb.owner);$fflush(fd);
  end
 end
 integer row,col;
 initial begin
  fd=$fopen("events.txt","w");repeat(12)@(negedge ui);rst=1;wait(&resetdone);repeat(8)@(negedge ui);
  if(CASE>=1)begin reader_start=1;@(negedge ui);reader_start=0;wait(reader.row==8);end
  @(negedge ui);select_pair=1;@(negedge ui);select_pair=0;ack=1;@(negedge ui);ack=0;
  wait(capture.state==capture.WAIT);@(negedge pix);sof=1;@(negedge pix);sof=0;repeat(1652)@(negedge pix);rt_enabled=1;
  for(row=0;row<720;row=row+1)begin
   for(col=0;col<1280;col=col+1)begin @(negedge pix);de=1;x=col;y=row;end
   @(negedge pix);de=0;repeat(369)@(negedge pix);
  end
  wait(done||controller.producer_done);repeat(1000)@(negedge ui);
  $display("SERVICE_DIAG_COMPLETE case=%0d reason=%0d pixels=%0d produced=%0d popped=%0d maxwc=%0d cA=%0d cB=%0d cW=%0d rA=%0d rDone=%0d rt0=%0d/%0d rt1=%0d/%0d maxwait=%0d blockedMux=%0d blockedBusy=%0d maxservice=%0d",CASE,controller.producer_reason,pixels,produced,popped,max_wc,cA,cB,cW,rA,rDone,rt0A,rt0D,rt1A,rt1D,maxwait,blocked_mux,blocked_busy,maxservice);
  if(CASE==0&&(controller.producer_reason!=0||pixels!=921600||cB!=1801))$fatal(1,"SERVICE_BASELINE_INCOMPLETE");
  $fclose(fd);$finish;
 end
 initial begin #40000000;$fatal(1,"SERVICE_DIAG_WATCHDOG");end
endmodule

