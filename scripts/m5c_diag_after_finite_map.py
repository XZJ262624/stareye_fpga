from pathlib import Path
import sys,json,time,hashlib,subprocess,os,traceback
R=Path(__file__).resolve().parents[1];F=Path(sys.argv[1]).resolve();B=Path(sys.argv[2]).resolve()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def state(status,**kw):
 q=B/'CONTINUATION_STATE.tmp';q.write_text(json.dumps(dict(status=status,updated=time.time(),**kw),indent=2));q.replace(B/'CONTINUATION_STATE.json')
(B/'CONTINUATION_OWNER.json').write_text(json.dumps(dict(pid=os.getpid(),started=time.time(),argv=sys.argv),indent=2))
try:
 state('WAITING_FINITE64_ACTUAL_COMPLETE')
 deadline=time.time()+7200
 while not (F/'RESULT_V3.json').exists():
  if (F/'PROGRESS_V3.json').exists():
   progress=json.loads((F/'PROGRESS_V3.json').read_text());assert all(x['status'].startswith('PASS') for x in progress),'Finite case failed'
  assert time.time()<deadline,'Finite result absent after bounded wait; no map started'
  time.sleep(10)
 final=json.loads((F/'RESULT_V3.json').read_text());assert final['status']=='PASS_46_CURRENT_POSITIVE_18_NAMED_NEGATIVE' and len(final['runs'])==64
 statuses=[];checked=0
 for x in final['runs']:
  p=R/x['result']['path'];assert rec(p)==x['result'];r=json.loads(p.read_text());assert r['source_unchanged'] and r['status'].startswith('PASS')
  for z in json.loads((p.parent/'INPUTS.json').read_text()):assert rec(R/z['path'])==z;checked+=1
  for step in r['steps']:assert rec(R/step['log']['path'])==step['log'];checked+=1
  statuses.append(r['status'])
 assert statuses.count('PASS_CURRENT_FOCUSED')==46 and statuses.count('PASS_EXPECTED_NAMED_FATAL')==18
 (B/'FINITE_ADMISSION.json').write_text(json.dumps(dict(status='PASS_CURRENT_FINITE_ONLY',results=final['runs'],hash_checks=checked,scope='DIAGNOSTICS default0 regressions plus separately recorded enabled short gates; not full-system type5 or timing acceptance.'),indent=2))
 state('DISCOVERY_MAP_RUNNING')
 with (B/'map_dispatch.log').open('wb') as log:p=subprocess.run([sys.executable,'-B',str(B/'run_stage.py'),'map'],stdout=log,stderr=subprocess.STDOUT)
 assert p.returncode==0,('map exit',p.returncode)
 state('DISCOVERY_MAP_COMPLETE_PENDING_CURRENT_CDC_AND_RESOURCE_AUDIT')
except BaseException as e:
 (B/'CONTINUATION_FAILURE.txt').write_text(traceback.format_exc());state('FAILED_NO_DESCENDANT',error=repr(e));raise
