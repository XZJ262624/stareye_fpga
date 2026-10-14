module m5b1_backend #(parameter REQUEST_CYCLES=96000000,CAPTURE_CYCLES=96000000,EXPORT_CYCLES=960000000)(
 input ui_clk,pix_clk,rst_n,run,stop,input [63:0] epoch,
 input tap_valid,input [1:0] tap_class,input [11:0] tap_x,tap_y,input [7:0] tap_high,tap_low,input tap_filter,
 input [63:0] tap_frame_id,tap_epoch,tap_timestamp,tap_display_seq,tap_config_generation,
 input fusion_acquire,input fusion_slot,input [319:0] fusion_identity,input [63:0] fusion_token,
 input fusion_release,fusion_retire,fusion_read_accept,fusion_read_done,
 output fusion_ack,fusion_denied,output [3:0] pair_leased,
 output result_valid,result_slot,output [767:0] result_descriptor,
 output export_exclusive,capture_priority,output lease_fault,output job_rejected_event,
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
  STATS=7,STATS_WAIT=8,EXPORT_START=9,EXPORT_READ=10,EXPORT_READ_WAIT=11,EXPORT_BYTES=12,
  EXPORT_FINISH=13,DRAIN=14,EXPORT_PREFETCH=15,FAULT_REPORT=16,FAULT_IDLE=17,
  RESERVE_WAIT=18,BIND=19,BIND_WAIT=20,UART_ACQUIRE=21,UART_WAIT=22,TELEMETRY=23,TELEMETRY_WAIT=24;
 wire tx_busy,tx_done,tx_error,tx_cancelled,tx_read_beat,tx_write_beat;wire [7:0] tx_beat;
 reg [7:0] export_type;
 reg [4:0] state;reg fault_reported,ever_run,job_failed;reg [31:0] local_cancels;
 wire export_active=(state>=EXPORT_START&&state<=EXPORT_FINISH)||state==EXPORT_PREFETCH;
 wire [13:0] capture_min,capture_max;wire [1:0] capture_fifo_faults;reg class_slot,latest_slot,latest_valid,exported;
 reg [63:0] job_id;reg [31:0] tick,requests,accepted,busy_rejected,capture_drop,published_count,result_age;
 reg [31:0] offset,capture_age,export_age;reg arm,descriptor_take;
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
 reg [767:0] frozen_extended,pair_descriptor[0:1];
 reg [319:0] writer_identity;
 reg [63:0] generation,uart_token;
 reg writer_owned,cancel_sent,uart_owned,uart_release;
 wire reserve_ack,reserve_denied,reserve_slot,bind_ack,acquire_ack,acquire_denied;
 wire lease_latest_valid,lease_latest_slot;wire [1:0] reserved,committed;
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
 wire publication_ok=eng_published&&metadata_committed&&eng_descriptor==frozen&&eng_result_slot==class_slot;
 wire uart_read_accept=transfer_segment_accept&&!transfer_segment_write&&uart_owned;
 wire uart_read_done=transfer_segment_done&&!transfer_segment_write&&uart_owned;
 wire uart_acquire=state==UART_ACQUIRE;
 assign result_valid=lease_latest_valid;assign result_slot=lease_latest_slot;
 assign result_descriptor=pair_descriptor[lease_latest_slot];
 assign export_exclusive=!exported;assign capture_priority=state>=HEADER&&state<=FREEZE;
 assign fusion_ack=acquire_ack&&!uart_acquire&&!uart_owned&&state!=UART_WAIT;
 assign fusion_denied=acquire_denied&&state!=UART_WAIT;
 // Initial bridge stop is not a runtime failure before first run; no job
 // exists then. Current run also covers a simultaneous first-run/stop edge.
 m5c_pair_lease lease(.clk(ui_clk),.rst_n(rst_n),.stop(stop&&(ever_run||run)),.export_exclusive(export_exclusive),
  .reserve_valid(want_reserve),.reserve_identity(provisional_identity),.reserve_ack(reserve_ack),.reserve_denied(reserve_denied),.reserve_slot(reserve_slot),
  .bind_valid(state==BIND),.bind_slot(class_slot),.bind_identity(captured_identity),.bind_ack(bind_ack),
  .publish_valid(publication_ok),.publish_slot(class_slot),.metadata_b_done(metadata_committed),.publish_identity(writer_identity),
  .cancel_valid(cancel_writer),.cancel_slot(class_slot),.write_drained(writer_drained),.cancel_identity(writer_identity),
  .acquire_valid(uart_acquire||(fusion_acquire&&!export_exclusive)),.acquire_slot(uart_acquire?latest_slot:fusion_slot),
  .acquire_uart(uart_acquire),.acquire_identity(uart_acquire?writer_identity:fusion_identity),.acquire_token(uart_acquire?uart_token:fusion_token),
  .acquire_ack(acquire_ack),.acquire_denied(acquire_denied),
  .release_valid(uart_release||fusion_release),.release_slot(uart_release?latest_slot:fusion_slot),.release_uart(uart_release),
  .release_identity(uart_release?writer_identity:fusion_identity),.release_token(uart_release?uart_token:fusion_token),
  .retire_valid(uart_release||fusion_retire),.retire_slot(uart_release?latest_slot:fusion_slot),.retire_uart(uart_release),
  .retire_identity(uart_release?writer_identity:fusion_identity),.retire_token(uart_release?uart_token:fusion_token),
  .read_accept(uart_read_accept||fusion_read_accept),.read_slot(uart_read_accept?latest_slot:fusion_slot),.read_uart(uart_read_accept),
  .read_identity(uart_read_accept?writer_identity:fusion_identity),.read_token(uart_read_accept?uart_token:fusion_token),
  .read_done(uart_read_done||fusion_read_done),.done_slot(uart_read_done?latest_slot:fusion_slot),.done_uart(uart_read_done),
  .done_identity(uart_read_done?writer_identity:fusion_identity),.done_token(uart_read_done?uart_token:fusion_token),
  .latest_valid(lease_latest_valid),.latest_slot(lease_latest_slot),.reserved(reserved),.committed(committed),.leased(pair_leased),
  .protocol_fault(lease_fault),.event_rejected(event_rejected));
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
 wire export_timeout=export_active&&export_age>=EXPORT_CYCLES;
 wire transfer_cancel=eng_selected?eng_tx_cancel:capture_timeout||export_timeout;
 wire transfer_start=eng_selected?eng_tx_start:!transfer_cancel&&((state==CAPTURE&&cap_count>=32&&!(descriptor_valid&&!cap_descriptor[308]))||(state==EXPORT_READ));
 wire [31:0] export_base=export_type==2?class_base:(latest_slot?32'h010c9000:32'h010ac000);
 wire [31:0] transfer_address=eng_selected?eng_tx_address:(state==CAPTURE?class_base+offset:export_base+offset);
 wire transfer_write=eng_selected?eng_tx_write:state==CAPTURE;
 m5b1_transfer transfer(.clk(ui_clk),.rst_n(rst_n),.stop(stop),.start(transfer_start),.cancel(transfer_cancel),.write_op(transfer_write),
  .address(transfer_address),.length(eng_selected?eng_tx_length:8'd31),.busy(tx_busy),.done(tx_done),.error(tx_error),.cancelled(tx_cancelled),.beat(tx_beat),.read_beat(tx_read_beat),.write_beat(tx_write_beat),
  .segment_accept(transfer_segment_accept),.segment_is_write(transfer_segment_write),.segment_done(transfer_segment_done),.segment_error(),.logical_drained(),
  .avalid(avalid),.aready(aready),.aaddr(aaddr),.alen(alen),.aid(aid),.atype(atype),
  .source_data(eng_selected?eng_tx_data:cap_data),.wdata(wdata),.wvalid(wvalid),.wlast(wlast),.wready(wready),
  .bvalid(bvalid),.bid(bid),.bresp(bresp),.rvalid(rvalid),.rlast(rlast),.rid(rid),.rresp(rresp),.rready(rready),.rejected(rejected));
 reg [2047:0] stats;reg [8:0] byte_index;
 (* syn_ramstyle="block_ram" *) reg [127:0] export_mem[0:31];reg [127:0] export_head;
 always @(posedge ui_clk)begin
  if(state==EXPORT_READ_WAIT&&tx_read_beat)export_mem[tx_beat[4:0]]<=rdata;
  export_head<=export_mem[byte_index[8:4]];
 end
 reg packet_start,packet_abort;wire packet_busy,packet_done,payload_ready;
 assign telemetry_index=byte_index;
 wire [7:0] payload=state==TELEMETRY_WAIT?telemetry_byte:state==STATS_WAIT?stats[byte_index*8+:8]:export_head[byte_index[3:0]*8+:8];
 wire payload_valid=state==STATS_WAIT||state==EXPORT_BYTES||state==TELEMETRY_WAIT;
 m5b1_packet_tx packet(.clk(ui_clk),.rst_n(rst_n),.abort(packet_abort),.start(packet_start),.packet_type(state==TELEMETRY_WAIT?8'd4:state==STATS_WAIT?8'd1:export_type),
  .length((state==STATS_WAIT||state==TELEMETRY_WAIT)?32'd256:(export_type==2?32'd230400:32'd115200)),.descriptor(state==TELEMETRY_WAIT?telemetry_descriptor:frozen),
  .payload(payload),.payload_valid(payload_valid),.payload_ready(payload_ready),.busy(packet_busy),.done(packet_done),.uart_tx(uart_tx));
 assign job_busy=state!=IDLE;
 always @*begin
  write_permission=0;read_permission=0;
  if(state==CAPTURE||state==CAPWAIT)write_permission[class_slot?1:0]=1;
  if(state==ENGINE_WAIT)begin
   read_permission[class_slot?1:0]=1;read_permission[3:2]=3;
   write_permission[3:2]=3;
   if(eng_reserved)begin write_permission[eng_result_slot?5:4]=1;write_permission[6]=1;end
  end
  if(state>=EXPORT_START&&state<=EXPORT_FINISH)begin read_permission[class_slot?1:0]=1;read_permission[latest_slot?5:4]=1;end
 end
 always @(posedge ui_clk or negedge rst_n)begin
  if(!rst_n)begin
   state<=IDLE;fault_reported<=0;ever_run<=0;job_failed<=0;local_cancels<=0;class_slot<=1;latest_slot<=0;latest_valid<=0;exported<=0;job_id<=0;tick<=0;requests<=0;accepted<=0;busy_rejected<=0;capture_drop<=0;published_count<=0;result_age<=0;
   offset<=0;capture_age<=0;export_age<=0;arm<=0;descriptor_take<=0;frozen<=0;publish_toggle<=0;bg_fault<=0;stats<=0;byte_index<=0;export_type<=2;packet_start<=0;packet_abort<=0;
   frozen_extended<=0;pair_descriptor[0]<=0;pair_descriptor[1]<=0;writer_identity<=0;generation<=0;
   uart_token<=0;writer_owned<=0;cancel_sent<=0;uart_owned<=0;uart_release<=0;metadata_committed<=0;telemetry_take<=0;
  end else begin
   arm<=0;descriptor_take<=0;packet_start<=0;packet_abort<=0;
   uart_release<=0;telemetry_take<=0;
   if(cancel_writer)cancel_sent<=1;
   if(writer_drained)begin writer_owned<=0;cancel_sent<=0;end
   if(state==ENGINE)metadata_committed<=0;
   if(eng_selected&&transfer_segment_done&&transfer_segment_write&&bresp==0&&bid==8'h22&&
      eng_tx_address==(32'h010e6000+(class_slot?128:0)))metadata_committed<=1;
   if(publication_ok)begin writer_owned<=0;pair_descriptor[class_slot]<=frozen_extended;end
   if(eng_published&&!publication_ok)begin bg_fault<=1;job_failed<=1;end
   if(event_rejected||lease_fault)bg_fault<=1;
   if(run)ever_run<=1;
   if(tx_cancelled)local_cancels<=local_cancels+1'b1;
   if(run&&!stop)begin
    if(tick==REQUEST_CYCLES-1)begin
     tick<=0;requests<=requests+1'b1;result_age<=result_age+1'b1;
     if(state!=IDLE)busy_rejected<=busy_rejected+1'b1;
     else if(want_reserve)state<=RESERVE_WAIT;
    end else tick<=tick+1'b1;
   end
   if(state>=HEADER&&state<=FREEZE)capture_age<=capture_age+1'b1;
   if(export_active)export_age<=export_age+1'b1;
   case(state)
    IDLE:if(telemetry_ready&&!telemetry_take&&!want_reserve&&!stop)state<=TELEMETRY;
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
      else if(!exported&&latest_valid&&!eng_failed&&!job_failed)begin export_type<=2;uart_token<=uart_token+1'b1;state<=UART_ACQUIRE;export_age<=0;end
      else state<=IDLE;
     end
    end
    UART_ACQUIRE:state<=UART_WAIT;
    UART_WAIT:if(acquire_ack)begin uart_owned<=1;state<=EXPORT_START;end
              else if(acquire_denied)begin bg_fault<=1;state<=IDLE;end
    EXPORT_START:begin offset<=0;packet_start<=1;state<=EXPORT_READ;end
    EXPORT_READ:state<=EXPORT_READ_WAIT;
    EXPORT_READ_WAIT:begin
     
     if(tx_done)begin
      if(tx_error)begin bg_fault<=1;exported<=1;packet_abort<=1;state<=IDLE;end
      else begin byte_index<=0;state<=EXPORT_PREFETCH;end
     end
    end
    EXPORT_PREFETCH:state<=EXPORT_BYTES;
    EXPORT_BYTES:if(payload_valid&&payload_ready)begin
     if(byte_index==511)begin
      if(offset==(export_type==2?230400:115200)-512)state<=EXPORT_FINISH;
      else begin offset<=offset+512;state<=EXPORT_READ;end
     end else byte_index<=byte_index+1'b1;
    end
    EXPORT_FINISH:if(packet_done)begin
     if(export_type==2)begin export_type<=3;state<=EXPORT_START;end
     else begin exported<=1;uart_release<=1;uart_owned<=0;state<=IDLE;end
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
   if(export_timeout&&!tx_busy)begin bg_fault<=1;job_failed<=1;exported<=1;packet_abort<=1;state<=FAULT_REPORT;end
   // UART fault telemetry is independent of the quarantined DDR transaction.
   // Keep the owner/busy state intact: this is not a DDR reset or synthetic ACK.
   if(stop&&ever_run&&!fault_reported)begin fault_reported<=1;latest_valid<=0;bg_fault<=1;packet_abort<=1;state<=FAULT_REPORT;end
  end
 end
endmodule
