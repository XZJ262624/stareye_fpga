from pathlib import Path
import json,hashlib,re
M=Path(__file__).resolve().parent;R=M.parents[2];P=M/'end_protocol_v1';O=M/'end_protocol_handback_1007';O.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
records={};checks=0;runs=[]
for name in ['positive_093237','negative_oldfinish_093317']:
 w=P/name;r=json.loads((w/'RESULT.json').read_text());assert r['source_unchanged']
 for x in json.loads((w/'INPUTS.json').read_text()):
  assert rec(R/x['path'])==x;records[x['path']]=x;checks+=1
 for x in json.loads((w/'SNAPSHOTS.json').read_text()):
  q=x['snapshot'];assert rec(R/q['path'])==q;records[q['path']]=q;checks+=1
 for p in w.rglob('*'):
  if p.is_file() and 'work' not in p.relative_to(w).parts:
   records[rec(p)['path']]=rec(p)
 assert next(x for x in r['steps'] if x['stage']=='compile')['exit']==0
 log=(w/'sim.log').read_text();fatals=re.findall(r'\*\* Fatal: ([^\r\n]+)',log)
 if name.startswith('positive'):assert not fatals and r['status']=='PASS_SIM_PENDING_SOFTWARE_UART'
 else:assert len(fatals)==1 and fatals[0].startswith('FINAL_SNAPSHOT_DRAIN_INCOMPLETE')
 runs.append(dict(run=name,result=rec(w/'RESULT.json'),native_exit=r['steps'][-1]['exit'],wall_seconds=r['steps'][-1]['seconds'],fatals=fatals))
identity=R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json'
selected=json.loads(identity.read_text())['records'];assert len(selected)==101
assert all(rec(R/x['adopted']['path'])==x['adopted'] for x in selected)
protection=R/'reports/m5c1b_fusion_integration/SOURCE_PROTECTION.json';protected=json.loads(protection.read_text());bad=[x['path'] for x in protected if rec(R/x['path'])!=x]
oracle=json.loads((P/'positive_093237/END_SOFTWARE_ORACLE.json').read_text());assert oracle['status'].startswith('PASS_')
(O/'HANDBACK.json').write_text(json.dumps(dict(status='PASS_SHORT_END_PROTOCOL_ONLY',runs=runs,independent_oracle=oracle,input_snapshot_checks=checks,input_snapshot_mismatches=0,selected_checks=101,selected_mismatches=0,protected_checks=len(protected),protected_mismatches=bad,boundary='Conditional REQUEST1M/UART960000/460800, 2 healthy720p/all7 displayed; no final96M60/sixphase qualification. Future OFF/fault targets require case-specific complete-frame qualification after all original coverage. Existing aborted tests not credited. Native negative exit0 disclosed. Testbench two-domain quiet is not production CDC timing proof.'),indent=2))
assert not bad,bad
for p in [O/'HANDBACK.json',Path(__file__),identity,protection]:records[rec(p)['path']]=rec(p)
(O/'MANIFEST.json').write_text(json.dumps(dict(records=list(records.values())),indent=2));print(len(records),checks,rec(O/'MANIFEST.json'))
