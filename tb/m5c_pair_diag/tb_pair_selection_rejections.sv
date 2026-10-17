`timescale 1ns/1ps
// Actual transfer + actual arbiter. Independent ownership and payload ledger.
module tb_pair_selection_rejections;
 parameter CASE=0,EXPORT_LIMIT=2000,FENCE=0;
 reg send_normal=0,send_diag=0;wire telemetry_ready,telemetry_pending;
 reg frame_done=0;reg [479:0] pixel_snapshot=0;wire [319:0] telemetry_header;wire [7:0] telemetry_byte;wire [8:0] telemetry_index;wire telemetry_take,telemetry_fault;
 wire pair_take,pair_busy;wire [63:0] pair_sid,active_sid;wire [767:0] active_desc;
 reg [63:0] normal_sid=64'h1234000000000007,diag_sid=64'h1234000000000007;
 wire session_fault;wire [767:0] offer_desc;wire [63:0] offer_sid;
 wire offer_valid;
 reg run_enable=1;wire fusion_acquire,fusion_release,fusion_retire,fusion_slot;wire [319:0] fusion_identity;wire [63:0] fusion_token;wire fusion_ack,fusion_denied,lease_fault;wire [3:0] pair_leased;
 reg clk=0,pix=0,rst_n=0,safe_window=1;always #6 pix=~pix;
 always #5 clk=~clk;
 wire request_pair;reg cap_done=0;wire cap_take;reg [63:0] sid=64'h1234000000000007;
 wire [767:0] result_desc;
 wire [31:0] address;wire [7:0] length;reg rt_req=0,rt_busy=0;integer rt_completed=0,rt_tick=0;
 wire tx_busy,done,error,cancelled,ta,tw,tl,tr,read_beat,write_beat;
 wire [31:0] taddr;wire [7:0] tlen,tid,index;wire tty;wire [127:0] td;
 assign address=taddr;assign length=tlen;
 wire [2:0] car,cwr,cb,cr,crl,rejected;wire [23:0] cbi,cri;wire [5:0] cbr,crp;wire [383:0] crd;
 wire [7:0] aid,alen,wid;wire [31:0] aaddr;wire [2:0] asize;wire [1:0] aburst,alock;
 wire avalid,atype,wlast,wvalid,bready,rready;wire [127:0] wdata;wire [15:0] wstrb;
 reg aready=0,wready=0,bvalid=0,rvalid=0,rlast=0;reg [7:0] bid=0,rid=0;reg [127:0] rdata=0;
 reg hold_a=0,hold_w=0,hold_b=0,hold_r=0,hold_last=0;
 wire arb_busy,quarantine,reset_request;wire [31:0] accepts,completes,rejects;
 function [127:0] token(input integer n);begin token={32'h01234567,32'h89abcdef,32'hfeedface,32'h13579bdf^n};end endfunction
 reg tap_valid=0;reg [11:0] tap_x=0,tap_y=0;wire [6:0] wp,rp;wire uart;
 m5c_pair_backend #(.REQUEST_CYCLES(5000000),.EXPORT_CYCLES(EXPORT_LIMIT)) backend(.pair_local_rst_n(rst_n),.pair_request(request_pair),.pair_request_session(pair_sid),.pair_request_take(pair_take),.pair_wait_expired(1'b0),.active_pair_descriptor(active_desc),.pair_session(active_sid),.pair_arm_busy(1'b0),.pair_done(cap_done),.pair_done_take(cap_take),.pair_reason(32'd2),.pair_empty(1'b1),.pair_count(10'd0),.pair_data(128'd0),.ui_clk(clk),.pix_clk(pix),.rst_n(rst_n),.run(run_enable),.stop(1'b0),.epoch(64'd1),
 .tap_valid(tap_valid),.tap_class(2'b0),.tap_x(tap_x),.tap_y(tap_y),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),
 .tap_frame_id(64'd7),.tap_epoch(64'd1),.tap_timestamp(64'd99),.tap_display_seq(64'd1),.tap_config_generation(64'd0),
 .fusion_acquire(fusion_acquire),.fusion_slot(fusion_slot),.fusion_identity(fusion_identity),.fusion_token(fusion_token),.fusion_release(fusion_release),.fusion_retire(fusion_retire),.fusion_read_accept(1'b0),.fusion_read_done(1'b0),.result_descriptor(result_desc),.fusion_ack(fusion_ack),.fusion_denied(fusion_denied),.lease_fault(lease_fault),.pair_leased(pair_leased),
 .telemetry_ready(telemetry_ready),.telemetry_descriptor(telemetry_header),.telemetry_byte(telemetry_byte),.telemetry_index(telemetry_index),.telemetry_take(telemetry_take),.max_wait(96'b0),.max_service(96'b0),.camera_max(14'b0),.display_min(14'b0),
 .system_status(32'b0),.error_counts(224'b0),.video_fifo_faults(4'b0),.uart_tx(uart),.job_busy(),.publish_toggle(),.bg_fault(),.capture_reset_done(),
 .avalid(ta),.aready(car[2]),.aaddr(taddr),.alen(tlen),.aid(tid),.atype(tty),.wdata(td),.wvalid(tw),.wlast(tl),.wready(cwr[2]),
 .bvalid(cb[2]),.bid(cbi[23:16]),.bresp(cbr[5:4]),.rvalid(cr[2]),.rlast(crl[2]),.rdata(crd[383:256]),.rid(cri[23:16]),.rresp(crp[5:4]),.rready(tr),.rejected(rejected[2]),.write_permission(wp),.read_permission(rp));
 defparam backend.packet.uart.CLOCK=960000;
 assign tx_busy=backend.tx_busy;assign done=backend.tx_done;assign error=backend.tx_error;assign cancelled=backend.tx_cancelled;
 assign read_beat=backend.tx_read_beat;assign write_beat=backend.tx_write_beat;assign index=backend.tx_beat;
 m5b1_arbiter #(.BG_REFILL(2)) arbiter(.clk(clk),.rst_n(rst_n),.soft_reset(1'b0),.ddr_reset_ack(1'b0),.urgent(2'b0),.safe_window(safe_window),
  .emergency_stop(1'b0),.epoch(64'd1),.c_epoch({64'd1,64'd1,64'd1}),.video_write_permission(4'hf),.video_read_permission(4'hf),.bg_write_permission(wp),.bg_read_permission(rp),
  .max_wait(),.max_service(),.qos_exceeded(),.error_counts(),.accepts(accepts),.completes(completes),.rejects(rejects),
  .c_avalid({ta,rt_req,1'b0}),.c_aready(car),.c_aaddr({taddr,32'h00400000,32'b0}),.c_alen({tlen,8'd3,8'b0}),.c_aid({tid,8'h11,8'b0}),.c_atype({tty,2'b0}),
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
  if(ms==2&&!rvalid&&!hold_r&&!(hold_last&&mb==ml))begin rid=saved_id;rdata=0;rlast=mb==ml;rvalid=1;end
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
  
  if(avalid&&aready)begin
   if(ms!=0||(aaddr&4095)+(alen+1)*16>4096)$fatal(1,"bad owned address");
   commands=commands+1;ms=atype?1:2;mb=0;ml=alen;saved_id=aid;logical_base=(aaddr-address)/16;
  end
  if(wvalid&&wready)begin
   if(ms!=1||wlast!=(mb==ml))$fatal(1,"CANCEL_OWNED_PAYLOAD_CORRUPT");
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
 integer px,py,uart_file,uart_bytes=0,denied_age=0,deny_bg_commands=0,bg_commands=0,deny_rt=0;
 reg denied=0,saw_queued=0;localparam LIMIT=EXPORT_LIMIT;
 initial uart_file=$fopen("system_uart.hex","w");
 initial begin
  repeat(5)@(negedge clk);rst_n=1;
  repeat(12000)@(negedge pix);
  forever begin
   for(py=0;py<720;py=py+1)for(px=0;px<1280;px=px+1)begin
    @(negedge pix);tap_valid=1;tap_x=px;tap_y=py;
   end
   @(negedge pix);tap_valid=0;repeat(2000)@(negedge pix);
  end
 end
 always @(posedge clk)if(rst_n)begin
  rt_tick<=rt_tick+1;
  if(!rt_busy&&!rt_req&&rt_tick%1024==0)rt_req<=1;
  if(rt_req&&car[1])begin rt_req<=0;rt_busy<=1;end
  if(cr[1]&&crl[1])begin rt_busy<=0;rt_completed=rt_completed+1;end
  if(avalid&&aready&&aid==3)bg_commands=bg_commands+1;
  if(backend.packet.uart.valid&&backend.packet.uart.ready)begin $fdisplay(uart_file,"%02x",backend.packet.uart.data);uart_bytes=uart_bytes+1;end
 end

 m5b1_mailbox #(.WIDTH(64)) pair_box(.sclk(pix),.dclk(clk),.arst_n(rst_n),.send(send_diag),.sdata(diag_sid),.busy(pair_busy),.valid(request_pair),.ddata(pair_sid),.take(pair_take));
 m5c_display_session ds(.ui_clk(clk),.pix_clk(pix),.rst_n(rst_n),.stop(1'b0),
 .request_frame(send_normal),.request_seq(normal_sid),.request_config(result_desc[735:576]),
 .pixel_release(1'b0),.pixel_release_final(1'b0),.pixel_release_session(64'd0),
 .result_valid(backend.result_valid),.result_slot(backend.result_slot),.result_descriptor(result_desc),.export_exclusive(backend.export_exclusive),
 .acquire(fusion_acquire),.lease_slot(fusion_slot),.lease_identity(fusion_identity),.lease_token(fusion_token),
 .acquire_ack(fusion_ack),.acquire_denied(fusion_denied),.pair_leased(pair_leased),.lease_release(fusion_release),.lease_retire(fusion_retire),.session_fault(session_fault),
 .telemetry_pending(telemetry_pending),.telemetry_descriptor(active_desc),.telemetry_session(active_sid),
 .offer_valid(offer_valid),.offer_take(1'b0),.offer_descriptor(offer_desc),.offer_session(offer_sid),
 .context_quiet(1'b1),.context_tail_fault(1'b0),.ce(1'b1),.read_valid(1'b0),.read_x(12'd0),.read_y(12'd0),.read_session(64'd0),
 .retire(1'b0),.retire_row(12'd0),.flush(1'b1),.aready(1'b0),.rvalid(1'b0),.rlast(1'b0),.rdata(128'd0),.rid(8'd0),.rresp(2'd0),.rejected(1'b0));
 integer cycle=0,pubs=0,selected=0,acks=0,consumed=0,stale=0,matching_reject=0,metadata_b=0;
 reg meta_pending=0;integer events;
 initial events=$fopen("events.txt","w");
 always @(posedge pix)if(rst_n&&(send_normal||send_diag))begin
  $fdisplay(events,"PIX t=%0t mode=%0d normal=%b nsid=%h nbusy=%b diag=%b dsid=%h dbusy=%b",$time,CASE>=8?CASE-8:6,send_normal,normal_sid,ds.req_busy,send_diag,diag_sid,pair_busy);$fflush(events);
 end
 always @(posedge clk)if(rst_n)begin
  cycle=cycle+1;
  if(backend.publication_accept)begin pubs=pubs+1;$fdisplay(events,"PUBLICATION t=%0t cycle=%0d job=%0d",$time,cycle,backend.job_id);end
  if(avalid&&aready)meta_pending=(aaddr==32'h010e6000||aaddr==32'h010e6080)&&atype;
  if(bvalid&&bready&&meta_pending)begin metadata_b=metadata_b+1;meta_pending=0;end


  if(session_fault||fusion_denied)$fatal(1,"DIAG_REAL_SESSION_FAULT");
  if(fusion_ack)begin acks=acks+1;if(!pair_leased[fusion_slot?2:0])$fatal(1,"DIAG_ACK_WITHOUT_REAL_LEASE");end
  if(backend.pair_selected)selected=selected+1;
  if(pair_take&&request_pair)begin
   consumed=consumed+1;
   if(pair_sid<active_sid)stale=stale+1;
   else if(backend.pair_selected)begin end
   else if(pair_sid==active_sid&&fusion_acquire)matching_reject=matching_reject+1;
   else $fatal(1,"DIAG_UNCLASSIFIED_CONSUMPTION");
  end
  if(fusion_acquire||fusion_ack||pair_take||backend.pair_selected||ds.req_take)begin
   $fdisplay(events,"UI t=%0t cyc=%0d req=%b pairSID=%h activeSID=%h normalvalid=%b normalSID=%h acq=%b ack=%b fresh=%b eq=%b state=%0d tx=%b eng=%b arm=%b writer=%b packet=%b start=%b hold=%b terminal=%b selected=%b take=%b pending=%b",$time,cycle,request_pair,pair_sid,active_sid,ds.req_valid,ds.req_data[223:160],fusion_acquire,fusion_ack,backend.fresh_publication_seen,active_desc==result_desc,backend.state,backend.tx_busy,backend.eng_busy,backend.arm_busy,backend.writer_owned,backend.packet_busy,backend.packet_start,backend.pair_hold,backend.pair_terminal,backend.pair_selected,pair_take,telemetry_pending);$fflush(events);
  end
 end
 task pulse(input integer normal,input integer diag);begin
  @(negedge pix);send_normal=normal;send_diag=diag;
  @(negedge pix);send_normal=0;send_diag=0;
 end endtask

 m5c_telemetry telemetry(.pix_clk(pix),.ui_clk(clk),.rst_n(rst_n),.frame_done(frame_done),.pixel_snapshot(pixel_snapshot),
 .active_descriptor(active_desc),.active_session(active_sid),.active_token(fusion_token),.active_slot(fusion_slot),.rejected_jobs(64'd0),.protocol_faults(64'd0),
 .payload_ready(telemetry_ready),.header_descriptor(telemetry_header),.payload_take(telemetry_take),.byte_index(telemetry_index),.payload_byte(telemetry_byte),.snapshot_pending(telemetry_pending),.snapshot_fault(telemetry_fault));
 integer arm_count=0;always @(posedge clk)if(rst_n&&backend.pair_arm)begin arm_count=arm_count+1;$fdisplay(events,"PAIR_ARM cyc=%0d sid=%h token=%h",cycle,active_sid,fusion_token);$fflush(events);end
 integer eof_count=0,build_count=0,t4_start=0,t4_done=0,takes=0,packet_window=0;reg oldpending=1,oldready=0;
 always @(posedge pix)if(rst_n&&frame_done)begin eof_count=eof_count+1;$fdisplay(events,"EOF t=%0t sourceSID=%0d seq=%0d",$time,pixel_snapshot[191:128],pixel_snapshot[63:0]);$fflush(events);end
 always @(posedge clk)if(rst_n)begin
  if(telemetry_fault)$fatal(1,"REAL_TELEMETRY_FAULT");
  if(telemetry.accepting)build_count=build_count+1;
  if(backend.packet.start&&backend.packet.packet_type==4)t4_start=t4_start+1;
  if(backend.packet_done&&backend.packet.packet_type==4)t4_done=t4_done+1;
  if(telemetry_take)takes=takes+1;
  if(backend.packet_busy&&!telemetry_pending&&backend.packet.packet_type==4)packet_window=packet_window+1;
  if(oldpending!==telemetry_pending||oldready!==telemetry_ready||telemetry_take||backend.packet_done||backend.packet.start)begin
   $fdisplay(events,"TELEM t=%0t cyc=%0d pending=%b ready=%b take=%b start=%b type=%0d done=%b packetbusy=%b building=%b mailvalid=%b sourcebusy=%b state=%0d",$time,cycle,telemetry_pending,telemetry_ready,telemetry_take,backend.packet.start,backend.packet.packet_type,backend.packet_done,backend.packet_busy,telemetry.building,telemetry.mail_valid,telemetry.mail_busy,backend.state);$fflush(events);
  end
  oldpending=telemetry_pending;oldready=telemetry_ready;
 end

 initial begin
  wait(rst_n);
  if(CASE==0)begin wait(pubs==1);pulse(1,1);end
  else begin
   wait(pubs==1&&backend.state==backend.IDLE&&!backend.packet_busy);
   if(CASE==1)begin wait(backend.writer_owned);pulse(1,1);end
   if(CASE==2)begin diag_sid=normal_sid^64'h0000000100000000;pulse(1,1);end
   if(CASE==3)begin pulse(1,0);repeat(8)@(negedge pix);pulse(0,1);end
  end
  wait(acks==1);repeat(40)@(negedge clk);
  if(selected!=0||arm_count!=0||acks!=1)$fatal(1,"REJECTION_PROTECTION_BYPASSED");
  if(CASE<2&&matching_reject!=1)$fatal(1,"REJECTION_WINDOW_NOT_HIT");
  $display("SELECTION_REJECTION_PASS case=%0d pubs=%0d selected=%0d ack=%0d rejected=%0d",CASE,pubs,selected,acks,matching_reject);
  $fclose(events);$fclose(uart_file);$finish;
 end
 initial begin #500000000;$fatal(1,"SELECTION_DIAG_WATCHDOG");end
endmodule
