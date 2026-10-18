from pathlib import Path
R=Path.cwd();D=R/'reports/m5c_pair_admission_20261018/implementation'
s=(R/'tb/m5c_pair_diag/tb_pair_latest_lifecycle.sv').read_text().replace('module tb_pair_latest_lifecycle;','module tb_pair_latest_queue;')
s=s.replace('reg send_normal=0,send_diag=0;','reg queue_hold=0;reg send_normal=0,send_diag=0;')
s=s.replace('.telemetry_pending(telemetry_pending),','.telemetry_pending(telemetry_pending||queue_hold),')
s=s.replace('if(!first_arm_cycle||!first_sample_busy)$fatal(1,"CAPTURE_FIRST_SAMPLE_NOT_OVERLAPPING_TYPE4");','if(!first_arm_cycle)$fatal(1,"CAPTURE_WITHOUT_REAL_ARM");')
a=s.index(' initial if(CASE==1)begin');b=s.index(' initial begin #500000000;',a)
s=s[:a]+r'''
 integer stale_ack=0;
 always @(posedge clk)if(rst_n&&fusion_acquire&&active_sid==64'd7)begin
  if(backend.pair_selected)$fatal(1,"LATEST_SID_STALE_ACQUIRE_SELECTED");
  if(!backend.fresh_publication_seen||backend.pair_attempts!=0||arm_count!=0)$fatal(1,"STALE_CONSUMED_CAPTURE_OPPORTUNITY");
  $display("STALE_ACQUIRE_REJECTED sid=%h latest=%h pubs=%0d attempts=%0d",active_sid,backend.pair_latest_request_session,pubs,backend.pair_attempts);
 end
 initial begin
  wait(rst_n);wait(pubs==1&&backend.state==backend.IDLE&&!backend.packet_busy);
  @(negedge clk);queue_hold=1;
  pulse(1,1);wait(ds.req_valid);wait(!pair_busy);
  // A new request reaches the independent pair mailbox while normal request stays queued.
  @(negedge pix);diag_sid=CASE==0?64'd12:64'h0000000100000007;
  pulse(0,1);wait(!pair_busy);repeat(12)@(negedge clk);
  if(ds.req_data[223:160]!=7||!backend.pair_latest_request_valid||backend.pair_latest_request_session!=diag_sid)$fatal(1,"QUEUE_FIXTURE_NOT_ESTABLISHED");
  if(pubs!=1||selected||backend.pair_attempts)$fatal(1,"QUEUE_FIXTURE_PRECONDITION");
  @(negedge clk);queue_hold=0;
  wait(acks==1);repeat(12)@(negedge pix);
  if(selected||arm_count||!backend.fresh_publication_seen||backend.pair_attempts)$fatal(1,"STALE_ACQUIRE_CONSUMED_FRESH");
  // Model the PIX rejection of the old offer using the normal session release mailbox.
  @(negedge pix);pixel_release=1;@(negedge pix);pixel_release=0;
  wait(ds.state==ds.IDLE&&pair_leased==0);repeat(8)@(negedge pix);
  if(!backend.fresh_publication_seen||pubs!=1)$fatal(1,"OLD_SESSION_DRAIN_LOST_FRESH");
  @(negedge pix);normal_sid=diag_sid;
  pulse(1,0);wait(acks==2);wait(cap_done);
  if(selected!=1||backend.pair_attempts!=1||pubs!=1||backend.fresh_publication_seen)$fatal(1,"CURRENT_SID_SAME_PUBLICATION_NOT_SELECTED");
  @(negedge pix);pixel_snapshot[63:0]=active_sid;pixel_snapshot[127:64]=ticks;pixel_snapshot[191:128]=active_sid;frame_done=1;pixel_release=1;
  @(negedge pix);frame_done=0;pixel_release=0;
  wait(pair_completed==1);wait(!backend.pair_hold&&pair_leased==0);repeat(10)@(negedge clk);
  if(backend.pair_failure!=0||current_B!=2||pair_metadata_B!=1||release_cycle<=final_b_cycle||takes!=1||t4_start!=1||t4_done!=1)$fatal(1,"LATEST_QUEUE_COMPLETE_DRAIN_FAILED");
  wait(pubs==2&&backend.state==backend.IDLE&&!backend.packet_busy);
  if(lease_fault||session_fault||pair_leased!=0||!backend.fresh_publication_seen)$fatal(1,"LATEST_QUEUE_RECOVERY_FAILED");
  $display("LATEST_QUEUE_PASS case=%0d acks=%0d selected=%0d currentB=%0d metadataB=%0d pubs=%0d same_low32=%0d",CASE,acks,selected,current_B,pair_metadata_B,pubs,CASE==1);$fclose(events);$fclose(uart_file);$finish;
 end
''' + s[b:]
p=R/'tb/m5c_pair_diag/tb_pair_latest_queue.sv';assert not p.exists();p.write_text(s)
s=(R/'scripts/m5c_pair_latest_lifecycle.py').read_text().replace("'lifecycle_'","'queue_'").replace('tb_pair_latest_lifecycle','tb_pair_latest_queue').replace('work.tb_pair_selection_lifecycle','work.tb_pair_latest_queue').replace('SELECTION_LIFECYCLE_PASS','LATEST_QUEUE_PASS').replace('PASS_SELECTION_LIFECYCLE','PASS_LATEST_QUEUE')
p=R/'scripts/m5c_pair_latest_queue.py';assert not p.exists();p.write_text(s)
