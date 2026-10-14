// One full identity is frozen until reader, row mailboxes and offer retire.
module m5c_display_session(
 input ui_clk,pix_clk,rst_n,stop,
 input request_frame,input [63:0] request_seq,input [159:0] request_config,
 input pixel_release,pixel_release_final,input [63:0] pixel_release_session,output pixel_release_ready,
 input result_valid,result_slot,input [767:0] result_descriptor,input export_exclusive,
 output reg acquire,output reg lease_slot,output [319:0] lease_identity,output reg [63:0] lease_token,
 input acquire_ack,acquire_denied,input [3:0] pair_leased,
 output reg lease_release,lease_retire,output read_accept,read_done,
 output reg session_fault,
 input telemetry_pending,output [767:0] telemetry_descriptor,output [63:0] telemetry_session,
 output reg offer_valid,input offer_take,output [767:0] offer_descriptor,output [63:0] offer_session,
 output context_block,input context_quiet,context_tail_fault,
 input ce,read_valid,input [11:0] read_x,read_y,input [63:0] read_session,
 output ref_ready,output [1:0] ref_class,output ref_mask,output [11:0] ref_x,ref_y,output [63:0] ref_session,
 input retire,input [11:0] retire_row,input flush,output prefilled,
 output avalid,input aready,output [31:0] aaddr,output [7:0] alen,aid,output atype,
 input rvalid,rlast,input [127:0] rdata,input [7:0] rid,input [1:0] rresp,output rready,input rejected,
 output [6:0] read_permission);
 (* async_reg="true", syn_srlstyle="registers", syn_keep="true" *) reg [1:0] context_ui_release;
 always @(posedge ui_clk or negedge rst_n)
  if(!rst_n)context_ui_release<=0;else context_ui_release<={context_ui_release[0],1'b1};
 wire context_ui_rst_n=context_ui_release[1];
 localparam IDLE=0,ACQUIRE=1,WAIT_CAPTURE=2,ACTIVE=3,DRAIN=4,RELEASE=5;
 reg [2:0] state;
 reg capture_seen,context_confirmed,abort_pending,revoke_issued;
 reg revoke_req;
 (* async_reg="true" *) reg [1:0] revoke_ack_sync,cap_drain_sync,context_fault_sync;
 reg cap_req,cap_ack,cap_valid,cap_send_pending;
 reg [63:0] cap_sid;
 (* async_reg="true" *) reg [1:0] cap_req_sync,cap_ack_sync,revoke_req_sync;
 reg revoke_ack;reg [1:0] context_state;
 localparam CTX_QUIET=0,CTX_LIVE=1,CTX_BLOCKING=2;
 reg context_protocol_fault;
 wire cap_busy=cap_req!=cap_ack_sync[1];
 wire cap_drained=!cap_send_pending&&!cap_busy;
 wire response_quiet;wire [7:0] free_banks,pixel_ready;
 assign context_block=context_state!=CTX_LIVE||context_tail_fault||context_protocol_fault;
 wire req_busy,req_valid;wire [223:0] req_data;reg req_take;
 m5b1_mailbox #(.WIDTH(224)) request_box(.sclk(pix_clk),.dclk(ui_clk),.arst_n(rst_n),
  .send(request_frame),.sdata({request_seq,request_config}),.busy(req_busy),.valid(req_valid),.ddata(req_data),.take(req_take));
 wire rel_busy,rel_valid;wire [64:0] rel_data;reg rel_take;
 assign pixel_release_ready=!rel_busy;
 m5b1_mailbox #(.WIDTH(65)) release_box(.sclk(pix_clk),.dclk(ui_clk),.arst_n(rst_n),
  .send(pixel_release),.sdata({pixel_release_final,pixel_release_session}),.busy(rel_busy),.valid(rel_valid),.ddata(rel_data),.take(rel_take));
 wire reader_busy,reader_drained,reader_fault,cache_fault,cache_empty;
 reg [767:0] active_descriptor;reg [63:0] active_session;reg offer_send;
 wire matching_release=rel_valid&&rel_data[63:0]==active_session;
 wire cancel_now=stop||session_fault||context_fault_sync[1]||cache_fault||reader_fault||rel_valid||abort_pending;
 assign telemetry_descriptor=active_descriptor;assign telemetry_session=active_session;
 wire offer_busy,offer_control_valid;reg [831:0] offered;reg offer_seen;
 (* async_reg="true", syn_srlstyle="registers", syn_keep="true" *) reg [1:0] offer_release;
 always @(posedge pix_clk or negedge rst_n)
  if(!rst_n)offer_release<=0;else offer_release<={offer_release[0],1'b1};
 wire offer_rst_n=offer_release[1];
 // active tuple is the held source, frozen by the existing session lifecycle.
 // Control valid precedes one atomic destination capture; early take cannot
 // acknowledge data before capture, and seen prevents recapture before ack.
 m5b1_mailbox #(.WIDTH(1)) offer_box(.sclk(ui_clk),.dclk(pix_clk),.arst_n(rst_n),
  .send(offer_send),.sdata(1'b1),.busy(offer_busy),.valid(offer_control_valid),.ddata(),.take(offer_valid&&offer_take));
 // P0 capture, P1 request. Reply source is the actual existing offered SID.
 always @(posedge pix_clk or negedge offer_rst_n)begin
  if(!offer_rst_n)begin
   offered<=0;offer_valid<=0;offer_seen<=0;cap_req<=0;cap_ack_sync<=0;
   cap_send_pending<=0;revoke_req_sync<=0;revoke_ack<=0;
   context_state<=CTX_QUIET;context_protocol_fault<=0;
  end else begin
   cap_ack_sync<={cap_ack_sync[0],cap_ack};
   revoke_req_sync<={revoke_req_sync[0],revoke_req};
   if(!offer_control_valid)offer_seen<=0;
   if(cap_send_pending&&!cap_busy)begin cap_req<=!cap_req;cap_send_pending<=0;end
   if(offer_valid&&offer_take)offer_valid<=0;
   if(revoke_req_sync[1]!=revoke_ack)begin
    if(context_state==CTX_LIVE)context_state<=CTX_BLOCKING;
    else if(context_state==CTX_BLOCKING&&response_quiet&&context_quiet&&
      !offer_valid&&!offer_control_valid&&cap_drained&&!(|pixel_ready))begin
     revoke_ack<=revoke_req_sync[1];context_state<=CTX_QUIET;
    end
   end else if(offer_control_valid&&!offer_seen)begin
    offer_seen<=1;
    if(context_state==CTX_QUIET&&cap_drained&&!context_tail_fault&&!context_protocol_fault)begin
     offered<={active_session,active_descriptor};offer_valid<=1;cap_send_pending<=1;context_state<=CTX_LIVE;
    end else context_protocol_fault<=1;
   end
  end
 end
 // U0 captures destination data; only U1 WAIT_CAPTURE consumes this valid.
 always @(posedge ui_clk or negedge context_ui_rst_n)begin
  if(!context_ui_rst_n)begin cap_req_sync<=0;cap_ack<=0;cap_valid<=0;
   revoke_ack_sync<=0;cap_drain_sync<=0;context_fault_sync<=0;end
  else begin
   cap_req_sync<={cap_req_sync[0],cap_req};
   revoke_ack_sync<={revoke_ack_sync[0],revoke_ack};
   cap_drain_sync<={cap_drain_sync[0],cap_drained};
   context_fault_sync<={context_fault_sync[0],(context_tail_fault||context_protocol_fault)};
   if(!cap_valid&&cap_req_sync[1]!=cap_ack)begin cap_sid<=active_session;cap_valid<=1;end
   if(cap_valid&&state==WAIT_CAPTURE)begin cap_ack<=cap_req_sync[1];cap_valid<=0;end
  end
 end
 assign offer_session=offered[831:768];assign offer_descriptor=offered[767:0];
 assign lease_identity={active_descriptor[63:0],active_descriptor[191:128],active_descriptor[127:64],active_descriptor[447:384],active_descriptor[511:448]};

 reg reader_start,reader_abort,terminal_seen;

 wire write_valid,write_mask,commit;wire [2:0] write_bank;
 wire [4:0] write_beat;wire [127:0] write_data;wire [11:0] commit_row;wire [63:0] commit_session;
 assign read_permission=(state!=IDLE)?(lease_slot?7'b0100010:7'b0010001):7'd0;
 m5c_mask_reader reader(.clk(ui_clk),.rst_n(rst_n),.stop(stop||session_fault),.start(reader_start),.abort(reader_abort||cancel_now),
  .slot(lease_slot),.session(active_session),.free_banks(free_banks),.busy(reader_busy),.drained(reader_drained),.fault(reader_fault),
  .write_valid(write_valid),.write_mask(write_mask),.write_bank(write_bank),.write_beat(write_beat),.write_data(write_data),
  .commit(commit),.commit_row(commit_row),.commit_session(commit_session),.segment_accept(read_accept),.segment_done(read_done),
  .avalid(avalid),.aready(aready),.aaddr(aaddr),.alen(alen),.aid(aid),.atype(atype),
  .rvalid(rvalid),.rlast(rlast),.rdata(rdata),.rid(rid),.rresp(rresp),.rready(rready),.rejected(rejected));
 m5c_line_cache cache(.ui_clk(ui_clk),.pix_clk(pix_clk),.rst_n(rst_n),
  .write_valid(write_valid),.write_mask(write_mask),.write_bank(write_bank),.write_beat(write_beat),.write_data(write_data),
  .commit(commit),.commit_row(commit_row),.commit_session(commit_session),.free_banks(free_banks),.ui_empty(cache_empty),
  .context_block(context_block),.context_sid(offered[831:768]),.context_confirmed(context_confirmed),
  .expected_sid(active_session),.cancel_now(cancel_now),.response_quiet(response_quiet),
  .ce(ce),.read_valid(read_valid),.read_x(read_x),.read_y(read_y),.read_session(read_session),
  .ref_ready(ref_ready),.ref_class(ref_class),.ref_mask(ref_mask),.ref_x(ref_x),.ref_y(ref_y),.ref_session(ref_session),
  .retire(retire),.retire_row(retire_row),.flush(flush),.pixel_ready(pixel_ready),.prefilled(prefilled),.cache_fault(cache_fault));
 always @(posedge ui_clk or negedge context_ui_rst_n)begin
  if(!context_ui_rst_n)begin
   state<=IDLE;req_take<=0;rel_take<=0;acquire<=0;lease_slot<=0;lease_token<=0;
   lease_release<=0;lease_retire<=0;session_fault<=0;active_descriptor<=0;active_session<=0;
   offer_send<=0;reader_start<=0;reader_abort<=0;terminal_seen<=0;
   capture_seen<=0;context_confirmed<=0;abort_pending<=0;revoke_issued<=0;revoke_req<=0;
  end else begin
   req_take<=0;rel_take<=0;acquire<=0;lease_release<=0;lease_retire<=0;offer_send<=0;reader_start<=0;
   if(cache_fault||reader_fault||context_fault_sync[1])begin session_fault<=1;reader_abort<=1;context_confirmed<=0;end
   else if(!stop&&!session_fault)case(state)
    IDLE:begin
     reader_abort<=0;
     if(rel_valid||cap_valid)session_fault<=1;
     if(req_valid&&!telemetry_pending&&!rel_valid&&!cap_valid)begin
      req_take<=1;
      if(result_valid&&!export_exclusive&&result_descriptor[735:576]==req_data[159:0]&&
         req_data[223:160]>active_session&&lease_token!=64'hffffffffffffffff)begin
       active_descriptor<=result_descriptor;active_session<=req_data[223:160];lease_slot<=result_slot;
       lease_token<=lease_token+1'b1;acquire<=1;state<=ACQUIRE;terminal_seen<=0;
       capture_seen<=0;context_confirmed<=0;abort_pending<=0;revoke_issued<=0;
      end
     end
    end
    ACQUIRE:begin
     if(acquire_ack)begin offer_send<=1;state<=WAIT_CAPTURE;end
     else if(acquire_denied)state<=IDLE;
    end
    WAIT_CAPTURE:begin
     if(rel_valid)begin
      rel_take<=1;
      if(!matching_release)session_fault<=1;
      else begin abort_pending<=1;terminal_seen<=terminal_seen||rel_data[64];end
     end
     if(cap_valid)begin
      capture_seen<=1;
      if(cap_sid!=active_session)begin session_fault<=1;reader_abort<=1;context_confirmed<=0;
       if(!revoke_issued)begin revoke_req<=!revoke_req;revoke_issued<=1;end
       state<=DRAIN;end
      else if(cancel_now)begin reader_abort<=1;context_confirmed<=0;state<=DRAIN;end
      else begin context_confirmed<=1;reader_start<=1;state<=ACTIVE;end
     end
    end
    ACTIVE:begin
     if(rel_valid)begin
      rel_take<=1;reader_abort<=1;context_confirmed<=0;
      if(!matching_release)session_fault<=1;
      else begin reader_abort<=1;abort_pending<=1;context_confirmed<=0;terminal_seen<=terminal_seen||rel_data[64];state<=DRAIN;end
     end
    end
    DRAIN:begin
     reader_abort<=1;context_confirmed<=0;
     if(capture_seen&&!revoke_issued)begin revoke_req<=!revoke_req;revoke_issued<=1;end
     if(rel_valid)begin rel_take<=1;if(!matching_release)session_fault<=1;else terminal_seen<=terminal_seen||rel_data[64];end
     if((!rel_valid||matching_release)&&terminal_seen&&reader_drained&&cache_empty&&!offer_busy&&!telemetry_pending&&
        revoke_issued&&revoke_ack_sync[1]==revoke_req&&cap_drain_sync[1]&&!cap_valid)begin
      lease_retire<=1;lease_release<=1;state<=RELEASE;
     end
    end
    RELEASE:if(!pair_leased[lease_slot*2])state<=IDLE;
    default:session_fault<=1;
   endcase
  end
 end
endmodule
