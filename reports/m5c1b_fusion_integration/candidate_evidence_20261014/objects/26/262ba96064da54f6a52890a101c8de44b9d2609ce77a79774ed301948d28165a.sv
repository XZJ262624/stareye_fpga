`timescale 1ns/1ps
module tb_descriptor_sid_late;
 integer late_case=0,early_final_releases=0;reg cancelled_u2=0;
 reg ui_clk=0,pix_clk=0;always #5 ui_clk=~ui_clk;
 integer phase=0;initial begin if(!$value$plusargs("PHASE=%d",phase))phase=0;#(phase);forever #7 pix_clk=~pix_clk;end
 reg rst_n=0,ce=1,raw_sof=0,stop=0;
 reg tap_valid=0,final_de=0;reg next_final_de=0;reg [11:0] next_final_x=0,next_final_y=0;
 reg [11:0] tap_x=0,tap_y=0,final_x=0,final_y=0;
 always @(posedge pix_clk)begin final_de<=next_final_de;final_x<=next_final_x;final_y<=next_final_y;end
 wire [1:0] tap_class=(tap_x+tap_y)%3;
 wire [63:0] ticks,seq,req_seq,read_sid,offer_sid,release_sid,ref_sid;
 wire [159:0] cfg;wire request,release_valid,release_final,release_ready,offer_valid,offer_take;
 wire [767:0] offer_desc;reg [767:0] result_desc=0;
 wire acquire,lease_release,lease_retire,sfault,read_accept,read_done;
 wire lease_slot;wire [319:0] lease_identity;wire [63:0] lease_token;reg acquire_ack=0;reg [3:0] leased=0;
 wire block,quiet,tail_fault,ref_ready,ref_mask,prefilled,retire,flush,promoted,frame_ok,eligible,frame_done;
 wire [1:0] ref_class;wire [11:0] ref_x,ref_y,retire_row;wire [23:0] rgb;wire [479:0] snapshot;
 wire avalid,rready,atype;wire [31:0] aaddr;wire [7:0] alen,aid;
 reg rvalid=0,rlast=0;reg [127:0] rdata=0;reg [7:0] rid=8'h22;
 reg mem_busy=0;integer mem_beat=0,mem_len=0;reg [31:0] mem_addr;wire aready=!mem_busy;
 integer ui_cycle=0,pix_cycle=0,accepts=0,completes=0,commits=0,checks=0,promotions=0,expected_promotions=0;
 integer starts=0,captures=0,revokes=0;reg last_cap_req=0,last_revoke_ack=0;reg [63:0] captured_sid;
 reg [831:0] held_offer;reg previous_hold=0;reg capture_edge=0;integer capture_cycle;
 reg seen_row[0:719];integer rows_checked=0;reg score=0;
 m5c_display_session dut(.ui_clk(ui_clk),.pix_clk(pix_clk),.rst_n(rst_n),.stop(stop),
  .request_frame(request),.request_seq(req_seq),.request_config(cfg),
  .pixel_release(release_valid),.pixel_release_final(release_final),.pixel_release_session(release_sid),.pixel_release_ready(release_ready),
  .result_valid(1'b1),.result_slot(1'b0),.result_descriptor(result_desc),.export_exclusive(1'b0),
  .acquire(acquire),.lease_slot(lease_slot),.lease_identity(lease_identity),.lease_token(lease_token),.acquire_ack(acquire_ack),.acquire_denied(1'b0),.pair_leased(leased),
  .lease_release(lease_release),.lease_retire(lease_retire),.read_accept(read_accept),.read_done(read_done),.session_fault(sfault),
  .telemetry_pending(1'b0),.offer_valid(offer_valid),.offer_take(offer_take),.offer_descriptor(offer_desc),.offer_session(offer_sid),
  .context_block(block),.context_quiet(quiet),.context_tail_fault(tail_fault),
  .ce(ce),.read_valid(tap_valid),.read_x(tap_x),.read_y(tap_y),.read_session(read_sid),
  .ref_ready(ref_ready),.ref_class(ref_class),.ref_mask(ref_mask),.ref_x(ref_x),.ref_y(ref_y),.ref_session(ref_sid),
  .retire(retire),.retire_row(retire_row),.flush(flush),.prefilled(prefilled),
  .avalid(avalid),.aready(aready),.aaddr(aaddr),.alen(alen),.aid(aid),.atype(atype),
  .rvalid(rvalid),.rlast(rlast),.rdata(rdata),.rid(rid),.rresp(2'd0),.rready(rready),.rejected(1'b0));
 m5c_fusion_display display(.context_block(block),.context_quiet(quiet),.context_tail_fault(tail_fault),
  .clk(pix_clk),.rst_n(rst_n),.ce(ce),.raw_sof(raw_sof),.stop(stop),.enable(1'b1),.export_status(1'b0),.ddr_error_status(1'b0),.hardstop_status(1'b0),
  .epoch(64'd1),.config_generation(64'd1),.high_threshold(8'd64),.filter_enable(1'b1),
  .tap_valid(tap_valid),.tap_qualified(1'b1),.tap_support(1'b1),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),
  .final_de(final_de),.final_x(final_x),.final_y(final_y),.local_edge(1'b0),.raw_gray(8'd37),.mode(3'd6),.base_rgb(24'd0),.fused_rgb(rgb),
  .pixel_ticks(ticks),.display_seq(seq),.config_signature(cfg),.request_frame(request),.request_seq(req_seq),
  .offer_valid(offer_valid),.offer_take(offer_take),.offer_descriptor(offer_desc),.offer_session(offer_sid),
  .pixel_release(release_valid),.release_final(release_final),.release_session(release_sid),.release_ready(release_ready),
  .read_session(read_sid),.prefilled(prefilled),.ref_ready(ref_ready),.ref_class(ref_class),.ref_mask(ref_mask),.ref_x(ref_x),.ref_y(ref_y),.ref_session(ref_sid),
  .retire(retire),.retire_row(retire_row),.flush(flush),.eligible(eligible),.promoted(promoted),.frame_ok(frame_ok),.frame_done(frame_done),.telemetry_snapshot(snapshot));
 function [127:0] memory_word(input [31:0] addr);
 integer row,col,j;reg [127:0] v;
 begin v=0;
  if(addr>=32'h010ac000)begin row=(addr-32'h010ac000)/160;col=((addr-32'h010ac000)%160)*8;for(j=0;j<128;j=j+1)v[j]=(col+j+2*row)%2;end
  else begin row=(addr-32'h01000000)/320;col=((addr-32'h01000000)%320)*4;for(j=0;j<64;j=j+1)v[2*j+:2]=(row+col+j)%3;end
  memory_word=v;
 end endfunction
 // Address/response driver advances only real accepted external handshakes.
 always @(posedge ui_clk)begin
  if(!rst_n)begin mem_busy<=0;rvalid<=0;rlast<=0;acquire_ack<=0;leased<=0;end
  else begin
   ui_cycle=ui_cycle+1;acquire_ack<=acquire;
   if(acquire)leased<=1;if(lease_release)leased<=0;
   if(avalid&&aready)begin
    if(mem_busy||atype||aid!=8'h22)$fatal(1,"DDR_ACCEPT_OWNERSHIP");
    mem_busy<=1;mem_beat<=0;mem_len<=alen;mem_addr<=aaddr;rvalid<=0;
   end else if(mem_busy&&!rvalid)begin rvalid<=1;rlast<=mem_beat==mem_len;rdata<=memory_word(mem_addr+16*mem_beat);end
   else if(rvalid&&rready)begin
    if(rlast)begin mem_busy<=0;rvalid<=0;rlast<=0;end
    else begin mem_beat<=mem_beat+1;rdata<=memory_word(mem_addr+16*(mem_beat+1));rlast<=mem_beat+1==mem_len;end
   end
   if(read_accept)accepts=accepts+1;if(read_done)completes=completes+1;
   if(dut.cap_valid&&dut.cap_sid!==captured_sid)$fatal(1,"ACTUAL_CAPTURE_PAYLOAD_MISMATCH");
   if(dut.reader_start&&!dut.cancel_now)begin
    if(!dut.capture_seen||!dut.context_confirmed||dut.cap_sid!==captured_sid||dut.cap_sid!==dut.active_session||dut.cancel_now)$fatal(1,"READER_BEFORE_REAL_CAPTURE");
    starts=starts+1;
   end
   if((dut.write_valid||dut.commit)&&!dut.cancel_now)begin
    if(!dut.context_confirmed||dut.commit_session!==dut.active_session||dut.cancel_now)$fatal(1,"WRITE_WITHOUT_CONTEXT");
   end
   if(dut.commit&&!dut.cancel_now)begin
    if(dut.commit_row>=720||seen_row[dut.commit_row])$fatal(1,"ROW_COMMIT_SEQUENCE");
    seen_row[dut.commit_row]=1;commits=commits+1;
   end
   if(lease_release&&(!dut.reader_drained||!dut.cache_empty||!dut.revoke_issued||dut.revoke_ack_sync[1]!=dut.revoke_req||!dut.cap_drain_sync[1]))$fatal(1,"REUSE_BEFORE_QUIESCENCE");
   if(sfault||tail_fault)$fatal(1,"UNEXPECTED_CONTEXT_FAULT");
  end
 end
 always @(posedge pix_clk)begin
  pix_cycle=pix_cycle+1;
  if(rst_n)begin
   if(dut.offer_control_valid&&!dut.offer_seen&&dut.context_state==0)begin capture_edge=1;capture_cycle=pix_cycle;captures=captures+1;end
   if(dut.cap_req!=last_cap_req)begin if(pix_cycle<=capture_cycle||offer_sid!==captured_sid)$fatal(1,"CAPTURE_REPLY_SOURCE");last_cap_req=dut.cap_req;end
   if(previous_hold&&dut.offered!==held_offer)$fatal(1,"OFFER_OVERWRITE_BEFORE_DRAIN");
   previous_hold=(dut.context_state!=0)||dut.cap_busy||dut.cap_send_pending;held_offer=dut.offered;
   if(dut.revoke_ack!=last_revoke_ack)begin
    if(!dut.response_quiet||!quiet||!dut.cap_drained||(|dut.pixel_ready)||!block)$fatal(1,"EARLY_REVOKE_ACK");
    revokes=revokes+1;last_revoke_ack=dut.revoke_ack;
   end
  end else begin previous_hold=0;last_cap_req=0;last_revoke_ack=0;end
  if(rst_n&&ce&&display.fusion.frame_ok&&((display.fusion.tap_valid&&(!display.fusion.tap_qualified||!display.fusion.coords_good||!display.fusion.reference_good))||(final_de&&!display.fusion.tag_good)))
   $display("FRAME_FAIL_EDGE tap=%0d/%0d ref=%0d/%0d ready=%0d coords=%0d final=%0d/%0d tag=%0d delayed=%h cookie=%0d",display.dx,display.dy,ref_x,ref_y,ref_ready,display.fusion.coords_good,final_x,final_y,display.fusion.tag_good,display.fusion.delayed,display.fusion.frame_cookie);
  #0.001;
  if(capture_edge)begin captured_sid=offer_sid;capture_edge=0;end
  if(rst_n&&ce&&tap_valid&&score)begin
   if(!ref_ready||ref_session_check()!=1||ref_class!==((tap_x+tap_y)%3)||ref_mask!==((tap_x+2*tap_y)%2))
    $fatal(1,"REAL_CACHE_PIXEL x=%0d y=%0d ready=%0d class=%0d mask=%0d sid=%0d",tap_x,tap_y,ref_ready,ref_class,ref_mask,ref_sid);
   checks=checks+1;
  end
  if(rst_n&&ce&&final_de&&score)begin
   if(promoted!==expected_pixel(final_x,final_y))$fatal(1,"REAL_PIPELINE_PIXEL x=%0d y=%0d got=%0d expected=%0d frameok=%0d",final_x,final_y,promoted,expected_pixel(final_x,final_y),frame_ok);
   if(promoted)promotions=promotions+1;if(expected_pixel(final_x,final_y))expected_promotions=expected_promotions+1;
  end
 end
 always @(posedge pix_clk)if(rst_n&&release_valid&&release_ready&&release_final&&!frame_done)early_final_releases=early_final_releases+1;
 always @(negedge pix_clk)if(rst_n&&late_case>=1&&promoted)$fatal(1,"LATE_OFFER_UNEXPECTED_PROMOTION");
 function bit ref_session_check;begin ref_session_check=ref_sid==read_sid&&ref_x==tap_x&&ref_y==tap_y;end endfunction
 function bit expected_pixel(input integer x,y);begin expected_pixel=x>=3&&x<1277&&y>=3&&y<717&&(x+y)%3==1&&(x+2*y)%2==1;end endfunction
 integer n,x,y,q,fn,fx,fy;
 task reset_case;begin
  @(negedge pix_clk);rst_n=0;ce=1;raw_sof=0;tap_valid=0;next_final_de=0;score=0;
  for(q=0;q<720;q=q+1)seen_row[q]=0;
  repeat(6)@(negedge pix_clk);rst_n=1;repeat(12)@(negedge pix_clk);
  result_desc=0;result_desc[63:0]=1;result_desc[191:128]=1;result_desc[447:384]=1;result_desc[511:448]=1;
  result_desc[735:576]=cfg;result_desc[751:744]=1;result_desc[743:736]=1;result_desc[272]=1;
 end endtask
 initial begin
  if(!$value$plusargs("LATE=%d",late_case))late_case=0;
  reset_case;@(negedge pix_clk);raw_sof=1;@(negedge pix_clk);raw_sof=0;
  if(late_case==0)begin
   ce=0;wait(prefilled&&display.have_offer);repeat(20)@(negedge pix_clk);
   if(!dut.capture_seen||!dut.context_confirmed||!dut.cap_drained||starts!=1||captures!=1||ref_ready)$fatal(1,"CE_ZERO_CAPTURE_DEADLOCK");
  end else begin
   if(late_case==2)wait(offer_valid);
   for(n=0;n<720*1650+1654;n=n+1)begin
    @(negedge pix_clk);x=n%1650;y=n/1650;tap_x=x;tap_y=y;tap_valid=y<720&&x<1280;
    fn=n-1653;fx=fn>=0?fn%1650:0;fy=fn>=0?fn/1650:0;next_final_x=fx;next_final_y=fy;next_final_de=fn>=0&&fy<720&&fx<1280;
   end
   @(negedge pix_clk);tap_valid=0;next_final_de=0;
   wait(dut.state==0);repeat(4)@(negedge pix_clk);
   if(captures!=1||revokes!=1||!dut.cap_drained||sfault||starts>1||accepts!=completes||display.late_rows!=1||early_final_releases==0)$fatal(1,"LATE_OFFER_RELEASE_DEADLOCK");
  end
  $display("CACHE_CONTEXT_PASS late_case=%0d captures=%0d starts=%0d revokes=%0d",late_case,captures,starts,revokes);$finish;
 end
 initial begin #100000000;$fatal(1,"CONTEXT_WATCHDOG state=%0d rows=%0d ready=%h block=%0d",dut.state,commits,dut.pixel_ready,block);end
always @(posedge ui_clk)begin
  cancelled_u2=rst_n&&dut.reader_start&&dut.cancel_now&&!dut.reader_busy;
  #0.003;if(cancelled_u2&&(dut.reader_busy||dut.reader.state!=0||avalid||read_accept||dut.write_valid||dut.commit))$fatal(1,"CANCELLED_U2_READER_ACCEPTED");
 end
initial begin
 wait(rst_n);wait(offer_valid);repeat(2)@(negedge pix_clk);
 if(late_case<1)$fatal(1,"LATE_STIMULUS_REQUIRED");
 if(display.have_offer||display.session!==64'd0)$fatal(1,"ACCEPTED_SID_CHANGED_ON_LATE");
 $display("LATE_INDEPENDENT_SID_RETAINED offered=%0d accepted=%0d",offer_sid,display.session);
end
endmodule
