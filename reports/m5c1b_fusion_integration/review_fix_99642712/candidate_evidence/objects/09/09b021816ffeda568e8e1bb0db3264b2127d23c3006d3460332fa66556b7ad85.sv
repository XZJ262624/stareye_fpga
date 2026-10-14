`timescale 1ns/1ps
// Actual transfer + actual arbiter. Independent ownership and payload ledger.
module tb_m5c1b_uart_lease_recovery_v3;
 parameter CASE=0,EXPORT_LIMIT=2000,FENCE=0;
 reg run_enable=1;reg fusion_acquire=0,fusion_release=0,fusion_retire=0;reg fusion_slot=0;reg [319:0] fusion_identity=0;reg [63:0] fusion_token=1;wire fusion_ack,fusion_denied,lease_fault;wire [3:0] pair_leased;
 reg clk=0,pix=0,rst_n=0,safe_window=1;always #6 pix=~pix;
 always #5 clk=~clk;
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
 m5b1_backend #(.REQUEST_CYCLES(10000),.EXPORT_CYCLES(EXPORT_LIMIT)) backend(.ui_clk(clk),.pix_clk(pix),.rst_n(rst_n),.run(run_enable),.stop(1'b0),.epoch(64'd1),
 .tap_valid(tap_valid),.tap_class(2'b0),.tap_x(tap_x),.tap_y(tap_y),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),
 .tap_frame_id(64'd7),.tap_epoch(64'd1),.tap_timestamp(64'd99),.tap_display_seq(64'd1),.tap_config_generation(64'd0),
 .fusion_acquire(fusion_acquire),.fusion_slot(fusion_slot),.fusion_identity(fusion_identity),.fusion_token(fusion_token),.fusion_release(fusion_release),.fusion_retire(fusion_retire),.fusion_read_accept(1'b0),.fusion_read_done(1'b0),.fusion_ack(fusion_ack),.fusion_denied(fusion_denied),.lease_fault(lease_fault),.pair_leased(pair_leased),
 .telemetry_ready(1'b0),.telemetry_descriptor(320'd0),.telemetry_byte(8'd0),.max_wait(96'b0),.max_service(96'b0),.camera_max(14'b0),.display_min(14'b0),
 .system_status(32'b0),.error_counts(224'b0),.video_fifo_faults(4'b0),.uart_tx(uart),.job_busy(),.publish_toggle(),.bg_fault(),.capture_reset_done(),
 .avalid(ta),.aready(car[2]),.aaddr(taddr),.alen(tlen),.aid(tid),.atype(tty),.wdata(td),.wvalid(tw),.wlast(tl),.wready(cwr[2]),
 .bvalid(cb[2]),.bid(cbi[23:16]),.bresp(cbr[5:4]),.rvalid(cr[2]),.rlast(crl[2]),.rdata(crd[383:256]),.rid(cri[23:16]),.rresp((CASE==2&&backend.uart_owned&&cr[2])?2'b10:crp[5:4]),.rready(tr),.rejected(rejected[2]),.write_permission(wp),.read_permission(rp));
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
 // Recovery oracle uses actual backend, lease, transfer and arbiter events.
 // CASE2 injects a recoverable error ONLY at the backend client RRESP boundary;
 // the production arbiter's physical badR cold quarantine is a separate gate.
 integer cleanup_deadline=0,early_stage=0,early_ack=0;
 integer phase=0,release_pulses=0,uart_reads=0,uart_done=0,metadata_b=0;
 integer last_r_cycle=-1,release_cycle=-1,cycle=0,cleanup_wait=0,post_publish=0;
 integer type2_done=0,type3_done=0,aborts=0,dual_events=0;
 reg [319:0] held_identity;reg held_slot;reg [63:0] held_token;
 reg meta_pending=0;reg [127:0] metadata_words[0:31];
 always @(posedge clk)if(rst_n)begin
  cycle=cycle+1;
  // Begins only after ordinary exit enters cleanup with real transfer drained.
  // Thus this16cycle bound does not shorten permitted accepted-read draining.
  if(backend.state==25||backend.state==26)begin
   cleanup_deadline=cleanup_deadline+1;
   if(cleanup_deadline>16)$fatal(1,"UART_CLEANUP_LEASE_NOT_RECLAIMED");
   if(FENCE&&early_stage==0)begin
    fusion_slot<=held_slot;fusion_identity<=held_identity;fusion_acquire<=1;early_stage=1;
   end
  end
  if(FENCE&&early_stage==1&&fusion_ack)begin
   if(backend.uart_owned||backend.export_exclusive||pair_leased[held_slot?3:1])$fatal(1,"UART_CLEANUP_FUSION_ACK_BEFORE_FENCE");
   early_ack=early_ack+1;fusion_acquire<=0;fusion_release<=1;fusion_retire<=1;early_stage=2;
  end else if(FENCE&&early_stage==2)begin fusion_release<=0;fusion_retire<=0;fusion_token<=2;early_stage=3;end

  if(lease_fault)$fatal(1,"UART_RECOVERY_LEASE_FAULT");
  if(backend.uart_read_accept&&backend.fusion_read_accept || backend.uart_read_done&&backend.fusion_read_done || backend.uart_release&&(fusion_release||fusion_retire))$fatal(1,"UART_FUSION_EVENT_COLLISION");
  if(avalid&&aready)meta_pending=(aaddr==32'h010e6000||aaddr==32'h010e6080)&&atype;
  if(wvalid&&wready&&meta_pending)metadata_words[mb]=wdata;
  if(bvalid&&bready&&meta_pending)begin metadata_b=metadata_b+1;meta_pending=0;end
  if(backend.packet_done&&backend.export_type==2&&backend.state==13)type2_done=type2_done+1;
  if(backend.packet_done&&backend.export_type==3&&backend.state==13)type3_done=type3_done+1;
  if(backend.packet_abort)aborts=aborts+1;
  if(backend.uart_read_accept)uart_reads=uart_reads+1;
  if(backend.uart_read_done)begin uart_done=uart_done+1;last_r_cycle=cycle;end
  if(backend.uart_release)begin
   release_pulses=release_pulses+1;release_cycle=cycle;
   if(tx_busy||uart_reads!=uart_done||backend.writer_identity!==held_identity||backend.latest_slot!==held_slot||backend.uart_token!==held_token)$fatal(1,"UART_RELEASE_BEFORE_REAL_DRAIN");
  end
  if(phase>0&&phase<3&&backend.uart_owned)begin
   if(backend.writer_identity!==held_identity||backend.latest_slot!==held_slot||backend.uart_token!==held_token)$fatal(1,"UART_OWNER_IDENTITY_CHANGED_BEFORE_DRAIN");
  end
  if(phase==0&&backend.state==backend.EXPORT_START)begin
   if(backend.published_count!=1||metadata_b!=1)$fatal(1,"UART_INITIAL_REAL_PUBLICATION_REQUIRED");
   held_identity=backend.writer_identity;held_slot=backend.latest_slot;held_token=backend.uart_token;phase=1;
   if(CASE==0)begin safe_window<=0;denied=1;end
   if(CASE==1)hold_last<=1;
   $display("UART_FIRST_OWNED case=%0d cycle=%0d slot=%0d token=%0d identity=%080h",CASE,cycle,held_slot,held_token,held_identity);
  end
  if(phase==1)begin
   if(backend.transfer.state==1&&tx_busy)saw_queued=1;
   if(CASE==1&&backend.export_timeout&&hold_last)begin
    if(!tx_busy||uart_reads!=1||uart_done!=0||release_pulses!=0)$fatal(1,"UART_TIMEOUT_NOT_OWNED_DRAIN");
    if(cleanup_wait==0)$display("UART_TIMEOUT_OWNED_DRAIN_BEGIN cycle=%0d busy=%b reads=%0d done=%0d",cycle,tx_busy,uart_reads,uart_done);
    cleanup_wait=cleanup_wait+1;
    if(cleanup_wait==32)begin hold_last<=0;$display("UART_REAL_LAST_R_SERVICE_RESTORED cycle=%0d",cycle);end
   end
   if(backend.state==25||backend.state==26)begin
    if(!backend.export_exclusive||!backend.uart_owned)$fatal(1,"UART_CLEANUP_FENCE_DROPPED");
    if(CASE==1&&(!cleanup_wait||uart_reads!=uart_done))$fatal(1,"UART_LAST_R_DRAIN_MISSING");
   end
   if(backend.state==backend.IDLE)begin
    if(backend.uart_owned!==1'b0||pair_leased[held_slot?3:1]!==1'b0||release_pulses!=1||tx_busy)$fatal(1,"UART_LEASE_NOT_RECLAIMED");
    if(CASE==0&&(!saw_queued||uart_reads!=0))$fatal(1,"UART_QUEUED_TIMEOUT_COVERAGE");
    if(CASE==1&&(last_r_cycle<0||release_cycle<=last_r_cycle))$fatal(1,"UART_RELEASE_ORDER");
    if(CASE==2&&(aborts!=1||uart_reads!=1||uart_done!=1))$fatal(1,"UART_READ_ERROR_COVERAGE");
    if(CASE==3&&(type2_done!=1||type3_done!=1||aborts!=0))$fatal(1,"UART_NORMAL_FULL_EXPORT_COVERAGE");
    safe_window<=1;phase=3;
    $display("UART_CLEANUP_PROVEN case=%0d cycle=%0d real_reads=%0d real_done=%0d releases=%0d lastR=%0d release=%0d",CASE,cycle,uart_reads,uart_done,release_pulses,last_r_cycle,release_cycle);
   end
  end
  if(phase==3&&backend.published_count==2)begin
   if(metadata_b!=2||!backend.result_valid||backend.uart_owned||pair_leased[held_slot?3:1])$fatal(1,"UART_NEXT_JOB_PUBLICATION_NOT_CLEAN");
   fusion_slot<=backend.result_slot;
   fusion_identity<={backend.result_descriptor[63:0],backend.result_descriptor[191:128],backend.result_descriptor[127:64],backend.result_descriptor[447:384],backend.result_descriptor[511:448]};
   fusion_acquire<=1;run_enable<=0;phase=4;post_publish=cycle;
  end
  if(phase==4)begin
   if(fusion_denied)$fatal(1,"UART_RECOVERY_FUSION_DENIED");
   if(fusion_ack)begin
    if(!pair_leased[fusion_slot?2:0]||backend.uart_owned||lease_fault)$fatal(1,"UART_RECOVERY_BAD_ACK");
    fusion_acquire<=0;fusion_retire<=1;fusion_release<=1;phase=5;
   end
   if(cycle-post_publish>32)$fatal(1,"UART_RECOVERY_FUSION_ACK_MISSING");
  end else if(phase==5)begin fusion_release<=0;fusion_retire<=0;phase=6;end
  else if(phase==6&&!pair_leased[fusion_slot?2:0]&&backend.state==backend.IDLE)begin
   if(lease_fault||tx_busy||uart_reads!=uart_done||release_pulses!=1||metadata_b!=2||backend.published_count!=2)$fatal(1,"UART_FINAL_RECOVERY_INCOMPLETE");
   if(FENCE&&early_ack!=1)$fatal(1,"UART_CLEANUP_FUSION_FENCE_NOT_EXERCISED");
   $fclose(uart_file);$display("REVIEW_PASS UART_RECOVERY case=%0d limit=%0d metadataB=%0d published=%0d fusionACK=1 leases=%h read_accept=%0d read_done=%0d release=%0d cycles=%0d",CASE,LIMIT,metadata_b,backend.published_count,pair_leased,uart_reads,uart_done,release_pulses,cycle);$finish;
  end
 end
 initial begin #((EXPORT_LIMIT+50000000)*10.0);$fatal(1,"UART_RECOVERY_WATCHDOG case=%0d phase=%0d state=%0d",CASE,phase,backend.state);end
endmodule
