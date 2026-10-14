// All event observations use actual pre-NBA handshakes; quiet checks use settled falling edges.
 wire end_counts_equal=end_src_count==end_ui_count&&end_ui_count==end_start_count&&end_start_count==end_done_count&&end_done_count==end_take_count&&
    telemetry_accepts==end_ui_count&&telemetry_starts==end_start_count&&packet_takes==end_take_count&&packet_starts==packet_dones&&wire_count==expected_wire_bytes;
 wire end_target_taken=end_target_fixed&&end_target_ui>0&&end_take_count>=end_target_ui;
 wire end_pix_raw_idle=!fusion_frame_done&&!dut.telemetry.mail_busy;
 wire end_ui_raw_idle=!dut.telemetry.mail_valid&&!dut.telemetry.building&&!dut.telemetry.raw_valid&&!dut.telemetry.payload_ready&&!dut.telemetry.mail_take&&
    !dut.background.packet_busy&&!dut.background.payload_ready&&!dut.background.packet_start&&!dut.background.packet_done&&!dut.telemetry_take&&!dut.telemetry.snapshot_pending;
 wire end_ui_idle=end_target_taken&&end_counts_equal&&end_ui_raw_idle;
 initial begin end_file=$fopen("end_events.txt","w");for(end_i=0;end_i<4096;end_i=end_i+1)begin end_done_cycle[end_i]=0;end_take_cycle[end_i]=0;end end
 task end_try_target;
 begin
  if(!end_target_fixed&&smoke_complete&&end_checked_qualified)begin
   if(end_src_count>0&&end_source_seq[end_src_count]==end_checked_seq)begin
    end_target_fixed=1;end_target_seq=end_checked_seq;end_target_src=end_src_count;
    $fdisplay(end_file,"TARGET %0d %0d %0t",end_target_seq,end_target_src,$time);
    $display("END_TARGET_FIXED seq=%0d source_index=%0d",end_target_seq,end_target_src);
   end else $fdisplay(end_file,"TARGET_WAIT_LEGAL_DROP %0d %0t",end_checked_seq,$time);
  end
 end endtask
 always @(posedge pix_clk)if(arst_n&&fusion_frame_done)begin
  end_src_version=end_src_version+1;
  if(fusion_telemetry_snapshot[63:0]!==display_seq)$fatal(1,"END_SOURCE_FRAME_IDENTITY");
  if(!dut.telemetry.mail_busy)begin
   end_src_count=end_src_count+1;if(end_src_count>=4096)$fatal(1,"END_SOURCE_LEDGER_OVERFLOW");
   end_source_seq[end_src_count]=display_seq;end_source_data[end_src_count]=fusion_telemetry_snapshot;
  end
  $fdisplay(end_file,"SOURCE %0d %0d %0d %0120h %0t",display_seq,!dut.telemetry.mail_busy,end_src_count,fusion_telemetry_snapshot,$time);
 end
 always @(posedge ui_clk)if(arst_n)begin
  end_ui_cycle=end_ui_cycle+1;
  if(dut.telemetry.accepting)begin
   end_ui_count=end_ui_count+1;end_ui_version=end_ui_version+1;
   if(end_ui_count>end_src_count||dut.telemetry.held!==end_source_data[end_ui_count])$fatal(1,"END_UI_NOT_REAL_SOURCE_SNAPSHOT");
   end_ui_seq[end_ui_count]=dut.telemetry.held[63:0];
   if(end_target_fixed&&end_ui_seq[end_ui_count]==end_target_seq)begin
    if(end_target_ui!=0||end_ui_count!=end_target_src)$fatal(1,"END_TARGET_UI_DUPLICATE");end_target_ui=end_ui_count;
   end
   $fdisplay(end_file,"UI %0d %0d %0120h %0d %0t",end_ui_count,end_ui_seq[end_ui_count],dut.telemetry.held,end_ui_cycle,$time);
  end
  // A target may be fixed after its UI acceptance only if the independent frame check follows that event.
  if(end_target_fixed&&end_target_ui==0&&end_ui_count>=end_target_src)begin
   if(end_ui_seq[end_target_src]!==end_target_seq)$fatal(1,"END_LATE_TARGET_IDENTITY");end_target_ui=end_target_src;
  end
  if(dut.background.packet_start)begin
   if(end_packet_active)$fatal(1,"END_PACKET_START_OVERLAP");end_packet_active=1;end_packet_type=dut.background.packet.packet_type;end_ui_version=end_ui_version+1;end_payload_count=0;
   if(end_packet_type==4)begin
    end_start_count=end_start_count+1;end_current_index=end_start_count;
    if(end_start_count>end_ui_count||end_pending_take!=0||!dut.telemetry_ready||dut.telemetry_take)$fatal(1,"END_TYPE4_START_WITHOUT_ACCEPT");
    $fdisplay(end_file,"START %0d %0d %0d %0t",end_current_index,end_ui_seq[end_current_index],end_ui_cycle,$time);
   end
  end
  if(end_packet_active&&end_packet_type==4&&dut.background.payload_valid&&dut.background.payload_ready)end_payload_count=end_payload_count+1;
  if(dut.background.packet_done)begin
   if(!end_packet_active)$fatal(1,"END_DONE_WITHOUT_START");end_packet_active=0;end_ui_version=end_ui_version+1;
   if(end_packet_type==4)begin
    end_done_count=end_done_count+1;
    if(end_done_count!=end_current_index||end_payload_count!=256||end_pending_take!=0)$fatal(1,"END_TYPE4_DONE_LEDGER");
    end_done_cycle[end_current_index]=end_ui_cycle;end_pending_take=end_current_index;
    $fdisplay(end_file,"DONE %0d %0d %0d %0d %0t",end_current_index,end_ui_seq[end_current_index],end_payload_count,end_ui_cycle,$time);
   end
  end
  if(dut.telemetry_take)begin
   end_take_count=end_take_count+1;end_ui_version=end_ui_version+1;
   if(end_pending_take!=end_take_count||end_done_cycle[end_take_count]==0||end_done_cycle[end_take_count]>=end_ui_cycle)$fatal(1,"END_TAKE_WITHOUT_PRIOR_PACKET_DONE");
   end_take_cycle[end_take_count]=end_ui_cycle;end_pending_take=0;
   $fdisplay(end_file,"TAKE %0d %0d %0d %0t",end_take_count,end_ui_seq[end_take_count],end_ui_cycle,$time);
  end
 end
 always @(negedge pix_clk)begin
  if(!arst_n)begin end_ui_idle_pix_sync<=0;end_pix_quiet=0;end_pix_anchor=0;end
  else begin
   end_ui_idle_pix_sync<={end_ui_idle_pix_sync[0],end_ui_idle};
   if(end_target_taken&&end_pix_raw_idle&&end_ui_idle_pix_sync[1])begin
    if(end_pix_quiet==0)end_pix_anchor=end_src_version;
    if(end_src_version!=end_pix_anchor)begin end_pix_quiet=0;end_pix_anchor=end_src_version;end
    else if(end_pix_quiet<8)begin end_pix_quiet=end_pix_quiet+1;$fdisplay(end_file,"PIX_QUIET %0d %0d %0t",end_pix_quiet,end_pix_anchor,$time);end
   end else end_pix_quiet=0;
  end
 end
 always @(negedge ui_clk)begin
  if(!arst_n)begin end_pix_idle_ui_sync<=0;end_ui_quiet=0;end_ui_anchor=0;end
  else begin
   end_pix_idle_ui_sync<={end_pix_idle_ui_sync[0],end_pix_raw_idle&&end_pix_quiet>=8};
   if(end_ui_idle&&end_pix_idle_ui_sync[1])begin
    if(end_ui_quiet==0)end_ui_anchor=end_ui_version;
    if(end_ui_version!=end_ui_anchor)begin end_ui_quiet=0;end_ui_anchor=end_ui_version;end
    else if(end_ui_quiet<8)begin end_ui_quiet=end_ui_quiet+1;$fdisplay(end_file,"UI_QUIET %0d %0d %0t",end_ui_quiet,end_ui_anchor,$time);end
   end else end_ui_quiet=0;
   if(end_ui_quiet>=8&&end_pix_quiet>=8&&end_ui_idle&&end_pix_raw_idle&&end_src_version==end_pix_anchor&&end_ui_version==end_ui_anchor)end_finish_permitted=1;
  end
 end
 task end_assert_complete;
 begin
  if(!end_target_taken||!end_counts_equal||!end_ui_raw_idle||!end_pix_raw_idle||end_packet_active||end_pending_take!=0)
   $fatal(1,"FINAL_SNAPSHOT_DRAIN_INCOMPLETE target=%0d/%0d src=%0d ui=%0d starts=%0d done=%0d take=%0d mail=%b valid=%b build=%b raw=%b ready=%b busy=%b pending=%b",end_target_seq,end_target_ui,end_src_count,end_ui_count,end_start_count,end_done_count,end_take_count,dut.telemetry.mail_busy,dut.telemetry.mail_valid,dut.telemetry.building,dut.telemetry.raw_valid,dut.telemetry_ready,dut.background.packet_busy,dut.telemetry.snapshot_pending);
  if(!END_RESTORE_OLD&&(end_ui_quiet<8||end_pix_quiet<8||end_src_version!=end_pix_anchor||end_ui_version!=end_ui_anchor))$fatal(1,"END_QUIET_WINDOW_INCOMPLETE");
 end endtask
