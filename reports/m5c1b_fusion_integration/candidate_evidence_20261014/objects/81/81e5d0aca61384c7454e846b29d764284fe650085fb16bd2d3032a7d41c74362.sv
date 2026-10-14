`timescale 1ns/1ps

module tb_replay_nonzero;
 localparam END_RESTORE_OLD=0;
 `include "end_declarations.svh"


 wire [31:0] nz_injections;wire [63:0] nz_sid;wire [767:0] nz_identity;
 wire nz_authorize;
 integer nz_equal=0,nz_rejected=0,nz_prom=0,nz_pixels=0,nz_refpixels=0,nz_fault_snapshot=0,nz_recovery_snapshot=0,nz_bad_samples=0,nz_model_a=0;
 reg nz_row_equal=1;reg [63:0] nz_event_sid=0;reg [1:0] nz_expected_class;reg nz_fault_frame;
 reg [31:0] nz_held_address;reg [7:0] nz_held_id;reg nz_hold_r=0;reg [138:0] nz_held_r;
 integer nz_event_file;
 initial nz_event_file=$fopen("nonzero_events.txt","w");
 parameter HEALTHY_FRAMES=3;

 parameter SERVICE_CYCLES=384,CAMERA_BLANK_CYCLES=478667;

 parameter SCENARIO=0,FUS_ENABLE=1,BG_REQUEST_CYCLES=96000000;

 reg [31:0] model_service_delay=SERVICE_CYCLES;

 integer fault_start_frame=0,recovered_healthy=0,fault_invalidations=0,fault_local_pixels=0;

 reg fault_active=0,fault_complete=0;

 reg [35:0] gold[0:921599];reg [2047:0] gold_path;

 initial begin if(!$value$plusargs("GOLD=%s",gold_path))$fatal(1,"GOLD_REQUIRED");$readmemh(gold_path,gold);end

 parameter CHECK=0;

 localparam TESTMODE=99;

 reg ui_clk=0,cam_clk=0,pix_clk=0,arst_n=0,run=0,stop=0;

 reg [831:0] previous_active_tuple=0;

 reg [2:0] previous_session_state=0;

 reg previous_tuple_guard=0;

 always @(posedge ui_clk)begin

  #1;

  if(!arst_n)begin previous_active_tuple=0;previous_session_state=0;previous_tuple_guard=0;end

  else begin

   if(previous_tuple_guard&&{dut.fusion.active_session,dut.fusion.active_descriptor}!==previous_active_tuple)

    $fatal(1,"SYSTEM_ACTIVE_TUPLE_STABILITY");

   previous_active_tuple={dut.fusion.active_session,dut.fusion.active_descriptor};

   previous_session_state=dut.fusion.state;

   previous_tuple_guard=(dut.fusion.state!=dut.fusion.IDLE)||dut.fusion.offer_busy||dut.fusion.telemetry_pending;

  end

 end

 always #5.208333 ui_clk=~ui_clk;

 integer cam_phase_seed=50708;initial begin if($value$plusargs("SEED=%d",cam_phase_seed))begin end $display("ACTUAL_CAMERA_PHASE seed=%0d initial_ns=%0.6f halfperiod_ns=5",cam_phase_seed,0.1+(cam_phase_seed%97)/10.0);#(0.1+(cam_phase_seed%97)/10.0);forever #5 cam_clk=~cam_clk;end

 integer pix_phase_seed=50708;initial begin if($value$plusargs("SEED=%d",pix_phase_seed))begin end $display("ACTUAL_PIXEL_PHASE seed=%0d initial_ns=%0.6f halfperiod_ns=6.720430",pix_phase_seed,0.2+(pix_phase_seed%79)/10.0);#(0.2+(pix_phase_seed%79)/10.0);forever #6.720430 pix_clk=~pix_clk;end

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

 wire aready,wready,bvalid,rvalid,rlast;wire [7:0] bid,rid;

 wire [1:0] bresp,rresp;wire [127:0] rdata;

 wire [95:0] max_wait,max_service;wire [31:0] qos_exceeded,accepts,completes,rejects;

 reg bg_req=0,bg_inflight=0;integer bg_beats=0,bg_count=0;

 wire [63:0] epoch;wire uart_tx;wire [5:0] led;

 wire [11:0] tap_x,tap_y;wire tap_valid;wire [1:0] tap_class;wire [63:0] stamp,tag_id,tag_epoch;

 wire [63:0] tap_display_seq,tap_config_generation,pixel_ticks,display_seq;

 wire fusion_request,fusion_release,fusion_release_final,fusion_release_ready,fusion_offer_valid,fusion_offer_take;

 wire [63:0] fusion_request_seq,fusion_release_session,fusion_session,fusion_read_session,fusion_ref_session;

 wire [159:0] fusion_config;wire [767:0] fusion_descriptor;

 wire fusion_ref_ready,fusion_ref_mask,fusion_retire,fusion_flush,fusion_prefilled,fusion_stop;

 wire [1:0] fusion_ref_class;wire [11:0] fusion_ref_x,fusion_ref_y,fusion_retire_row;

 wire fusion_tap_valid,fusion_tap_qualified,fusion_tap_support;

 wire [23:0] fused_rgb;wire fusion_eligible,fusion_promoted,fusion_frame_ok,fusion_frame_done;

 wire [31:0] fusion_age_frames,fusion_age_ticks;wire [479:0] fusion_telemetry_snapshot;

 wire fusion_export_ui,fusion_ddr_error_ui,fusion_hardstop_ui;

 reg [1:0] fusion_export_sync=0,fusion_ddr_error_sync=0,fusion_hardstop_sync=0;

 always @(posedge pix_clk)if(!arst_n)begin fusion_export_sync<=0;fusion_ddr_error_sync<=0;fusion_hardstop_sync<=0;end

 else begin fusion_export_sync<={fusion_export_sync[0],fusion_export_ui};fusion_ddr_error_sync<={fusion_ddr_error_sync[0],fusion_ddr_error_ui};fusion_hardstop_sync<={fusion_hardstop_sync[0],fusion_hardstop_ui};end

 reg [1:0] fusion_stop_sync=3;

 always @(posedge pix_clk)if(!arst_n)fusion_stop_sync<=3;else fusion_stop_sync<={fusion_stop_sync[0],fusion_stop};

 wire fusion_context_block,fusion_context_quiet,fusion_context_tail_fault;
 reg [1:0] key_n=3;wire [2:0] selected_mode;wire [7:0] selected_threshold;wire control_fusion;wire [63:0] control_generation;
 m5a_controls #(.DEBOUNCE_CYCLES(4),.LONG_CYCLES(64)) controls(.clk(pix_clk),.ce(1'b1),.arst_n(arst_n),.key_n(key_n),.frame_start(pix_sof),.threshold(selected_threshold),.mode(selected_mode),.pending_threshold(),.pending_mode(),.fusion_enable(control_fusion),.config_generation(control_generation));
 initial begin wait(arst_n);repeat(80)@(negedge pix_clk);if(FUS_ENABLE)begin key_n=0;repeat(100)@(negedge pix_clk);key_n=3;end
 forever begin @(posedge pix_sof);repeat(100)@(negedge pix_clk);key_n=0;repeat(20)@(negedge pix_clk);key_n=3;end end


 m5b1_system dut(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.rst_n(arst_n),.pll_locked(arst_n),.cal_done(arst_n),.cal_pass(arst_n),

  .cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.pix_sof(pix_sof),.pix_request(pix_request),.pix_data(pix_data),.frame_id(replay_frame_id),.epoch(epoch),.pix_qualified(),

  .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(selected_threshold),.tap_low(8'd32),.tap_filter(1'b1),.tap_frame_id(tag_id),.tap_epoch(tag_epoch),.tap_timestamp(stamp),.tap_display_seq(tap_display_seq),.tap_config_generation(tap_config_generation),.uart_tx(uart_tx),.led(led),

  .fusion_request(fusion_request),.fusion_request_seq(fusion_request_seq),.fusion_config(fusion_config),

  .fusion_release(fusion_release),.fusion_release_final(fusion_release_final),.fusion_release_session(fusion_release_session),.fusion_release_ready(fusion_release_ready),

  .fusion_offer_valid(fusion_offer_valid),.fusion_offer_take(fusion_offer_take),.fusion_descriptor(fusion_descriptor),.fusion_session(fusion_session),

  .fusion_context_block(fusion_context_block),.fusion_context_quiet(fusion_context_quiet),.fusion_context_tail_fault(fusion_context_tail_fault),.fusion_ce(1'b1),.fusion_read(fusion_tap_valid),.fusion_x(tap_x),.fusion_y(tap_y),.fusion_read_session(fusion_read_session),

  .fusion_ref_ready(fusion_ref_ready),.fusion_ref_class(fusion_ref_class),.fusion_ref_mask(fusion_ref_mask),.fusion_ref_x(fusion_ref_x),.fusion_ref_y(fusion_ref_y),.fusion_ref_session(fusion_ref_session),

  .fusion_retire(fusion_retire),.fusion_retire_row(fusion_retire_row),.fusion_flush(fusion_flush),.fusion_prefilled(fusion_prefilled),.fusion_stop(fusion_stop),

  .fusion_export_status(fusion_export_ui),.fusion_ddr_error_status(fusion_ddr_error_ui),.fusion_hardstop_status(fusion_hardstop_ui),

  .fusion_frame_done(fusion_frame_done),.fusion_telemetry_snapshot(fusion_telemetry_snapshot),

  .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),

  .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),

  .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));

 // Accelerate only UART serialization; complete byte stream still passes real packet CRC.

 defparam dut.background.REQUEST_CYCLES=BG_REQUEST_CYCLES;

 defparam dut.background.EXPORT_CYCLES=(TESTMODE==1||TESTMODE==4)?10000:960000000;

 parameter UART_CLOCK_HZ=960000;
 defparam dut.background.packet.uart.CLOCK=UART_CLOCK_HZ; // TB-only100x acceleration; BAUD460800 unchanged.

 assign fault=dut.video_fault;assign quarantine=dut.quarantine;assign reset_request=dut.reset_request;

 assign cam_bytes=dut.camera_bytes;assign disp_bytes=dut.display_bytes;assign cam_max=dut.camera_max;assign disp_min=dut.display_min;

 assign rejected=dut.rejected;assign max_service=dut.max_service;assign max_wait=dut.max_wait;assign qos_exceeded=dut.qos_exceeded;

 reg stall_bus=0;wire [31:0] bus_accepted,bus_completed,bus_max;

 selected_nonzero_ddr_model memory(.clk(ui_clk),.rst_n(arst_n),.stall(stall_bus),.authorize_class_fault(nz_authorize),.fault_sid(dut.fusion.reader.nonce),.fault_identity(dut.fusion.active_descriptor),.injection_count(nz_injections),.injected_sid(nz_sid),.injected_identity(nz_identity),

  .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),

  .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),

  .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready),

  .service_delay(model_service_delay),.inject_b_error(1'b0),.inject_r_error(1'b0),.accepted(bus_accepted),.completed(bus_completed),.max_service(bus_max));

 integer f,x,y;

 function [7:0] pixel(input integer frame,input integer pos);begin pixel=gold[pos][7:0];end endfunction

 initial begin

  

  

  repeat(10)@(negedge ui_clk);arst_n=1;wait(dut.run);@(negedge ui_clk);run=1;

  repeat(1500000)@(negedge cam_clk);cam_vs=0;repeat(20)@(negedge cam_clk);

  for(f=0;f<10000;f=f+1)begin // camera remains active beyond watchdog and60-frame gate

   cam_vs=1;

   for(y=0;y<720;y=y+1)begin

    for(x=0;x<1650;x=x+1)begin

     @(negedge cam_clk);cam_valid=x<1280;if(x<1280)cam_data=pixel(f,y*1280+x);

    end

   end

   @(negedge cam_clk);cam_valid=0;cam_vs=0;repeat(CAMERA_BLANK_CYCLES)@(negedge cam_clk);

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

  .in_hs(lcd_hs),.in_vs(lcd_vs),.in_sof(!lcd_vs),.filter_request(1'b1),.threshold(selected_threshold),.mode(selected_mode),

  .source_pixel_tick(pixel_ticks),.source_display_seq(display_seq),.source_config_generation(control_generation),

  .tap_display_seq(tap_display_seq),.tap_config_generation(tap_config_generation),

  .fusion_tap_valid(fusion_tap_valid),.fusion_tap_qualified(fusion_tap_qualified),.fusion_tap_support(fusion_tap_support),

  .tap_input_frame_id(lcd_frame_id),.tap_input_epoch(lcd_epoch),.tap_input_qualified(lcd_qualified),.tap_valid(tap_valid),.tap_class(tap_class),

  .tap_x(tap_x),.tap_y(tap_y),.tap_high(),.tap_low(),.tap_filter(),.tap_frame_id(tag_id),.tap_epoch(tag_epoch),.tap_timestamp(stamp),

  .out_rgb(out_rgb),.out_de(out_de),.out_hs(out_hs),.out_vs(out_vs),.out_raw(out_raw),.out_legacy_mag(out_mag),

  .out_threshold(out_threshold),.out_nms(out_nms),.out_legacy_bin(out_bin),.out_overlay_valid(out_ovvalid),.out_overlay_edge(out_ovedge),

  .out_nms_valid(out_nv),.out_canny_valid(out_cv),.out_canny_edge(out_ce),.out_mode(out_mode),.out_filter_enable(out_filter),

  .out_x(out_x),.out_y(out_y),.raster_fault(raster_fault));

 m5c_fusion_display display(.context_block(fusion_context_block),.context_quiet(fusion_context_quiet),.context_tail_fault(fusion_context_tail_fault),.clk(pix_clk),.rst_n(arst_n),.ce(1'b1),.raw_sof(pix_sof),

  .stop(fusion_stop_sync[1]),.enable(control_fusion),.export_status(fusion_export_sync[1]),.ddr_error_status(fusion_ddr_error_sync[1]),.hardstop_status(fusion_hardstop_sync[1]),.epoch(epoch),.config_generation(control_generation),.high_threshold(selected_threshold),.filter_enable(1'b1),

  .tap_valid(fusion_tap_valid),.tap_qualified(fusion_tap_qualified),.tap_support(fusion_tap_support),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),

  .final_de(out_de),.final_x(out_x),.final_y(out_y),.local_edge(out_ce),.raw_gray(out_raw),.mode(out_mode),.base_rgb(out_rgb),.fused_rgb(fused_rgb),

  .pixel_ticks(pixel_ticks),.display_seq(display_seq),.config_signature(fusion_config),.request_frame(fusion_request),.request_seq(fusion_request_seq),

  .offer_valid(fusion_offer_valid),.offer_take(fusion_offer_take),.offer_descriptor(fusion_descriptor),.offer_session(fusion_session),

  .pixel_release(fusion_release),.release_final(fusion_release_final),.release_session(fusion_release_session),.release_ready(fusion_release_ready),

  .read_session(fusion_read_session),.prefilled(fusion_prefilled),.ref_ready(fusion_ref_ready),.ref_class(fusion_ref_class),.ref_mask(fusion_ref_mask),

  .ref_x(fusion_ref_x),.ref_y(fusion_ref_y),.ref_session(fusion_ref_session),.retire(fusion_retire),.retire_row(fusion_retire_row),.flush(fusion_flush),

  .eligible(fusion_eligible),.age_frames(fusion_age_frames),.age_ticks(fusion_age_ticks),.promoted(fusion_promoted),.frame_ok(fusion_frame_ok),

  .frame_done(fusion_frame_done),.telemetry_snapshot(fusion_telemetry_snapshot));

 wire [23:0] osd_rgb;wire osd_de,osd_hs,osd_vs;

 m5a_osd osd(.clk(pix_clk),.ce(1'b1),.arst_n(arst_n),.rgb(fused_rgb),.de(out_de),.hs(out_hs),.vs(out_vs),

  .threshold(out_threshold),.mode(out_mode),.fusion_enable(control_fusion),.fusion_active(fusion_frame_ok),.fusion_age_valid(fusion_eligible),.fusion_age(fusion_age_frames),

  .out_rgb(osd_rgb),.out_de(osd_de),.out_hs(osd_hs),.out_vs(osd_vs));

 reg source_good[0:511];reg [63:0] source_ids[0:511];

 integer input_frames=0,input_pos=0,output_frames=0,output_pos=0,tap_frames=0,tap_pos=0;

 integer lcd_checked=0,tap_checked=0,output_checked=0,healthy=0,frame_additions=0,healthy_modes[0:6],mi;

 reg output_healthy=0;reg [35:0] expected;reg [23:0] expected_rgb;

 reg smoke_complete=0;
 function integer all_healthy_modes;integer j;begin all_healthy_modes=1;for(j=0;j<7;j=j+1)if(healthy_modes[j]==0)all_healthy_modes=0;end endfunction
 integer real_metadata_b=0,publishes=0;reg [319:0] committed_descriptor[0:1];reg [1:0] metadata_seen=0;

 integer previous_bg_state=-1,previous_scans=-1,ui_cycles=0;

 initial for(mi=0;mi<7;mi=mi+1)healthy_modes[mi]=0;

 initial if(SCENARIO!=0)begin

  wait(healthy>=1);wait(memory.state==0);@(negedge ui_clk);

  model_service_delay=SCENARIO==1?1632:10000;fault_active=1;fault_start_frame=output_frames;

  $display("SYSTEM_FAULT_START scenario=%0d frame=%0d delay=%0d",SCENARIO,output_frames,model_service_delay);

  wait(output_frames>=fault_start_frame+3);wait(memory.state==0);@(negedge ui_clk);

  model_service_delay=SERVICE_CYCLES;fault_active=0;fault_complete=1;

  $display("SYSTEM_FAULT_RECOVERY frame=%0d",output_frames);

 end

 always @(posedge ui_clk)if(arst_n&&dut.run)begin

  ui_cycles=ui_cycles+1;

  if(ui_cycles==1)$display("STARTUP_LEASE run=%b stop=%b ever_run=%b halted=%b reserved=%b leased=%b",dut.run,dut.stop,dut.background.ever_run,dut.background.lease.halted,dut.background.reserved,dut.pair_leased);

  if(previous_bg_state!=dut.background.state)begin

   $display("BG_STAGE ui=%0d state=%0d request=%0d accepted=%0d busyreject=%0d drops=%0d capcount=%0d capdesc=%b capgood=%b engbusy=%b finished=%b failed=%b telemetry=%b packetdone=%b run=%b stop=%b physicalA=%0d physicalDone=%0d",

    ui_cycles,dut.background.state,dut.background.requests,dut.background.accepted,dut.background.busy_rejected,dut.background.capture_drop,

    dut.background.cap_count,dut.background.descriptor_valid,dut.background.cap_descriptor[308],dut.background.eng_busy,dut.background.eng_finished,dut.background.eng_failed,

    dut.telemetry_ready,dut.background.packet_done,dut.run,dut.stop,bus_accepted,bus_completed);

   previous_bg_state=dut.background.state;

  end

  if(dut.background.engine.scans!=previous_scans)begin

   $display("ENGINE_PROGRESS ui=%0d scans=%0d pairs=%0d elapsed=%0d",ui_cycles,dut.background.engine.scans,dut.background.engine.pairs,dut.background.engine.elapsed);

   previous_scans=dut.background.engine.scans;

  end

  if(dut.background.descriptor_take)$display("CAPTURE_DESC ui=%0d success=%b epoch=%0d source=%0d job=%0d seq=%0d cfg=%0d stamp=%0d",ui_cycles,

   dut.background.cap_descriptor[308],dut.background.cap_descriptor[63:0],dut.background.cap_descriptor[127:64],dut.background.cap_descriptor[191:128],

   dut.background.cap_descriptor[383:320],dut.background.cap_descriptor[447:384],dut.background.cap_descriptor[575:512]);

  if(dut.lease_fault||dut.fusion.session_fault||fault||quarantine||reset_request)$fatal(1,"SYSTEM_PROTOCOL_FAULT");

  if(|dut.rejected)$fatal(1,"SYSTEM_PERMISSION_REJECT");

  if(dut.background.reserve_ack)metadata_seen[dut.background.reserve_slot]=0;

  if(bvalid&&bready&&bresp==0&&(memory.base==32'h010e6000/16||memory.base==(32'h010e6000+128)/16))begin

   real_metadata_b=real_metadata_b+1;metadata_seen[memory.base==(32'h010e6000+128)/16]=1;

   committed_descriptor[memory.base==(32'h010e6000+128)/16]={memory.mem[memory.base+2][63:0],memory.mem[memory.base+1],memory.mem[memory.base]};

   $display("REAL_METADATA_B ui=%0d slot=%0d",ui_cycles,memory.base==(32'h010e6000+128)/16);

  end

  if(dut.background.publication_ok)begin

   if(!metadata_seen[dut.background.eng_result_slot]||!dut.background.metadata_committed||dut.background.eng_descriptor!==dut.background.frozen||

      committed_descriptor[dut.background.eng_result_slot]!==dut.background.eng_descriptor)$fatal(1,"SYSTEM_METADATA_TUPLE");

   publishes=publishes+1;

  end

 end

 always @(posedge pix_clk)if(arst_n)begin

  if(lcd_de)begin

   if(input_pos==0)begin source_good[input_frames]=lcd_qualified;source_ids[input_frames]=lcd_frame_id;end

   if(lcd_qualified)begin

    if(lcd_gray!==gold[input_pos][7:0])$fatal(1,"SYSTEM_LCD_ORACLE frame=%0d pos=%0d",input_frames,input_pos);

    lcd_checked=lcd_checked+1;

   end

   if(input_pos==921599)begin input_pos=0;input_frames=input_frames+1;end else input_pos=input_pos+1;

  end

  if(fusion_tap_valid)begin

   if(tap_x!=tap_pos%1280||tap_y!=tap_pos/1280)$fatal(1,"SYSTEM_TAP_RASTER");

   if(fusion_tap_qualified!==source_good[tap_frames])$fatal(1,"SYSTEM_TAP_QUALIFICATION");

   if(fusion_tap_qualified)begin

    if(tap_class!==gold[tap_pos][31:30]||tag_id!=source_ids[tap_frames]||tag_epoch!=epoch||tap_config_generation!=control_generation)$fatal(1,"SYSTEM_TAP_ORACLE");

    tap_checked=tap_checked+1;

   end

   if(tap_pos==921599)begin tap_pos=0;tap_frames=tap_frames+1;end else tap_pos=tap_pos+1;

  end

  if(!out_de&&fused_rgb!==0)$fatal(1,"SYSTEM_BLANKING_RGB");

  if(out_de)begin

   if(SCENARIO!=0&&output_healthy&&!fusion_frame_ok)begin output_healthy=0;fault_invalidations=fault_invalidations+1;end

   if(fault_active&&!fusion_frame_ok)fault_local_pixels=fault_local_pixels+1;

   if(out_x!=output_pos%1280||out_y!=output_pos/1280)$fatal(1,"SYSTEM_OUTPUT_RASTER");

   if(output_pos==0)begin output_healthy=fusion_frame_ok;frame_additions=0;end

   if(source_good[output_frames])begin

    expected=gold[output_pos];if(nz_injections==1&&display.session==nz_sid&&out_y==110)expected[33]=0;

    if({out_ce,out_cv,out_nv,out_nms,out_ovedge,out_ovvalid,out_bin,out_mag,out_raw}!==expected[29:0])$fatal(1,"SYSTEM_M5A_ORACLE frame=%0d pos=%0d",output_frames,output_pos);

    case(out_mode)

     0:expected_rgb={3{expected[7:0]}};

     1:expected_rgb={3{expected[15:8]}};

     2:expected_rgb={24{expected[16]}};

     3:expected_rgb=expected[18]?24'hff0000:{3{expected[7:0]}};

     4:expected_rgb={3{expected[26:19]}};

     5:expected_rgb={24{expected[29]}};

     6:expected_rgb=expected[29]?24'hff0000:(fusion_promoted?24'h00ffff:{3{expected[7:0]}});

    endcase

    if(fused_rgb!==expected_rgb)$fatal(1,"SYSTEM_FUSED_RGB frame=%0d pos=%0d",output_frames,output_pos);

    if(fusion_promoted&&!expected[33])$fatal(1,"SYSTEM_ILLEGAL_PROMOTION frame=%0d mode=%0d x=%0d y=%0d local=%b expected_local=%b expected_class=%0d expected_added=%b delayed=%h framecookie=%h session=%h refsession=%h refclass=%0d refmask=%b",output_frames,out_mode,out_x,out_y,out_ce,expected[29],expected[31:30],expected[33],display.fusion.delayed,display.fusion.frame_cookie,display.session,display.ref_session,display.ref_class,display.ref_mask);

    if(output_healthy&&fusion_promoted!==expected[33])$fatal(1,"SYSTEM_HEALTHY_PIXEL pos=%0d",output_pos);

    output_checked=output_checked+1;

   end else if(fusion_promoted)$fatal(1,"SYSTEM_INVALID_SOURCE_PROMOTION");

   if(fusion_promoted)frame_additions=frame_additions+1;

   if(output_healthy&&!fusion_frame_ok)$fatal(1,"SYSTEM_HEALTHY_UNDERRUN frame=%0d y=%0d",output_frames,out_y);

   if(output_pos==921599)begin

    if(output_healthy)begin

     if(frame_additions!=((nz_injections==1&&display.session==nz_sid)?6:7))$fatal(1,"SYSTEM_UTILITY additions=%0d",frame_additions);

     healthy=healthy+1;if(fault_complete)recovered_healthy=recovered_healthy+1;healthy_modes[out_mode]=healthy_modes[out_mode]+1;

    end

    $display("SYSTEM_FRAME frame=%0d mode=%0d healthy=%0d added=%0d published=%0d bg=%0d request=%0d accept=%0d drop=%0d engstate=%0d row=%0d column=%0d captureactive=%b qualifiedpixels=%0d C2=%b/%b maxservice=%0d",

     output_frames,out_mode,healthy,frame_additions,publishes,dut.background.state,dut.background.requests,dut.background.accepted,dut.background.capture_drop,

     dut.background.engine.state,dut.background.engine.row,dut.background.engine.column,dut.background.capture.active,tap_checked,dut.ca[2],dut.car[2],bus_max);

    $display("FUSION_CADENCE frame=%0d state=%0d active_session=%0d offer=%b offered_session=%0d prefilled=%b admitted=%b broken=%b reason=%h underflow=%0d late=%0d telemetry_pending=%b request_cycles=%0d",
     output_frames,dut.fusion.state,dut.fusion.active_session,fusion_offer_valid,fusion_session,fusion_prefilled,display.frame_admitted,display.broken,display.reason_bits,display.underflows,display.late_rows,dut.fusion.telemetry_pending,BG_REQUEST_CYCLES);
    end_checked_seq=display_seq;end_checked_qualified=output_healthy;
    output_pos=0;output_frames=output_frames+1;

    if((FUS_ENABLE&&SCENARIO==0&&healthy>=HEALTHY_FRAMES&&nz_fault_snapshot&&nz_recovery_snapshot)||

       (!FUS_ENABLE&&output_frames>=9)||(SCENARIO!=0&&fault_complete&&recovered_healthy>=2))begin

     if(SCENARIO!=0&&(fault_local_pixels==0||fault_invalidations==0))$fatal(1,"SYSTEM_FAULT_COVERAGE");

     if(!FUS_ENABLE&&frame_additions!=0)$fatal(1,"SYSTEM_FUS_OFF_PROMOTION");

     for(mi=0;mi<7;mi=mi+1)if(FUS_ENABLE&&SCENARIO==0&&HEALTHY_FRAMES>=7&&healthy_modes[mi]==0)$fatal(1,"SYSTEM_MODE_COVERAGE");

     if(FUS_ENABLE&&publishes==0)$fatal(1,"SYSTEM_PUBLISH_COVERAGE");

     #2;$display("M5C1B_SMOKE_PIXELS REAL_SYSTEM healthy=%0d lcd=%0d taps=%0d output=%0d max_service=%0d osd_pixels=%0d scenario=%0d invalidations=%0d fallback_pixels=%0d recovered=%0d",healthy,lcd_checked,tap_checked,output_checked,bus_max,osd_pixels,SCENARIO,fault_invalidations,fault_local_pixels,recovered_healthy);if(nz_fault_snapshot&&nz_recovery_snapshot)begin smoke_complete=1;end_try_target;end

    end

   end else output_pos=output_pos+1;

  end

 end

 initial begin #4000000000.0;$fatal(1,"SYSTEM_WATCHDOG healthy=%0d published=%0d",healthy,publishes);end



 wire [23:0] baseline_osd_rgb;wire baseline_osd_de,baseline_osd_hs,baseline_osd_vs;

 m5a_osd_baseline_reference baseline_osd(.clk(pix_clk),.ce(1'b1),.arst_n(arst_n),

  .rgb(fused_rgb),.de(out_de),.hs(out_hs),.vs(out_vs),.threshold(out_threshold),.mode(out_mode),

  .out_rgb(baseline_osd_rgb),.out_de(baseline_osd_de),.out_hs(baseline_osd_hs),.out_vs(baseline_osd_vs));

 function [34:0] osd_glyph(input [7:0] c);begin case(c)

 "F":osd_glyph=35'b11111_10000_10000_11110_10000_10000_10000;

 "U":osd_glyph=35'b10001_10001_10001_10001_10001_10001_01110;

 "S":osd_glyph=35'b01111_10000_10000_01110_00001_00001_11110;

 "L":osd_glyph=35'b10000_10000_10000_10000_10000_10000_11111;

 "O":osd_glyph=35'b01110_10001_10001_10001_10001_10001_01110;

 "C":osd_glyph=35'b01110_10001_10000_10000_10000_10001_01110;

 "A":osd_glyph=35'b01110_10001_10001_11111_10001_10001_10001;

 "-":osd_glyph=35'b00000_00000_00000_11111_00000_00000_00000;

 "0":osd_glyph=35'b01110_10001_10011_10101_11001_10001_01110;

 "1":osd_glyph=35'b00100_01100_00100_00100_00100_00100_01110;

 "2":osd_glyph=35'b01110_10001_00001_00010_00100_01000_11111;

 "9":osd_glyph=35'b01110_10001_10001_01111_00001_00001_01110;



 "3":osd_glyph=35'b11110_00001_00001_01110_00001_00001_11110;

 "4":osd_glyph=35'b00010_00110_01010_10010_11111_00010_00010;

 "5":osd_glyph=35'b11111_10000_10000_11110_00001_00001_11110;

 "6":osd_glyph=35'b01110_10000_10000_11110_10001_10001_01110;

 "7":osd_glyph=35'b11111_00001_00010_00100_01000_01000_01000;

 "8":osd_glyph=35'b01110_10001_10001_01110_10001_10001_01110;

 default:osd_glyph=0;

 endcase end endfunction

 integer osd_pixels=0,osd_slot,osd_col,osd_row,osd_age,osd_digit;

 reg osd_window,osd_sample_de;reg [23:0] osd_expected;reg [7:0] osd_char;reg [34:0] osd_bitmap;

 always @(posedge pix_clk)if(arst_n)begin

  osd_sample_de=out_de;

  osd_window=control_fusion&&out_de&&out_mode==6&&out_x>=244&&out_x<412&&out_y>=12&&out_y<34;

  osd_expected=0;

  if(osd_window)begin

   osd_slot=($signed({1'b0,out_x})-248)/16;osd_col=($signed({1'b0,out_x})-248)%16/2;osd_row=(out_y-16)/2;osd_char=" ";

   case(osd_slot)

    0:osd_char=fusion_frame_ok?"F":"L";1:osd_char=fusion_frame_ok?"U":"O";2:osd_char=fusion_frame_ok?"S":"C";

    3:osd_char=fusion_frame_ok?" ":"A";4:osd_char=fusion_frame_ok?" ":"L";6:osd_char="A";

    7,8,9:begin osd_age=fusion_age_frames>999?999:fusion_age_frames;

     osd_digit=osd_slot==7?osd_age/100:osd_slot==8?(osd_age/10)%10:osd_age%10;osd_char=fusion_eligible?48+osd_digit:"-";end

   endcase

   osd_bitmap=osd_glyph(osd_char);

   if(out_x>=248&&out_x<408&&out_y>=16&&out_y<30&&osd_col<5&&osd_bitmap[34-osd_row*5-osd_col])osd_expected=24'hffffff;

  end

  #1;

  if({osd_de,osd_hs,osd_vs}!=={baseline_osd_de,baseline_osd_hs,baseline_osd_vs})$fatal(1,"SYSTEM_OSD_TIMING");

  if(osd_rgb!==(osd_window?osd_expected:baseline_osd_rgb))$fatal(1,"SYSTEM_OSD_PIXELS window=%b expected=%h actual=%h",osd_window,osd_window?osd_expected:baseline_osd_rgb,osd_rgb);

  if(osd_sample_de)osd_pixels=osd_pixels+1;

 end




 integer wirefile,metafile,wire_count=0,telemetry_accepts=0,packet_starts=0,packet_dones=0,packet_takes=0,capconfirms=0,revokes=0;
 integer healthy_accept_index=0,telemetry_starts=0,expected_wire_bytes=0;integer mode_seen[0:6],cm;reg [7:0] serial_byte;integer bitn;localparam real UART_BIT_NS=10.416666*UART_CLOCK_HZ/460800.0;
 initial begin wirefile=$fopen("serial.hex","w");metafile=$fopen("uart_meta.txt","w");for(cm=0;cm<7;cm=cm+1)mode_seen[cm]=0;end
 always @(negedge uart_tx)if(arst_n)begin
  #(UART_BIT_NS*1.5);for(bitn=0;bitn<8;bitn=bitn+1)begin serial_byte[bitn]=uart_tx;#(UART_BIT_NS);end
  if(uart_tx!==1'b1)$fatal(1,"SMOKE_UART_STOP");$fdisplay(wirefile,"%02h",serial_byte);wire_count=wire_count+1;
 end
 always @(posedge pix_clk)if(arst_n)begin
  if(pix_sof)mode_seen[selected_mode]=mode_seen[selected_mode]+1;
  if(!control_fusion&&fusion_promoted)$fatal(1,"SMOKE_FUSOFF_PROMOTION");
  if(fusion_frame_done)$fdisplay(metafile,"FRAME %0d %0d %0d %0120h",display_seq,frame_additions,output_healthy,fusion_telemetry_snapshot);
 end
 always @(posedge ui_clk)if(arst_n)begin
  if(dut.fusion.cap_valid&&dut.fusion.state==dut.fusion.WAIT_CAPTURE&&!dut.fusion.cancel_now)capconfirms=capconfirms+1;
  if(dut.fusion.state==dut.fusion.RELEASE)revokes=revokes+1;
  if(dut.telemetry.accepting)begin telemetry_accepts=telemetry_accepts+1;if(dut.telemetry.held[287:256]==7&&dut.telemetry.source_guard!=0)healthy_accept_index=telemetry_accepts;
   $fdisplay(metafile,"INPUT %0120h %0192h %016h %0d %016h %016h",dut.telemetry.held,dut.telemetry.active_descriptor,dut.telemetry.active_token,dut.telemetry.active_slot,dut.telemetry.rejected_jobs,dut.telemetry.protocol_faults);
  end
  if(dut.background.packet_start)begin
   if(dut.background.packet.packet_type==4)begin
    if(!dut.telemetry_ready||dut.telemetry_take||telemetry_starts>=telemetry_accepts)$fatal(1,"SMOKE_PACKET_REARM_OR_TYPE");telemetry_starts=telemetry_starts+1;
   end
   $fdisplay(metafile,"PACKET %0d %0d %080h",dut.background.packet.packet_type,dut.background.packet.length,dut.background.packet.descriptor);
   expected_wire_bytes=expected_wire_bytes+68+dut.background.packet.length;packet_starts=packet_starts+1;
  end
  if(dut.background.packet_done)packet_dones=packet_dones+1;
  if(dut.telemetry_take)packet_takes=packet_takes+1;
 end
 initial begin wait(end_finish_permitted);end_assert_complete;
  $fdisplay(end_file,"FINISH %0d %0d %0d %0d %0d %0d %0d %0d %0t",end_target_seq,end_target_ui,end_src_count,end_ui_count,end_start_count,end_done_count,end_take_count,end_ui_quiet,$time);$fclose(end_file);
  if(capconfirms==0||revokes==0||packet_starts!=packet_dones||telemetry_starts!=packet_takes||wire_count!=expected_wire_bytes)$fatal(1,"SMOKE_CONTEXT_UART_COVERAGE");
  for(cm=0;cm<7;cm=cm+1)if(mode_seen[cm]==0)$fatal(1,"SMOKE_REAL_CONTROL_MODES");
  $fclose(wirefile);$fclose(metafile);$fclose(nz_event_file);if(nz_injections!=1||nz_bad_samples!=1)$fatal(1,"REAL_CLASS_MISMATCH_COVERAGE");$display("HEALTHY_MODE_COUNTS %0d %0d %0d %0d %0d %0d %0d",healthy_modes[0],healthy_modes[1],healthy_modes[2],healthy_modes[3],healthy_modes[4],healthy_modes[5],healthy_modes[6]);$display("M5C1B_PASS SELECTED_NONZERO healthy=%0d published=%0d LCD=%0d tap=%0d output=%0d OSD=%0d capture=%0d revoke=%0d packets=%0d wirebytes=%0d",healthy,publishes,lcd_checked,tap_checked,output_checked,osd_pixels,capconfirms,revokes,packet_starts,wire_count);$finish;
 end


 // Outer client2 is secondary background mux; latched owner1 is real fusion reader.
 assign nz_authorize=healthy>=1&&nz_injections==0&&dut.arbiter.owner==2&&dut.bg_mux.busy&&dut.bg_mux.owner==1&&
  !atype&&aaddr==((dut.fusion.reader.pair_slot?32'h01039000:32'h01000000)+32'd35200)&&
  dut.fusion.reader.row==110&&dut.fusion.reader.state==dut.fusion.reader.CLASS&&
  display.frame_admitted&&fusion_frame_ok&&display.session==dut.fusion.reader.nonce&&display.session!=0;
 always @(posedge ui_clk)if(arst_n)begin
  if(nz_hold_r&&{rid,rresp,rlast,rdata}!==nz_held_r)$fatal(1,"NZ_R_HELD_STABILITY");
  nz_hold_r=rvalid&&!rready;nz_held_r={rid,rresp,rlast,rdata};
  if(avalid&&aready&&nz_authorize)begin
   if(nz_model_a!=0||dut.bg_mux.owner!==1||dut.arbiter.owner!==2||aid!=3||alen!=19)$fatal(1,"NZ_REAL_READER_OWNERSHIP");
   nz_model_a=nz_model_a+1;nz_held_address=aaddr;nz_held_id=aid;
   $display("NZ_OWNER outer=%0d secondary=%0d sid=%0d nonce=%0d slot=%0d A=%h id=%0d len=%0d",dut.arbiter.owner,dut.bg_mux.owner,display.session,dut.fusion.reader.nonce,dut.fusion.reader.pair_slot,aaddr,aid,alen);
  end
 end
 always @(posedge pix_clk)if(arst_n)begin
  if(display.first_tap)begin nz_equal=0;nz_rejected=0;nz_prom=0;nz_pixels=0;nz_refpixels=0;nz_row_equal=1;nz_event_sid=display.session;end
  if(display.dvalid&&display.frame_admitted&&display.have_offer&&!display.broken&&control_fusion&&!fusion_context_block)begin
   if(!fusion_ref_ready||fusion_ref_x!=display.dx||fusion_ref_y!=display.dy||fusion_ref_session!=display.dsession||display.dsession!=display.session)$fatal(1,"NZ_REFERENCE_TAG_OR_READY");
   nz_expected_class=gold[display.dy*1280+display.dx][31:30];
   if(display.dclass!==nz_expected_class)$fatal(1,"NZ_CURRENT_CLASS_GOLD");
   if(nz_injections==1&&display.session==nz_sid&&display.dy==110&&display.dx==163)begin nz_expected_class=0;nz_bad_samples=nz_bad_samples+1;end
   if(fusion_ref_class!==nz_expected_class||fusion_ref_mask!==gold[display.dy*1280+display.dx][32])$fatal(1,"NZ_REFERENCE_DATA_ORACLE");
   if(display.dx==0)nz_row_equal=1;
   nz_row_equal=nz_row_equal&&(display.dclass==nz_expected_class);nz_refpixels=nz_refpixels+1;
   if(display.dx==1279)begin if(nz_row_equal)nz_equal=nz_equal+1;else nz_rejected=nz_rejected+1;end
  end
  if(out_de)begin nz_pixels=nz_pixels+1;if(fusion_promoted)nz_prom=nz_prom+1;end
  if(fusion_frame_done&&output_healthy)begin
   nz_fault_frame=nz_injections==1&&display.session==nz_sid;
   if(nz_pixels!=921600||nz_refpixels!=921600||nz_equal!=(nz_fault_frame?719:720)||nz_rejected!=(nz_fault_frame?1:0)||nz_prom!=(nz_fault_frame?6:7))$fatal(1,"NZ_INDEPENDENT_COORDINATE_COUNTS e=%0d r=%0d p=%0d pixels=%0d refs=%0d",nz_equal,nz_rejected,nz_prom,nz_pixels,nz_refpixels);
   if(fusion_telemetry_snapshot[223:192]!=nz_equal||fusion_telemetry_snapshot[255:224]!=nz_rejected||fusion_telemetry_snapshot[287:256]!=nz_prom)$fatal(1,"NONZERO_REJECT_COUNTER_MISMATCH equal=%0d rejected=%0d promoted=%0d",nz_equal,nz_rejected,nz_prom);
   if(nz_fault_frame)begin
    if(!fusion_telemetry_snapshot[327]||display.underflows!=0)$fatal(1,"NZ_MISMATCH_REASON_OR_UNDERFLOW");nz_fault_snapshot=1;
   end else if(nz_fault_snapshot)nz_recovery_snapshot=1;
   $fdisplay(nz_event_file,"NZ_FRAME %0d %0d %0d %0d %0d %0d",display_seq,display.session,nz_equal,nz_rejected,nz_prom,nz_fault_frame);
   $display("NZ_FRAME seq=%0d sid=%0d equal=%0d rejected=%0d promoted=%0d fault=%b recovery=%0d",display_seq,display.session,nz_equal,nz_rejected,nz_prom,nz_fault_frame,nz_recovery_snapshot);
  end
 end
 `include "end_protocol.svh"
endmodule

