from pathlib import Path
import hashlib,json,re
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016/recovery_regression';records={};checks=0
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def add(x):
 global checks
 assert rec(R/x['path'])==x,x['path'];checks+=1
 if x['path'] in records:assert records[x['path']]==x
 records[x['path']]=x
z=json.loads((A/'RESULT_V3.json').read_bytes());assert z['status']=='PASS_38_CURRENT_CONTEXT_RECOVERY_COUNTER_DIFFERENTIAL' and len(z['runs'])==38
for i,x in enumerate(z['runs']):
 add(x['result']);w=A/f'v3_case_{i:02d}';r=json.loads((w/'RESULT.json').read_bytes())
 assert r['status']=='PASS_CURRENT_FOCUSED' and r['source_unchanged'] and not r['case']['expected']
 for s in r['steps']:
  assert s['exit']==0 and not s.get('timeout',False);add(s['log'])
  if s['stage'] in ['compile','sim']:assert not re.search(r'\*\* (Error|Fatal):',(R/s['log']['path']).read_text(errors='replace'))
 assert r['case']['positive_marker'] in (w/'sim.log').read_text(errors='replace')
 for v in json.loads((w/'INPUTS.json').read_bytes()):add(v)
 for v in json.loads((w/'SNAPSHOTS.json').read_bytes()):
  add(v['input']);add(v['snapshot']);assert v['input']['sha256']==v['snapshot']['sha256'] and v['input']['bytes']==v['snapshot']['bytes']
 for p in w.iterdir():
  if p.is_file() and p.name not in ['transcript']:add(rec(p))
for n in ['RESULT_V3.json','PROGRESS_V3.json','CASES.json','DERIVATION.json','run_replay.py']:add(rec(A/n))
add(rec(Path(__file__)))
p=A/'GATE_HANDBACK.json';assert not p.exists()
p.write_text(json.dumps(dict(status='PASS_38_CURRENT_POSITIVE_RECOVERY_AND_COUNTER_RECIPES',positive=38,checks=checks,unique_records=len(records),scope='Current row/display source compiled into 38 original context/reset/cancel/tail/stall/descriptor/counter fixtures. All native and assigned software checkers passed. Not 38 full systems; diagnostic enabled system and new shadow negatives separate. No old failures relabeled, no unchanged legacy negative claimed newly executed.'),indent=2));add(rec(p))
p=A/'HANDBACK_MANIFEST.json';assert not p.exists();p.write_text(json.dumps(dict(records=list(records.values()),checks_including_handback=checks),indent=2))
print('SEALED_RECOVERY',len(records),checks,rec(p))
