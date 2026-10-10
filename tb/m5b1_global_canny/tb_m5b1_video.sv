`timescale 1ns/1ps
module tb_m5b1_video;
 reg ui_clk=0,cam_clk=0,pix_clk=0,arst_n=0,run=0,stop=0;
 always #5.208333 ui_clk=~ui_clk;
 initial begin #1.7;forever #5 cam_clk=~cam_clk;end
 initial begin #3.2;forever #6.720430 pix_clk=~pix_clk;end
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
 m5b1_video_dma dut(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.arst_n(arst_n),.run(run),.stop(stop),.epoch(64'd1),
  .cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.pix_sof(pix_sof),.pix_request(pix_request),
  .pix_data(pix_data),.replay_frame_id(replay_frame_id),.display_valid(display_valid),.fault(fault),
  .avalid(va),.aready(c_aready[1:0]),.aaddr(vad),.alen(vl),.aid(vi),.atype(vt),
  .wvalid(vw),.wlast(vlast),.wdata(vdata),.wready(c_wready[0]),
  .bvalid(c_bvalid[0]),.bresp(c_bresp[1:0]),.bid(c_bid[7:0]),
  .rvalid(c_rvalid[1]),.rlast(c_rlast[1]),.rdata(c_rdata[255:128]),.rresp(c_rresp[3:2]),.rid(c_rid[15:8]),
  .rready(rr),.rejected(rejected[1:0]),.write_permission(wp),.read_permission(rp),
  .camera_bytes(cam_bytes),.display_bytes(disp_bytes),.urgent(urgent),.safe_window(safe_window),.fifo_ready(ready),
  .camera_max(cam_max),.display_min(disp_min));
 m5b1_arbiter arb(.clk(ui_clk),.rst_n(arst_n),.soft_reset(1'b0),.ddr_reset_ack(1'b0),
  .urgent(urgent),.safe_window(safe_window),.emergency_stop(stop),.epoch(64'd1),.c_epoch({64'd1,64'd1,64'd1}),
  .video_write_permission(wp),.video_read_permission(rp),.bg_write_permission(7'h01),.bg_read_permission(7'h01),
  .max_wait(max_wait),.max_service(max_service),.qos_exceeded(qos_exceeded),.accepts(accepts),.completes(completes),.rejects(rejects),
  .c_avalid({bg_req,va}),.c_aready(c_aready),.c_aaddr({32'h01000000,vad}),.c_alen({8'd31,vl}),.c_aid({8'h22,vi}),.c_atype({1'b0,vt}),
  .c_wvalid({2'b0,vw}),.c_wlast({2'b0,vlast}),.c_wready(c_wready),.c_wdata({256'b0,vdata}),.c_wstrb(48'hffffffffffff),
  .c_bvalid(c_bvalid),.c_bready(3'b111),.c_bid(c_bid),.c_bresp(c_bresp),
  .c_rvalid(c_rvalid),.c_rlast(c_rlast),.c_rready({1'b1,rr,1'b1}),.c_rdata(c_rdata),.c_rid(c_rid),.c_rresp(c_rresp),
  .rejected(rejected),.quarantine(quarantine),.reset_request(reset_request),.error_reason(error_reason),.busy(busy),
  .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),
  .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),
  .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
 reg [127:0] mem[0:1048575];integer ms=0,beat=0,len=0,base=0,age=0;
 integer seed=50708,rng,cycles=0,delay_target=0;reg [7:0] tid;
 integer bus_accepted=0,bus_completed=0;reg stalled=0;reg [49:0] held;
 always @(negedge ui_clk)if(arst_n)begin
  rng=$random(seed)&32'h7fffffff;
  aready=ms==0&&(delay_target!=0||rng%4!=0);
  wready=ms==1&&rng%4!=0;
  if(ms==2&&!rvalid&&(delay_target!=0||rng%4!=0)&&(delay_target==0||age>delay_target-130))begin
   rid=tid;rresp=0;rdata=base>=1048576?128'hface0000:mem[base+beat];rlast=beat==len;rvalid=1;
  end
  if(ms==3&&!bvalid&&(delay_target!=0||rng%4!=0)&&(delay_target==0||age>=delay_target))begin bid=tid;bresp=0;bvalid=1;end
 end
 always @(posedge ui_clk)if(arst_n)begin
  cycles=cycles+1;if(ms!=0)age=age+1;
  if(fault||quarantine||reset_request)$fatal(1,"VIDEO_PROTOCOL_FAULT cycles=%0d cam=%0d display=%0d ws=%0d rs=%0d camfault=%b pixfault=%b",cycles,cam_bytes,disp_bytes,dut.ws,dut.rs,dut.cam_fault,dut.pix_fault);
  if(|rejected)$fatal(1,"legal DMA rejected");
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
  if(run&&!bg_inflight)bg_req<=1;
  if(bg_req&&c_aready[2])begin bg_req<=0;bg_inflight<=1;bg_beats<=0;end
  if(c_rvalid[2])begin
   if(c_rid[23:16]!=8'h22||c_rresp[5:4]!=0||c_rlast[2]!=(bg_beats==31))$fatal(1,"BG response");
   bg_beats<=bg_beats+1;if(c_rlast[2])begin bg_inflight<=0;bg_count<=bg_count+1;end
  end
 end
 integer f,x,y;
 function [7:0] pixel(input integer frame,input integer pos);begin pixel=(pos*13)^(pos/1280)^frame;end endfunction
 initial begin
  if($value$plusargs("SEED=%d",seed))begin end
  if($value$plusargs("DELAY=%d",delay_target))begin end
  repeat(10)@(negedge ui_clk);arst_n=1;repeat(10)@(negedge ui_clk);run=1;
  repeat(10)@(negedge cam_clk);cam_vs=0;repeat(20)@(negedge cam_clk);
  for(f=0;f<10;f=f+1)begin
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
   @(negedge pix_clk);pix_sof=1;pix_request=0;
   @(negedge pix_clk);pix_sof=0;
   repeat(49500)@(negedge pix_clk);
   for(py=0;py<720;py=py+1)for(px=0;px<1650;px=px+1)begin
    @(negedge pix_clk);pix_request=px<1280;
   end
   @(negedge pix_clk);pix_request=0;frames=frames+1;
   if(checked>=2*921600)begin
    if(bg_count<100||qos_exceeded!=0||fault||cam_max>=8192)$fatal(1,"coverage/qos bg=%0d qos=%0d max=%h cam=%0d",bg_count,qos_exceeded,max_service,cam_max);
    $display("M5B1_VIDEO_PASS checked=%0d frames=%0d BG=%0d camera_max=%0d display_min=%0d accepted=%0d completed=%0d max_service=%h max_wait=%h",checked,frames,bg_count,cam_max,disp_min,bus_accepted,bus_completed,max_service,max_wait);$finish;
   end
  end
 end
 always @(posedge pix_clk)begin
  if(pix_sof)position=0;
  if(pix_request)begin
   #0.01;
   if(dut.frame_used)begin
    if(pix_data!==pixel(replay_frame_id,position))$fatal(1,"pixel mismatch frame=%0d pos=%0d got=%h expected=%h",replay_frame_id,position,pix_data,pixel(replay_frame_id,position));
    checked=checked+1;
   end
   position=position+1;
  end
 end
 initial begin #150000000;$fatal(1,"VIDEO_WATCHDOG");end
endmodule


