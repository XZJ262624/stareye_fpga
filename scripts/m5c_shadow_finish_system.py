from pathlib import Path
import json,sys,time,subprocess,hashlib,os,traceback
R=Path(__file__).resolve().parents[1];W=Path(sys.argv[1]).resolve();O=W/'completion_gate';O.mkdir(exist_ok=False)
checker=R/'scripts/m5c_shadow_check_system.py'
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
frozen=rec(checker);(O/'OWNER.json').write_text(json.dumps(dict(pid=os.getpid(),started=time.time(),argv=sys.argv,checker=frozen),indent=2))
def state(status,**kw):
 p=O/'STATE.tmp';p.write_text(json.dumps(dict(status=status,updated=time.time(),**kw),indent=2));p.replace(O/'STATE.json')
try:
 state('WAITING_NATIVE_RESULT_NO_RESTART');deadline=time.time()+7500
 while not (W/'RESULT.json').exists():
  assert time.time()<deadline,'No result by bounded completion deadline';time.sleep(15)
 r=json.loads((W/'RESULT.json').read_text());assert r['status']=='PASS_SIM_PENDING_SOFTWARE' and r['inputs_unchanged'],r
 assert rec(checker)==frozen
 inputs=json.loads((W/'INPUTS.json').read_text())
 for x in inputs:assert rec(Path(x['path']))==x
 state('STRICT_SOFTWARE_RUNNING')
 with (O/'software.log').open('wb') as log:p=subprocess.run([sys.executable,'-B',str(checker),str(W)],stdout=log,stderr=subprocess.STDOUT,timeout=300)
 assert p.returncode==0,('software exit',p.returncode)
 oracle=json.loads((W/'SOFTWARE_DIAGNOSTIC_SYSTEM.json').read_text());assert oracle['status']=='PASS_ACTUAL_SYSTEM_TYPE5_AND_ORIGINAL_WIRE'
 files={Path(x['path']) for x in inputs}|{checker,Path(__file__).resolve()}
 for d in [W,W/'snapshots',W/'original_types_view',O]:
  files.update(p for p in d.glob('*') if p.is_file() and p.name not in ['STATE.json','MANIFEST.json','HEARTBEAT.json','HEARTBEAT.tmp','completion_worker.log'])
 (O/'MANIFEST.json').write_text(json.dumps(dict(records=[rec(p) for p in sorted(files)],excluded_live_epilogue=['HEARTBEAT.json','completion_worker.log'],scope='Stable completed-native/raw/software/input files; manager epilogue separately post-exit.'),indent=2));state('PASS_SYSTEM_NATIVE_AND_INDEPENDENT_SOFTWARE',manifest=rec(O/'MANIFEST.json'));print('PASS_SYSTEM_NATIVE_AND_INDEPENDENT_SOFTWARE',flush=True)
except BaseException as e:
 (O/'FAILURE.txt').write_text(traceback.format_exc());state('FAIL_NO_GATE_CLOSED',error=repr(e));raise
