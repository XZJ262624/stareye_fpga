from pathlib import Path
import subprocess,sys,time,json
A=Path(__file__).resolve().parent;R=A.parents[3];start=time.time()
def put(status,**kw):
 p=A/'BACKEND_QUERY_STATE.json';t=p.with_suffix('.tmp');t.write_text(json.dumps(dict(status=status,updated=time.time(),**kw),indent=2));t.replace(p)
try:
 put('WAIT_ORIGINAL5_QUERY_COMPLETION')
 while True:
  q=json.loads((A/'CURRENT_QUERY_CHAIN_STATE.json').read_text())
  assert q['status']!='FAIL_BLOCKED',q
  if q['status']=='ALL5_EXECUTED_PENDING_FULL_RECONCILIATION':break
  assert time.time()-start<7200,'WAIT_TIMEOUT';time.sleep(5)
 with (A/'chain_query06.log').open('wb') as log:
  p=subprocess.Popen([sys.executable,'-B',str(A/'run_query_followon.py'),'QUERY06_DERIVATION.json','sta_05_clock_pairs'],cwd=R,stdout=log,stderr=subprocess.STDOUT);put('RUNNING_QUERY06',pid=p.pid);code=p.wait()
 assert code==0,code;put('EXECUTED_PENDING_PIN_RECONCILIATION',exit=code)
except BaseException as e:put('FAIL_BLOCKED',error=repr(e));raise
