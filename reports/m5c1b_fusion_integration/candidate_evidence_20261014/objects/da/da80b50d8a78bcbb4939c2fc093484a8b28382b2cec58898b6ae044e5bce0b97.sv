`timescale 1ns/1ps
module tb_raster_counter_semantics;
 descriptor_case_control c();descriptor_case_variant v();
 integer invalid_difference=0,valid_equal=0,qualified_frames=0;
 always @(posedge v.pix_clk)begin
  #0.002;
  if(v.rst_n)begin
   if(c.display.descriptor!==v.display.descriptor)begin
    if(c.display.have_offer||v.display.have_offer||c.frame_ok||v.frame_ok)$fatal(1,"QUALIFIED_DESCRIPTOR_DIFFERENCE");
    invalid_difference=invalid_difference+1;
   end
   if(v.display.have_offer)begin
    valid_equal=valid_equal+1;
    if(c.display.descriptor!==v.display.descriptor||v.display.descriptor!==v.offer_desc)$fatal(1,"ACCEPTED_DESCRIPTOR_DIFFERENCE");
   end
   if({c.osd_rgb,c.osd_de,c.osd_hs,c.osd_vs,c.rgb,c.snapshot,c.eligible,c.frame_ok,c.promoted,c.release_valid,c.release_final,c.release_sid,c.read_sid,c.quiet,c.flush,c.retire,c.retire_row}!=={v.osd_rgb,v.osd_de,v.osd_hs,v.osd_vs,v.rgb,v.snapshot,v.eligible,v.frame_ok,v.promoted,v.release_valid,v.release_final,v.release_sid,v.read_sid,v.quiet,v.flush,v.retire,v.retire_row})$fatal(1,"QUALIFIED_OUTPUT_DIFFERENCE");
   if(v.eligible&&{c.display.age_frames,c.display.age_ticks,c.display.identity,c.display.config_bad,c.display.age_bad}!=={v.display.age_frames,v.display.age_ticks,v.display.identity,v.display.config_bad,v.display.age_bad})$fatal(1,"QUALIFIED_AGE_IDENTITY_DIFFERENCE");
   if(v.frame_ok&&{c.display.fusion.frame_identity,c.display.fusion.ref_identity}!=={v.display.fusion.frame_identity,v.display.fusion.ref_identity})$fatal(1,"QUALIFIED_ROW_IDENTITY_DIFFERENCE");
  end
 end
 always @(posedge v.ui_clk)begin
  #0.002;if(v.rst_n&&{c.avalid,c.aaddr,c.alen,c.aid,c.rready,c.lease_release,c.lease_retire,c.read_accept,c.read_done,c.sfault,c.dut.state}!=={v.avalid,v.aaddr,v.alen,v.aid,v.rready,v.lease_release,v.lease_retire,v.read_accept,v.read_done,v.sfault,v.dut.state})$fatal(1,"PROTOCOL_DIFFERENCE");
 end
 initial begin wait(c.done&&v.done);if(invalid_difference==0||valid_equal==0)$fatal(1,"DISTINCT_IMPLEMENTATION_NOT_OBSERVED");$display("CACHE_CONTEXT_PASS descriptor_differential invalid_diff=%0d valid_equal=%0d",invalid_difference,valid_equal);$finish;end
endmodule
`timescale 1ns/1ps
module descriptor_case_control;
 localparam SIDE=0;
 integer blocked_edges=0;reg cancelled_u2=0;wire [23:0] osd_rgb;wire osd_de,osd_hs,osd_vs;
 reg done=0;reg enable_fusion=1,result_available=1,memory_enabled=1;
 integer event_promotions=0,event_equal=0,event_rejected=0,event_pixels=0,event_file;reg event_row_good=0;reg event_this_good;
 initial event_file=$fopen($sformatf("events_%0d.txt",SIDE),"w");reg [63:0] current_epoch=1,current_generation=1;reg [7:0] threshold=64;reg filtering=1;
 integer frame_promotions[0:7];integer frame_checks_before=0;integer radius;
 wire telemetry_pending;
 reg pixel_abort=0;integer pause_at=-1,frame_num,old_commits;reg [63:0] old_cookie;
 reg ui_clk=0,pix_clk=0;always #5 ui_clk=~ui_clk;
 integer phase=0;initial begin if(!$value$plusargs("PHASE=%d",phase))phase=0;#(phase);forever #7 pix_clk=~pix_clk;end
 reg rst_n=0,ce=1,raw_sof=0,stop=0;
 reg tap_valid=0,final_de=0;reg next_final_de=0;reg [11:0] next_final_x=0,next_final_y=0;
 reg [11:0] tap_x=0,tap_y=0,final_x=0,final_y=0;
 always @(posedge pix_clk)if(ce)begin final_de<=next_final_de;final_x<=next_final_x;final_y<=next_final_y;end
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
  .result_valid(result_available),.result_slot(1'b0),.result_descriptor(result_desc),.export_exclusive(1'b0),
  .acquire(acquire),.lease_slot(lease_slot),.lease_identity(lease_identity),.lease_token(lease_token),.acquire_ack(acquire_ack),.acquire_denied(1'b0),.pair_leased(leased),
  .lease_release(lease_release),.lease_retire(lease_retire),.read_accept(read_accept),.read_done(read_done),.session_fault(sfault),
  .telemetry_pending(telemetry_pending),.offer_valid(offer_valid),.offer_take(offer_take),.offer_descriptor(offer_desc),.offer_session(offer_sid),
  .context_block(block),.context_quiet(quiet),.context_tail_fault(tail_fault),
  .ce(ce),.read_valid(tap_valid),.read_x(tap_x),.read_y(tap_y),.read_session(read_sid),
  .ref_ready(ref_ready),.ref_class(ref_class),.ref_mask(ref_mask),.ref_x(ref_x),.ref_y(ref_y),.ref_session(ref_sid),
  .retire(retire),.retire_row(retire_row),.flush(flush),.prefilled(prefilled),
  .avalid(avalid),.aready(aready),.aaddr(aaddr),.alen(alen),.aid(aid),.atype(atype),
  .rvalid(rvalid),.rlast(rlast),.rdata(rdata),.rid(rid),.rresp(2'd0),.rready(rready),.rejected(1'b0));
 m5c_fusion_display_control display(.context_block(block),.context_quiet(quiet),.context_tail_fault(tail_fault),
  .clk(pix_clk),.rst_n(rst_n),.ce(ce),.raw_sof(raw_sof),.stop(stop||pixel_abort),.enable(enable_fusion),.export_status(1'b0),.ddr_error_status(1'b0),.hardstop_status(1'b0),
  .epoch(current_epoch),.config_generation(current_generation),.high_threshold(threshold),.filter_enable(filtering),
  .tap_valid(tap_valid),.tap_qualified(1'b1),.tap_support(1'b1),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),
  .final_de(final_de),.final_x(final_x),.final_y(final_y),.local_edge(1'b0),.raw_gray(8'd37),.mode(3'd6),.base_rgb(24'd0),.fused_rgb(rgb),
  .pixel_ticks(ticks),.display_seq(seq),.config_signature(cfg),.request_frame(request),.request_seq(req_seq),
  .offer_valid(offer_valid),.offer_take(offer_take),.offer_descriptor(offer_desc),.offer_session(offer_sid),
  .pixel_release(release_valid),.release_final(release_final),.release_session(release_sid),.release_ready(release_ready),
  .read_session(read_sid),.prefilled(prefilled),.ref_ready(ref_ready),.ref_class(ref_class),.ref_mask(ref_mask),.ref_x(ref_x),.ref_y(ref_y),.ref_session(ref_sid),
  .retire(retire),.retire_row(retire_row),.flush(flush),.eligible(eligible),.promoted(promoted),.frame_ok(frame_ok),.frame_done(frame_done),.telemetry_snapshot(snapshot));
 always @(posedge ui_clk)begin
 cancelled_u2=rst_n&&dut.reader_start&&dut.cancel_now&&!dut.reader_busy;
 #0.003;if(cancelled_u2&&(dut.reader_busy||dut.reader.state!=0||avalid||read_accept||dut.write_valid||dut.commit))$fatal(1,"CANCELLED_U2_READER_ACCEPTED");
 end
 m5a_osd osd(.clk(pix_clk),.ce(ce),.arst_n(rst_n),.rgb(rgb),.fusion_enable(enable_fusion),.fusion_active(frame_ok),.fusion_age_valid(eligible),.fusion_age(display.age_frames),.de(final_de),.hs(1'b0),.vs(1'b0),.threshold(threshold),.mode(3'd6),.out_rgb(osd_rgb),.out_de(osd_de),.out_hs(osd_hs),.out_vs(osd_vs));
 always @(posedge pix_clk)if(rst_n&&ce)begin
  // Independent raster-boundary and pixel/row-event oracle. No DUT counters or row_match read.
  if(tap_valid&&tap_x==0&&tap_y==0)begin event_promotions=0;event_equal=0;event_rejected=0;event_pixels=0;event_row_good=0;end
  else begin
   if(final_de)begin event_pixels=event_pixels+1;if(promoted)event_promotions=event_promotions+1;end
   if(display.dvalid&&display.frame_admitted&&display.have_offer&&!display.broken&&enable_fusion&&!block&&!tail_fault)begin
    event_this_good=ref_ready&&ref_sid==display.dsession&&display.dsession==display.session&&display.dclass==ref_class&&display.dclass!=3;
    if(ref_ready&&(ref_x!=display.dx||ref_y!=display.dy||ref_class!==((ref_x+ref_y)%3)))$fatal(1,"ROW_EVENT_REFERENCE_COORDINATE");
    if(display.dx==0)event_row_good=event_this_good;else event_row_good=event_row_good&&event_this_good;
    if(display.dx==1279)begin if(event_row_good)event_equal=event_equal+1;else event_rejected=event_rejected+1;end
   end
  end
  if(frame_done)begin
   $display("INDEPENDENT_FRAME side=%0d frame=%0d pixels=%0d promoted=%0d equal=%0d rejected=%0d sid=%0d",SIDE,frame_num,event_pixels,event_promotions,event_equal,event_rejected,snapshot[191:128]);
   $fdisplay(event_file,"FRAME %0d %0d %0d %0d %0d %0d",frame_num,event_pixels,event_equal,event_rejected,event_promotions,snapshot[191:128]);
   if(event_pixels!=921600)$fatal(1,"EVENT_FRAME_PIXEL_COVERAGE");
   if(snapshot[223:192]!=event_equal||snapshot[255:224]!=event_rejected||snapshot[287:256]!=event_promotions)$fatal(1,"CURRENT_FRAME_COUNTER_MISMATCH");
   if((frame_num==2||frame_num==3||frame_num==4||frame_num==5)&&(event_promotions||event_equal||event_rejected))$fatal(1,"FALLBACK_EVENTS_NONZERO");
   if(frame_num==6&&(event_promotions==0||event_equal==0||event_equal>=720))$fatal(1,"PARTIAL_EVENTS_NOT_PRESERVED");
   if((frame_num==0||frame_num==1||frame_num==7)&&(event_promotions==0||event_equal!=720))$fatal(1,"RECOVERY_EVENTS_MISSING");
  end
 end
 descriptor_packet_sink #(.ID(SIDE)) sink(.ui(ui_clk),.pix(pix_clk),.rst(rst_n),.frame_done(frame_done),.pixels(snapshot),.desc(dut.active_descriptor),.sid(dut.active_session),.token(lease_token),.slot(lease_slot),.pending(telemetry_pending));
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
   end else if(mem_busy&&!rvalid&&memory_enabled)begin rvalid<=1;rlast<=mem_beat==mem_len;rdata<=memory_word(mem_addr+16*mem_beat);end
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
 function bit ref_session_check;begin ref_session_check=ref_sid==read_sid&&ref_x==tap_x&&ref_y==tap_y;end endfunction
 function bit expected_pixel(input integer x,y);begin expected_pixel=x>=(filtering?3:2)&&x<1280-(filtering?3:2)&&y>=(filtering?3:2)&&y<720-(filtering?3:2)&&(x+y)%3==1&&(x+2*y)%2==1;end endfunction
 integer n,x,y,q,fn,fx,fy;
 task reset_case;begin
  @(negedge pix_clk);rst_n=0;ce=1;raw_sof=0;tap_valid=0;next_final_de=0;score=0;
  for(q=0;q<720;q=q+1)seen_row[q]=0;
  repeat(6)@(negedge pix_clk);rst_n=1;repeat(12)@(negedge pix_clk);
  result_desc=0;result_desc[63:0]=1;result_desc[191:128]=1;result_desc[447:384]=1;result_desc[511:448]=1;
  result_desc[735:576]=cfg;result_desc[751:744]=1;result_desc[743:736]=1;result_desc[272]=1;
 end endtask
 initial begin
  if(!$value$plusargs("PAUSE=%d",pause_at))pause_at=-1;
  reset_case;
  for(frame_num=0;frame_num<8;frame_num=frame_num+1)begin
   for(q=0;q<720;q=q+1)seen_row[q]=0;
   @(negedge pix_clk);
   enable_fusion=frame_num!=5;result_available=frame_num!=3;memory_enabled=frame_num!=4;pixel_abort=0;
   current_epoch=frame_num+1;current_generation=frame_num+11;threshold=frame_num==0?64:96;filtering=frame_num==0;
   #0.001;result_desc=0;result_desc[63:0]=current_epoch;result_desc[127:64]=64'h11110000+frame_num;result_desc[191:128]=64'h22220000+frame_num;
   result_desc[447:384]=64'h33330000+frame_num;result_desc[511:448]=64'h44440000+frame_num;
   result_desc[383:320]=seq;result_desc[575:512]=ticks;result_desc[735:576]=cfg;result_desc[751:744]=1;result_desc[743:736]=1;result_desc[759:752]=1;result_desc[272]=filtering;
   frame_promotions[frame_num]=promotions;frame_checks_before=checks;
   @(negedge pix_clk);raw_sof=1;@(negedge pix_clk);raw_sof=0;
   if(frame_num==0||frame_num==1||frame_num==6||frame_num==7)begin wait(prefilled&&display.have_offer);repeat(4)@(negedge pix_clk);end else if(frame_num==4)begin wait(display.have_offer);if(prefilled)$fatal(1,"NOREF_PRECONDITION");end score=frame_num==0||frame_num==1||frame_num==6||frame_num==7;
   for(n=0;n<720*1650+1654;n=n+1)begin
    @(negedge pix_clk);
    if(frame_num==0&&n==pause_at)begin
     if(!ref_ready)$fatal(1,"PAUSE_NO_REAL_RESPONSE");
     if(pause_at==1&&!display.dsof)$fatal(1,"PAUSE_NO_HELD_DSOF");
     if(pause_at==2000&&!display.fusion.row_complete[0])$fatal(1,"PAUSE_NO_COMPLETED_ROW");
     if(pause_at==5300&&(!frame_ok||display.fusion.frame_cookie==0||display.equal_rows<3||!display.fusion.delayed[3]||!(display.fusion.row_complete[0]||display.fusion.row_complete[1]||display.fusion.row_complete[2]||display.fusion.row_complete[3])))$fatal(1,"PAUSE_NO_QUALIFIED_OLD_TAIL");
     $display("PAUSE_PRECONDITION at=%0d cookie=%0d frameok=%0d equalrows=%0d oldvalid=%0d",pause_at,display.fusion.frame_cookie,frame_ok,display.equal_rows,display.fusion.delayed[3]);
     score=0;old_cookie=display.fusion.frame_cookie;ce=0;pixel_abort=1;
     wait(dut.revoke_issued&&dut.revoke_ack_sync[1]==dut.revoke_req);repeat(4)@(negedge pix_clk);
     if(!block||!quiet||ref_ready||display.dsof||frame_ok||promoted||!dut.cap_drained||lease_release||dut.state!=4)$fatal(1,"CE_PAUSE_QUIESCENCE");
     if(display.fusion.frame_cookie!==old_cookie)$fatal(1,"KILL_CHANGED_COOKIE");
     $display("CE_PAUSE_REAL_QUIET pause=%0d cookie=%0d terminal=%0d",pause_at,old_cookie,dut.terminal_seen);
     pixel_abort=0;ce=1;
    end
    if(frame_num==4&&n==64)memory_enabled=1;
    if(frame_num==6&&n==12000)begin
     if(event_promotions==0||event_equal==0)$fatal(1,"PARTIAL_ABORT_NO_EVENTS");
     pixel_abort=1;score=0;$display("MIDFRAME_PARTIAL side=%0d promoted=%0d equal=%0d",SIDE,event_promotions,event_equal);
    end
    x=n%1650;y=n/1650;tap_x=x;tap_y=y;tap_valid=y<720&&x<1280;
    fn=n-1653;fx=fn>=0?fn%1650:0;fy=fn>=0?fn/1650:0;next_final_x=fx;next_final_y=fy;next_final_de=fn>=0&&fy<720&&fx<1280;
   end
   @(negedge pix_clk);tap_valid=0;next_final_de=0;score=0;
   wait(dut.state==0);repeat(8)@(negedge pix_clk);
   if(frame_num==0||frame_num==1||frame_num==7)begin
    frame_promotions[frame_num]=promotions-frame_promotions[frame_num];
    if(frame_promotions[frame_num]==0)$fatal(1,"MULTIFIELD_CONTEXT_NO_PROMOTION");
    if((frame_num==1||pause_at<0)&&checks-frame_checks_before!=921600)$fatal(1,"MULTIFIELD_PIXEL_COVERAGE");
    $display("REAL_CHANGED_CONTEXT frame=%0d epoch=%0d gen=%0d H=%0d filter=%0d source=%h job=%h slotgen=%h seq=%0d tick=%0d promotions=%0d",frame_num,current_epoch,current_generation,threshold,filtering,result_desc[191:128],result_desc[447:384],result_desc[511:448],result_desc[383:320],result_desc[575:512],frame_promotions[frame_num]);
   end else if(frame_num==2&&(display.session!=2||display.have_offer||display.late_rows!=1))$fatal(1,"ACCEPTED_SID_CHANGED_ON_LATE");
   if(frame_num==0)old_commits=commits;
  end
  wait(sink.packets==8);repeat(4)@(negedge pix_clk);
  if(starts<4||starts>6||captures!=6||revokes!=6||accepts!=completes||frame_promotions[0]==0||frame_promotions[1]==0)$fatal(1,"MULTICONTEXT_COVERAGE");
  $display("DESCRIPTOR_SIDE_DONE checks=%0d promotions=%0d packets=%0d",checks,promotions,sink.packets);done=1;

 end
 initial begin #200000000;$fatal(1,"CONTEXT_WATCHDOG state=%0d rows=%0d ready=%h block=%0d",dut.state,commits,dut.pixel_ready,block);end
 always @(posedge pix_clk)begin
  if(!rst_n||!block)blocked_edges=0;else blocked_edges=blocked_edges+1;
  if(blocked_edges>=3&&(!quiet||ref_ready||display.dsof||frame_ok||promoted))$fatal(1,"CE_KILL_VALIDITY");
 end
endmodule

`timescale 1ns/1ps
module descriptor_case_variant;
 localparam SIDE=1;
 integer blocked_edges=0;reg cancelled_u2=0;wire [23:0] osd_rgb;wire osd_de,osd_hs,osd_vs;
 reg done=0;reg enable_fusion=1,result_available=1,memory_enabled=1;
 integer event_promotions=0,event_equal=0,event_rejected=0,event_pixels=0,event_file;reg event_row_good=0;reg event_this_good;
 initial event_file=$fopen($sformatf("events_%0d.txt",SIDE),"w");reg [63:0] current_epoch=1,current_generation=1;reg [7:0] threshold=64;reg filtering=1;
 integer frame_promotions[0:7];integer frame_checks_before=0;integer radius;
 wire telemetry_pending;
 reg pixel_abort=0;integer pause_at=-1,frame_num,old_commits;reg [63:0] old_cookie;
 reg ui_clk=0,pix_clk=0;always #5 ui_clk=~ui_clk;
 integer phase=0;initial begin if(!$value$plusargs("PHASE=%d",phase))phase=0;#(phase);forever #7 pix_clk=~pix_clk;end
 reg rst_n=0,ce=1,raw_sof=0,stop=0;
 reg tap_valid=0,final_de=0;reg next_final_de=0;reg [11:0] next_final_x=0,next_final_y=0;
 reg [11:0] tap_x=0,tap_y=0,final_x=0,final_y=0;
 always @(posedge pix_clk)if(ce)begin final_de<=next_final_de;final_x<=next_final_x;final_y<=next_final_y;end
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
  .result_valid(result_available),.result_slot(1'b0),.result_descriptor(result_desc),.export_exclusive(1'b0),
  .acquire(acquire),.lease_slot(lease_slot),.lease_identity(lease_identity),.lease_token(lease_token),.acquire_ack(acquire_ack),.acquire_denied(1'b0),.pair_leased(leased),
  .lease_release(lease_release),.lease_retire(lease_retire),.read_accept(read_accept),.read_done(read_done),.session_fault(sfault),
  .telemetry_pending(telemetry_pending),.offer_valid(offer_valid),.offer_take(offer_take),.offer_descriptor(offer_desc),.offer_session(offer_sid),
  .context_block(block),.context_quiet(quiet),.context_tail_fault(tail_fault),
  .ce(ce),.read_valid(tap_valid),.read_x(tap_x),.read_y(tap_y),.read_session(read_sid),
  .ref_ready(ref_ready),.ref_class(ref_class),.ref_mask(ref_mask),.ref_x(ref_x),.ref_y(ref_y),.ref_session(ref_sid),
  .retire(retire),.retire_row(retire_row),.flush(flush),.prefilled(prefilled),
  .avalid(avalid),.aready(aready),.aaddr(aaddr),.alen(alen),.aid(aid),.atype(atype),
  .rvalid(rvalid),.rlast(rlast),.rdata(rdata),.rid(rid),.rresp(2'd0),.rready(rready),.rejected(1'b0));
 m5c_fusion_display display(.context_block(block),.context_quiet(quiet),.context_tail_fault(tail_fault),
  .clk(pix_clk),.rst_n(rst_n),.ce(ce),.raw_sof(raw_sof),.stop(stop||pixel_abort),.enable(enable_fusion),.export_status(1'b0),.ddr_error_status(1'b0),.hardstop_status(1'b0),
  .epoch(current_epoch),.config_generation(current_generation),.high_threshold(threshold),.filter_enable(filtering),
  .tap_valid(tap_valid),.tap_qualified(1'b1),.tap_support(1'b1),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),
  .final_de(final_de),.final_x(final_x),.final_y(final_y),.local_edge(1'b0),.raw_gray(8'd37),.mode(3'd6),.base_rgb(24'd0),.fused_rgb(rgb),
  .pixel_ticks(ticks),.display_seq(seq),.config_signature(cfg),.request_frame(request),.request_seq(req_seq),
  .offer_valid(offer_valid),.offer_take(offer_take),.offer_descriptor(offer_desc),.offer_session(offer_sid),
  .pixel_release(release_valid),.release_final(release_final),.release_session(release_sid),.release_ready(release_ready),
  .read_session(read_sid),.prefilled(prefilled),.ref_ready(ref_ready),.ref_class(ref_class),.ref_mask(ref_mask),.ref_x(ref_x),.ref_y(ref_y),.ref_session(ref_sid),
  .retire(retire),.retire_row(retire_row),.flush(flush),.eligible(eligible),.promoted(promoted),.frame_ok(frame_ok),.frame_done(frame_done),.telemetry_snapshot(snapshot));
 always @(posedge ui_clk)begin
 cancelled_u2=rst_n&&dut.reader_start&&dut.cancel_now&&!dut.reader_busy;
 #0.003;if(cancelled_u2&&(dut.reader_busy||dut.reader.state!=0||avalid||read_accept||dut.write_valid||dut.commit))$fatal(1,"CANCELLED_U2_READER_ACCEPTED");
 end
 m5a_osd osd(.clk(pix_clk),.ce(ce),.arst_n(rst_n),.rgb(rgb),.fusion_enable(enable_fusion),.fusion_active(frame_ok),.fusion_age_valid(eligible),.fusion_age(display.age_frames),.de(final_de),.hs(1'b0),.vs(1'b0),.threshold(threshold),.mode(3'd6),.out_rgb(osd_rgb),.out_de(osd_de),.out_hs(osd_hs),.out_vs(osd_vs));
 always @(posedge pix_clk)if(rst_n&&ce)begin
  // Independent raster-boundary and pixel/row-event oracle. No DUT counters or row_match read.
  if(tap_valid&&tap_x==0&&tap_y==0)begin event_promotions=0;event_equal=0;event_rejected=0;event_pixels=0;event_row_good=0;end
  else begin
   if(final_de)begin event_pixels=event_pixels+1;if(promoted)event_promotions=event_promotions+1;end
   if(display.dvalid&&display.frame_admitted&&display.have_offer&&!display.broken&&enable_fusion&&!block&&!tail_fault)begin
    event_this_good=ref_ready&&ref_sid==display.dsession&&display.dsession==display.session&&display.dclass==ref_class&&display.dclass!=3;
    if(ref_ready&&(ref_x!=display.dx||ref_y!=display.dy||ref_class!==((ref_x+ref_y)%3)))$fatal(1,"ROW_EVENT_REFERENCE_COORDINATE");
    if(display.dx==0)event_row_good=event_this_good;else event_row_good=event_row_good&&event_this_good;
    if(display.dx==1279)begin if(event_row_good)event_equal=event_equal+1;else event_rejected=event_rejected+1;end
   end
  end
  if(frame_done)begin
   $display("INDEPENDENT_FRAME side=%0d frame=%0d pixels=%0d promoted=%0d equal=%0d rejected=%0d sid=%0d",SIDE,frame_num,event_pixels,event_promotions,event_equal,event_rejected,snapshot[191:128]);
   $fdisplay(event_file,"FRAME %0d %0d %0d %0d %0d %0d",frame_num,event_pixels,event_equal,event_rejected,event_promotions,snapshot[191:128]);
   if(event_pixels!=921600)$fatal(1,"EVENT_FRAME_PIXEL_COVERAGE");
   if(snapshot[223:192]!=event_equal||snapshot[255:224]!=event_rejected||snapshot[287:256]!=event_promotions)$fatal(1,"CURRENT_FRAME_COUNTER_MISMATCH");
   if((frame_num==2||frame_num==3||frame_num==4||frame_num==5)&&(event_promotions||event_equal||event_rejected))$fatal(1,"FALLBACK_EVENTS_NONZERO");
   if(frame_num==6&&(event_promotions==0||event_equal==0||event_equal>=720))$fatal(1,"PARTIAL_EVENTS_NOT_PRESERVED");
   if((frame_num==0||frame_num==1||frame_num==7)&&(event_promotions==0||event_equal!=720))$fatal(1,"RECOVERY_EVENTS_MISSING");
  end
 end
 descriptor_packet_sink #(.ID(SIDE)) sink(.ui(ui_clk),.pix(pix_clk),.rst(rst_n),.frame_done(frame_done),.pixels(snapshot),.desc(dut.active_descriptor),.sid(dut.active_session),.token(lease_token),.slot(lease_slot),.pending(telemetry_pending));
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
   end else if(mem_busy&&!rvalid&&memory_enabled)begin rvalid<=1;rlast<=mem_beat==mem_len;rdata<=memory_word(mem_addr+16*mem_beat);end
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
 function bit ref_session_check;begin ref_session_check=ref_sid==read_sid&&ref_x==tap_x&&ref_y==tap_y;end endfunction
 function bit expected_pixel(input integer x,y);begin expected_pixel=x>=(filtering?3:2)&&x<1280-(filtering?3:2)&&y>=(filtering?3:2)&&y<720-(filtering?3:2)&&(x+y)%3==1&&(x+2*y)%2==1;end endfunction
 integer n,x,y,q,fn,fx,fy;
 task reset_case;begin
  @(negedge pix_clk);rst_n=0;ce=1;raw_sof=0;tap_valid=0;next_final_de=0;score=0;
  for(q=0;q<720;q=q+1)seen_row[q]=0;
  repeat(6)@(negedge pix_clk);rst_n=1;repeat(12)@(negedge pix_clk);
  result_desc=0;result_desc[63:0]=1;result_desc[191:128]=1;result_desc[447:384]=1;result_desc[511:448]=1;
  result_desc[735:576]=cfg;result_desc[751:744]=1;result_desc[743:736]=1;result_desc[272]=1;
 end endtask
 initial begin
  if(!$value$plusargs("PAUSE=%d",pause_at))pause_at=-1;
  reset_case;
  for(frame_num=0;frame_num<8;frame_num=frame_num+1)begin
   for(q=0;q<720;q=q+1)seen_row[q]=0;
   @(negedge pix_clk);
   enable_fusion=frame_num!=5;result_available=frame_num!=3;memory_enabled=frame_num!=4;pixel_abort=0;
   current_epoch=frame_num+1;current_generation=frame_num+11;threshold=frame_num==0?64:96;filtering=frame_num==0;
   #0.001;result_desc=0;result_desc[63:0]=current_epoch;result_desc[127:64]=64'h11110000+frame_num;result_desc[191:128]=64'h22220000+frame_num;
   result_desc[447:384]=64'h33330000+frame_num;result_desc[511:448]=64'h44440000+frame_num;
   result_desc[383:320]=seq;result_desc[575:512]=ticks;result_desc[735:576]=cfg;result_desc[751:744]=1;result_desc[743:736]=1;result_desc[759:752]=1;result_desc[272]=filtering;
   frame_promotions[frame_num]=promotions;frame_checks_before=checks;
   @(negedge pix_clk);raw_sof=1;@(negedge pix_clk);raw_sof=0;
   if(frame_num==0||frame_num==1||frame_num==6||frame_num==7)begin wait(prefilled&&display.have_offer);repeat(4)@(negedge pix_clk);end else if(frame_num==4)begin wait(display.have_offer);if(prefilled)$fatal(1,"NOREF_PRECONDITION");end score=frame_num==0||frame_num==1||frame_num==6||frame_num==7;
   for(n=0;n<720*1650+1654;n=n+1)begin
    @(negedge pix_clk);
    if(frame_num==0&&n==pause_at)begin
     if(!ref_ready)$fatal(1,"PAUSE_NO_REAL_RESPONSE");
     if(pause_at==1&&!display.dsof)$fatal(1,"PAUSE_NO_HELD_DSOF");
     if(pause_at==2000&&!display.fusion.row_complete[0])$fatal(1,"PAUSE_NO_COMPLETED_ROW");
     if(pause_at==5300&&(!frame_ok||display.fusion.frame_cookie==0||display.equal_rows<3||!display.fusion.delayed[3]||!(display.fusion.row_complete[0]||display.fusion.row_complete[1]||display.fusion.row_complete[2]||display.fusion.row_complete[3])))$fatal(1,"PAUSE_NO_QUALIFIED_OLD_TAIL");
     $display("PAUSE_PRECONDITION at=%0d cookie=%0d frameok=%0d equalrows=%0d oldvalid=%0d",pause_at,display.fusion.frame_cookie,frame_ok,display.equal_rows,display.fusion.delayed[3]);
     score=0;old_cookie=display.fusion.frame_cookie;ce=0;pixel_abort=1;
     wait(dut.revoke_issued&&dut.revoke_ack_sync[1]==dut.revoke_req);repeat(4)@(negedge pix_clk);
     if(!block||!quiet||ref_ready||display.dsof||frame_ok||promoted||!dut.cap_drained||lease_release||dut.state!=4)$fatal(1,"CE_PAUSE_QUIESCENCE");
     if(display.fusion.frame_cookie!==old_cookie)$fatal(1,"KILL_CHANGED_COOKIE");
     $display("CE_PAUSE_REAL_QUIET pause=%0d cookie=%0d terminal=%0d",pause_at,old_cookie,dut.terminal_seen);
     pixel_abort=0;ce=1;
    end
    if(frame_num==4&&n==64)memory_enabled=1;
    if(frame_num==6&&n==12000)begin
     if(event_promotions==0||event_equal==0)$fatal(1,"PARTIAL_ABORT_NO_EVENTS");
     pixel_abort=1;score=0;$display("MIDFRAME_PARTIAL side=%0d promoted=%0d equal=%0d",SIDE,event_promotions,event_equal);
    end
    x=n%1650;y=n/1650;tap_x=x;tap_y=y;tap_valid=y<720&&x<1280;
    fn=n-1653;fx=fn>=0?fn%1650:0;fy=fn>=0?fn/1650:0;next_final_x=fx;next_final_y=fy;next_final_de=fn>=0&&fy<720&&fx<1280;
   end
   @(negedge pix_clk);tap_valid=0;next_final_de=0;score=0;
   wait(dut.state==0);repeat(8)@(negedge pix_clk);
   if(frame_num==0||frame_num==1||frame_num==7)begin
    frame_promotions[frame_num]=promotions-frame_promotions[frame_num];
    if(frame_promotions[frame_num]==0)$fatal(1,"MULTIFIELD_CONTEXT_NO_PROMOTION");
    if((frame_num==1||pause_at<0)&&checks-frame_checks_before!=921600)$fatal(1,"MULTIFIELD_PIXEL_COVERAGE");
    $display("REAL_CHANGED_CONTEXT frame=%0d epoch=%0d gen=%0d H=%0d filter=%0d source=%h job=%h slotgen=%h seq=%0d tick=%0d promotions=%0d",frame_num,current_epoch,current_generation,threshold,filtering,result_desc[191:128],result_desc[447:384],result_desc[511:448],result_desc[383:320],result_desc[575:512],frame_promotions[frame_num]);
   end else if(frame_num==2&&(display.session!=2||display.have_offer||display.late_rows!=1))$fatal(1,"ACCEPTED_SID_CHANGED_ON_LATE");
   if(frame_num==0)old_commits=commits;
  end
  wait(sink.packets==8);repeat(4)@(negedge pix_clk);
  if(starts<4||starts>6||captures!=6||revokes!=6||accepts!=completes||frame_promotions[0]==0||frame_promotions[1]==0)$fatal(1,"MULTICONTEXT_COVERAGE");
  $display("DESCRIPTOR_SIDE_DONE checks=%0d promotions=%0d packets=%0d",checks,promotions,sink.packets);done=1;

 end
 initial begin #200000000;$fatal(1,"CONTEXT_WATCHDOG state=%0d rows=%0d ready=%h block=%0d",dut.state,commits,dut.pixel_ready,block);end
 always @(posedge pix_clk)begin
  if(!rst_n||!block)blocked_edges=0;else blocked_edges=blocked_edges+1;
  if(blocked_edges>=3&&(!quiet||ref_ready||display.dsof||frame_ok||promoted))$fatal(1,"CE_KILL_VALIDITY");
 end
endmodule
