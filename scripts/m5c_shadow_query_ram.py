"""Isolated native pin/net discovery; Tcl exits before packing or placement."""
from pathlib import Path
import json,hashlib,shutil,subprocess,time,os
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/physical_133645';Q=B/'ram_native_query';Q.mkdir()
P=Q/'project';P.mkdir();src=B/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
rows=[]
for name in ['Ti60_Demo.xml','Ti60_Demo.peri.xml','outflow/Ti60_Demo.vdb','outflow/Ti60_Demo.map.v']:
 a=src/name;b=P/name;b.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(a,b);rows.append(dict(source=rec(a),copy=rec(b)))
tcl=R/'reports/m5c_diagnostics/stage2_ram_pin_query_20261015_181127/mirror/efinity/m5c_fusion_i3/diag_pin_query.sdc';shutil.copyfile(tcl,P/'diag_pin_query.sdc')
batch=Q/'query.bat';batch.write_bytes((R/'reports/m5c_diagnostics/stage2_ram_pin_query_20261015_181127/query.bat').read_bytes())
(Q/'INPUTS.json').write_text(json.dumps(dict(copies=rows,query=rec(P/'diag_pin_query.sdc'),runner=rec(Path(__file__)),batch=rec(batch),scope='Native object discovery only. Explicit Tcl exit before pack/place; not physical qualification.'),indent=2))
start=time.time()
with (Q/'tool.log').open('wb') as f:
 p=subprocess.Popen(['cmd','/c',str(batch)],cwd=P,stdout=f,stderr=subprocess.STDOUT)
 (Q/'OWNER.json').write_text(json.dumps(dict(pid=p.pid,manager_pid=os.getpid(),start=start,cwd=str(P),command=['cmd','/c',str(batch)]),indent=2));print('RAM_QUERY_PID',p.pid,flush=True)
 while p.poll() is None:
  (Q/'HEARTBEAT.json').write_text(json.dumps(dict(pid=p.pid,updated=time.time(),elapsed=time.time()-start)));time.sleep(5)
 code=p.returncode
txt=(Q/'tool.log').read_text(errors='replace');unchanged=all(rec(Path(x['source']['path']))==x['source'] and rec(Path(x['copy']['path']))==x['copy'] for x in rows)
ok=code==0 and unchanged and 'DIAG_RAM_QUERY_COMPLETE_NO_PACK_PLACE_ROUTE' in txt
(Q/'RESULT.json').write_text(json.dumps(dict(status='PASS_NATIVE_PIN_QUERY_ONLY' if ok else 'FAIL',exit=code,seconds=time.time()-start,inputs_unchanged=unchanged,log=rec(Q/'tool.log')),indent=2));print('RESULT',ok,flush=True)
