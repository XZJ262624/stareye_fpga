from pathlib import Path
import json,subprocess,sys,time,os
A=Path(__file__).resolve().parent;R=A.parents[3];state=A/'BACKEND_CONNECTION_CHAIN_STATE.json'
def put(status,**extra):
 p=state.with_suffix('.tmp');p.write_text(json.dumps(dict(status=status,updated=time.time(),pid=os.getpid(),**extra),indent=2));p.replace(state)
start=time.time();put('WAIT_BACKEND_QUERY06_COMPLETE')
try:
 while True:
  p=A/'BACKEND_QUERY_STATE.json'
  j=json.loads(p.read_text())
  if j['status']=='EXECUTED_PENDING_PIN_RECONCILIATION':break
  assert not any(x in j['status'] for x in ['FAIL','BLOCK']),j
  assert time.time()-start<7200,'WAIT_BACKEND06_TIMEOUT'
  time.sleep(10)
 for label,args in [('prepare07',['prepare_backend_connections.py']),('native07',['run_query_followon.py','QUERY07_DERIVATION.json','sta_06_backend_cleanup_controls']),('audit_backend',['audit_backend_controls.py'])]:
  with (A/(label+'_chain.log')).open('xb') as f:
   cmd=[sys.executable,'-B',str(A/args[0])]+args[1:];p=subprocess.Popen(cmd,cwd=R,stdout=f,stderr=subprocess.STDOUT);put('RUNNING',stage=label,child_pid=p.pid,command=cmd);code=p.wait();assert code==0,(label,code)
 put('BACKEND_COMPLETE_PENDING_FINAL_SEAL')
except BaseException as e:
 put('FAIL_BACKEND_CONNECTION_CHAIN',error=repr(e));raise
