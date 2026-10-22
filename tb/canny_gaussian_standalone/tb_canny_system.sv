`default_nettype none
`timescale 1ns/1ps

module tb_canny_system;
 integer stable=0;
 reg [7:0] source_hi[0:255];reg[93:0] gau80_gold[0:921599];
 integer diag_started=0,diag_completed=0,diag_taken=0,diag_file,diag_k;reg [896:0] diag_tuple;reg diag_tuple_guard=0;

 localparam END_RESTORE_OLD=0;


 parameter HEALTHY_FRAMES=60;

 parameter SERVICE_CYCLES=384,CAMERA_BLANK_CYCLES=478667;

 parameter SCENARIO=0,FUS_ENABLE=1,BG_REQUEST_CYCLES=96000000;

 reg [31:0] model_service_delay=SERVICE_CYCLES;

 integer fault_start_frame=0,recovered_healthy=0,fault_invalidations=0,fault_local_pixels=0;

 reg fault_active=0,fault_complete=0;

 reg [93:0] gold[0:921599];reg [2047:0] gold_path;

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

 wire fusion_context_block,fusion_context_quiet,fusion_context_tail_fault;reg final_vs_previous=1,final_fusion=0;
 reg [1:0] key_n=3;wire [2:0] selected_mode;wire [7:0] selected_threshold;wire control_fusion;wire [63:0] control_generation;wire[7:0] source_high;wire[2:0] source_mode;wire[1:0] source_filter;wire[63:0] source_generation;wire source_fusion;wire[7:0] tap_hi,tap_lo;wire[1:0] tap_f;
 m5a_controls #(.DEBOUNCE_CYCLES(4),.LONG_CYCLES(64)) controls(.clk(pix_clk),.ce(1'b1),.arst_n(arst_n),.key_n(key_n),.frame_start(pix_sof),.threshold(selected_threshold),.mode(selected_mode),.pending_threshold(),.pending_mode(),.fusion_enable(control_fusion),.config_generation(control_generation),.effective_threshold(source_high),.effective_mode(source_mode),.effective_filter(source_filter),.effective_generation(source_generation),.effective_fusion_enable(source_fusion));
 integer med_healthy=0,gau_healthy=0,gau80_healthy=0,cov_healthy=0,off_frames=0,cyan=0,stage=0,restore_target=0;
 task press(input [1:0] keys,input integer ticks);begin
  @(posedge pix_sof);repeat(100)@(negedge pix_clk);key_n=keys;repeat(ticks)@(negedge pix_clk);key_n=3;repeat(30)@(negedge pix_clk);
 end endtask
 initial begin
  wait(arst_n);repeat(80)@(negedge pix_clk);key_n=0;repeat(100)@(negedge pix_clk);key_n=3;
  wait(med_healthy>=1);stage=1;
  press(0,20);wait(selected_mode==3);wait(stable>med_healthy);
  press(0,20);wait(selected_mode==4);wait(gau_healthy>=1);stage=2;
  press(0,20);wait(selected_mode==5);press(0,20);wait(selected_mode==6);wait(cov_healthy>=1&&cyan>0);stage=3;
  press(2,20);wait(selected_threshold==80);wait(gau80_healthy>=1);stage=4;
  off_frames=0;press(0,100);wait(!control_fusion);wait(off_frames>=1);stage=5;
  restore_target=gau80_healthy+1;press(0,100);wait(control_fusion);wait(gau80_healthy>=restore_target);stage=6;
 end
    wire shvalid,sh64,sh128,shstrong,shillegal;
    wire [1:0] pair_final_class;
    wire diag_ctx,diag_sof,diag_admit,diag_kill,diag_cv,diag_cq,diag_rq;
    wire [63:0] diag_sid,diag_csid,diag_token,diag_word;
    wire diag_source_slot,diag_tag,diag_bounds,diag_weak,diag_support,diag_global,diag_rc,diag_re,diag_rt;
    wire [1:0] diag_class;wire [11:0] diag_x,diag_y;
    wire diag_pix_ready,diag_take,diag_pix_cancel,diag_ui_ready,diag_done,diag_cancel,diag_valid,diag_window;
    wire diag_prst,diag_urst;wire [5:0] diag_read_word;wire [8:0] diag_index;wire [7:0] diag_byte;
  wire [23:0] out_rgb;wire out_de,out_hs,out_vs,raster_fault;
 wire [7:0] out_raw,out_mag,out_nms,out_threshold;wire out_bin,out_ovvalid,out_ovedge,out_nv,out_cv,out_ce;wire[1:0] out_filter;
 wire [11:0] out_x,out_y;wire [2:0] out_mode;
