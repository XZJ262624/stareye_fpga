`timescale 1ns/1ps
// Actual transfer + actual arbiter. Independent ownership and payload ledger.
module tb_pair_backend_fresh;
 parameter CASE=0,EXPORT_LIMIT=2000,FENCE=0;
 reg run_enable=1;reg fusion_acquire=0,fusion_release=0,fusion_retire=0;reg fusion_slot=0;reg [319:0] fusion_identity=0;reg [63:0] fusion_token=1;wire fusion_ack,fusion_denied,lease_fault;wire [3:0] pair_leased;
 reg clk=0,pix=0,rst_n=0,safe_window=1;always #6 pix=~pix;
 always #5 clk=~clk;
 reg request_pair=0,cap_done=0;wire cap_take;reg [63:0] sid=64'h1234000000000007;
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
 m5c_pair_backend #(.REQUEST_CYCLES(10000),.EXPORT_CYCLES(EXPORT_LIMIT)) backend(.pair_local_rst_n(rst_n),.pair_request(request_pair),.pair_request_session(sid),.pair_wait_expired(1'b0),.active_pair_descriptor(result_desc),.pair_session(sid),.pair_arm_busy(1'b0),.pair_done(cap_done),.pair_done_take(cap_take),.pair_reason(32'd2),.pair_empty(1'b1),.pair_count(10'd0),.pair_data(128'd0),.ui_clk(clk),.pix_clk(pix),.rst_n(rst_n),.run(run_enable),.stop(1'b0),.epoch(64'd1),
 .tap_valid(tap_valid),.tap_class(2'b0),.tap_x(tap_x),.tap_y(tap_y),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),
 .tap_frame_id(64'd7),.tap_epoch(64'd1),.tap_timestamp(64'd99),.tap_display_seq(64'd1),.tap_config_generation(64'd0),
 .fusion_acquire(fusion_acquire),.fusion_slot(fusion_slot),.fusion_identity(fusion_identity),.fusion_token(fusion_token),.fusion_release(fusion_release),.fusion_retire(fusion_retire),.fusion_read_accept(1'b0),.fusion_read_done(1'b0),.result_descriptor(result_desc),.fusion_ack(fusion_ack),.fusion_denied(fusion_denied),.lease_fault(lease_fault),.pair_leased(pair_leased),
 .telemetry_ready(1'b0),.telemetry_descriptor(320'd0),.telemetry_byte(8'd0),.max_wait(96'b0),.max_service(96'b0),.camera_max(14'b0),.display_min(14'b0),
 .system_status(32'b0),.error_counts(224'b0),.video_fifo_faults(4'b0),.uart_tx(uart),.job_busy(),.publish_toggle(),.bg_fault(),.capture_reset_done(),
 .avalid(ta),.aready(car[2]),.aaddr(taddr),.alen(tlen),.aid(tid),.atype(tty),.wdata(td),.wvalid(tw),.wlast(tl),.wready(cwr[2]),
 .bvalid(cb[2]),.bid(cbi[23:16]),.bresp(cbr[5:4]),.rvalid(cr[2]),.rlast(crl[2]),.rdata(crd[383:256]),.rid(cri[23:16]),.rresp(crp[5:4]),.rready(tr),.rejected(rejected[2]),.write_permission(wp),.read_permission(rp));
 defparam backend.packet.uart.CLOCK=460800;
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
 integer cycle=0,metadata_b=0,phase=0,pubs=0,selected=0,failed_packets=0,stats_packets=0;
 reg meta_pending=0;reg previous_fresh=0;integer ack_deadline=0;
 always @(posedge clk)if(rst_n)begin
  cycle=cycle+1;
  if(lease_fault||backend.export_exclusive||pair_leased[1]||pair_leased[3])$fatal(1,"PAIR_ONLY_LEASE_PROFILE");
  if(backend.publication_accept)begin
   pubs=pubs+1;if(backend.pair_selected||backend.state!=backend.ENGINE_WAIT)$fatal(1,"PAIR_ONLY_PUBLISH_SELECT_LIFECYCLE");
  end
  if(backend.pair_selected)begin selected=selected+1;if(!backend.fresh_publication_seen||pubs!=2)$fatal(1,"PAIR_ONLY_NOT_REAL_FRESH");end
  if(backend.packet.start&&backend.packet.packet_type!=1&&backend.packet.packet_type!=10)$fatal(1,"PAIR_ONLY_LEGACY_PACKET");
  if(backend.packet_done)begin
   if(backend.packet.packet_type==1)stats_packets=stats_packets+1;
   else if(backend.packet.packet_type==10)failed_packets=failed_packets+1;
  end
  if(avalid&&aready)meta_pending=(aaddr==32'h010e6000||aaddr==32'h010e6080)&&atype;
  if(bvalid&&bready&&meta_pending)begin metadata_b=metadata_b+1;meta_pending=0;end
  if(backend.pair_arm)cap_done<=1;
  if(cap_take)cap_done<=0;
  if(phase==0&&pubs==1&&backend.state==backend.IDLE)begin
   if(!backend.fresh_publication_seen||metadata_b!=1||stats_packets!=1)$fatal(1,"PAIR_ONLY_FIRST_PUBLICATION");
   fusion_slot<=backend.result_slot;fusion_identity<={result_desc[63:0],result_desc[191:128],result_desc[127:64],result_desc[447:384],result_desc[511:448]};fusion_acquire<=1;ack_deadline=cycle+32;phase=1;
  end
  if((phase==1||phase==4)&&cycle>ack_deadline)$fatal(1,"PAIR_ONLY_ACK_DEADLINE");
  if((phase==1||phase==4)&&fusion_ack)begin
   if(fusion_denied||!pair_leased[fusion_slot?2:0])$fatal(1,"PAIR_ONLY_BAD_REAL_ACK");
   fusion_acquire<=0;fusion_release<=1;fusion_retire<=1;request_pair<=0;phase=phase==1?2:5;
  end else if(phase==2)begin fusion_release<=0;fusion_retire<=0;fusion_token<=2;phase=3;end
  else if(phase==5)begin fusion_release<=0;fusion_retire<=0;phase=6;end
  if(phase==3&&pubs==2&&backend.state==backend.IDLE)begin
   if(metadata_b!=2||!backend.fresh_publication_seen||selected!=0)$fatal(1,"PAIR_ONLY_SECOND_PUBLICATION");
   fusion_slot<=backend.result_slot;fusion_identity<={result_desc[63:0],result_desc[191:128],result_desc[127:64],result_desc[447:384],result_desc[511:448]};request_pair<=1;fusion_acquire<=1;ack_deadline=cycle+32;phase=4;
  end
  if(phase==6&&!backend.pair_hold)begin
   if(selected!=1||backend.fresh_publication_seen||failed_packets!=1||pair_leased!=0)$fatal(1,"PAIR_ONLY_FAILED_ATTEMPT_DRAIN");phase=7;
  end
  if(phase==7&&pubs==3&&backend.state==backend.IDLE)begin
   if(!backend.fresh_publication_seen||metadata_b!=3||selected!=1||stats_packets!=3||backend.requests!=backend.accepted+backend.busy_rejected)$fatal(1,"PAIR_ONLY_RECOVERY_PUBLICATION");
   $fclose(uart_file);$display("PAIR_ONLY_BACKEND_PASS pubs=%0d metadataB=%0d selected=%0d failurePackets=%0d stats=%0d RT=%0d",pubs,metadata_b,selected,failed_packets,stats_packets,rt_completed);$finish;
  end
 end
 initial begin #500000000;$fatal(1,"PAIR_ONLY_WATCHDOG phase=%0d state=%0d",phase,backend.state);end
endmodule
