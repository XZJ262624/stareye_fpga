from pathlib import Path
R=Path.cwd();s=(R/'tb/m5c_pair_diag/tb_pair_latest_queue_v2.sv').read_text().replace('module tb_pair_latest_queue_v2;','module tb_pair_latest_sameedge_match;')
s=s.replace('reg queue_hold=0;','reg inject_valid=0;reg [63:0] inject_sid=0;reg queue_hold=0;')
s=s.replace('.pair_request(request_pair),.pair_request_session(pair_sid)', '.pair_request(request_pair||inject_valid),.pair_request_session(inject_valid?inject_sid:pair_sid)')
a=s.index(' integer stale_ack=0;');b=s.index(' initial begin #500000000;',a)
s=s[:a]+r'''
 initial begin
  wait(rst_n);wait(pubs==1&&backend.state==backend.IDLE&&!backend.packet_busy);
  @(negedge pix);diag_sid=64'h0000000100000007;normal_sid=7;
  pulse(0,1);wait(!pair_busy);repeat(12)@(negedge clk);
  if(backend.pair_latest_request_session!=diag_sid||!backend.pair_latest_request_valid)$fatal(1,"SAMEEDGE_SETUP_MISSING");
  pulse(1,0);wait(fusion_acquire);
  @(negedge clk);inject_valid=1;inject_sid=7;
  @(posedge clk);
  if(backend.pair_latest_request_session!=diag_sid||!backend.pair_selected)$fatal(1,"SAME_EDGE_MATCHING_REQUEST_NOT_SELECTED");
  $display("SAMEEDGE_MATCH actualacquire=%h stored=%h incoming=%h selected=%b",active_sid,backend.pair_latest_request_session,inject_sid,backend.pair_selected);
  @(negedge clk);inject_valid=0;
  wait(cap_arm);@(negedge clk);
  if(acks!=1||selected!=1||backend.pair_attempts!=1||backend.fresh_publication_seen)$fatal(1,"SAMEEDGE_MATCH_ARM_MISSING");
  $display("SAMEEDGE_MATCH_PASS pubs=%0d ack=%0d select=%0d attempts=%0d",pubs,acks,selected,backend.pair_attempts);$fclose(events);$fclose(uart_file);$finish;
 end
''' +s[b:]
p=R/'tb/m5c_pair_diag/tb_pair_latest_sameedge_match.sv';assert not p.exists();p.write_text(s)
s=(R/'scripts/m5c_pair_latest_queue_v2.py').read_text().replace('tb_pair_latest_queue_v2','tb_pair_latest_sameedge_match').replace("'queue_v2_'","'sameedge_match_'").replace('for c in [0,1]','for c in [0]').replace('LATEST_QUEUE_PASS','SAMEEDGE_MATCH_PASS')
p=R/'scripts/m5c_pair_latest_sameedge_match.py';assert not p.exists();p.write_text(s)
