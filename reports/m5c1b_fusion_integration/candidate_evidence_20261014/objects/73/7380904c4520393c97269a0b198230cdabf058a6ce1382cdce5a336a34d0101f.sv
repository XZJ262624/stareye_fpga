`timescale 1ns/1ps

module tb_retry_starvation;
 reg monitor_armed=0;
 localparam END_RESTORE_OLD=0;
 `include "end_declarations.svh"

 parameter HEALTHY_FRAMES=60;

 reg off_have_healthy=0,output_off=0;integer off_step=0,off_frames=0,off_modes[0:6],off_i;reg [63:0] off_generation;reg [7:0] off_threshold;
 initial for(off_i=0;off_i<7;off_i=off_i+1)off_modes[off_i]=0;
 function integer all_off_modes;integer j;begin all_off_modes=1;for(j=0;j<7;j=j+1)if(off_modes[j]==0)all_off_modes=0;end endfunction

 integer sid_commits=0,sid_offers=0,sid_admissions=0,sid_lcd_frames=0,sid_k;reg [63:0] sid_slots[0:3],sid_admitted[0:511];reg [3:0] sid_slots_valid=0;
 reg [1:0] sid_commit_slot;reg [63:0] sid_commit_value;

 reg starve_deny=0,starve_counting=0,starve_drained=0,starve_target_frame=0;
 integer starve_pending_cycles=0,starve_denial_cycles=0,starve_rt_accepts=0,starve_rt_done=0,starve_c2_accepts=0,starve_local_pixels=0,starve_local_frames=0,starve_recovery_frames=0;
 reg [63:0] starve_session=0,starve_previous_session=0;reg [31:0] starve_address=0;reg [7:0] starve_length=0,starve_id=0;reg starve_type=0;
 integer expected_bad_r=0,reader_outstanding=0,queued_cancels=0,cancel_releases=0,cancel_recoveries=0;
 reg physical_pending=0;reg [7:0] physical_id=0;reg [7:0] physical_len=0;reg physical_write=0;
 integer physical_beats=0;reg awaiting_queued_cancel=0,cancel_seen=0,cancel_released=0;
 reg [63:0] cancelled_session=0;

 integer repeat_ids=0,jump_ids=0;
 reg hard_loss=0,inject_read_error=0;

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
 forever begin @(posedge pix_sof);repeat(100)@(negedge pix_clk);
  if(SCENARIO==8&&off_have_healthy&&off_step==0&&!dut.fusion.export_exclusive&&dut.fusion.result_valid&&dut.fusion.result_descriptor[735:576]==fusion_config)begin
   off_generation=control_generation;off_threshold=selected_threshold;off_step=1;
   $display("FUSOFF_REAL_LONGPRESS generation=%0d threshold=%0d latest=%0192h",off_generation,off_threshold,dut.fusion.result_descriptor);
   key_n=0;repeat(100)@(negedge pix_clk);key_n=3;
  end else begin key_n=0;repeat(20)@(negedge pix_clk);key_n=3;end
 end end
 always @(negedge pix_clk)if(arst_n&&SCENARIO==8&&off_step==1&&!control_fusion)begin off_step=2;$display("FUSOFF_ACTUAL_CONTROL_LATCH seq=%0d generation=%0d threshold=%0d",display_seq,control_generation,selected_threshold);end
 always @(posedge pix_clk)if(arst_n&&SCENARIO==8&&off_step==2)begin
  if(control_fusion||control_generation!==off_generation||selected_threshold!==off_threshold)$fatal(1,"FUSOFF_CHANGED_CONFIGURATION");
  if(fusion_frame_done&&output_off&&fusion_telemetry_snapshot[287:192]!==96'd0)$fatal(1,"FUSOFF_NONZERO_FRAME_COUNTERS");
 end


 m5b1_system dut(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.rst_n(arst_n),.pll_locked(arst_n),.cal_done(arst_n),.cal_pass(arst_n&&!hard_loss),

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

 selected_fault_ddr_model_v9 memory(.clk(ui_clk),.rst_n(arst_n),.stall(stall_bus),

  .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),

  .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),

  .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready),

  .service_delay(model_service_delay),.inject_b_error(1'b0),.inject_r_error(inject_read_error&&expected_bad_r==0),.accepted(bus_accepted),.completed(bus_completed),.max_service(bus_max));

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

 initial if(SCENARIO==1||SCENARIO==2)begin

  wait(healthy>=1);wait(memory.state==0);@(negedge ui_clk);

  model_service_delay=SCENARIO==1?1632:384;if(SCENARIO==2)force dut.arbiter.safe_window=1'b0;fault_active=1;fault_start_frame=output_frames;

  $display("SYSTEM_FAULT_START scenario=%0d frame=%0d delay=%0d",SCENARIO,output_frames,model_service_delay);

  wait(output_frames>=fault_start_frame+3);wait(memory.state==0);@(negedge ui_clk);

  model_service_delay=SERVICE_CYCLES;if(SCENARIO==2)release dut.arbiter.safe_window;fault_active=0;fault_complete=1;

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

  if(dut.lease_fault||dut.fusion.session_fault||fault)$fatal(1,"SYSTEM_PROTOCOL_FAULT");

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

   if(SCENARIO==7)begin
    if(output_pos==0)starve_target_frame=starve_session!=0&&display.session==starve_session;
    if(starve_target_frame)begin
     if(fusion_frame_ok||fusion_promoted||fused_rgb!==out_rgb)$fatal(1,"STARVATION_AFFECTED_FRAME_NOT_LOCAL");starve_local_pixels=starve_local_pixels+1;
     if(output_pos==921599)begin if(starve_local_pixels!=921600)$fatal(1,"STARVATION_LOCAL_PIXEL_COUNT");starve_local_frames=starve_local_frames+1;end
    end
    if(output_pos==921599&&output_healthy&&fault_complete)begin
     if(display.session==starve_session||display.session==0)$fatal(1,"STARVATION_RECOVERY_OLD_SESSION");starve_recovery_frames=starve_recovery_frames+1;
    end
   end
   if(output_pos==0)begin output_healthy=fusion_frame_ok;frame_additions=0;output_off=SCENARIO==8&&off_step==2&&!control_fusion;end
   if(output_off&&(fusion_promoted||fusion_frame_ok||fused_rgb!==out_rgb))$fatal(1,"FUSOFF_NOT_EXACT_LOCAL");

   if(source_good[output_frames])begin

    expected=gold[output_pos];

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

     if(frame_additions!=7)$fatal(1,"SYSTEM_UTILITY additions=%0d",frame_additions);

     healthy=healthy+1;off_have_healthy=1;if(fault_complete)recovered_healthy=recovered_healthy+1;healthy_modes[out_mode]=healthy_modes[out_mode]+1;

    end

    $display("SYSTEM_FRAME frame=%0d mode=%0d healthy=%0d added=%0d published=%0d bg=%0d request=%0d accept=%0d drop=%0d engstate=%0d row=%0d column=%0d captureactive=%b qualifiedpixels=%0d C2=%b/%b maxservice=%0d",

     output_frames,out_mode,healthy,frame_additions,publishes,dut.background.state,dut.background.requests,dut.background.accepted,dut.background.capture_drop,

     dut.background.engine.state,dut.background.engine.row,dut.background.engine.column,dut.background.capture.active,tap_checked,dut.ca[2],dut.car[2],bus_max);

    $display("FUSION_CADENCE frame=%0d state=%0d active_session=%0d offer=%b offered_session=%0d prefilled=%b admitted=%b broken=%b reason=%h underflow=%0d late=%0d telemetry_pending=%b request_cycles=%0d",
     output_frames,dut.fusion.state,dut.fusion.active_session,fusion_offer_valid,fusion_session,fusion_prefilled,display.frame_admitted,display.broken,display.reason_bits,display.underflows,display.late_rows,dut.fusion.telemetry_pending,BG_REQUEST_CYCLES);
    if(output_off)begin
     if(frame_additions!=0||!source_good[output_frames]||!dut.fusion.result_valid||dut.fusion.export_exclusive||dut.fusion.result_descriptor[735:576]!==fusion_config||display_seq<dut.fusion.result_descriptor[383:320]||display_seq-dut.fusion.result_descriptor[383:320]>120||pixel_ticks<dut.fusion.result_descriptor[575:512]||pixel_ticks-dut.fusion.result_descriptor[575:512]>148500000)$fatal(1,"FUSOFF_NO_USABLE_COMPATIBLE_HISTORY");
     off_frames=off_frames+1;off_modes[out_mode]=off_modes[out_mode]+1;$display("FUSOFF_COMPLETE_FRAME count=%0d mode=%0d added=%0d available=1",off_frames,out_mode,frame_additions);
    end
    end_checked_seq=display_seq;end_checked_qualified=output_healthy;
    output_pos=0;output_frames=output_frames+1;

    if((FUS_ENABLE&&SCENARIO==0&&healthy>=HEALTHY_FRAMES&&all_healthy_modes())||

       (!FUS_ENABLE&&output_frames>=9)||(SCENARIO==8&&off_frames>=9&&all_off_modes())||((SCENARIO==1||SCENARIO==2||SCENARIO==6||SCENARIO==7)&&fault_complete&&recovered_healthy>=2))begin

     if((SCENARIO==1||SCENARIO==2||SCENARIO==7)&&(fault_local_pixels==0||fault_invalidations==0))$fatal(1,"SYSTEM_FAULT_COVERAGE");

     if(!FUS_ENABLE&&frame_additions!=0)$fatal(1,"SYSTEM_FUS_OFF_PROMOTION");

     for(mi=0;mi<7;mi=mi+1)if(FUS_ENABLE&&SCENARIO==0&&HEALTHY_FRAMES>=7&&healthy_modes[mi]==0)$fatal(1,"SYSTEM_MODE_COVERAGE");

     
     if(SCENARIO==6&&(repeat_ids==0||jump_ids==0||sid_commits==0||sid_offers==0||sid_admissions==0||sid_lcd_frames==0))$fatal(1,"SYSTEM_SOURCE_ID_COVERAGE");
     if(SCENARIO==2&&(queued_cancels==0||cancel_releases==0||cancel_recoveries==0))$fatal(1,"SYSTEM_READER_CANCEL_COVERAGE");
     if(SCENARIO==1&&memory.max_by_id[3]!=1632)$fatal(1,"SYSTEM_BG_DELAY_COVERAGE");
     if(SCENARIO==7&&(starve_pending_cycles<10000||starve_c2_accepts!=0||starve_rt_accepts==0||starve_rt_done==0||!starve_drained||starve_local_frames==0||starve_recovery_frames<2||memory.max_by_id[3]>384))$fatal(1,"STARVATION_REAL_QUEUE_DRAIN_RECOVERY_COVERAGE");
     if(SCENARIO==7)$display("STARVATION_FINAL pending=%0d denial=%0d C2accept=%0d RTaccept=%0d RTdone=%0d drained=%b localframes=%0d recovery=%0d maxservice=%0d",starve_pending_cycles,starve_denial_cycles,starve_c2_accepts,starve_rt_accepts,starve_rt_done,starve_drained,starve_local_frames,starve_recovery_frames,memory.max_by_id[3]);
     $display("SELECTED_FAULT_COVERAGE scenario=%0d repeat=%0d jump=%0d commits=%0d offers=%0d admissions=%0d LCDframes=%0d queued=%0d releases=%0d recoveries=%0d",SCENARIO,repeat_ids,jump_ids,sid_commits,sid_offers,sid_admissions,sid_lcd_frames,queued_cancels,cancel_releases,cancel_recoveries);

     if(FUS_ENABLE&&publishes==0)$fatal(1,"SYSTEM_PUBLISH_COVERAGE");

     #2;$display("M5C1B_SMOKE_PIXELS REAL_SYSTEM healthy=%0d lcd=%0d taps=%0d output=%0d max_service=%0d osd_pixels=%0d scenario=%0d invalidations=%0d fallback_pixels=%0d recovered=%0d",healthy,lcd_checked,tap_checked,output_checked,bus_max,osd_pixels,SCENARIO,fault_invalidations,fault_local_pixels,recovered_healthy);if(1)begin smoke_complete=1;end_try_target;end

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
  $fclose(wirefile);$fclose(metafile);$display("HEALTHY_MODE_COUNTS %0d %0d %0d %0d %0d %0d %0d",healthy_modes[0],healthy_modes[1],healthy_modes[2],healthy_modes[3],healthy_modes[4],healthy_modes[5],healthy_modes[6]);$display("M5C1B_PASS SELECTED_STARVATION_V11 healthy=%0d published=%0d LCD=%0d tap=%0d output=%0d OSD=%0d capture=%0d revoke=%0d packets=%0d wirebytes=%0d",healthy,publishes,lcd_checked,tap_checked,output_checked,osd_pixels,capconfirms,revokes,packet_starts,wire_count);$finish;
 end

 reg terminal_guard=0;reg [959:0] frozen_lease;reg [5:0] frozen_owners;
 integer v7_first4=0,v7_watchdog_transition=0,v7_cycle=0,v7_log;
 integer stopped_accepts,stopped_completes,stopped_publishes;
 integer next_normal_presented=0;reg v6_stalled_r=0;reg [138:0] v6_held_r;
 // Observe, never modify, model RVALID/RRESP and held payload under backpressure.
 always @(posedge ui_clk)if(arst_n&&SCENARIO==4)begin
  if(v6_stalled_r&&(!rvalid||{rid,rresp,rlast,rdata}!==v6_held_r))$fatal(1,"V6_R_STABILITY");
  v6_stalled_r=rvalid&&!rready;v6_held_r={rid,rresp,rlast,rdata};
 end
 always @(negedge ui_clk)begin
  #0.001;
  if(arst_n&&SCENARIO==4&&expected_bad_r==1&&memory.beat==1&&rvalid)begin
   if(rid!=3||rresp!=0||rlast!=(memory.beat==memory.len))$fatal(1,"V6_NEXT_R_NOT_NORMAL");
   if(next_normal_presented==0)$display("V6_NEXT_NORMAL_R id=%0d beat=%0d rresp=%0d rready=%0d time=%0t",rid,memory.beat,rresp,rready,$time);
   next_normal_presented=next_normal_presented+1;
  end
 end
 wire [959:0] lease_tuple={dut.background.lease.identity[0],dut.background.lease.identity[1],
  dut.background.lease.token[0][0],dut.background.lease.token[0][1],dut.background.lease.token[1][0],dut.background.lease.token[1][1],
  dut.background.lease.reads[0][0],dut.background.lease.reads[0][1],dut.background.lease.reads[1][0],dut.background.lease.reads[1][1]};
 initial if(SCENARIO==3||SCENARIO==4)begin
  wait(healthy>=1);
  wait(!lcd_vs&&memory.state==2&&memory.transaction_id==3&&memory.len>0&&memory.beat==0&&!rvalid&&(SCENARIO!=4||!dut.bg_mux.owner));
  @(negedge ui_clk);fault_start_frame=output_frames;fault_active=1;
  if(SCENARIO==3)hard_loss=1;else inject_read_error=1;
  if(SCENARIO==4)begin wait(expected_bad_r==1);@(negedge ui_clk);inject_read_error=0;end
  wait(dut.stop);repeat(32)@(negedge ui_clk);
  hard_loss=0;inject_read_error=0;terminal_guard=1;
  frozen_lease=lease_tuple;frozen_owners={dut.background.lease.reserved,dut.background.lease.leased};
  stopped_accepts=bus_accepted;stopped_completes=bus_completed;stopped_publishes=publishes;
  if(!dut.arbiter.busy||memory.state==0||bus_accepted!=bus_completed+1)$fatal(1,"SYSTEM_HARDSTOP_NO_OWNER");
  wait(output_frames>=fault_start_frame+3);@(negedge pix_clk);
  if(fault_local_pixels==0||!display.reason_bits[9]||(SCENARIO==4&&(!display.reason_bits[8]||expected_bad_r!=1)))$fatal(1,"SYSTEM_HARDSTOP_REASON");
  if(SCENARIO==4&&(expected_bad_r!=1||next_normal_presented==0))$fatal(1,"V6_SINGLE_BAD_AND_NEXT_NORMAL_COVERAGE");
  if(SCENARIO==4&&(v7_first4!=1||v7_watchdog_transition!=1))$fatal(1,"V7_CAUSE_COVERAGE");
  $display("M5C1B_PASS REAL_SYSTEM_HARDSTOP scenario=%0d lcd=%0d taps=%0d output=%0d osd=%0d fallback=%0d outstanding=1 source_return_no_recovery=1",SCENARIO,lcd_checked,tap_checked,output_checked,osd_pixels,fault_local_pixels);$finish;
 end
 always @(posedge ui_clk)if(terminal_guard)begin
  if(!dut.stop||!dut.background.lease.halted||!dut.arbiter.busy||lease_tuple!==frozen_lease||
    {dut.background.lease.reserved,dut.background.lease.leased}!==frozen_owners||bus_accepted!=stopped_accepts||bus_completed!=stopped_completes||publishes!=stopped_publishes||dut.ack)
   $fatal(1,"SYSTEM_HARDSTOP_REUSE_OR_FAKE_ACK");
 end
 always @(posedge pix_clk)if(terminal_guard&&out_de)begin
  if(fusion_promoted||fusion_frame_ok||fused_rgb!==out_rgb)$fatal(1,"SYSTEM_HARDSTOP_LOCAL");
 end


 // Source-ID fault injection is at the camera DMA identity generator, before
 // real completed-slot commit and its actual offer mailbox; never at M5A taps.
 reg seen_id=0;reg [63:0] previous_id;
 reg tick_seen=0;reg [63:0] previous_tick,previous_display;
 initial if(SCENARIO==6)begin
  wait(dut.run);force dut.video.capture_id=64'd7;
  wait(input_frames>=4);force dut.video.capture_id=64'd91;
  wait(input_frames>=8);release dut.video.capture_id;fault_complete=1;
 end
 always @(negedge pix_clk)if(SCENARIO==6&&arst_n)begin
  if(lcd_de&&input_pos==1&&lcd_qualified)begin
   if(seen_id&&lcd_frame_id==previous_id)repeat_ids=repeat_ids+1;
   if(seen_id&&lcd_frame_id>previous_id+1)jump_ids=jump_ids+1;
   previous_id=lcd_frame_id;seen_id=1;
  end
 end
 always @(posedge pix_clk)if(SCENARIO==6&&arst_n)begin
  #1;
  if(tick_seen&&(pixel_ticks!=previous_tick+1||display_seq<previous_display))$fatal(1,"SYSTEM_SOURCE_ID_CHANGED_TIMEBASE");
  previous_tick=pixel_ticks;previous_display=display_seq;tick_seen=1;
 end


 // Independent physical address/response scoreboard. Error authorization is
 // earned by exactly one accepted, correctly tagged non-final bad R beat.
 always @(posedge ui_clk)if(arst_n)begin
  if(avalid&&aready)begin
   if(physical_pending)$fatal(1,"V4_PHYSICAL_OVERLAP");
   physical_pending=1;physical_id=aid;physical_len=alen;physical_write=atype;physical_beats=0;
  end
  if(rvalid&&rready)begin
   if(!physical_pending||physical_write||rid!=physical_id||rlast!=(physical_beats==physical_len))$fatal(1,"V4_UNEXPECTED_R_TAG");
   if(rresp!=0)begin
    if(SCENARIO!=4||!inject_read_error||expected_bad_r!=0||rid!=3||rresp!=2||rlast||physical_beats!=0||dut.arbiter.owner!=2||!dut.bg_mux.busy||dut.bg_mux.owner!=0)
     $fatal(1,"V4_UNAUTHORIZED_BAD_R id=%0d owner=%0d inner=%0d beat=%0d",rid,dut.arbiter.owner,dut.bg_mux.owner,physical_beats);
    expected_bad_r=expected_bad_r+1;
    $display("V4_EXPECTED_BAD_R id=%0d outer_owner=%0d backend_owner=%0d len=%0d beat=%0d time=%0t",rid,dut.arbiter.owner,dut.bg_mux.owner,physical_len,physical_beats,$time);
   end
   physical_beats=physical_beats+1;if(rlast)physical_pending=0;
  end
  if(bvalid&&bready)begin
   if(!physical_pending||!physical_write||bid!=physical_id||bresp!=0)$fatal(1,"V4_UNEXPECTED_B");
   physical_pending=0;
  end
  // Check PRE-edge outstanding before allowing a real final-R completion.
  if(dut.fusion.read_done)begin
   if(reader_outstanding==0)$fatal(1,"V4_READER_SYNTHETIC_DONE");
   reader_outstanding=reader_outstanding-1;
  end
  if(dut.fusion.read_accept)reader_outstanding=reader_outstanding+1;
  if(awaiting_queued_cancel)begin
   if(!dut.fusion.reader.transfer.cancelled||dut.fusion.read_accept||dut.fusion.read_done||reader_outstanding!=0)$fatal(1,"V4_QUEUED_CANCEL_EVENT");
   queued_cancels=queued_cancels+1;awaiting_queued_cancel=0;cancel_seen=1;cancel_released=0;
   $display("V4_QUEUED_CANCEL session=%0d count=%0d",cancelled_session,queued_cancels);
  end
  if(SCENARIO==2&&dut.fusion.reader.transfer.state==1&&dut.fusion.reader.transfer.cancel)begin
   if(dut.fusion.reader.transfer.avalid||dut.fusion.reader.transfer.client_accepted||dut.fusion.read_accept||dut.fusion.read_done||reader_outstanding!=0)$fatal(1,"V4_CANCEL_NOT_UNACCEPTED");
   awaiting_queued_cancel=1;cancelled_session=dut.fusion.active_session;
  end
  if(dut.fusion.lease_release)begin
   if(!dut.fusion.reader_drained||!dut.fusion.cache_empty||reader_outstanding!=0)$fatal(1,"V4_RELEASE_BEFORE_REAL_DRAIN");
   if(cancel_seen&&dut.fusion.active_session==cancelled_session)begin cancel_releases=cancel_releases+1;cancel_released=1;end
  end
  if(cancel_released&&dut.fusion.acquire_ack&&dut.fusion.active_session!=cancelled_session)begin
   cancel_recoveries=cancel_recoveries+1;cancel_released=0;
   $display("V4_CANCEL_NEW_SESSION old=%0d new=%0d",cancelled_session,dut.fusion.active_session);
  end
 end
 // Dynamic cause proof: sampled pre-edge watchdog condition and post-NBA reason.

 integer v7_accepts,v7_publishes,v7_owner,v7_localid,v7_len;
 reg [31:0] v7_address;reg v7_bad_edge,v7_watchdog_edge;reg [7:0] v7_prebeat;
 reg [31:0] v7_preage;reg [3:0] v7_prereason;
 initial v7_log=$fopen("v7_cause_trace.txt","w");
 always @(posedge ui_clk)if(arst_n&&SCENARIO==4)begin
  v7_cycle=v7_cycle+1;
  v7_bad_edge=rvalid&&rready&&rresp==2;
  v7_preage=dut.arbiter.age;v7_prebeat=dut.arbiter.beat;v7_prereason=dut.arbiter.error_reason;
  v7_watchdog_edge=dut.arbiter.state!=dut.arbiter.IDLE&&dut.arbiter.age==dut.arbiter.TX_LIMIT-1;
  if(v7_bad_edge)begin
   v7_owner=dut.arbiter.owner;v7_localid=dut.arbiter.local_id;v7_len=dut.arbiter.len;v7_address=dut.arbiter.address;
   v7_accepts=bus_accepted;v7_publishes=publishes;
  end
  #0.001;
  if(v7_bad_edge)begin
   if(expected_bad_r!=1||!quarantine||!reset_request||dut.arbiter.error_reason!=4||v7_first4!=0||v7_owner!=2||!dut.bg_mux.busy)
    $fatal(1,"V7_FIRST_BAD_NOT_REASON4_ISOLATION");
   v7_first4=1;
   $display("V7_FIRST4 cycle=%0d time=%0t owner=%0d localid=%0d physicalid=%0d len=%0d prebeat=%0d beat=%0d state=%0d age=%0d busy=%0d quarantine=%0d reset_request=%0d reason=%0d",v7_cycle,$time,v7_owner,v7_localid,rid,v7_len,v7_prebeat,dut.arbiter.beat,dut.arbiter.state,dut.arbiter.age,dut.bg_mux.busy,quarantine,reset_request,dut.arbiter.error_reason);
  end
  if(v7_first4)begin
   if(dut.arbiter.owner!=v7_owner||dut.arbiter.local_id!=v7_localid||dut.arbiter.len!=v7_len||dut.arbiter.address!=v7_address||dut.arbiter.state!=dut.arbiter.R||bus_accepted!=v7_accepts||publishes!=v7_publishes||!physical_pending||dut.lease_fault||dut.fusion.session_fault)
    $fatal(1,"V7_RETAINED_TRANSACTION_CHANGED");
   $fdisplay(v7_log,"C %0d time %0t preage %0d age %0d prereason %0d reason %0d state %0d owner %0d beat %0d stop %0d emergency %0d rready %0d outstanding %0d busy %0d accepts %0d publishes %0d",v7_cycle,$time,v7_preage,dut.arbiter.age,v7_prereason,dut.arbiter.error_reason,dut.arbiter.state,dut.arbiter.owner,dut.arbiter.beat,dut.stop,dut.arbiter.emergency_stop,rready,physical_pending,dut.bg_mux.busy,bus_accepted,publishes);
   if(v7_prereason==4&&dut.arbiter.error_reason==1)begin
    if(!v7_watchdog_edge||dut.arbiter.age!=dut.arbiter.TX_LIMIT||!dut.arbiter.emergency_stop||rready||v7_watchdog_transition!=0||!quarantine||!reset_request)
     $fatal(1,"V7_REASON1_WITHOUT_EXACT_WATCHDOG");
    v7_watchdog_transition=1;
    $display("V7_WATCHDOG_4_TO_1 cycle=%0d time=%0t preage=%0d age=%0d TX_LIMIT=%0d owner=%0d state=%0d beat=%0d emergency=%0d rready=%0d outstanding=%0d busy=%0d accepts=%0d publishes=%0d",v7_cycle,$time,v7_preage,dut.arbiter.age,dut.arbiter.TX_LIMIT,dut.arbiter.owner,dut.arbiter.state,dut.arbiter.beat,dut.arbiter.emergency_stop,rready,physical_pending,dut.bg_mux.busy,bus_accepted,publishes);
   end
   if(dut.arbiter.error_reason!=4&&!(dut.arbiter.error_reason==1&&v7_watchdog_transition==1&&dut.arbiter.age==dut.arbiter.TX_LIMIT))$fatal(1,"V7_UNPROVEN_LATER_CAUSE");
  end
 end
 // Keep checking when failstop has deasserted run. Only the deliberately
 // accepted RRESP error may explain reason4 quarantine/reset_request.
 always @(negedge ui_clk)if(arst_n)begin
  if(dut.lease_fault||dut.fusion.session_fault||fault)$fatal(1,"V4_UNRELATED_PROTOCOL_FAULT lease=%b session=%b video=%b",dut.lease_fault,dut.fusion.session_fault,fault);
  if((quarantine||reset_request)&&!(SCENARIO==4&&expected_bad_r==1&&v7_first4==1&&(dut.arbiter.error_reason==4||(dut.arbiter.error_reason==1&&v7_watchdog_transition==1&&dut.arbiter.age==dut.arbiter.TX_LIMIT))))
   $fatal(1,"V4_UNEXPECTED_QUARANTINE evidence=%0d reason=%0d",expected_bad_r,dut.arbiter.error_reason);
 end

 always @(posedge ui_clk)if(arst_n&&SCENARIO==6)begin
  if(dut.video.ws==dut.video.W_EOF&&dut.video.eof_valid&&dut.video.eof_count==dut.video.FRAME_BYTES)begin
   sid_commit_slot=dut.video.wslot;sid_commit_value=dut.video.capture_id;
   sid_slots[sid_commit_slot]=sid_commit_value;sid_slots_valid[sid_commit_slot]=1;sid_commits=sid_commits+1;
   $display("SID_REAL_COMMIT slot=%0d id=%0d eof=%0d physicalB=%0d",sid_commit_slot,sid_commit_value,dut.video.eof_count,bus_completed);
   #1;if(!dut.video.complete[sid_commit_slot]||dut.video.slot_id[sid_commit_slot]!==sid_commit_value)$fatal(1,"SID_COMMIT_NOT_STORED");
  end
  if(dut.video.offer_send)begin
   if(!sid_slots_valid[dut.video.rslot]||dut.video.slot_id[dut.video.rslot]!==sid_slots[dut.video.rslot])$fatal(1,"SID_OFFER_WITHOUT_REAL_COMMIT");
   sid_offers=sid_offers+1;$display("SID_UI_OFFER slot=%0d id=%0d",dut.video.rslot,dut.video.slot_id[dut.video.rslot]);
  end
 end
 always @(posedge pix_clk)if(arst_n&&SCENARIO==6&&dut.video.first_pixel&&pix_request&&dut.video.admit)begin
  if(sid_admissions>=512)$fatal(1,"SID_LEDGER_CAPACITY");sid_admitted[sid_admissions]=dut.video.offer_id;sid_admissions=sid_admissions+1;
  $display("SID_PIX_ADMIT count=%0d id=%0d",sid_admissions,dut.video.offer_id);
 end
 always @(negedge pix_clk)if(arst_n&&SCENARIO==6&&lcd_de&&input_pos==1&&lcd_qualified)begin
  if(sid_lcd_frames>=sid_admissions||lcd_frame_id!==sid_admitted[sid_lcd_frames])$fatal(1,"SID_LCD_NOT_REAL_ADMITTED_ID");sid_lcd_frames=sid_lcd_frames+1;
  $display("SID_LCD_REAL_FRAME count=%0d id=%0d displayseq=%0d tick=%0d",sid_lcd_frames,lcd_frame_id,display_seq,pixel_ticks);
 end
 always @(posedge ui_clk)if(arst_n&&SCENARIO==2&&fault_active&&dut.ca[2]&&dut.car[2])$fatal(1,"SYSTEM_STARVATION_FALSE_GRANT");

 always @(posedge ui_clk)if(!arst_n)monitor_armed<=0;else if(dut.run&&!monitor_armed)begin monitor_armed<=1;$display("STARVATION_MONITOR_ARMED UI=%0d run=%b emergency=%b",ui_cycles,dut.run,dut.arbiter.emergency_stop);end
 initial if(SCENARIO==7)begin
  wait(healthy>=1);wait(dut.fusion.state==dut.fusion.IDLE&&!dut.fusion.offer_busy);@(negedge ui_clk);
  if(!monitor_armed||!dut.run||dut.stop||quarantine||reset_request||dut.arbiter.emergency_stop)$fatal(1,"STARVATION_ENTRY_NOT_ARMED_RUN");
  if(!dut.fusion.cache_empty||!dut.fusion.reader_drained||dut.fusion.context_confirmed)$fatal(1,"STARVATION_START_NOT_QUIET");starve_previous_session=dut.fusion.active_session;
  if(model_service_delay!=384)$fatal(1,"STARVATION_ACCEPTED_SERVICE_MUST_STAY384");
  force dut.arbiter.safe_window=1'b0;starve_deny=1;fault_active=1;fault_start_frame=output_frames;
  wait(dut.ca[2]&&!dut.car[2]&&dut.bg_mux.pending&&dut.bg_mux.pending_owner==1&&!dut.bg_mux.busy&&dut.fusion.reader.transfer.avalid&&dut.fusion.reader.transfer.state==1);@(negedge ui_clk);
  if(!dut.ca[2]||dut.car[2]||dut.fusion.read_accept||!dut.bg_mux.pending||dut.bg_mux.pending_owner!=1||dut.bg_mux.busy||!dut.fusion.reader.avalid||dut.bg_mux.aaddr!==dut.fusion.reader.aaddr||dut.bg_mux.alen!==dut.fusion.reader.alen||dut.bg_mux.aid!==dut.fusion.reader.aid||dut.bg_mux.atype!==dut.fusion.reader.atype)$fatal(1,"STARVATION_NO_REAL_PENDING_START");
  starve_session=dut.fusion.active_session;if(starve_session==0||starve_session==starve_previous_session||dut.fusion.write_valid||dut.fusion.commit)$fatal(1,"STARVATION_NOT_NEW_PREFILL_CONTEXT");
  starve_address=dut.fusion.reader.aaddr;starve_length=dut.fusion.reader.alen;starve_id=dut.fusion.reader.aid;starve_type=dut.fusion.reader.atype;starve_counting=1;
  $display("STARVATION_PENDING_PAYLOAD SID=%0d previousSID=%0d addr=%h len=%0d id=%h type=%b pending_owner=%b",starve_session,starve_previous_session,starve_address,starve_length,starve_id,starve_type,dut.bg_mux.pending_owner);
  $display("STARVATION_PENDING_START SID=%0d UI=%0d physical_pending=%0d physicalowner=%0d",starve_session,ui_cycles,physical_pending,physical_id);
  wait(starve_pending_cycles>=10000&&fault_invalidations>0);@(negedge ui_clk);
  release dut.arbiter.safe_window;starve_deny=0;fault_active=0;fault_complete=1;
  $display("STARVATION_ELIGIBILITY_RESTORED SID=%0d queued=%0d UI=%0d RTdone=%0d",starve_session,starve_pending_cycles,ui_cycles,starve_rt_done);
 end
 always @(posedge ui_clk)if(arst_n&&SCENARIO==7)begin
  if(quarantine||reset_request||(monitor_armed&&dut.arbiter.emergency_stop))$fatal(1,"STARVATION_UNEXPECTED_COLD_STOP");
  if(starve_deny)begin
   if(dut.ca[2]&&dut.car[2])begin starve_c2_accepts=starve_c2_accepts+1;$fatal(1,"STARVATION_C2_ACCEPT_DURING_DENIAL");end
   if(starve_counting)begin
    starve_denial_cycles=starve_denial_cycles+1;if(starve_denial_cycles>2000000)$fatal(1,"STARVATION_BOUNDED_WINDOW_NOT_REACHED");
    if(dut.ca[2]&&!dut.car[2])begin
     if(!dut.bg_mux.pending||dut.bg_mux.pending_owner!=1||dut.bg_mux.busy||!dut.fusion.reader.avalid||dut.fusion.active_session!=starve_session||{dut.bg_mux.aaddr,dut.bg_mux.alen,dut.bg_mux.aid,dut.bg_mux.atype}!={starve_address,starve_length,starve_id,starve_type})$fatal(1,"STARVATION_PENDING_IDENTITY_CHANGED");
     starve_pending_cycles=starve_pending_cycles+1;
    end else if(starve_pending_cycles<10000)$fatal(1,"STARVATION_PENDING_WINDOW_TOO_SHORT");
    if((dut.ca[0]&&dut.car[0])||(dut.ca[1]&&dut.car[1]))starve_rt_accepts=starve_rt_accepts+1;
    if((bvalid&&bready&&bid<3)||(rvalid&&rready&&rlast&&rid<3))starve_rt_done=starve_rt_done+1;
   end
  end
  if(starve_session!=0&&dut.fusion.lease_release&&dut.fusion.active_session==starve_session)begin
   if(!dut.fusion.reader_drained||!dut.fusion.cache_empty||reader_outstanding!=0)$fatal(1,"STARVATION_RELEASE_BEFORE_DRAIN");
   starve_drained=1;$display("STARVATION_REAL_DRAIN SID=%0d UI=%0d",starve_session,ui_cycles);
  end
 end

 `include "end_protocol.svh"
endmodule

