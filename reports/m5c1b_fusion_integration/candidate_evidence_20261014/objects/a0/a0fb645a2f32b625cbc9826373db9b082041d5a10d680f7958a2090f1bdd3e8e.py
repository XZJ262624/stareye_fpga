from pathlib import Path
import json,hashlib,re
M=Path(__file__).resolve().parent;R=M.parents[2]
O=M/'legacy37_handback_0955';O.mkdir(exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
old=M/'legacy_remaining_v1/run_091740';new=M/'legacy_remaining_tap28_v4/run_094847'
folders=[p.parent for p in old.glob('*/RESULT.json') if json.loads(p.read_text())['status']=='PASS_CURRENT_LEGACY']+[p.parent for p in new.glob('*/RESULT.json')]
assert len(folders)==37
records={};runs=[];checks=0
def bind(p):records[str(p)]=rec(p)
for d in folders:
 r=json.loads((d/'RESULT.json').read_text());assert r['source_unchanged']
 assert r['status'] in ('PASS_CURRENT_LEGACY','PASS_EXPECTED_NAMED_FATAL')
 inputs=json.loads((d/'INPUTS.json').read_text());snaps=json.loads((d/'SNAPSHOTS.json').read_text())
 for x in inputs:
  assert rec(R/x['path'])==x;xname=R/x['path'];bind(xname);checks+=1
 for x in snaps:
  assert rec(R/x['snapshot']['path'])==x['snapshot'];bind(R/x['snapshot']['path']);checks+=1
 for p in d.glob('*'):
  if p.is_file() and p.suffix in ('.json','.log'):bind(p)
 compile_step=next(x for x in r['steps'] if x['stage']=='compile');sim=next(x for x in r['steps'] if x['stage']=='sim')
 assert compile_step['exit']==0 and not sim['timeout']
 log=(d/'sim.log').read_text(errors='replace');fatals=re.findall(r'\*\* Fatal: ([^\r\n]+)',log)
 if r['case']['fatal']:assert len(fatals)==1 and fatals[0].startswith(r['case']['fatal'])
 else:assert not fatals and sim['exit']==0 and r['case']['marker'] in log
 runs.append(dict(case=r['case']['name'],status=r['status'],result=rec(d/'RESULT.json'),compile_exit=compile_step['exit'],native_exit=sim['exit'],named_fatals=fatals))
for p in [M/'legacy_remaining_v1/TAP_SMALL_FAILURE_RECEIPT_0947.json',old/'tap_small/RESULT.json',old/'tap_small/sim.log',old/'tap_small/compile.log',M/'legacy_remaining_tap28_v3/PRE_NATIVE_FAILURE.json',M/'prepare_tap28_revision.py',M/'prepare_tap28_revision_v2.py',Path(__file__)]:bind(p)
positive=sum(x['status']=='PASS_CURRENT_LEGACY' for x in runs);assert positive==14
(O/'HANDBACK.json').write_text(json.dumps(dict(status='PASS_CURRENT_LEGACY37_FOCUSED_ONLY',positive=positive,named_negative=37-positive,input_and_snapshot_checks=checks,mismatches=0,runs=runs,boundary='8 actual engine runs plus 29 actual corrected tap/remaining runs. Old tap26-vs28 failure and pre-native CRLF generation failure preserved. Native Fatal exit0 allowed only compile0 and unique expected Fatal. No timing/hardware acceptance.'),indent=2))
bind(O/'HANDBACK.json')
(O/'MANIFEST.json').write_text(json.dumps(dict(records=list(records.values())),indent=2))
print(O, len(records),checks,rec(O/'MANIFEST.json'))
