// EXPORT_CYCLES is a deprecated unused compatibility parameter in pair-only profile.
// Actual pair export timeout is m5c_pair_controller.EXPORT_CYCLES (6144000000 UI cycles).
module m5c_pair_backend #(parameter REQUEST_CYCLES=96000000,CAPTURE_CYCLES=96000000,EXPORT_CYCLES=960000000,DIAGNOSTICS=0)(
 input pair_local_rst_n,input pair_request,pair_wait_expired,input [767:0] active_pair_descriptor,input [63:0] pair_session,pair_request_session,
 output pair_request_take,pair_arm,pair_cancel,pair_terminal,
 input pair_arm_busy,pair_done,input [31:0] pair_reason,output pair_done_take,
 input pair_empty,input [9:0] pair_count,input [127:0] pair_data,output pair_pop,
 output pair_current_write,pair_metadata_write,pair_current_read,pair_metadata_read,
 input ui_clk,pix_clk,rst_n,run,stop,input [63:0] epoch,
 input tap_valid,input [1:0] tap_class,input [11:0] tap_x,tap_y,input [7:0] tap_high,tap_low,input tap_filter,
 input [63:0] tap_frame_id,tap_epoch,tap_timestamp,tap_display_seq,tap_config_generation,
 input fusion_acquire,input fusion_slot,input [319:0] fusion_identity,input [63:0] fusion_token,
 input fusion_release,fusion_retire,fusion_read_accept,fusion_read_done,
 output fusion_ack,fusion_denied,output [3:0] pair_leased,
 output result_valid,result_slot,output [767:0] result_descriptor,
 output export_exclusive,capture_priority,output lease_fault,output job_rejected_event,
 input diag_ready,diag_window,input [7:0] diag_byte,input diag_byte_valid,
 output [8:0] diag_index,output diag_done,diag_cancel,
 input telemetry_ready,input [319:0] telemetry_descriptor,input [7:0] telemetry_byte,
 output [8:0] telemetry_index,output reg telemetry_take,
 input [95:0] max_wait,max_service,input [13:0] camera_max,display_min,
 input [31:0] system_status, input [223:0] error_counts,input [3:0] video_fifo_faults,
 output uart_tx,output job_busy,output reg publish_toggle,output reg bg_fault,
 output [1:0] capture_reset_done,
 output avalid,input aready,output [31:0] aaddr,output [7:0] alen,aid,output atype,
 output wvalid,wlast,output [127:0] wdata,input wready,input bvalid,input [7:0] bid,input [1:0] bresp,
 input rvalid,rlast,input [127:0] rdata,input [7:0] rid,input [1:0] rresp,output rready,input rejected,
 output reg [6:0] write_permission,read_permission);
 localparam IDLE=0,HEADER=1,CAPTURE=2,CAPWAIT=3,FREEZE=4,ENGINE=5,ENGINE_WAIT=6,
  STATS=7,STATS_WAIT=8,DRAIN=14,FAULT_REPORT=16,FAULT_IDLE=17,
  RESERVE_WAIT=18,BIND=19,BIND_WAIT=20,TELEMETRY=23,TELEMETRY_WAIT=24;
 reg packet_start,packet_abort;wire packet_busy,packet_done,payload_ready;
 wire tx_busy,tx_done,tx_error,tx_cancelled,tx_read_beat,tx_write_beat;wire [7:0] tx_beat;

 reg [4:0] state;reg fault_reported,ever_run,job_failed;reg [31:0] local_cancels;

 wire [13:0] capture_min,capture_max;wire [1:0] capture_fifo_faults;reg class_slot,latest_slot,latest_valid;
 reg [63:0] job_id;reg [31:0] tick,requests,accepted,busy_rejected,capture_drop,published_count,result_age;
 reg [31:0] offset,capture_age;reg arm,descriptor_take;
 wire arm_busy,cap_empty,descriptor_valid;wire [127:0] cap_data;wire [9:0] cap_count;wire [767:0] cap_descriptor;
 wire cap_dropped;
 (* async_reg="true" *) reg [1:0] dropped_sync;
 always @(posedge ui_clk or negedge rst_n)if(!rst_n)dropped_sync<=0;else dropped_sync<={dropped_sync[0],cap_dropped};
 wire cap_pop=(state==HEADER&&!cap_empty)||(state==CAPWAIT&&tx_write_beat)||(state==DRAIN&&!cap_empty);
 m5b1_capture capture(.ui_clk(ui_clk),.pix_clk(pix_clk),.arst_n(rst_n),.cancel(state==DRAIN||stop),.arm(arm),.job(job_id),.epoch(epoch),.arm_busy(arm_busy),
  .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(tap_high),.tap_low(tap_low),.tap_filter(tap_filter),
  .tap_frame_id(tap_frame_id),.tap_epoch(tap_epoch),.tap_timestamp(tap_timestamp),.tap_display_seq(tap_display_seq),.tap_config_generation(tap_config_generation),.data(cap_data),.empty(cap_empty),.pop(cap_pop),.count(cap_count),
  .descriptor_valid(descriptor_valid),.descriptor(cap_descriptor),.descriptor_take(descriptor_take),.reset_done(capture_reset_done),.dropped(cap_dropped),.fifo_min_bytes(capture_min),.fifo_max_bytes(capture_max),.fifo_faults(capture_fifo_faults));
 reg [319:0] frozen;
 wire eng_busy,eng_finished,eng_failed,eng_published,eng_result_slot;wire [319:0] eng_descriptor;
 reg [767:0] frozen_extended,latest_descriptor;
 reg [319:0] writer_identity;
 reg [63:0] generation;
 reg writer_owned,cancel_sent;
 wire reserve_ack,reserve_denied,reserve_slot,bind_ack,acquire_ack,acquire_denied;
 wire lease_latest_valid,lease_latest_slot,publication_accept;wire [1:0] reserved,committed;
 wire event_rejected;
 wire pair_buffer_write;wire [4:0] pair_buffer_write_address,pair_buffer_read_address;wire [127:0] pair_buffer_write_data;
 wire pair_fail_selected,pair_packet_reserve,pair_hold,pair_retain_owner,pair_selected,pair_release,pair_retire,pair_export,pair_reference_read;
 wire pair_tx_start,pair_tx_write,pair_tx_cancel;wire [31:0] pair_tx_addr;wire [7:0] pair_tx_len;wire [127:0] pair_tx_data;
 wire pair_packet_start,pair_packet_abort,pair_payload_valid;wire [7:0] pair_packet_type,pair_payload;
 wire [31:0] pair_packet_length,pair_failure;wire [3:0] pair_attempts;
 // Consume the independent mailbox promptly; preserve the latest observed full SID.
 reg [63:0] pair_latest_request_session;
 reg pair_latest_request_valid;
 always @(posedge ui_clk or negedge pair_local_rst_n)
  if(!pair_local_rst_n)begin pair_latest_request_session<=0;pair_latest_request_valid<=0;end
  else if(pair_request)begin pair_latest_request_session<=pair_request_session;pair_latest_request_valid<=1;end
 wire pair_effective_request_valid=pair_request||pair_latest_request_valid;
 wire [63:0] pair_effective_request_session=pair_request?pair_request_session:pair_latest_request_session;
 reg fresh_publication_seen;
 always @(posedge ui_clk or negedge pair_local_rst_n)
  if(!pair_local_rst_n)fresh_publication_seen<=0;
  else if(pair_selected)fresh_publication_seen<=0;
  else if(publication_accept)fresh_publication_seen<=1;
 // Capture may retain this acquisition while ordinary type4 finishes.
 // UART ownership remains with type4 until its actual DONE/TAKE fence;
 // the pair controller cannot export until release/retire and packet quiet.
 wire pair_selection_window=(state==IDLE&&!packet_busy&&!packet_start)||
  state==TELEMETRY||state==TELEMETRY_WAIT;
 assign pair_selected=pair_effective_request_valid&&fusion_acquire&&fresh_publication_seen&&
  active_pair_descriptor==result_descriptor&&!pair_terminal&&!pair_hold&&pair_selection_window&&
  !tx_busy&&!eng_busy&&!arm_busy&&!writer_owned&&!stop;
 assign pair_fail_selected=pair_wait_expired&&!pair_terminal&&!pair_hold&&state==IDLE&&
  !tx_busy&&!eng_busy&&!arm_busy&&!writer_owned&&!packet_busy&&!packet_start&&!stop;
 // ACK every visible message, independently of ordinary fusion acquisition.
 assign pair_request_take=pair_request;
 wire want_reserve=run&&!stop&&tick==REQUEST_CYCLES-1&&state==IDLE&&!arm_busy&&!writer_owned&&!pair_hold&&!pair_selected&&!pair_fail_selected;
 // One event for a scheduling request not admitted, or its later slot denial.
 assign job_rejected_event=run&&!stop&&((tick==REQUEST_CYCLES-1&&!want_reserve)||
  (state==RESERVE_WAIT&&reserve_denied));
 wire [319:0] provisional_identity={epoch,job_id+64'd1,64'd0,64'd0,generation+64'd1};
 wire [319:0] captured_identity={frozen_extended[63:0],frozen_extended[191:128],frozen_extended[127:64],frozen_extended[447:384],frozen_extended[511:448]};
 wire cancel_writer=writer_owned&&!cancel_sent&&(state==DRAIN||(state==STATS&&job_failed));
 wire writer_drained=cancel_sent&&!tx_busy&&!eng_busy&&!arm_busy&&cap_empty&&!descriptor_valid;
 wire transfer_segment_accept,transfer_segment_done,transfer_segment_write;
 reg metadata_committed;
 wire publication_ok=eng_published&&metadata_committed&&eng_descriptor==frozen&&eng_result_slot==class_slot;



 assign result_valid=lease_latest_valid;assign result_slot=lease_latest_slot;
 assign result_descriptor=latest_descriptor;
 assign export_exclusive=1'b0;assign capture_priority=state>=HEADER&&state<=FREEZE;
 assign fusion_ack=acquire_ack;
 assign fusion_denied=acquire_denied;
 // Initial bridge stop is not a runtime failure before first run; no job
 // exists then. Current run also covers a simultaneous first-run/stop edge.
 m5c_pair_diag_lease lease(.clk(ui_clk),.rst_n(rst_n),.stop(stop&&(ever_run||run)),.export_exclusive(export_exclusive),
  .reserve_valid(want_reserve),.reserve_identity(provisional_identity),.reserve_ack(reserve_ack),.reserve_denied(reserve_denied),.reserve_slot(reserve_slot),
  .bind_valid(state==BIND),.bind_slot(class_slot),.bind_identity(captured_identity),.bind_ack(bind_ack),
  .publish_valid(publication_ok),.publish_slot(class_slot),.metadata_b_done(metadata_committed),.publish_identity(writer_identity),
  .cancel_valid(cancel_writer),.cancel_slot(class_slot),.write_drained(writer_drained),.cancel_identity(writer_identity),
  .acquire_valid(fusion_acquire),.acquire_slot(fusion_slot),.acquire_uart(1'b0),.acquire_identity(fusion_identity),.acquire_token(fusion_token),
  .acquire_ack(acquire_ack),.acquire_denied(acquire_denied),
  .release_valid(pair_retain_owner?pair_release:fusion_release),.release_slot(fusion_slot),.release_uart(1'b0),.release_identity(fusion_identity),.release_token(fusion_token),
  .retire_valid(pair_retain_owner?pair_retire:fusion_retire),.retire_slot(fusion_slot),.retire_uart(1'b0),.retire_identity(fusion_identity),.retire_token(fusion_token),
  .read_accept(fusion_read_accept||(pair_hold&&transfer_segment_accept&&!transfer_segment_write)),.read_slot(fusion_slot),.read_uart(1'b0),.read_identity(fusion_identity),.read_token(fusion_token),
  .read_done(fusion_read_done||(pair_hold&&transfer_segment_done&&!transfer_segment_write)),.done_slot(fusion_slot),.done_uart(1'b0),.done_identity(fusion_identity),.done_token(fusion_token),
  .latest_valid(lease_latest_valid),.latest_slot(lease_latest_slot),.reserved(reserved),.committed(committed),.leased(pair_leased),
  .protocol_fault(lease_fault),.event_rejected(event_rejected),.publication_accept(publication_accept));
 wire eng_reserved;
 wire [15:0] eng_pairs,eng_scans;wire [31:0] eng_elapsed,eng_changed;
 wire eng_tx_start,eng_tx_write,eng_tx_cancel;wire [31:0] eng_tx_address;wire [7:0] eng_tx_length;wire [127:0] eng_tx_data;
 wire [31:0] class_base=class_slot?32'h01039000:32'h01000000;
 m5b1_global_engine engine(.clk(ui_clk),.rst_n(rst_n),.stop(stop),.start(state==ENGINE),.descriptor(frozen),.class_base(class_base),
  .result_available(class_slot?2'b10:2'b01),
  .result_reserved(eng_reserved),.busy(eng_busy),.finished(eng_finished),.failed(eng_failed),.published(eng_published),.result_slot(eng_result_slot),.published_descriptor(eng_descriptor),
  .pairs(eng_pairs),.scans(eng_scans),.elapsed(eng_elapsed),.changed_pixels(eng_changed),
  .tx_start(eng_tx_start),.tx_write(eng_tx_write),.tx_cancel(eng_tx_cancel),.tx_address(eng_tx_address),.tx_length(eng_tx_length),
  .tx_busy(tx_busy),.tx_done(state==ENGINE_WAIT&&tx_done),.tx_error(tx_error),.tx_beat(tx_beat),.tx_read_beat(state==ENGINE_WAIT&&tx_read_beat),.tx_rdata(rdata),.tx_write_beat(state==ENGINE_WAIT&&tx_write_beat),.tx_wdata(eng_tx_data));

 wire eng_selected=state==ENGINE_WAIT;
 wire capture_timeout=state>=HEADER&&state<=FREEZE&&capture_age>=CAPTURE_CYCLES;

 wire transfer_cancel=eng_selected?eng_tx_cancel:capture_timeout;
 wire transfer_start=eng_selected?eng_tx_start:!transfer_cancel&&((state==CAPTURE&&cap_count>=32&&!(descriptor_valid&&!cap_descriptor[308])));

 wire [31:0] transfer_address=eng_selected?eng_tx_address:class_base+offset;
 wire transfer_write=eng_selected?eng_tx_write:state==CAPTURE;
 m5b1_transfer transfer(.clk(ui_clk),.rst_n(rst_n),.stop(stop),.start(pair_hold?pair_tx_start:transfer_start),.cancel(pair_hold?pair_tx_cancel:transfer_cancel),.write_op(pair_hold?pair_tx_write:transfer_write),
  .address(pair_hold?pair_tx_addr:transfer_address),.length(pair_hold?pair_tx_len:eng_selected?eng_tx_length:8'd31),.busy(tx_busy),.done(tx_done),.error(tx_error),.cancelled(tx_cancelled),.beat(tx_beat),.read_beat(tx_read_beat),.write_beat(tx_write_beat),
  .segment_accept(transfer_segment_accept),.segment_is_write(transfer_segment_write),.segment_done(transfer_segment_done),.segment_error(),.logical_drained(),
  .avalid(avalid),.aready(aready),.aaddr(aaddr),.alen(alen),.aid(aid),.atype(atype),
  .source_data(pair_hold?pair_tx_data:eng_selected?eng_tx_data:cap_data),.wdata(wdata),.wvalid(wvalid),.wlast(wlast),.wready(wready),
  .bvalid(bvalid),.bid(bid),.bresp(bresp),.rvalid(rvalid),.rlast(rlast),.rid(rid),.rresp(rresp),.rready(rready),.rejected(rejected));
 reg [2047:0] stats;reg [8:0] byte_index;
 (* syn_ramstyle="block_ram" *) reg [127:0] export_mem[0:31];reg [127:0] export_head;
 wire shared_write_enable=pair_buffer_write;
 wire [4:0] shared_write_address=pair_buffer_write_address;
 wire [4:0] shared_read_address=pair_buffer_read_address;
 wire [127:0] shared_write_data=pair_buffer_write_data;
 always @(posedge ui_clk)begin
  if(shared_write_enable)export_mem[shared_write_address]<=shared_write_data;
  export_head<=export_mem[shared_read_address];
 end

 wire diag_busy;reg diag_slot;
 wire diag_grant=DIAGNOSTICS&&diag_slot&&diag_ready&&diag_window&&run&&!stop&&state==IDLE&&
  !packet_busy&&!packet_start&&!telemetry_ready&&!telemetry_take&&!want_reserve&&!arm_busy&&!writer_owned&&
  REQUEST_CYCLES>700000&&tick<REQUEST_CYCLES-700000;
 always @(posedge ui_clk or negedge rst_n)begin
  if(!rst_n)diag_slot<=0;
  else if(!diag_window||stop||diag_grant)diag_slot<=0;
  else if(state==TELEMETRY_WAIT&&packet_done)diag_slot<=1;
 end
 assign telemetry_index=byte_index;
 wire [7:0] payload=state==TELEMETRY_WAIT?telemetry_byte:stats[byte_index*8+:8];
 wire payload_valid=state==STATS_WAIT||state==TELEMETRY_WAIT;
 m5b1_packet_tx #(.DIAGNOSTICS(DIAGNOSTICS)) packet(.clk(ui_clk),.rst_n(rst_n),.abort(packet_abort||(pair_export&&pair_packet_abort)),.start(pair_export?pair_packet_start:packet_start),.packet_type(pair_export?pair_packet_type:state==TELEMETRY_WAIT?8'd4:8'd1),
  .length(pair_export?pair_packet_length:32'd256),.descriptor(pair_export?active_pair_descriptor[319:0]:state==TELEMETRY_WAIT?telemetry_descriptor:frozen),
  .diag_grant(diag_grant),.diag_byte(diag_byte),.diag_byte_valid(diag_byte_valid),.diag_index(diag_index),.diag_busy(diag_busy),.diag_done(diag_done),.diag_cancel(diag_cancel),
  .payload(pair_export?pair_payload:payload),.payload_valid(pair_export?pair_payload_valid:payload_valid),.payload_ready(payload_ready),.busy(packet_busy),.done(packet_done),.uart_tx(uart_tx));
 m5c_pair_controller pair_controller(.clk(ui_clk),.rst_n(pair_local_rst_n),.stop(stop),.select(pair_selected),.wait_expired(pair_fail_selected),
 .acquire_ack(fusion_ack),.acquire_denied(fusion_denied),.descriptor(active_pair_descriptor),.identity(fusion_identity),.session(pair_session),.token(fusion_token),.slot(fusion_slot),
 .fusion_release(fusion_release),.fusion_retire(fusion_retire),.held(pair_leased[fusion_slot?2:0]),
 .hold(pair_hold),.retain_owner(pair_retain_owner),.arm(pair_arm),.cancel_capture(pair_cancel),.release_owned(pair_release),.retire_owned(pair_retire),
 .cap_arm_busy(pair_arm_busy),.cap_done(pair_done),.cap_reason(pair_reason),.cap_take(pair_done_take),.cap_empty(pair_empty),.cap_count(pair_count),.cap_data(pair_data),.cap_pop(pair_pop),
 .tx_start(pair_tx_start),.tx_write(pair_tx_write),.tx_cancel(pair_tx_cancel),.tx_addr(pair_tx_addr),.tx_len(pair_tx_len),.tx_data(pair_tx_data),
 .tx_busy(tx_busy),.tx_done(tx_done),.tx_error(tx_error),.tx_read_beat(tx_read_beat),.tx_write_beat(tx_write_beat),.tx_beat(tx_beat),.rdata(rdata),
 .buffer_write(pair_buffer_write),.buffer_write_address(pair_buffer_write_address),.buffer_read_address(pair_buffer_read_address),.buffer_write_data(pair_buffer_write_data),.buffer_read_data(export_head),
 .packet_start(pair_packet_start),.packet_abort(pair_packet_abort),.packet_type(pair_packet_type),.packet_length(pair_packet_length),.payload(pair_payload),.payload_valid(pair_payload_valid),
 .payload_ready(pair_export&&payload_ready),.packet_done(pair_export&&packet_done),.packet_busy(packet_busy||packet_start||state==TELEMETRY||state==TELEMETRY_WAIT),
 .packet_reserve(pair_packet_reserve),.export_active(pair_export),.current_write(pair_current_write),.metadata_write(pair_metadata_write),.current_read(pair_current_read),.metadata_read(pair_metadata_read),.reference_read(pair_reference_read),
 .terminal(pair_terminal),.failure(pair_failure),.attempts(pair_attempts));
 // synthesis translate_off
 always @(posedge ui_clk)if(rst_n&&!stop)begin
  if(pair_selected&&want_reserve)$fatal(1,"PAIR_SELECTED_WRITER_COLLISION");
  if(pair_hold&&writer_owned)$fatal(1,"PAIR_HELD_WITH_WRITER");
  if(pair_selected&&publication_accept)$fatal(1,"PAIR_PUBLICATION_SELECTION_SAME_EDGE");
  if(pair_leased[3]||pair_leased[1])$fatal(1,"PAIR_ONLY_UART_OWNER_NONZERO");
  if(pair_export&&packet_start)$fatal(1,"PAIR_PACKET_ORIGINAL_COLLISION");
 end
 // synthesis translate_on
 assign job_busy=state!=IDLE;
 always @*begin
  write_permission=0;read_permission=0;
  if(pair_reference_read)begin
   read_permission[fusion_slot?1:0]=1;
   read_permission[fusion_slot?5:4]=1;
  end
  if(state==CAPTURE||state==CAPWAIT)write_permission[class_slot?1:0]=1;
  if(state==ENGINE_WAIT)begin
   read_permission[class_slot?1:0]=1;read_permission[3:2]=3;
   write_permission[3:2]=3;
   if(eng_reserved)begin write_permission[eng_result_slot?5:4]=1;write_permission[6]=1;end
  end

 end
 always @(posedge ui_clk or negedge rst_n)begin
  if(!rst_n)begin
   state<=IDLE;fault_reported<=0;ever_run<=0;job_failed<=0;local_cancels<=0;class_slot<=1;latest_slot<=0;latest_valid<=0;job_id<=0;tick<=0;requests<=0;accepted<=0;busy_rejected<=0;capture_drop<=0;published_count<=0;result_age<=0;
   offset<=0;capture_age<=0;arm<=0;descriptor_take<=0;frozen<=0;publish_toggle<=0;bg_fault<=0;stats<=0;byte_index<=0;packet_start<=0;packet_abort<=0;
   frozen_extended<=0;latest_descriptor<=0;writer_identity<=0;generation<=0;
   writer_owned<=0;cancel_sent<=0;metadata_committed<=0;telemetry_take<=0;
  end else begin
   arm<=0;descriptor_take<=0;packet_start<=0;packet_abort<=0;
   telemetry_take<=0;
   if(cancel_writer)cancel_sent<=1;
   if(writer_drained)begin writer_owned<=0;cancel_sent<=0;end
   if(state==ENGINE)metadata_committed<=0;
   if(eng_selected&&transfer_segment_done&&transfer_segment_write&&bresp==0&&bid==8'h22&&
      eng_tx_address==(32'h010e6000+(class_slot?128:0)))metadata_committed<=1;
   if(publication_ok)writer_owned<=0;
   if(publication_accept)latest_descriptor<=frozen_extended;
   if(eng_published&&!publication_ok)begin bg_fault<=1;job_failed<=1;end
   if(event_rejected||lease_fault)bg_fault<=1;
   if(run)ever_run<=1;
   if(tx_cancelled)local_cancels<=local_cancels+1'b1;
   if(run&&!stop)begin
    if(tick==REQUEST_CYCLES-1)begin
     tick<=0;requests<=requests+1'b1;result_age<=result_age+1'b1;
     if(!want_reserve)busy_rejected<=busy_rejected+1'b1;
     else if(want_reserve)state<=RESERVE_WAIT;
    end else tick<=tick+1'b1;
   end
   if(state>=HEADER&&state<=FREEZE)capture_age<=capture_age+1'b1;

   case(state)
    IDLE:if(!pair_fail_selected&&!pair_packet_reserve&&telemetry_ready&&!telemetry_take&&!want_reserve&&!stop)state<=TELEMETRY;
    TELEMETRY:begin byte_index<=0;packet_start<=1;state<=TELEMETRY_WAIT;end
    TELEMETRY_WAIT:begin
     if(payload_ready&&payload_valid&&byte_index<255)byte_index<=byte_index+1'b1;
     if(packet_done)begin telemetry_take<=1;state<=IDLE;end
    end
    RESERVE_WAIT:begin
     if(reserve_ack)begin
      accepted<=accepted+1'b1;job_id<=job_id+1'b1;generation<=generation+1'b1;job_failed<=0;
      writer_identity<=provisional_identity;writer_owned<=1;cancel_sent<=0;class_slot<=reserve_slot;
      arm<=1;state<=HEADER;offset<=0;capture_age<=0;
     end else if(reserve_denied)begin busy_rejected<=busy_rejected+1'b1;state<=IDLE;end
    end
    HEADER:if(!cap_empty)begin
     if(cap_data!={job_id,epoch})begin bg_fault<=1;state<=DRAIN;end else state<=CAPTURE;
    end
    CAPTURE:begin
     if(descriptor_valid&&!cap_descriptor[308])begin state<=DRAIN;capture_drop<=capture_drop+1'b1;end
     else if(cap_count>=32)state<=CAPWAIT;
    end
    CAPWAIT:if(tx_done)begin
     if(tx_error)begin bg_fault<=1;state<=DRAIN;end
     else if(offset==230400-512)state<=FREEZE;
     else begin offset<=offset+512;state<=CAPTURE;end
    end
    FREEZE:if(descriptor_valid&&!capture_timeout)begin
     frozen<=cap_descriptor[319:0];frozen_extended<=cap_descriptor;frozen_extended[511:448]<=generation;descriptor_take<=1;
     if(cap_descriptor[308]&&cap_descriptor[63:0]==epoch&&cap_descriptor[191:128]==job_id)state<=BIND;
     else begin capture_drop<=capture_drop+1'b1;bg_fault<=1;job_failed<=1;state<=STATS;end
    end
    BIND:state<=BIND_WAIT;
    BIND_WAIT:if(bind_ack)begin writer_identity<=captured_identity;state<=ENGINE;end
              else if(event_rejected)begin job_failed<=1;state<=STATS;end
    ENGINE:state<=ENGINE_WAIT;
    ENGINE_WAIT:if(eng_finished)begin
     if(eng_failed)begin bg_fault<=1;job_failed<=1;end
     if(publication_ok)begin latest_valid<=1;latest_slot<=eng_result_slot;published_count<=published_count+1'b1;publish_toggle<=!publish_toggle;result_age<=0;end
     state<=STATS;
    end
    STATS:begin
     stats<=0;stats[31:0]<=requests;stats[63:32]<=accepted;stats[95:64]<=busy_rejected;
     stats[127:96]<=capture_drop;stats[159:128]<=published_count;stats[191:160]<=result_age;
     stats[223:192]<={18'b0,camera_max};stats[255:224]<={18'b0,display_min};
     stats[351:256]<=max_wait;stats[447:352]<=max_service;
     stats[479:448]<={eng_scans,eng_pairs};stats[511:480]<=eng_elapsed;stats[543:512]<=eng_changed;
     stats[575:544]<=system_status;stats[639:576]<=job_id;stats[703:640]<=frozen[127:64];
     stats[735:704]<={28'b0,job_failed,stop,eng_failed,dropped_sync[1]};
     stats[767:736]<={18'b0,capture_min};stats[799:768]<={18'b0,capture_max};
     stats[831:800]<={26'b0,capture_fifo_faults,video_fifo_faults};stats[1055:832]<=error_counts;stats[1087:1056]<=local_cancels;byte_index<=0;packet_start<=1;state<=STATS_WAIT;
    end
    STATS_WAIT:begin
     if(payload_ready&&payload_valid&&byte_index<255)byte_index<=byte_index+1'b1;
     if(packet_done)begin
      if(stop)state<=FAULT_IDLE;
      else state<=IDLE;
     end
    end
    FAULT_REPORT:state<=STATS;
    FAULT_IDLE:begin end
    DRAIN:begin
     job_failed<=1;
     if(cap_empty&&descriptor_valid&&!tx_busy)begin descriptor_take<=1;frozen<=cap_descriptor;frozen[308]<=0;state<=STATS;end
    end
   endcase
   // Keep CAPWAIT's payload/pop contract until the owned transaction drains.
   // Cancelling only a queued request also terminates without future READY.
   if(capture_timeout&&!tx_busy)begin bg_fault<=1;job_failed<=1;capture_drop<=capture_drop+1'b1;state<=DRAIN;end
   // UART fault telemetry is independent of the quarantined DDR transaction.
   // Keep the owner/busy state intact: this is not a DDR reset or synthetic ACK.
   if(stop&&ever_run&&!fault_reported)begin fault_reported<=1;latest_valid<=0;bg_fault<=1;packet_abort<=1;state<=FAULT_REPORT;end
  end
 end
endmodule