canny_system dut(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.rst_n(arst_n),.pll_locked(arst_n),.cal_done(arst_n),.cal_pass(arst_n),

  .cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.pix_sof(pix_sof),.pix_request(pix_request),.pix_data(pix_data),.frame_id(replay_frame_id),.epoch(epoch),.pix_qualified(),

  .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(tap_hi),.tap_low(tap_lo),.tap_filter(tap_f),.tap_frame_id(tag_id),.tap_epoch(tag_epoch),.tap_timestamp(stamp),.tap_display_seq(tap_display_seq),.tap_config_generation(tap_config_generation),.uart_tx(uart_tx),.led(led),

  .fusion_request(fusion_request),.fusion_request_seq(fusion_request_seq),.fusion_config(fusion_config),

  .fusion_release(fusion_release),.fusion_release_final(fusion_release_final),.fusion_release_session(fusion_release_session),.fusion_release_ready(fusion_release_ready),

  .fusion_offer_valid(fusion_offer_valid),.fusion_offer_take(fusion_offer_take),.fusion_descriptor(fusion_descriptor),.fusion_session(fusion_session),

  .fusion_context_block(fusion_context_block),.fusion_context_quiet(fusion_context_quiet),.fusion_context_tail_fault(fusion_context_tail_fault),.fusion_ce(1'b1),.fusion_read(fusion_tap_valid),.fusion_x(tap_x),.fusion_y(tap_y),.fusion_read_session(fusion_read_session),

  .fusion_ref_ready(fusion_ref_ready),.fusion_ref_class(fusion_ref_class),.fusion_ref_mask(fusion_ref_mask),.fusion_ref_x(fusion_ref_x),.fusion_ref_y(fusion_ref_y),.fusion_ref_session(fusion_ref_session),

  .fusion_retire(fusion_retire),.fusion_retire_row(fusion_retire_row),.fusion_flush(fusion_flush),.fusion_prefilled(fusion_prefilled),.fusion_stop(fusion_stop),

  .fusion_export_status(fusion_export_ui),.fusion_ddr_error_status(fusion_ddr_error_ui),.fusion_hardstop_status(fusion_hardstop_ui),

  .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),

  .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),

  .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));

 // Accelerate only UART serialization; complete byte stream still passes real packet CRC.

 defparam dut.background.REQUEST_CYCLES=BG_REQUEST_CYCLES;

 defparam dut.background.EXPORT_CYCLES=(TESTMODE==1||TESTMODE==4)?10000:960000000;

 parameter UART_CLOCK_HZ=960000;

 assign fault=dut.video_fault;assign quarantine=dut.quarantine;assign reset_request=dut.reset_request;

 assign cam_bytes=dut.camera_bytes;assign disp_bytes=dut.display_bytes;assign cam_max=dut.camera_max;assign disp_min=dut.display_min;

 assign rejected=dut.rejected;assign max_service=dut.max_service;assign max_wait=dut.max_wait;assign qos_exceeded=dut.qos_exceeded;

 reg stall_bus=0;wire [31:0] bus_accepted,bus_completed,bus_max;

 m5c1b_ddr_service_model #(.WORDS(32'h011e2000/16)) memory(.clk(ui_clk),.rst_n(arst_n),.stall(stall_bus),

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







 m5a_stream_top stream(.clk(pix_clk),.ce(1'b1),.arst_n(arst_n),.in_gray(lcd_gray),.in_de(lcd_de),

  .in_hs(lcd_hs),.in_vs(lcd_vs),.in_sof(!lcd_vs),.filter_request(source_filter),.threshold(source_high),.mode(source_mode),

  .source_pixel_tick(pixel_ticks),.source_display_seq(display_seq),.source_config_generation(source_generation),

  .tap_display_seq(tap_display_seq),.tap_config_generation(tap_config_generation),

  .fusion_tap_valid(fusion_tap_valid),.fusion_tap_qualified(fusion_tap_qualified),.fusion_tap_support(fusion_tap_support),

  .tap_input_frame_id(lcd_frame_id),.tap_input_epoch(lcd_epoch),.tap_input_qualified(lcd_qualified),.tap_valid(tap_valid),.tap_class(tap_class),

  .tap_x(tap_x),.tap_y(tap_y),.tap_high(tap_hi),.tap_low(tap_lo),.tap_filter(tap_f),.tap_frame_id(tag_id),.tap_epoch(tag_epoch),.tap_timestamp(stamp),

  .out_rgb(out_rgb),.out_de(out_de),.out_hs(out_hs),.out_vs(out_vs),.out_raw(out_raw),.out_legacy_mag(out_mag),

  .out_threshold(out_threshold),.out_nms(out_nms),.out_legacy_bin(out_bin),.out_overlay_valid(out_ovvalid),.out_overlay_edge(out_ovedge),

  .out_nms_valid(out_nv),.out_canny_valid(out_cv),.out_canny_edge(out_ce),.out_mode(out_mode),.out_filter_enable(out_filter),

  .out_x(out_x),.out_y(out_y),.raster_fault(raster_fault));

 m5c_fusion_display display(.context_block(fusion_context_block),.context_quiet(fusion_context_quiet),.context_tail_fault(fusion_context_tail_fault),.clk(pix_clk),.rst_n(arst_n),.ce(1'b1),.raw_sof(pix_sof),

  .stop(fusion_stop_sync[1]),.enable(control_fusion),.export_status(fusion_export_sync[1]),.ddr_error_status(fusion_ddr_error_sync[1]),.hardstop_status(fusion_hardstop_sync[1]),.epoch(epoch),.config_generation(source_generation),.high_threshold(source_high),.filter_enable(source_filter),.final_enable(final_fusion),

  .tap_valid(fusion_tap_valid),.tap_qualified(fusion_tap_qualified),.tap_support(fusion_tap_support),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),

  .final_de(out_de),.final_x(out_x),.final_y(out_y),.local_edge(out_ce),.raw_gray(out_raw),.mode(out_mode),.base_rgb(out_rgb),.fused_rgb(fused_rgb),

  .pixel_ticks(pixel_ticks),.display_seq(display_seq),.config_signature(fusion_config),.request_frame(fusion_request),.request_seq(fusion_request_seq),

  .offer_valid(fusion_offer_valid),.offer_take(fusion_offer_take),.offer_descriptor(fusion_descriptor),.offer_session(fusion_session),

  .pixel_release(fusion_release),.release_final(fusion_release_final),.release_session(fusion_release_session),.release_ready(fusion_release_ready),

  .read_session(fusion_read_session),.prefilled(fusion_prefilled),.ref_ready(fusion_ref_ready),.ref_class(fusion_ref_class),.ref_mask(fusion_ref_mask),

  .ref_x(fusion_ref_x),.ref_y(fusion_ref_y),.ref_session(fusion_ref_session),.retire(fusion_retire),.retire_row(fusion_retire_row),.flush(fusion_flush),

  .eligible(fusion_eligible),.age_frames(fusion_age_frames),.age_ticks(fusion_age_ticks),.promoted(fusion_promoted),.frame_ok(fusion_frame_ok),

.diag_context_valid(diag_ctx),.diag_sof(diag_sof),.diag_admit(diag_admit),.diag_kill(diag_kill),.diag_session(diag_sid),.diag_compare_session(diag_csid),
.diag_compare_valid(diag_cv),.diag_current_qualified(diag_cq),.diag_reference_qualified(diag_rq),.diag_current_class(diag_class),.diag_compare_x(diag_x),.diag_compare_y(diag_y),
.diag_shadow_valid(shvalid),.diag_shadow64(sh64),.diag_shadow128(sh128),.diag_strong_loss(shstrong),.diag_illegal(shillegal),.diag_tag_good(diag_tag),.diag_bounds(diag_bounds),.diag_weak(diag_weak),.diag_support(diag_support),.diag_global(diag_global),.diag_row_complete(diag_rc),.diag_row_equal(diag_re),.diag_row_tag(diag_rt),
  .frame_done(fusion_frame_done),.telemetry_snapshot(fusion_telemetry_snapshot));


 `include "gaussian_contract_functions.vh"
 always @(posedge pix_clk)begin final_vs_previous<=out_vs;if(final_vs_previous&&!out_vs)final_fusion<=control_fusion;end
 wire[23:0] osd_rgb;wire osd_de,osd_hs,osd_vs;
 canny_osd osd(.clk(pix_clk),.ce(1'b1),.arst_n(arst_n),.rgb(fused_rgb),.de(out_de),.hs(out_hs),.vs(out_vs),.threshold(out_threshold),.mode(out_mode),.filter_id(out_filter),.fusion_enable(final_fusion),.fusion_active(fusion_frame_ok),.fusion_age_valid(fusion_eligible),.fusion_age(fusion_age_frames),.out_rgb(osd_rgb),.out_de(osd_de),.out_hs(osd_hs),.out_vs(osd_vs));
 assign diag_ui_ready=0;assign diag_window=0;assign diag_byte=0;assign diag_valid=0;assign diag_pix_ready=0;
 reg[93:0] gau_gold[0:921599];reg[2047:0] gau_path;
 initial begin if(!$value$plusargs("GAU=%s",gau_path))$fatal(1,"GAU_REQUIRED");$readmemh(gau_path,gau_gold);end
 integer pc=0,sof_tick=0,sof_count=0,lcd_pos=0,src_frames=0,tap_pos=0,tap_frames=0,final_pos=0,final_frames=0;
 integer lcd_pixels=0,tap_pixels=0,final_pixels=0,med_frames=0,gau_frames=0,results=0,rect_results=0,unknown_results=0,visible_pixels=0,osd_filter_pixels=0,publications=0;
 reg source_good[0:255];reg[63:0] source_id[0:255],source_gen[0:255],source_seq[0:255];reg[1:0] source_f[0:255];reg armed=0;
 reg[93:0] e;reg[23:0] expected_rgb;reg de_saved,hs_saved,vs_saved;integer old_stable;
 always @(posedge ui_clk)if(arst_n)begin
  if(dut.lease_fault||dut.fusion.session_fault||fault||quarantine||reset_request||(|dut.rejected))$fatal(1,"GAUSS_REAL_PROTOCOL_GUARD");
  if(dut.background.publication_ok)begin
   if(!dut.background.metadata_committed||!gauss_descriptor_valid(dut.background.frozen_extended,1280,720))$fatal(1,"GAUSS_REAL_PUBLICATION_SCHEMA");publications=publications+1;
  end
 end
 always @(posedge pix_clk)if(arst_n)begin
  pc=pc+1;
  if(pix_sof)begin sof_tick=pc;sof_count=sof_count+1;armed=1;end
  if(lcd_de)begin
   if(lcd_pos==0)begin
    if(sof_count>1&&pc-sof_tick!=39861)$fatal(1,"GAUSS_REAL_LCD_SOF_FIRST_DE got=%0d",pc-sof_tick);
    source_good[src_frames]=lcd_qualified;source_id[src_frames]=lcd_frame_id;source_gen[src_frames]=source_generation;source_seq[src_frames]=display_seq;source_f[src_frames]=source_filter;source_hi[src_frames]=source_high;
    $display("REAL_FIRST_DE frame=%0d delta=%0d id=%0d epoch=%0d generation=%0d filter=%0d qualified=%b",src_frames,pc-sof_tick,lcd_frame_id,lcd_epoch,source_generation,source_filter,lcd_qualified);
   end
   if(lcd_qualified)begin if(lcd_gray!==gold[lcd_pos][7:0])$fatal(1,"GAUSS_REAL_DDR_LCD_PIXEL");lcd_pixels=lcd_pixels+1;end
   if(lcd_pos==921599)begin lcd_pos=0;src_frames=src_frames+1;end else lcd_pos=lcd_pos+1;
  end
  if(fusion_tap_valid)begin
   if(tap_x!==tap_pos%1280||tap_y!==tap_pos/1280)$fatal(1,"GAUSS_REAL_TAP_COORD");
   if(fusion_tap_qualified!==source_good[tap_frames])$fatal(1,"GAUSS_REAL_TAP_QUALIFICATION");
   if(fusion_tap_qualified)begin
    e=source_hi[tap_frames]==80?gau80_gold[tap_pos]:source_f[tap_frames]==2?gau_gold[tap_pos]:gold[tap_pos];
    if(tap_class!==e[93:92]||tag_id!==source_id[tap_frames]||tap_config_generation!==source_gen[tap_frames]||tap_display_seq!==source_seq[tap_frames]||tap_f!==source_f[tap_frames])$fatal(1,"GAUSS_REAL_TAP_DATA_IDENTITY");tap_pixels=tap_pixels+1;
   end
   if(tap_pos==921599)begin tap_pos=0;tap_frames=tap_frames+1;end else tap_pos=tap_pos+1;
  end
  if(out_de)begin
   if(out_x!==final_pos%1280||out_y!==final_pos/1280)$fatal(1,"GAUSS_REAL_FINAL_COORD");
   if(source_good[final_frames])begin
    e=source_hi[final_frames]==80?gau80_gold[final_pos]:source_f[final_frames]==2?gau_gold[final_pos]:gold[final_pos];
    if(out_filter!==source_f[final_frames]||{out_raw,out_mag,out_bin,out_ovvalid,out_ovedge,out_nms,out_nv,out_cv,out_ce}!=={e[7:0],e[15:8],e[16],e[17],e[18],e[26:19],e[27],e[28],e[29]})$fatal(1,"GAUSS_REAL_ALL_PIXEL_GOLD");final_pixels=final_pixels+1;
   end

   if(final_pos==921599)begin
    if(source_good[final_frames])begin stable=stable+1;if(out_filter==1)med_frames=med_frames+1;else if(out_filter==2)gau_frames=gau_frames+1;end
    $display("REAL_FINAL frame=%0d stable=%0d filter=%0d mode=%0d generation=%0d result_count=%0d",final_frames,stable,out_filter,out_mode,source_gen[final_frames],results);
    final_pos=0;final_frames=final_frames+1;
   end else final_pos=final_pos+1;
  end
  de_saved=out_de;hs_saved=out_hs;vs_saved=out_vs;
  #1;if({osd_de,osd_hs,osd_vs}!=={de_saved,hs_saved,vs_saved})$fatal(1,"GAUSS_REAL_OSD_SYNC");
 end

 reg[2047:0] path80,maskmed,maskgau,mask80;
 reg med_bfs[0:921599],gau_bfs[0:921599],gau80_bfs[0:921599];integer bs=0,rs=0,j,baseaddr;reg goldenbit;
 initial begin
  if(!$value$plusargs("GAU80=%s",path80)||!$value$plusargs("MED_BFS=%s",maskmed)||!$value$plusargs("GAU_BFS=%s",maskgau)||!$value$plusargs("GAU80_BFS=%s",mask80))$fatal(1,"BFS_ARGS");
  $readmemh(path80,gau80_gold);$readmemh(maskmed,med_bfs);$readmemh(maskgau,gau_bfs);$readmemh(mask80,gau80_bfs);
 end
 always @(posedge ui_clk)if(arst_n)begin
  if(bvalid&&bready)bs=bs+1;if(rvalid&&rready&&rlast)rs=rs+1;
  if(uart_tx!==1'b1)$fatal(1,"UNEXPECTED_UART_ACTIVITY");
  if(dut.background.publication_accept)begin
   baseaddr=dut.background.class_slot?32'h010c9000:32'h010ac000;
   for(j=0;j<921600;j=j+1)begin
    goldenbit=dut.background.frozen_extended[263:256]==80?gau80_bfs[j]:dut.background.frozen_extended[310:309]==2?gau_bfs[j]:med_bfs[j];
    if(memory.mem[(baseaddr>>4)+(j>>7)][j%128]!==goldenbit)$fatal(1,"REAL_PRODUCTION_BFS_MISMATCH pixel=%0d",j);
   end
   $display("REAL_PUBLICATION_BFS job=%0d filter=%0d high=%0d",dut.background.job_id,dut.background.frozen_extended[310:309],dut.background.frozen_extended[263:256]);
  end
 end
 integer framegood=0,framecyan=0,framered=0,old_config_reject=0;
 always @(posedge pix_clk)if(arst_n)begin
  if(out_de)begin
   if(out_x==0&&out_y==0)begin framegood=0;framecyan=0;framered=0;end
   if(fusion_frame_ok)framegood=framegood+1;
   if(fusion_eligible&&fusion_descriptor[735:576]!=fusion_config)$fatal(1,"OLD_CONFIG_ELIGIBLE");
   if(!control_fusion&&fusion_promoted)$fatal(1,"DISABLED_PROMOTED");
   if(out_mode==6&&final_fusion)begin
    if(out_ce)begin if(fused_rgb!==24'hff0000)$fatal(1,"LOCAL_RED_PRIORITY");framered=framered+1;end
    else if(fusion_promoted)begin if(fused_rgb!==24'h00ffff)$fatal(1,"PROMOTED_CYAN");framecyan=framecyan+1;cyan=cyan+1;end
    else if(fused_rgb!=={out_raw,out_raw,out_raw})$fatal(1,"FUSION_GRAY_ALIGNMENT");
   end
   if(out_x==1279&&out_y==719)begin
    if(framegood>900000)begin
     if(out_filter==1)med_healthy=med_healthy+1;
     if(out_filter==2&&out_threshold==64)gau_healthy=gau_healthy+1;
     if(out_mode==6&&framecyan>0&&framered>0)cov_healthy=cov_healthy+1;
     if(out_filter==2&&out_threshold==80)gau80_healthy=gau80_healthy+1;
     $display("REAL_HEALTHY filter=%0d high=%0d mode=%0d good=%0d cyan=%0d",out_filter,out_threshold,out_mode,framegood,framecyan);
    end
    if(!control_fusion&&!final_fusion&&framecyan==0)off_frames=off_frames+1;
   end
  end
 end
 initial begin
  wait(stage==6);repeat(5000)@(negedge pix_clk);
  if(publications<3||med_healthy==0||gau_healthy==0||cov_healthy==0||gau80_healthy<2||off_frames==0||cyan==0||bs==0||rs==0)$fatal(1,"SYSTEM_COVERAGE");
  $display("PASS_CANNY_SYSTEM stable=%0d MEDhealthy=%0d GAUhealthy=%0d COVhealthy=%0d threshold80healthy=%0d off=%0d cyan=%0d publications=%0d B=%0d lastR=%0d pixel_gold=%0d",stable,med_healthy,gau_healthy,cov_healthy,gau80_healthy,off_frames,cyan,publications,bs,rs,final_pixels);$finish;
 end
 initial begin #4000000000;$fatal(1,"SYSTEM_WATCHDOG stage=%0d pubs=%0d med=%0d gau=%0d cov=%0d gau80=%0d",stage,publications,med_healthy,gau_healthy,cov_healthy,gau80_healthy);end
endmodule
`default_nettype wire
