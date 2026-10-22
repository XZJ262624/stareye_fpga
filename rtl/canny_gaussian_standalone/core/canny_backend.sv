module canny_backend #(parameter REQUEST_CYCLES=96000000,CAPTURE_CYCLES=96000000,EXPORT_CYCLES=960000000,DIAGNOSTICS=0)(
 input ui_clk,pix_clk,rst_n,run,stop,input [63:0] epoch,
 input tap_valid,input [1:0] tap_class,input [11:0] tap_x,tap_y,input [7:0] tap_high,tap_low,input [1:0] tap_filter,
 input [63:0] tap_frame_id,tap_epoch,tap_timestamp,tap_display_seq,tap_config_generation,
 input fusion_acquire,input fusion_slot,input [319:0] fusion_identity,input [63:0] fusion_token,
 input fusion_release,fusion_retire,fusion_read_accept,fusion_read_done,
 output fusion_ack,fusion_denied,output [3:0] pair_leased,
 output result_valid,result_slot,output [767:0] result_descriptor,
 output export_exclusive,capture_priority,output lease_fault,output job_rejected_event,
 output uart_tx,output job_busy,output reg publish_toggle,output reg bg_fault,
 output [1:0] capture_reset_done,
 output avalid,input aready,output [31:0] aaddr,output [7:0] alen,aid,output atype,
 output wvalid,wlast,output [127:0] wdata,input wready,input bvalid,input [7:0] bid,input [1:0] bresp,
 input rvalid,rlast,input [127:0] rdata,input [7:0] rid,input [1:0] rresp,output rready,input rejected,
 output reg [6:0] write_permission,read_permission);
 `include "gaussian_contract_functions.vh"

 localparam IDLE=0,HEADER=1,CAPTURE=2,CAPWAIT=3,FREEZE=4,ENGINE=5,ENGINE_WAIT=6,
  STATS=7,STATS_WAIT=8,DRAIN=14,FAULT_REPORT=16,FAULT_IDLE=17,
  RESERVE_WAIT=18,BIND=19,BIND_WAIT=20;
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
 wire want_reserve=run&&!stop&&tick==REQUEST_CYCLES-1&&state==IDLE&&!arm_busy&&!writer_owned;
 // One event for a scheduling request not admitted, or its later slot denial.
 assign job_rejected_event=run&&!stop&&((tick==REQUEST_CYCLES-1&&!want_reserve)||
  (state==RESERVE_WAIT&&reserve_denied));
 wire [319:0] provisional_identity={epoch,job_id+64'd1,64'd0,64'd0,generation+64'd1};
 wire [319:0] captured_identity={frozen_extended[63:0],frozen_extended[191:128],frozen_extended[127:64],frozen_extended[447:384],frozen_extended[511:448]};
 wire cancel_writer=writer_owned&&!cancel_sent&&(state==DRAIN||(state==STATS&&job_failed));
 wire writer_drained=cancel_sent&&!tx_busy&&!eng_busy&&!arm_busy&&cap_empty&&!descriptor_valid;
 wire transfer_segment_accept,transfer_segment_done,transfer_segment_write;
 reg metadata_committed;
 wire publication_ok=eng_published&&metadata_committed&&eng_descriptor==frozen&&eng_result_slot==class_slot&&gauss_descriptor_valid(frozen_extended,12'd1280,12'd720);



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
  .release_valid(fusion_release),.release_slot(fusion_slot),.release_uart(1'b0),.release_identity(fusion_identity),.release_token(fusion_token),
  .retire_valid(fusion_retire),.retire_slot(fusion_slot),.retire_uart(1'b0),.retire_identity(fusion_identity),.retire_token(fusion_token),
  .read_accept(fusion_read_accept),.read_slot(fusion_slot),.read_uart(1'b0),.read_identity(fusion_identity),.read_token(fusion_token),
  .read_done(fusion_read_done),.done_slot(fusion_slot),.done_uart(1'b0),.done_identity(fusion_identity),.done_token(fusion_token),
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
 m5b1_transfer transfer(.clk(ui_clk),.rst_n(rst_n),.stop(stop),.start(transfer_start),.cancel(transfer_cancel),.write_op(transfer_write),
  .address(transfer_address),.length(eng_selected?eng_tx_length:8'd31),.busy(tx_busy),.done(tx_done),.error(tx_error),.cancelled(tx_cancelled),.beat(tx_beat),.read_beat(tx_read_beat),.write_beat(tx_write_beat),
  .segment_accept(transfer_segment_accept),.segment_is_write(transfer_segment_write),.segment_done(transfer_segment_done),.segment_error(),.logical_drained(),
  .avalid(avalid),.aready(aready),.aaddr(aaddr),.alen(alen),.aid(aid),.atype(atype),
  .source_data(eng_selected?eng_tx_data:cap_data),.wdata(wdata),.wvalid(wvalid),.wlast(wlast),.wready(wready),
  .bvalid(bvalid),.bid(bid),.bresp(bresp),.rvalid(rvalid),.rlast(rlast),.rid(rid),.rresp(rresp),.rready(rready),.rejected(rejected));
 // UART is deliberately idle; no packet engine or pair owner exists.
 assign uart_tx=1'b1;
 assign job_busy=state!=IDLE;
 always @*begin
  write_permission=0;read_permission=0;
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
   offset<=0;capture_age<=0;arm<=0;descriptor_take<=0;frozen<=0;publish_toggle<=0;bg_fault<=0;
   frozen_extended<=0;latest_descriptor<=0;writer_identity<=0;generation<=0;
   writer_owned<=0;cancel_sent<=0;metadata_committed<=0;
  end else begin
   arm<=0;descriptor_take<=0;
   
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
    IDLE:begin end
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
     if(gauss_descriptor_valid(cap_descriptor,12'd1280,12'd720)&&cap_descriptor[63:0]==epoch&&cap_descriptor[191:128]==job_id)state<=BIND;
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
    // Cancellation is issued in STATS and retained through real drain.
    // Returning to IDLE requires the original writer/transfer/arm fences;
    // there is no synthetic UART DONE or DDR acknowledgment.
    STATS:state<=STATS_WAIT;
    STATS_WAIT:if(!writer_owned&&!tx_busy&&!eng_busy&&!arm_busy&&cap_empty&&!descriptor_valid)
      state<=stop?FAULT_IDLE:IDLE;
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
   // Fail-stop retains the quarantined DDR owner; only cold reconfiguration recovers.
   // Keep the owner/busy state intact: this is not a DDR reset or synthetic ACK.
   if(stop&&ever_run&&!fault_reported)begin fault_reported<=1;latest_valid<=0;bg_fault<=1;state<=FAULT_REPORT;end
  end
 end
endmodule
