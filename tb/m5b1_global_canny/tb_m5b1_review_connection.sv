`timescale 1ns/1ps
module tb_m5b1_review_connection;
 parameter CHECK=0;
 localparam TESTMODE=99;
 reg ui_clk=0,cam_clk=0,pix_clk=0,arst_n=0,run=0,stop=0;
 always #5.208333 ui_clk=~ui_clk;
 integer cam_phase_seed=50708;initial begin if($value$plusargs("SEED=%d",cam_phase_seed))begin end #(0.1+(cam_phase_seed%97)/10.0);forever #5 cam_clk=~cam_clk;end
 integer pix_phase_seed=50708;initial begin if($value$plusargs("SEED=%d",pix_phase_seed))begin end #(0.2+(pix_phase_seed%79)/10.0);forever #6.720430 pix_clk=~pix_clk;end
 reg cam_vs=1,cam_valid=0;reg [7:0] cam_data=0;wire pix_sof,pix_request;
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
 wire [11:0] tap_x,tap_y;wire tap_valid;wire [1:0] tap_class;wire [63:0] stamp,tag_id,tag_epoch;
 m5b1_system dut(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.rst_n(arst_n),.pll_locked(arst_n),.cal_done(arst_n),.cal_pass(arst_n),
  .cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.pix_sof(pix_sof),.pix_request(pix_request),.pix_data(pix_data),.frame_id(replay_frame_id),.epoch(epoch),.pix_qualified(),
  .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),.tap_frame_id(tag_id),.tap_epoch(tag_epoch),.tap_timestamp(stamp),.uart_tx(uart_tx),.led(led),
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
 reg stall_bus=0;
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
 function [7:0] pixel(input integer frame,input integer pos);begin pixel=(CHECK==3||frame%2)?0:(8'h35^((pos*13)^(pos/1280)));end endfunction
 initial begin
  if($value$plusargs("SEED=%d",seed))begin end
  if($value$plusargs("DELAY=%d",delay_target))begin end
  repeat(10)@(negedge ui_clk);arst_n=1;wait(dut.run);@(negedge ui_clk);run=1;
  repeat(1500000)@(negedge cam_clk);cam_vs=0;repeat(20)@(negedge cam_clk);
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
 // Actual production wiring: request -> DMA -> lcd_driver register -> M5A.
 wire [7:0] lcd_gray;wire lcd_de,lcd_hs,lcd_vs;reg vs_d=1;
 reg lcd_qualified=0;reg [63:0] lcd_frame_id=0,lcd_epoch=0;
 always @(posedge pix_clk)begin lcd_qualified<=dut.pix_qualified;lcd_frame_id<=replay_frame_id;lcd_epoch<=epoch;end
 always @(posedge pix_clk or negedge arst_n)if(!arst_n)vs_d<=1;else vs_d<=lcd_vs;
 assign pix_sof=vs_d&&!lcd_vs;
 lcd_driver #(.DATA_WIDTH(8)) lcd(.clk(pix_clk),.rst_n(arst_n),.lcd_request(pix_request),
  .lcd_hs(lcd_hs),.lcd_vs(lcd_vs),.lcd_en(lcd_de),.lcd_rgb(lcd_gray),.lcd_data(pix_data),
  .lcd_dclk(),.lcd_blank(),.lcd_sync(),.lcd_xpos(),.lcd_ypos());
 wire [23:0] out_rgb;wire out_de,out_hs,out_vs,raster_fault;
 wire [7:0] out_raw,out_mag,out_nms,out_threshold;wire out_bin,out_ovvalid,out_ovedge,out_nv,out_cv,out_ce,out_filter;
 wire [11:0] out_x,out_y;wire [2:0] out_mode;
 m5a_stream_top stream(.clk(pix_clk),.ce(1'b1),.arst_n(arst_n),.in_gray(lcd_gray),.in_de(lcd_de),
  .in_hs(lcd_hs),.in_vs(lcd_vs),.in_sof(!lcd_vs),.filter_request(1'b1),.threshold(8'd64),.mode(3'd6),
  .tap_input_frame_id(lcd_frame_id),.tap_input_epoch(lcd_epoch),.tap_input_qualified(lcd_qualified),.tap_valid(tap_valid),.tap_class(tap_class),
  .tap_x(tap_x),.tap_y(tap_y),.tap_high(),.tap_low(),.tap_filter(),.tap_frame_id(tag_id),.tap_epoch(tag_epoch),.tap_timestamp(stamp),
  .out_rgb(out_rgb),.out_de(out_de),.out_hs(out_hs),.out_vs(out_vs),.out_raw(out_raw),.out_legacy_mag(out_mag),
  .out_threshold(out_threshold),.out_nms(out_nms),.out_legacy_bin(out_bin),.out_overlay_valid(out_ovvalid),.out_overlay_edge(out_ovedge),
  .out_nms_valid(out_nv),.out_canny_valid(out_cv),.out_canny_edge(out_ce),.out_mode(out_mode),.out_filter_enable(out_filter),
  .out_x(out_x),.out_y(out_y),.raster_fault(raster_fault));
 reg [31:0] gold[0:1843199];reg [2047:0] gold_path;
 initial begin if(!$value$plusargs("GOLD=%s",gold_path))$fatal(1,"gold missing");$readmemh(gold_path,gold);end
 reg source_qualified[0:63];reg [63:0] source_id[0:63],source_stamp[0:63];
 reg mid_injected=0,mid_released=0;integer mid_source=-1,mid_age=0;
 integer successful_descriptors=0,failed_descriptors=0,zero_descriptors=0,post_failure_success=0,descriptor_source;
 integer si;reg descriptor_match;
 integer checked=0,position=0,frames=0,source_frames=0,tap_frames=0,tap_position=0,output_frames=0,output_position=0;
 integer full_valid=0,full_blank=0,invalid_frames=0,tap_checked=0,mode_pixels=0,m;reg qualified=0;
 reg [3:0] admission_cover=0;integer injection_age=0;
 // Loss is injected at the actual registered LCD qualification input only;
 // pixel transport and the complete capture/DDR/engine remain real.
 always @(negedge pix_clk)if(arst_n&&CHECK==2)begin
  if(!mid_injected&&source_frames==2&&position==100000)begin
   if(!qualified||!dut.background.capture.active)$fatal(1,"MIDFRAME_CAPTURE_PRECONDITION");
   mid_injected=1;mid_source=source_frames;force stream.tap_input_qualified=0;
  end
  if(mid_injected&&!mid_released&&source_frames>mid_source)begin release stream.tap_input_qualified;mid_released=1;end
 end
 // A successful descriptor must identify one independently observed complete
 // qualified source raster, including its source SOF timestamp, never black
 // substitution. Checking actual descriptor_take also checks mailbox use.
 always @(posedge ui_clk)if(arst_n&&dut.background.descriptor_take)begin
  if(dut.background.cap_descriptor[308])begin
   descriptor_match=0;descriptor_source=-1;
   for(si=0;si<source_frames;si=si+1)begin
    if(source_qualified[si]&&si!=mid_source&&source_id[si]==dut.background.cap_descriptor[127:64]&&source_stamp[si]==dut.background.cap_descriptor[255:192]&&dut.background.cap_descriptor[63:0]==1)begin descriptor_match=1;descriptor_source=si;end
   end
   if(!descriptor_match)$fatal(1,"REVIEW_R2_UNQUALIFIED_SUCCESS_DESCRIPTOR frame=%0d stamp=%0d",dut.background.cap_descriptor[127:64],dut.background.cap_descriptor[255:192]);
   successful_descriptors=successful_descriptors+1;
   if(CHECK==3||source_id[descriptor_source]%2)zero_descriptors=zero_descriptors+1;
   if(failed_descriptors)post_failure_success=post_failure_success+1;
   $display("CAPTURE_DESCRIPTOR_SUCCESS job=%0d source=%0d frame=%0d timestamp=%0d legal_zero=%0d",dut.background.cap_descriptor[191:128],descriptor_source,source_id[descriptor_source],source_stamp[descriptor_source],CHECK==3||source_id[descriptor_source]%2);
  end else begin
   failed_descriptors=failed_descriptors+1;
   if(CHECK==2&&dut.background.published_count!=0)$fatal(1,"MIDFRAME_FAILURE_PUBLISHED");
   $display("CAPTURE_DESCRIPTOR_FAILED job=%0d frame=%0d published=%0d",dut.background.cap_descriptor[191:128],dut.background.cap_descriptor[127:64],dut.background.published_count);
  end
 end
 // Fault-inject an early/late offer and boundary receiver occupancy without
 // replacing the real DDR, FIFO, lcd_driver or classification pipeline.
 // Producer-side prefill and real FIFO conservation are covered separately.
 always @(negedge pix_clk)if(arst_n&&CHECK==1)begin
  if(injection_age!=0)begin
   injection_age=injection_age+1;
   if(injection_age==100)begin release dut.video.offer_valid;release dut.video.display_rc;injection_age=0;end
  end
  if(pix_request&&dut.video.first_pixel&&(frames==4||frames==6||frames==8||frames==10))begin
   if(!dut.video.offer_valid||dut.video.display_rc<256)$fatal(1,"ADMISSION_INJECTION_PRECONDITION");
   injection_age=1;
   case(frames)
    4:begin force dut.video.offer_valid=0;admission_cover[0]=1;end
    6:begin force dut.video.display_rc=0;admission_cover[1]=1;end
    8:begin force dut.video.display_rc=255;admission_cover[2]=1;end
    10:begin force dut.video.display_rc=256;admission_cover[3]=1;end
   endcase
  end
 end
 reg [63:0] source_ticks=0,sof_tick=0;reg sof_previous=0,raster_acquired=0;integer startup_fault_ticks=0;
 reg [31:0] expected_gold;reg [23:0] expected_rgb;
 wire [23:0] mode_rgb[0:6];
 genvar gm;
 generate for(gm=0;gm<7;gm=gm+1)begin: all_modes
  m5a_colorize color(.de(out_de),.mode(gm[2:0]),.raw(out_raw),.legacy_mag(out_mag),.legacy_bin(out_bin),
   .overlay_valid(out_ovvalid),.overlay_edge(out_ovedge),.nms_gray(out_nms),.canny_valid(out_cv),.canny_edge(out_ce),.rgb(mode_rgb[gm]));
 end endgenerate
 // All oracles observe pre-NBA values on the exact receiving sample edge.
 // Queue EVERY source raster, independently of the qualified tap gating.
 always @(posedge pix_clk)if(arst_n)begin
  // Existing M5A deliberately starts bad_frame=1 until its first delayed VS
  // edge. Actual lcd_driver starts part-way through a raster before that edge.
  // Observe acquisition explicitly; no qualified pixel may use that interval.
  if(!raster_acquired)begin
   if(raster_fault)startup_fault_ticks=startup_fault_ticks+1;
   if(tap_valid||lcd_qualified)$fatal(1,"QUALIFIED_BEFORE_RASTER_ACQUISITION");
   if(stream.u_base.vs_previous&&!stream.u_base.vs)raster_acquired<=1;
  end else if(raster_fault)$fatal(1,"REVIEW_CONNECTION_RASTER_FAULT");
  if(stream.rst_n)begin
   if(!lcd_vs&&!sof_previous)sof_tick=source_ticks;
   sof_previous=!lcd_vs;source_ticks=source_ticks+1;
  end
  if(pix_sof)begin position=0;qualified=0;end
  if(pix_request&&dut.video.first_pixel)qualified=dut.video.offer_valid&&dut.video.pix_run[1]&&dut.video.display_rc>=256;
  if(lcd_de)begin
   if(position==0)begin source_qualified[source_frames]=qualified;source_id[source_frames]=lcd_frame_id;source_stamp[source_frames]=sof_tick;end
   if(qualified&&lcd_gray!==pixel(lcd_frame_id,position))
    $fatal(1,"REVIEW_R1_LCD_SAMPLE frame=%0d pos=%0d actual=%h expected=%h",lcd_frame_id,position,lcd_gray,pixel(lcd_frame_id,position));
   if(lcd_qualified!==qualified)$fatal(1,"REVIEW_R2_LCD_QUALIFICATION pos=%0d",position);
   if(qualified)checked=checked+1;
   position=position+1;
   if(position==921600)begin frames=frames+1;source_frames=source_frames+1;end
  end
  if(stream.nms_ready&&stream.nms_packet[26])begin
   if(tap_x!=tap_position%1280||tap_y!=tap_position/1280)$fatal(1,"REVIEW_R2_RAW_TAG_COORDINATES");
   if(tap_valid!==(source_qualified[tap_frames]&&!(CHECK==2&&tap_frames==mid_source&&mid_age>=1)))$fatal(1,"REVIEW_R2_UNQUALIFIED_TAP raster=%0d pos=%0d got=%b expected=%b",tap_frames,tap_position,tap_valid,source_qualified[tap_frames]);
   if(tap_valid)begin
    expected_gold=gold[(CHECK==3?1:source_id[tap_frames]%2)*921600+tap_position];
    if(tag_id!=source_id[tap_frames]||tag_epoch!=1||stamp!=source_stamp[tap_frames])$fatal(1,"REVIEW_R2_TAG_IDENTITY raster=%0d pos=%0d id=%0d/%0d stamp=%0d/%0d",tap_frames,tap_position,tag_id,source_id[tap_frames],stamp,source_stamp[tap_frames]);
    if(tap_class!==expected_gold[31:30])$fatal(1,"REVIEW_R1_TAP_GOLD frame=%0d pos=%0d class=%d gold=%d",tag_id,tap_position,tap_class,expected_gold[31:30]);
    tap_checked=tap_checked+1;
   end
   tap_position=tap_position+1;
   if(tap_position==921600)begin
    if(source_qualified[tap_frames]&&tap_frames!=mid_source)begin full_valid=full_valid+1;if(CHECK==3||source_id[tap_frames]%2)full_blank=full_blank+1;end
    else invalid_frames=invalid_frames+1;
    tap_position=0;tap_frames=tap_frames+1;
   end
  end
  if(out_de)begin
   if(out_x!=output_position%1280||out_y!=output_position/1280)$fatal(1,"REVIEW_R1_OUTPUT_COORDINATES");
   if(source_qualified[output_frames])begin
    expected_gold=gold[(CHECK==3?1:source_id[output_frames]%2)*921600+output_position];
    if({out_ce,out_cv,out_nv,out_nms,out_ovedge,out_ovvalid,out_bin,out_mag,out_raw}!==expected_gold[29:0])$fatal(1,"REVIEW_R1_DISPLAY_GOLD frame=%0d pos=%0d",source_id[output_frames],output_position);
    for(m=0;m<7;m=m+1)begin
     case(m)
      0:expected_rgb={3{expected_gold[7:0]}};
      1:expected_rgb={3{expected_gold[15:8]}};
      2:expected_rgb={24{expected_gold[16]}};
      3:expected_rgb=expected_gold[18]?24'hff0000:{3{expected_gold[7:0]}};
      4:expected_rgb={3{expected_gold[26:19]}};
      5:expected_rgb={24{expected_gold[29]}};
      6:expected_rgb=expected_gold[29]?24'hff0000:{3{expected_gold[7:0]}};
     endcase
     if(mode_rgb[m]!==expected_rgb)$fatal(1,"REVIEW_R1_SEVEN_MODES mode=%0d pos=%0d",m,output_position);
    end
    mode_pixels=mode_pixels+1;
   end
   output_position=output_position+1;
   if(output_position==921600)begin output_position=0;output_frames=output_frames+1;end
  end
  if(mid_injected)mid_age=mid_age+1;
  if(full_valid>=(CHECK==3?2:7)&&full_blank>=1&&invalid_frames>=(CHECK==1?5:1)&&output_frames==tap_frames&&output_position==0&&(CHECK!=2||post_failure_success>0))begin
   if(CHECK==1&&admission_cover!=4'b1111)$fatal(1,"ADMISSION_BOUNDARY_COVERAGE");
   if((CHECK!=2&&mode_pixels!=tap_checked)||stream.tag_read!=stream.tag_write||successful_descriptors==0)$fatal(1,"REVIEW_R2_QUEUE_CAPTURE_COVERAGE");
   if(CHECK==2&&(!mid_injected||!mid_released||failed_descriptors==0))$fatal(1,"MIDFRAME_RECOVERY_COVERAGE");
   if(CHECK==3&&zero_descriptors<1)$fatal(1,"VALID_ZERO_SNAPSHOT_NOT_PROVEN");
   if(!raster_acquired)$fatal(1,"MISSING_RASTER_ACQUISITION");
   $display("RASTER_ACQUISITION startup_fault_ticks=%0d qualified_during_startup=0 later_faults=0",startup_fault_ticks);
   $display("REVIEW_PASS connection lcd=%0d tap=%0d seven_modes=%0d full_valid=%0d legal_zero=%0d invalid=%0d tags_drained=1 admission_cover=%b successful_descriptors=%0d zero_descriptors=%0d failed_descriptors=%0d post_failure_success=%0d",checked,tap_checked,mode_pixels,full_valid,full_blank,invalid_frames,admission_cover,successful_descriptors,zero_descriptors,failed_descriptors,post_failure_success);$finish;
  end
 end
 initial begin #500000000;$fatal(1,"VIDEO_WATCHDOG");end
endmodule
