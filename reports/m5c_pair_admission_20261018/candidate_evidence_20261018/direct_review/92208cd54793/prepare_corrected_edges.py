from pathlib import Path
import json,zlib
R=Path.cwd();D=R/'reports/m5c_pair_admission_20261018/implementation'
out=[]
for run in ['queue_160619/case1','queue_v2_160916/case1','edges_161040/case2']:
 b=bytes(int(x,16) for x in (D/run/'system_uart.hex').read_text().split());i=0;pk=[]
 while i<len(b):
  assert b[i:i+4]==b'SM5B';n=int.from_bytes(b[i+8:i+12],'little');p=b[i:i+64+n+4];assert len(p)==64+n+4
  # Existing packet CRC convention is IEEE over header+payload.
  assert zlib.crc32(p[:-4])==int.from_bytes(p[-4:],'little')
  if p[5]==10:pk.append(dict(reason=int.from_bytes(p[64+100:64+104],'little')))
  i+=len(p)
 out.append(dict(run=run,bytes=len(b),completion=pk))
(D/'HIGH_SID_FIXTURE_FAILURE.json').write_text(json.dumps(out,indent=2));print(out)
s=(R/'tb/m5c_pair_diag/tb_pair_latest_queue_v2.sv').read_text().replace('module tb_pair_latest_queue_v2;','module tb_pair_latest_highsid;')
s=s.replace('pulse(1,0);wait(acks==2);wait(cap_done);','''pulse(1,0);wait(acks==2);wait(cap_arm);@(negedge clk);
  if(selected!=1||backend.pair_attempts!=1||pubs!=1||backend.fresh_publication_seen||active_sid!=64'h0000000100000007)$fatal(1,"HIGH_SID_ACTUAL_ARM_MISSING");
  $display("HIGH_SID_ARM_PASS old=7 current=%h pubs=%0d acks=%0d selected=%0d",active_sid,pubs,acks,selected);$fclose(events);$fclose(uart_file);$finish;
  wait(cap_done);''')
p=R/'tb/m5c_pair_diag/tb_pair_latest_highsid.sv';assert not p.exists();p.write_text(s)
s=(R/'scripts/m5c_pair_latest_queue_v2.py').read_text().replace('tb_pair_latest_queue_v2','tb_pair_latest_highsid').replace("'queue_v2_'","'highsid_'").replace('for c in [0,1]','for c in [1]').replace('LATEST_QUEUE_PASS','HIGH_SID_ARM_PASS')
p=R/'scripts/m5c_pair_latest_highsid.py';assert not p.exists();p.write_text(s)
s=(R/'tb/m5c_pair_diag/tb_pair_latest_edges.sv').read_text().replace('module tb_pair_latest_edges;','module tb_pair_latest_edges_v2;').replace("diag_sid=CASE==0?64'd12:64'h0000000100000007;","diag_sid=64'd12;")
p=R/'tb/m5c_pair_diag/tb_pair_latest_edges_v2.sv';assert not p.exists();p.write_text(s)
s=(R/'scripts/m5c_pair_latest_edges.py').read_text().replace('tb_pair_latest_edges','tb_pair_latest_edges_v2').replace("'edges_'","'edges_v2_'")
p=R/'scripts/m5c_pair_latest_edges_v2.py';assert not p.exists();p.write_text(s)
