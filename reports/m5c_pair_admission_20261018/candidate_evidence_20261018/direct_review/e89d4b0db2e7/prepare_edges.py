from pathlib import Path
R=Path.cwd();s=(R/'tb/m5c_pair_diag/tb_pair_latest_queue_v2.sv').read_text().replace('module tb_pair_latest_queue_v2;','module tb_pair_latest_edges;')
s=s.replace('reg queue_hold=0;','reg pair_reset_ok=1,inject_valid=0;reg [63:0] inject_sid=0;reg queue_hold=0;')
s=s.replace('.pair_local_rst_n(rst_n),.pair_request(request_pair),.pair_request_session(pair_sid)', '.pair_local_rst_n(rst_n&&pair_reset_ok),.pair_request(request_pair||inject_valid),.pair_request_session(inject_valid?inject_sid:pair_sid)')
s=s.replace('pulse(1,1);wait(ds.req_valid);wait(!pair_busy);', 'pulse(1,CASE==2?0:1);wait(ds.req_valid);wait(!pair_busy);')
a='''  pulse(0,1);wait(!pair_busy);repeat(12)@(negedge clk);
  if(ds.req_data[223:160]!=7||!backend.pair_latest_request_valid||backend.pair_latest_request_session!=diag_sid)$fatal(1,"QUEUE_FIXTURE_NOT_ESTABLISHED");'''
b='''  if(CASE<2)begin pulse(0,1);wait(!pair_busy);end
  if(CASE==3)begin @(negedge clk);pair_reset_ok=0;repeat(3)@(negedge clk);pair_reset_ok=1;end
  repeat(12)@(negedge clk);
  if(ds.req_data[223:160]!=7)$fatal(1,"QUEUE_FIXTURE_NOT_ESTABLISHED");
  if(CASE==2||CASE==3)begin if(backend.pair_latest_request_valid)$fatal(1,"UNOBSERVED_REQUEST_VALID");end
  else if(CASE<2&&(!backend.pair_latest_request_valid||backend.pair_latest_request_session!=diag_sid))$fatal(1,"QUEUE_FIXTURE_LATEST_NOT_ESTABLISHED");'''
assert a in s;s=s.replace(a,b)
s=s.replace('wait(acks==1);repeat(12)@(negedge pix);','''if(CASE==4)begin
   wait(fusion_acquire);@(negedge clk);inject_valid=1;inject_sid=diag_sid;
   @(posedge clk);if(backend.pair_selected)$fatal(1,"SAME_EDGE_NEW_SID_IGNORED");
   @(negedge clk);inject_valid=0;
  end
  wait(acks==1);repeat(12)@(negedge pix);''')
s=s.replace('@(negedge pix);normal_sid=diag_sid;', '''if(CASE==2||CASE==3)begin pulse(0,1);wait(!pair_busy);repeat(12)@(negedge clk);end
  @(negedge pix);normal_sid=diag_sid;''')
# Reset clears fresh-publication too, correctly; exercise latest reset before the real publication instead.
s=s.replace('if(CASE==3)begin @(negedge clk);pair_reset_ok=0;repeat(3)@(negedge clk);pair_reset_ok=1;end','')
s=s.replace('wait(rst_n);wait(pubs==1', '''wait(rst_n);
  if(CASE==3)begin pulse(0,1);wait(!pair_busy);repeat(12)@(negedge clk);if(!backend.pair_latest_request_valid)$fatal(1,"RESET_SETUP_NO_REQUEST");pair_reset_ok=0;repeat(3)@(negedge clk);pair_reset_ok=1;end
  wait(pubs==1''')
s=s.replace('pulse(1,CASE==2?0:1)','pulse(1,(CASE==2||CASE==3)?0:1)')
p=R/'tb/m5c_pair_diag/tb_pair_latest_edges.sv';assert not p.exists();p.write_text(s)
s=(R/'scripts/m5c_pair_latest_queue_v2.py').read_text().replace('tb_pair_latest_queue_v2','tb_pair_latest_edges').replace("'queue_v2_'","'edges_'").replace('for c in [0,1]','for c in [2,3,4]')
p=R/'scripts/m5c_pair_latest_edges.py';assert not p.exists();p.write_text(s)
