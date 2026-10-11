`timescale 1ns/1ps
module tb_m5b1_system;
 parameter TESTMODE=0;
 reg ui_clk=0,cam_clk=0,pix_clk=0,arst_n=0,run=0,stop=0;
 always #5.208333 ui_clk=~ui_clk;
 integer cam_phase_seed=50708;initial begin if($value$plusargs("SEED=%d",cam_phase_seed))begin end #(0.1+(cam_phase_seed%97)/10.0);forever #5 cam_clk=~cam_clk;end
 integer pix_phase_seed=50708;initial begin if($value$plusargs("SEED=%d",pix_phase_seed))begin end #(0.2+(pix_phase_seed%79)/10.0);forever #6.720430 pix_clk=~pix_clk;end
 reg cam_vs=1,cam_valid=0;reg [7:0] cam_data=0;reg pix_sof=0,pix_request=0;
 wire [7:0] pix_data;wire [63:0] replay_frame_id;wire display_valid,fault;
 wire [1:0] va,vr;wire [63:0] vad;wire [15:0] vl,vi;wire [1:0] vt;
 wire vw,vlast;wire [127:0] vdata;wire rr;
 wire [3:0] wp,rp,ready;wire [13:0] cam_bytes,disp_bytes,cam_max,disp_min;
 wire [1:0] urgent;wire safe_window;
 wire [2:0] c_aready,c_wready,c_bvalid,c_rvalid,c_rlast,rejected;
 wire [23:0] c_bid,c_rid;wire [5:0] c_bresp,c_rresp;wire [383:0] c_rdata;
 wire quarantine,reset_request,busy;wire [3:0] error_reason;
 wire [7:0] aid,alen,wid;wire [31:0] aaddr;wire [2:0] asize;wire [1:0] aburst,alock;
 wire avalid,atype,wlast,wvalid,bready,rready;wire [127:0] wdata;wire [15:0] wstrb;
 reg aready=0,wready=0,bvalid=0,rvalid=0,rlast=0;reg [7:0] bid=0,rid=0;
 reg [1:0] bresp=0,rresp=0;reg [127:0] rdata=0;
 wire [95:0] max_wait,max_service;wire [31:0] qos_exceeded,accepts,completes,rejects;
 reg bg_req=0,bg_inflight=0;integer bg_beats=0,bg_count=0;
 wire [63:0] epoch;wire uart_tx;wire [5:0] led;
 reg [11:0] tap_x=0,tap_y=0;reg tap_valid=0;reg [1:0] tap_class=0;reg [63:0] stamp=0,tap_source_id=0;
 m5b1_system dut(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.rst_n(arst_n),.pll_locked(arst_n),.cal_done(arst_n),.cal_pass(arst_n),
  .cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.pix_sof(pix_sof),.pix_request(pix_request),.pix_data(pix_data),.frame_id(replay_frame_id),.epoch(epoch),.pix_qualified(),
  .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),.tap_frame_id(tap_source_id),.tap_epoch(TESTMODE==3?64'd0:epoch),.tap_timestamp(stamp),.uart_tx(uart_tx),.led(led),
  .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),
  .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),
  .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
 // Accelerate only UART serialization; complete byte stream still passes real packet CRC.
 defparam dut.background.REQUEST_CYCLES=1000000;
 defparam dut.background.EXPORT_CYCLES=(TESTMODE==1||TESTMODE==4)?10000:960000000;
 defparam dut.background.packet.uart.CLOCK=460800;
 assign fault=dut.video_fault;assign quarantine=dut.quarantine;assign reset_request=dut.reset_request;
 assign cam_bytes=dut.camera_bytes;assign disp_bytes=dut.display_bytes;assign cam_max=dut.camera_max;assign disp_min=dut.display_min;
 assign rejected=dut.rejected;assign max_service=dut.max_service;assign max_wait=dut.max_wait;assign qos_exceeded=dut.qos_exceeded;
 reg stall_bus=0;reg w_stalled=0;reg [153:0] w_held;
 reg hardstop_seen=0;integer hardstop_backend=-1,hardstop_published=0;
 reg [2:0] hardstop_owner_state;reg [1:0] hardstop_owner;reg [127:0] hardstop_data;
 integer fileout,bytes_out=0,class_cross=0,work_cross=0,metadata_b=0,publish_observed=0;reg last_metadata_slot=0,abort_seen=0;
 initial fileout=$fopen("system_uart.hex","w");
 reg [127:0] mem[0:1107711];integer ms=0,beat=0,len=0,base=0,age=0;
 integer seed=50708,rng,cycles=0,delay_target=0;reg [7:0] tid;
 integer bus_accepted=0,bus_completed=0;reg stalled=0;reg [49:0] held;
 always @(negedge ui_clk)if(arst_n)begin
  rng=$random(seed)&32'h7fffffff;
  aready=!stall_bus&&ms==0&&(delay_target!=0||rng%4!=0);
  wready=!stall_bus&&ms==1&&rng%4!=0;
  if(!stall_bus&&ms==2&&!rvalid&&(delay_target!=0||rng%4!=0)&&(delay_target==0||age>delay_target-130))begin
   rid=tid;rresp=0;rdata=mem[base+beat];rlast=beat==len;rvalid=1;
  end
  if(!stall_bus&&ms==3&&!bvalid&&(delay_target!=0||rng%4!=0)&&(delay_target==0||age>=delay_target))begin bid=tid;bresp=0;bvalid=1;end
 end
 always @(posedge ui_clk)if(arst_n)begin
  cycles=cycles+1;if(ms!=0)age=age+1;
  if(TESTMODE!=2&&(fault||quarantine||reset_request))$fatal(1,"VIDEO_PROTOCOL_FAULT cycles=%0d cam=%0d display=%0d ws=%0d rs=%0d camfault=%b pixfault=%b",cycles,cam_bytes,disp_bytes,dut.video.ws,dut.video.rs,dut.video.cam_fault,dut.video.pix_fault);
  if(|rejected)$fatal(1,"legal DMA rejected");
  // Normal cancellation and ordinary soft reset retain the complete stalled
  // tuple. The frozen prototype's protocol-watchdog emergency isolation is
  // separately observed below: it withdraws VALID, retains ownership, never
  // asserts a synthetic ACK, and requires cold reconfiguration. It is NOT a
  // claim of AXI VALID compliance or finite drainage after a dead DDR bus.
  if(w_stalled&&!dut.stop&&{wid,wstrb,wlast,wvalid,wdata}!==w_held)$fatal(1,"system W payload changed while stalled");
  if(dut.stop&&dut.background.ever_run)begin
   if(TESTMODE!=2||!dut.quarantine||!dut.reset_request||dut.error_reason!=1||dut.ack)$fatal(1,"unexpected hardstop exception");
   if(!hardstop_seen)begin
    if(!w_stalled||w_held[128]!==1'b1||wvalid||{wid,wstrb,wlast,wdata}!=={w_held[153:129],w_held[127:0]})$fatal(1,"hardstop first edge differs beyond VALID withdrawal");
    hardstop_owner=dut.arbiter.owner;hardstop_owner_state=dut.arbiter.state;hardstop_published=dut.background.published_count;
    $display("HARDSTOP_FIRST watchdog=1 calibration_done=1 calibration_pass=1 stop=%b reset_request=%b quarantine=%b ACK=%b owner=%0d arbstate=%0d transfer=%0d busy=%b eng_selected=%b backend=%0d Wbefore=%h Wnow=%h",dut.stop,dut.reset_request,dut.quarantine,dut.ack,dut.arbiter.owner,dut.arbiter.state,dut.background.transfer.state,dut.background.tx_busy,dut.background.eng_selected,dut.background.state,w_held,{wid,wstrb,wlast,wvalid,wdata});
    hardstop_seen=1;
   end
   if(avalid||wvalid||bready||rready||dut.arbiter.owner!=hardstop_owner||dut.arbiter.state!=hardstop_owner_state||!dut.background.tx_busy||dut.background.published_count!=hardstop_published)$fatal(1,"hardstop isolated interface/retained owner/publication");
   if(hardstop_backend!=dut.background.state||hardstop_data!==wdata)begin
    $display("HARDSTOP_TRACE backend=%0d eng_selected=%b owner=%0d arbstate=%0d transfer=%0d busy=%b WVALID=%b WLAST=%b WDATA=%h cap_data=%h",dut.background.state,dut.background.eng_selected,dut.arbiter.owner,dut.arbiter.state,dut.background.transfer.state,dut.background.tx_busy,wvalid,wlast,wdata,dut.background.cap_data);
    hardstop_backend=dut.background.state;hardstop_data=wdata;
   end
  end
  w_stalled=wvalid&&!wready;w_held={wid,wstrb,wlast,wvalid,wdata};
  if(stalled&&{aaddr,aid,alen,atype,avalid}!==held)$fatal(1,"unstable A");
  stalled=avalid&&!aready;held={aaddr,aid,alen,atype,avalid};
  if(avalid&&aready)begin
   if(ms!=0||asize!=4||aburst!=1||alock!=0)$fatal(1,"bad single-owner command");
   ms=atype?1:2;beat=0;len=alen;base=aaddr>>4;tid=aid;age=0;bus_accepted=bus_accepted+1;
  end
  if(wvalid&&wready)begin
   if(ms!=1||wid!=tid||wlast!=(beat==len)||wstrb!=16'hffff)$fatal(1,"bad W");
   mem[base+beat]=wdata;if(beat==len)ms=3;else beat=beat+1;
  end
  if(bvalid&&bready)begin bvalid<=0;ms=0;bus_completed=bus_completed+1;if(delay_target==0&&age>382)$fatal(1,"conditional model exceeds 384UI");end
  if(rvalid&&rready)begin
   rvalid<=0;if(beat==len)begin ms=0;bus_completed=bus_completed+1;if(delay_target==0&&age>382)$fatal(1,"conditional R model exceeds bound");end
   else beat=beat+1;
  end
  if(bus_accepted!=bus_completed+(ms!=0))$fatal(1,"independent conservation");

 end
 integer f,x,y;
 function [7:0] pixel(input integer frame,input integer pos);begin pixel=(pos*13)^(pos/1280)^frame;end endfunction
 initial begin
  if($value$plusargs("SEED=%d",seed))begin end
  if($value$plusargs("DELAY=%d",delay_target))begin end
  repeat(10)@(negedge ui_clk);arst_n=1;wait(dut.run);@(negedge ui_clk);run=1;
  repeat(10)@(negedge cam_clk);cam_vs=0;repeat(20)@(negedge cam_clk);
  for(f=0;f<40;f=f+1)begin
   cam_vs=1;
   for(y=0;y<720;y=y+1)begin
    for(x=0;x<1650;x=x+1)begin
     @(negedge cam_clk);cam_valid=x<1280;if(x<1280)cam_data=pixel(f,y*1280+x);
    end
   end
   @(negedge cam_clk);cam_valid=0;cam_vs=0;repeat(10000)@(negedge cam_clk);
  end
 end
 integer px,py,frames=0,checked=0,position=0;reg check_pending=0;reg [7:0] expected;
 initial begin
  wait(run);
  forever begin
   @(negedge pix_clk);pix_sof=1;pix_request=0;stamp=stamp+1;
   @(negedge pix_clk);pix_sof=0;
   repeat(49500)@(negedge pix_clk);
   for(py=0;py<720;py=py+1)for(px=0;px<1650;px=px+1)begin
    @(negedge pix_clk);pix_request=px<1280;
   end
   @(negedge pix_clk);pix_request=0;frames=frames+1;

  end
 end
 always @(posedge pix_clk)begin
  if(pix_sof)position=0;
  if(pix_request)begin
   if(dut.video.pix_qualified&&!dut.stop)begin
    if(pix_data!==pixel(replay_frame_id,position))$fatal(1,"pixel mismatch frame=%0d pos=%0d got=%h expected=%h",replay_frame_id,position,pix_data,pixel(replay_frame_id,position));
    checked=checked+1;
   end
   position=position+1;
  end
 end
 initial begin #500000000;$fatal(1,"VIDEO_WATCHDOG");end
 always @(posedge ui_clk)begin
  if(TESTMODE==2&&avalid&&aready&&aid==3)stall_bus<=1;
  if(dut.background.export_active&&dut.background.write_permission!=0)$fatal(1,"export lease permits writes");
  if(dut.background.eng_busy&&dut.background.eng_reserved&&dut.background.latest_valid&&dut.background.eng_result_slot==dut.background.latest_slot)$fatal(1,"reserved pending result slot");
  if(TESTMODE==2&&dut.background.state==17)begin
   if(bytes_out!=324||!dut.stop||dut.ack||!dut.background.tx_busy||dut.error_counts[223:192]!=1)$fatal(1,"fault telemetry/owner disposal");
   $fclose(fileout);$display("M5B1_SYSTEM_FAULT_PASS bytes=%0d inflight=%0d watchdog=%0d no_synthetic_ack=1",bytes_out,bus_accepted-bus_completed,dut.error_counts[223:192]);$finish;
  end
  if(TESTMODE==3&&dut.background.state==0&&bytes_out==324)begin
   if(dut.background.published_count||dut.background.capture_drop!=1)$fatal(1,"stale epoch published");
   $fclose(fileout);$display("M5B1_SYSTEM_EPOCH_PASS stale_capture_rejected=1 statistics_bytes=324");$finish;
  end
  if(TESTMODE==1&&dut.background.exported&&dut.background.state==0)begin
   if(!dut.background.bg_fault||!dut.background.latest_valid||dut.background.published_count!=1||dut.background.tx_busy||dut.background.read_permission!=0||bytes_out<=324||bytes_out>=346060)$fatal(1,"export timeout release");
   $fclose(fileout);$display("M5B1_SYSTEM_EXPORT_TIMEOUT_PASS bytes=%0d lease_released=1 published_result_preserved=1",bytes_out);$finish;
  end
  if(TESTMODE==4&&dut.background.exported&&dut.background.state==0)begin
   if(!abort_seen)begin
    if(!dut.background.bg_fault||!dut.background.latest_valid||dut.background.published_count!=1||dut.background.tx_busy||dut.background.read_permission!=0||bytes_out<=324||bytes_out>=346060)$fatal(1,"export timeout release before recovery");
    abort_seen<=1;
   end else if(dut.background.published_count==2)begin
    if(metadata_b!=2||publish_observed!=2||bytes_out<=648||!dut.background.latest_valid||dut.background.read_permission!=0)$fatal(1,"export timeout next job recovery");
    $fclose(fileout);$display("M5B1_SYSTEM_EXPORT_RECOVERY_PASS bytes=%0d metadata_B=%0d aborted_partial_then_next_stats=1",bytes_out,metadata_b);$finish;
   end
  end
  if(dut.background.packet.uart.valid&&dut.background.packet.uart.ready)begin $fdisplay(fileout,"%02x",dut.background.packet.uart.data);bytes_out=bytes_out+1;end
  if(avalid&&aready)begin
   if((aaddr&4095)+(alen+1)*16>4096)$fatal(1,"4KiB escaped");
   if(aaddr==32'h01001000)class_cross=class_cross+1;
   if(aaddr==32'h01073000||aaddr==32'h01090000)work_cross=work_cross+1;
  end
  if(bvalid&&bready&&(base==32'h010e6000/16||base==32'h010e6080/16))begin metadata_b=metadata_b+1;last_metadata_slot=base==32'h010e6080/16;end
  if(dut.background.eng_published)begin
   if(metadata_b!=publish_observed+1||last_metadata_slot!==dut.background.eng_result_slot)$fatal(1,"publish before this job/slot metadata B");
   if(TESTMODE==3)$fatal(1,"stale epoch published");
   publish_observed=publish_observed+1;
  end
  if((TESTMODE==0||(TESTMODE==5&&dut.background.published_count==2))&&dut.background.exported&&dut.background.state==0)begin
   if(bytes_out!=345600+3*68+256+(TESTMODE==5?324:0)||class_cross==0||work_cross==0||metadata_b!=(TESTMODE==5?2:1)||checked<921600||dut.background.capture_drop!=0||dut.background.bg_fault||dut.background.published_count!=(TESTMODE==5?2:1)||dut.background.busy_rejected==0)$fatal(1,"integration coverage bytes=%0d class=%0d work=%0d meta=%0d checked=%0d",bytes_out,class_cross,work_cross,metadata_b,checked);
   $fclose(fileout);$display("M5B1_SYSTEM_PASS full_capture=921600 exported_bytes=%0d class_split=%0d work_split=%0d metadata_B=%0d checked_video=%0d accepted=%0d completed=%0d max_service=%h camera_max=%0d display_min=%0d capture_max=%0d C2_wait=%0d mode=%0d",bytes_out,class_cross,work_cross,metadata_b,checked,bus_accepted,bus_completed,max_service,cam_max,disp_min,dut.background.capture_max,max_wait[95:64],TESTMODE);$finish;
  end
 end
 integer cx,cy;
 initial begin
  wait(run);
  forever begin
   @(posedge pix_sof);repeat(50500)@(negedge pix_clk);tap_source_id=replay_frame_id;
   for(cy=0;cy<720;cy=cy+1)for(cx=0;cx<1650;cx=cx+1)begin
    @(negedge pix_clk);tap_valid=cx<1280;tap_x=cx;tap_y=cy;tap_class=(cx%97==0&&cy%11==0)?2:((cx%13<8&&cy%17<12)?1:0);
   end
   @(negedge pix_clk);tap_valid=0;
  end
 end
endmodule


