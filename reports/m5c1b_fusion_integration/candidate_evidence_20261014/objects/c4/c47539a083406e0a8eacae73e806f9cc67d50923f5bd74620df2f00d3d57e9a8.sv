module m5b1_system(
 input ui_clk,cam_clk,pix_clk,rst_n,pll_locked,cal_done,cal_pass,
 input cam_vs,cam_valid,input [7:0] cam_data,input pix_sof,pix_request,
 output [7:0] pix_data,output [63:0] frame_id,output [63:0] epoch,output pix_qualified,
 input tap_valid,input [1:0] tap_class,input [11:0] tap_x,tap_y,input [7:0] tap_high,tap_low,input tap_filter,
 input [63:0] tap_frame_id,tap_epoch,tap_timestamp,tap_display_seq,tap_config_generation,output uart_tx,output [5:0] led,
 input fusion_request,input [63:0] fusion_request_seq,input [159:0] fusion_config,
 input fusion_release,fusion_release_final,input [63:0] fusion_release_session,output fusion_release_ready,
 output fusion_offer_valid,input fusion_offer_take,output [767:0] fusion_descriptor,output [63:0] fusion_session,
 input fusion_ce,fusion_read,input [11:0] fusion_x,fusion_y,input [63:0] fusion_read_session,
 output fusion_ref_ready,output [1:0] fusion_ref_class,output fusion_ref_mask,output [11:0] fusion_ref_x,fusion_ref_y,output [63:0] fusion_ref_session,
 output fusion_context_block,input fusion_context_quiet,fusion_context_tail_fault,
 input fusion_retire,input [11:0] fusion_retire_row,input fusion_flush,output fusion_prefilled,output fusion_stop,
 output fusion_export_status,fusion_ddr_error_status,fusion_hardstop_status,
 input fusion_frame_done,input [479:0] fusion_telemetry_snapshot,
 output [7:0] aid,alen,wid,output [31:0] aaddr,output [2:0] asize,
 output [1:0] aburst,alock,output avalid,atype,input aready,
 output [127:0] wdata,output [15:0] wstrb,output wlast,wvalid,input wready,
 input [7:0] bid,input [1:0] bresp,input bvalid,output bready,
 input [7:0] rid,input [1:0] rresp,input [127:0] rdata,input rlast,rvalid,output rready);
 wire run,stop,ack,video_fault,quarantine,reset_request,arb_busy;
 wire [3:0] error_reason;wire [5:0] fifo_ready;
 wire [223:0] error_counts;wire [3:0] video_fifo_faults;
 wire [95:0] max_wait,max_service;wire [31:0] qos_exceeded,accepts,completes,rejects;
 wire [2:0] ca,car,cw,cwl,cwr,cb,cr,crl,crr,rejected;wire [95:0] cad;
 wire [23:0] cl,ci,cbi,cri;wire [2:0] ct;wire [383:0] cwd,crd;wire [5:0] cbr,crresp;
 wire [3:0] wp,rp;wire [6:0] bwp,brp;wire [13:0] camera_bytes,display_bytes,camera_max,display_min;
 wire [1:0] urgent;wire safe_window;wire display_valid;
 wire job_busy,publish_toggle,bg_fault;
 wire [1:0] sa,sar,sw,swl,swr,sb,sr,srr,srej,sat;
 wire [63:0] sad;wire [15:0] sal,sai;wire [255:0] swd;wire [127:0] srd;
 wire [7:0] sbi,sri;wire [1:0] sbr,sresp;wire srl;
 wire [6:0] backend_wp,backend_rp,fusion_rp;
 wire result_valid,result_slot,export_exclusive,capture_priority,lease_fault,session_fault;
 wire [767:0] result_descriptor;wire [3:0] pair_leased;
 wire lease_acquire,lease_slot,lease_ack,lease_denied,lease_release,lease_retire,read_accept,read_done;
 wire [319:0] lease_identity;wire [63:0] lease_token;
 wire telemetry_ready,telemetry_take,telemetry_pending,telemetry_fault;
 wire job_rejected_event;
 reg [63:0] rejected_job_count,protocol_fault_count;
 reg [4:0] fault_seen;
 wire [4:0] fault_levels={reset_request,quarantine,telemetry_fault,session_fault,lease_fault};
 // Count UI cycles with a newly asserted protocol source, coalescing same-cycle sources.
 always @(posedge ui_clk or negedge rst_n)begin
  if(!rst_n)begin rejected_job_count<=0;protocol_fault_count<=0;fault_seen<=0;end
  else begin
   fault_seen<=fault_levels;
   if(job_rejected_event&&rejected_job_count!=64'hffffffffffffffff)rejected_job_count<=rejected_job_count+1'b1;
   if(|fault_levels&&protocol_fault_count!=64'hffffffffffffffff)protocol_fault_count<=protocol_fault_count+1'b1;
  end
 end
 wire [319:0] telemetry_header;wire [7:0] telemetry_byte;wire [8:0] telemetry_index;
 wire [767:0] telemetry_descriptor;wire [63:0] telemetry_session;
 assign bwp=backend_wp;assign brp=backend_rp|fusion_rp;
 assign fusion_stop=stop||!run||lease_fault||session_fault;
 assign fusion_export_status=export_exclusive;
 assign fusion_ddr_error_status=quarantine||reset_request;
 assign fusion_hardstop_status=stop||lease_fault||session_fault;
 m5b1_failstop bridge(.ref_clk(ui_clk),.pll_locked(pll_locked),.cal_done(cal_done),.cal_pass(cal_pass),
  .protocol_fault(quarantine||reset_request),.fifo_fault(video_fault),.domains_ready(&fifo_ready),
  .allow_run(run),.stop(stop),.ddr_reset_ack(ack),.epoch(epoch));
 m5b1_video_dma video(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.arst_n(rst_n),.run(run),.stop(stop),.epoch(epoch),
  .cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.pix_sof(pix_sof),.pix_request(pix_request),
  .pix_data(pix_data),.replay_frame_id(frame_id),.pix_qualified(pix_qualified),.display_valid(display_valid),.fault(video_fault),
  .avalid(ca[1:0]),.aready(car[1:0]),.aaddr(cad[63:0]),.alen(cl[15:0]),.aid(ci[15:0]),.atype(ct[1:0]),
  .wvalid(cw[0]),.wlast(cwl[0]),.wdata(cwd[127:0]),.wready(cwr[0]),
  .bvalid(cb[0]),.bresp(cbr[1:0]),.bid(cbi[7:0]),.rvalid(cr[1]),.rlast(crl[1]),.rdata(crd[255:128]),.rresp(crresp[3:2]),.rid(cri[15:8]),.rready(crr[1]),
  .rejected(rejected[1:0]),.write_permission(wp),.read_permission(rp),.camera_bytes(camera_bytes),.display_bytes(display_bytes),.urgent(urgent),.safe_window(safe_window),
  .fifo_ready(fifo_ready[3:0]),.camera_max(camera_max),.display_min(display_min),.fifo_faults(video_fifo_faults));
 assign cw[1]=0;assign cwl[1]=0;assign cwd[255:128]=0;assign crr[0]=1;
 m5b1_backend background(.ui_clk(ui_clk),.pix_clk(pix_clk),.rst_n(rst_n),.run(run),.stop(stop),.epoch(epoch),
  .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(tap_high),.tap_low(tap_low),.tap_filter(tap_filter),
  .tap_frame_id(tap_frame_id),.tap_epoch(tap_epoch),.tap_timestamp(tap_timestamp),.tap_display_seq(tap_display_seq),.tap_config_generation(tap_config_generation),
  .fusion_acquire(lease_acquire),.fusion_slot(lease_slot),.fusion_identity(lease_identity),.fusion_token(lease_token),
  .fusion_release(lease_release),.fusion_retire(lease_retire),.fusion_read_accept(read_accept),.fusion_read_done(read_done),
  .fusion_ack(lease_ack),.fusion_denied(lease_denied),.pair_leased(pair_leased),.result_valid(result_valid),.result_slot(result_slot),
  .result_descriptor(result_descriptor),.export_exclusive(export_exclusive),.capture_priority(capture_priority),.lease_fault(lease_fault),.job_rejected_event(job_rejected_event),
  .telemetry_ready(telemetry_ready),.telemetry_descriptor(telemetry_header),.telemetry_byte(telemetry_byte),.telemetry_index(telemetry_index),.telemetry_take(telemetry_take),
  .max_wait(max_wait),.max_service(max_service),.camera_max(camera_max),.display_min(display_min),
  .system_status({19'b0,ack,error_reason,4'b0,stop,quarantine,cal_pass,cal_done}),.error_counts(error_counts),.video_fifo_faults(video_fifo_faults),
  .uart_tx(uart_tx),.job_busy(job_busy),.publish_toggle(publish_toggle),.bg_fault(bg_fault),.capture_reset_done(fifo_ready[5:4]),
  .avalid(sa[0]),.aready(sar[0]),.aaddr(sad[31:0]),.alen(sal[7:0]),.aid(sai[7:0]),.atype(sat[0]),
  .wvalid(sw[0]),.wlast(swl[0]),.wdata(swd[127:0]),.wready(swr[0]),.bvalid(sb[0]),.bid(sbi),.bresp(sbr),
  .rvalid(sr[0]),.rlast(srl),.rdata(srd),.rid(sri),.rresp(sresp),.rready(srr[0]),.rejected(srej[0]),.write_permission(backend_wp),.read_permission(backend_rp));
 assign sw[1]=0;assign swl[1]=0;assign swd[255:128]=0;
 m5c_display_session fusion(.ui_clk(ui_clk),.pix_clk(pix_clk),.rst_n(rst_n),.stop(fusion_stop),
  .request_frame(fusion_request),.request_seq(fusion_request_seq),.request_config(fusion_config),
  .pixel_release(fusion_release),.pixel_release_final(fusion_release_final),.pixel_release_session(fusion_release_session),.pixel_release_ready(fusion_release_ready),
  .result_valid(result_valid),.result_slot(result_slot),.result_descriptor(result_descriptor),.export_exclusive(export_exclusive),
  .acquire(lease_acquire),.lease_slot(lease_slot),.lease_identity(lease_identity),.lease_token(lease_token),
  .acquire_ack(lease_ack),.acquire_denied(lease_denied),.pair_leased(pair_leased),.lease_release(lease_release),.lease_retire(lease_retire),
  .read_accept(read_accept),.read_done(read_done),.session_fault(session_fault),
  .telemetry_pending(telemetry_pending),.telemetry_descriptor(telemetry_descriptor),.telemetry_session(telemetry_session),
  .offer_valid(fusion_offer_valid),.offer_take(fusion_offer_take),.offer_descriptor(fusion_descriptor),.offer_session(fusion_session),
  .context_block(fusion_context_block),.context_quiet(fusion_context_quiet),.context_tail_fault(fusion_context_tail_fault),
  .ce(fusion_ce),.read_valid(fusion_read),.read_x(fusion_x),.read_y(fusion_y),.read_session(fusion_read_session),
  .ref_ready(fusion_ref_ready),.ref_class(fusion_ref_class),.ref_mask(fusion_ref_mask),.ref_x(fusion_ref_x),.ref_y(fusion_ref_y),.ref_session(fusion_ref_session),
  .retire(fusion_retire),.retire_row(fusion_retire_row),.flush(fusion_flush),.prefilled(fusion_prefilled),
  .avalid(sa[1]),.aready(sar[1]),.aaddr(sad[63:32]),.alen(sal[15:8]),.aid(sai[15:8]),.atype(sat[1]),
  .rvalid(sr[1]),.rlast(srl),.rdata(srd),.rid(sri),.rresp(sresp),.rready(srr[1]),.rejected(srej[1]),.read_permission(fusion_rp));
 m5c_telemetry telemetry(.pix_clk(pix_clk),.ui_clk(ui_clk),.rst_n(rst_n),
  .frame_done(fusion_frame_done),.pixel_snapshot(fusion_telemetry_snapshot),.active_descriptor(telemetry_descriptor),
  .active_session(telemetry_session),.active_token(lease_token),.active_slot(lease_slot),
  .rejected_jobs(rejected_job_count),.protocol_faults(protocol_fault_count),
  .payload_ready(telemetry_ready),.header_descriptor(telemetry_header),.payload_take(telemetry_take),
  .byte_index(telemetry_index),.payload_byte(telemetry_byte),.snapshot_pending(telemetry_pending),.snapshot_fault(telemetry_fault));
 m5c_bg_mux bg_mux(.clk(ui_clk),.rst_n(rst_n),.stop(stop),.capture_priority(capture_priority),
  .s_avalid(sa),.s_aready(sar),.s_aaddr(sad),.s_alen(sal),.s_aid(sai),.s_atype(sat),
  .s_wvalid(sw),.s_wlast(swl),.s_wdata(swd),.s_wready(swr),.s_bvalid(sb),.s_bid(sbi),.s_bresp(sbr),
  .s_rvalid(sr),.s_rlast(srl),.s_rdata(srd),.s_rid(sri),.s_rresp(sresp),.s_rready(srr),.s_rejected(srej),.busy(),.owner(),
  .avalid(ca[2]),.aready(car[2]),.aaddr(cad[95:64]),.alen(cl[23:16]),.aid(ci[23:16]),.atype(ct[2]),
  .wvalid(cw[2]),.wlast(cwl[2]),.wdata(cwd[383:256]),.wready(cwr[2]),.bvalid(cb[2]),.bid(cbi[23:16]),.bresp(cbr[5:4]),
  .rvalid(cr[2]),.rlast(crl[2]),.rdata(crd[383:256]),.rid(cri[23:16]),.rresp(crresp[5:4]),.rready(crr[2]),.rejected(rejected[2]));
 m5b1_arbiter arbiter(.clk(ui_clk),.rst_n(rst_n),.soft_reset(1'b0),.ddr_reset_ack(ack),.urgent(urgent),.safe_window(safe_window),
  .emergency_stop(stop||!run),.epoch(epoch),.c_epoch({epoch,epoch,epoch}),.video_write_permission(wp),.video_read_permission(rp),.bg_write_permission(bwp),.bg_read_permission(brp),
  .error_counts(error_counts),.max_wait(max_wait),.max_service(max_service),.qos_exceeded(qos_exceeded),.accepts(accepts),.completes(completes),.rejects(rejects),
  .c_avalid(ca),.c_aready(car),.c_aaddr(cad),.c_alen(cl),.c_aid(ci),.c_atype(ct),
  .c_wvalid(cw),.c_wlast(cwl),.c_wready(cwr),.c_wdata(cwd),.c_wstrb(48'hffffffffffff),
  .c_bvalid(cb),.c_bready(3'b111),.c_bid(cbi),.c_bresp(cbr),.c_rvalid(cr),.c_rlast(crl),.c_rready(crr),.c_rdata(crd),.c_rid(cri),.c_rresp(crresp),
  .rejected(rejected),.quarantine(quarantine),.reset_request(reset_request),.error_reason(error_reason),.busy(arb_busy),
  .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),
  .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),
  .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
 reg [26:0] heartbeat;always @(posedge ui_clk or negedge rst_n)if(!rst_n)heartbeat<=0;else heartbeat<=heartbeat+1'b1;
 assign led={bg_fault,video_fault||quarantine||stop,publish_toggle,job_busy,cal_done&&cal_pass,heartbeat[25]};
endmodule
