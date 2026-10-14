from pathlib import Path
import subprocess,sys,json,time,os,traceback
B=Path(__file__).resolve().parent
(B/'CHAIN_OWNER.json').write_text(json.dumps(dict(pid=os.getpid(),started_unix=time.time(),command=sys.argv),indent=2))
try:
 for label,args in [('map',[B/'run_stage.py','map']),('audit_place',[B/'audit_then_place.py'])]:
  (B/'CHAIN_STATE.json').write_text(json.dumps(dict(status='RUNNING',stage=label),indent=2))
  with (B/(label+'_chain.log')).open('wb') as out:r=subprocess.run([sys.executable,'-B',*map(str,args)],stdout=out,stderr=subprocess.STDOUT)
  assert r.returncode==0,(label,r.returncode)
 (B/'CHAIN_STATE.json').write_text(json.dumps(dict(status='COMPLETE_STOP_FOR_WORK_NO_ROUTE'),indent=2))
except BaseException as e:
 (B/'CHAIN_FAILURE.txt').write_text(traceback.format_exc());(B/'CHAIN_STATE.json').write_text(json.dumps(dict(status='FAILED_BLOCKED',error=repr(e)),indent=2));raise
