module m5b1_backend #(parameter REQUEST_CYCLES=96000000,CAPTURE_CYCLES=96000000,EXPORT_CYCLES=960000000)(
 input ui_clk,pix_clk,rst_n,run,stop,input [63:0] epoch,
 input tap_valid,input [1:0] tap_class,input [11:0] tap_x,tap_y,input [7:0] tap_high,tap_low,input tap_filter,
 input [63:0] tap_frame_id,tap_epoch,tap_timestamp,
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
  EXPORT_FINISH=13,DRAIN=14,EXPORT_PREFETCH=15,FAULT_REPORT=16,FAULT_IDLE=17;
 wire tx_busy,tx_done,tx_error,tx_read_beat,tx_write_beat;wire [7:0] tx_beat;
 reg [7:0] export_type;
 reg [4:0] state;reg fault_reported,ever_run;
 wire export_active=(state>=EXPORT_START&&state<=EXPORT_FINISH)||state==EXPORT_PREFETCH;
 wire [13:0] capture_min,capture_max;wire [1:0] capture_fifo_faults;reg class_slot,latest_slot,latest_valid,exported;
 reg [63:0] job_id;reg [31:0] tick,requests,accepted,busy_rejected,capture_drop,published_count,result_age;
 reg [31:0] offset,capture_age,export_age;reg arm,descriptor_take;
 wire arm_busy,cap_empty,descriptor_valid;wire [127:0] cap_data;wire [9:0] cap_count;wire [319:0] cap_descriptor;
 wire cap_dropped;
 (* async_reg="true" *) reg [1:0] dropped_sync;
 always @(posedge ui_clk or negedge rst_n)if(!rst_n)dropped_sync<=0;else dropped_sync<={dropped_sync[0],cap_dropped};
 wire cap_pop=(state==HEADER&&!cap_empty)||(state==CAPWAIT&&tx_write_beat)||(state==DRAIN&&!cap_empty);
 m5b1_capture capture(.ui_clk(ui_clk),.pix_clk(pix_clk),.arst_n(rst_n),.cancel(state==DRAIN||stop),.arm(arm),.job(job_id),.epoch(epoch),.arm_busy(arm_busy),
  .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(tap_high),.tap_low(tap_low),.tap_filter(tap_filter),
  .tap_frame_id(tap_frame_id),.tap_epoch(tap_epoch),.tap_timestamp(tap_timestamp),.data(cap_data),.empty(cap_empty),.pop(cap_pop),.count(cap_count),
  .descriptor_valid(descriptor_valid),.descriptor(cap_descriptor),.descriptor_take(descriptor_take),.reset_done(capture_reset_done),.dropped(cap_dropped),.fifo_min_bytes(capture_min),.fifo_max_bytes(capture_max),.fifo_faults(capture_fifo_faults));
 reg [319:0] frozen;
 wire eng_reserved;
 wire eng_busy,eng_finished,eng_failed,eng_published,eng_result_slot;wire [319:0] eng_descriptor;
 wire [15:0] eng_pairs,eng_scans;wire [31:0] eng_elapsed,eng_changed;
 wire eng_tx_start,eng_tx_write;wire [31:0] eng_tx_address;wire [7:0] eng_tx_length;wire [127:0] eng_tx_data;
 wire [31:0] class_base=class_slot?32'h01039000:32'h01000000;
 m5b1_global_engine engine(.clk(ui_clk),.rst_n(rst_n),.stop(stop),.start(state==ENGINE),.descriptor(frozen),.class_base(class_base),
  .result_available(latest_valid?(latest_slot?2'b01:2'b10):2'b11),
  .result_reserved(eng_reserved),.busy(eng_busy),.finished(eng_finished),.failed(eng_failed),.published(eng_published),.result_slot(eng_result_slot),.published_descriptor(eng_descriptor),
  .pairs(eng_pairs),.scans(eng_scans),.elapsed(eng_elapsed),.changed_pixels(eng_changed),
  .tx_start(eng_tx_start),.tx_write(eng_tx_write),.tx_address(eng_tx_address),.tx_length(eng_tx_length),
  .tx_busy(tx_busy),.tx_done(state==ENGINE_WAIT&&tx_done),.tx_error(tx_error),.tx_beat(tx_beat),.tx_read_beat(state==ENGINE_WAIT&&tx_read_beat),.tx_rdata(rdata),.tx_write_beat(state==ENGINE_WAIT&&tx_write_beat),.tx_wdata(eng_tx_data));

 wire eng_selected=state==ENGINE_WAIT;
 wire transfer_start=eng_selected?eng_tx_start:(state==CAPTURE&&cap_count>=32&&!(descriptor_valid&&!cap_descriptor[308]))||(state==EXPORT_READ);
 wire [31:0] export_base=export_type==2?class_base:(latest_slot?32'h010c9000:32'h010ac000);
 wire [31:0] transfer_address=eng_selected?eng_tx_address:(state==CAPTURE?class_base+offset:export_base+offset);
 wire transfer_write=eng_selected?eng_tx_write:state==CAPTURE;
 m5b1_transfer transfer(.clk(ui_clk),.rst_n(rst_n),.stop(stop),.start(transfer_start),.write_op(transfer_write),
  .address(transfer_address),.length(eng_selected?eng_tx_length:8'd31),.busy(tx_busy),.done(tx_done),.error(tx_error),.beat(tx_beat),.read_beat(tx_read_beat),.write_beat(tx_write_beat),
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
 wire [7:0] payload=state==STATS_WAIT?stats[byte_index*8+:8]:export_head[byte_index[3:0]*8+:8];
 wire payload_valid=state==STATS_WAIT||state==EXPORT_BYTES;
 m5b1_packet_tx packet(.clk(ui_clk),.rst_n(rst_n),.abort(packet_abort),.start(packet_start),.packet_type(state==STATS_WAIT?8'd1:export_type),
  .length(state==STATS_WAIT?32'd256:(export_type==2?32'd230400:32'd115200)),.descriptor(frozen),
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
   state<=IDLE;fault_reported<=0;ever_run<=0;class_slot<=1;latest_slot<=0;latest_valid<=0;exported<=0;job_id<=0;tick<=0;requests<=0;accepted<=0;busy_rejected<=0;capture_drop<=0;published_count<=0;result_age<=0;
   offset<=0;capture_age<=0;export_age<=0;arm<=0;descriptor_take<=0;frozen<=0;publish_toggle<=0;bg_fault<=0;stats<=0;byte_index<=0;export_type<=2;packet_start<=0;packet_abort<=0;
  end else begin
   arm<=0;descriptor_take<=0;packet_start<=0;packet_abort<=0;
   if(run)ever_run<=1;
   if(run&&!stop)begin
    if(tick==REQUEST_CYCLES-1)begin
     tick<=0;requests<=requests+1'b1;result_age<=result_age+1'b1;
     if(state!=IDLE)busy_rejected<=busy_rejected+1'b1;
     else if(!arm_busy)begin
      accepted<=accepted+1'b1;job_id<=job_id+1'b1;class_slot<=!class_slot;arm<=1;state<=HEADER;offset<=0;capture_age<=0;
     end
    end else tick<=tick+1'b1;
   end
   if(state>=HEADER&&state<=FREEZE)capture_age<=capture_age+1'b1;
   if(export_active)export_age<=export_age+1'b1;
   case(state)
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
    FREEZE:if(descriptor_valid)begin
     frozen<=cap_descriptor;descriptor_take<=1;
     if(cap_descriptor[308]&&cap_descriptor[63:0]==epoch&&cap_descriptor[191:128]==job_id)state<=ENGINE;
     else begin capture_drop<=capture_drop+1'b1;bg_fault<=1;state<=STATS;end
    end
    ENGINE:state<=ENGINE_WAIT;
    ENGINE_WAIT:if(eng_finished)begin
     if(eng_failed)bg_fault<=1;
     if(eng_published)begin latest_valid<=1;latest_slot<=eng_result_slot;published_count<=published_count+1'b1;publish_toggle<=!publish_toggle;result_age<=0;end
     state<=STATS;
    end
    STATS:begin
     stats<=0;stats[31:0]<=requests;stats[63:32]<=accepted;stats[95:64]<=busy_rejected;
     stats[127:96]<=capture_drop;stats[159:128]<=published_count;stats[191:160]<=result_age;
     stats[223:192]<={18'b0,camera_max};stats[255:224]<={18'b0,display_min};
     stats[351:256]<=max_wait;stats[447:352]<=max_service;
     stats[479:448]<={eng_scans,eng_pairs};stats[511:480]<=eng_elapsed;stats[543:512]<=eng_changed;
     stats[575:544]<=system_status;stats[639:576]<=job_id;stats[703:640]<=frozen[127:64];
     stats[735:704]<={29'b0,stop,eng_failed,dropped_sync[1]};
     stats[767:736]<={18'b0,capture_min};stats[799:768]<={18'b0,capture_max};
     stats[831:800]<={26'b0,capture_fifo_faults,video_fifo_faults};stats[1055:832]<=error_counts;byte_index<=0;packet_start<=1;state<=STATS_WAIT;
    end
    STATS_WAIT:begin
     if(payload_ready&&payload_valid&&byte_index<255)byte_index<=byte_index+1'b1;
     if(packet_done)begin
      if(stop)state<=FAULT_IDLE;
      else if(!exported&&latest_valid&&!eng_failed)begin export_type<=2;state<=EXPORT_START;export_age<=0;end
      else state<=IDLE;
     end
    end
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
     else begin exported<=1;state<=IDLE;end
    end
    FAULT_REPORT:state<=STATS;
    FAULT_IDLE:begin end
    DRAIN:if(cap_empty&&descriptor_valid&&!tx_busy)begin descriptor_take<=1;frozen<=cap_descriptor;state<=STATS;end
   endcase
   if(state>=HEADER&&state<=FREEZE&&capture_age>=CAPTURE_CYCLES&&!tx_busy)begin bg_fault<=1;state<=DRAIN;end
   if(export_active&&export_age>=EXPORT_CYCLES&&!tx_busy)begin bg_fault<=1;exported<=1;packet_abort<=1;state<=IDLE;end
   // UART fault telemetry is independent of the quarantined DDR transaction.
   // Keep the owner/busy state intact: this is not a DDR reset or synthetic ACK.
   if(stop&&ever_run&&!fault_reported)begin fault_reported<=1;latest_valid<=0;bg_fault<=1;packet_abort<=1;state<=FAULT_REPORT;end
  end
 end
endmodule
