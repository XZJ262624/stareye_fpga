from pathlib import Path
import json,hashlib,datetime,collections
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_diagnostics/stage2_finite_20261015_155023';O=R/'reports/m5c_diagnostics'/('stage2_finite_seal_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));O.mkdir();files=set();checks=0
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(x):
 global checks
 p=R/x['path'];assert rec(p)==x,x['path'];files.add(p);checks+=1
final=json.loads((F/'RESULT_V3.json').read_text());assert final['status']=='PASS_46_CURRENT_POSITIVE_18_NAMED_NEGATIVE' and len(final['runs'])==64
counts=collections.Counter()
for entry in final['runs']:
 verify(entry['result']);p=R/entry['result']['path'];r=json.loads(p.read_text());counts[r['status']]+=1;assert r['source_unchanged']
 inp=p.parent/'INPUTS.json';files.add(inp)
 for x in json.loads(inp.read_text()):verify(x)
 for step in r['steps']:
  assert step['exit']==0 and not step.get('timeout',False);verify(step['log'])
 for q in p.parent.iterdir():
  if q.is_file() and q.suffix in ['.json','.log','.do','.py']:files.add(q)
 for q in (p.parent/'source_snapshot').glob('*'):
  if q.is_file():files.add(q)
assert counts=={'PASS_CURRENT_FOCUSED':46,'PASS_EXPECTED_NAMED_FATAL':18}
for p in F.iterdir():
 if p.is_file() and p.suffix in ['.json','.py','.sv','.svh']:files.add(p)
files.add(Path(__file__).resolve())
out=dict(status='PASS_FINITE_CURRENT_DIAGNOSTICS_DEFAULT0_ONLY',counts=counts,verified_record_checks=checks,scope='46 positive and18 named-fatal sensitivity gates with current source bindings and actual software checkers. This does not qualify enabled observer system, physical resource, timing or hardware.',historical='Failed preparation revisions and prior runs remain at their original paths; no old results reclassified.')
(O/'HANDBACK.json').write_text(json.dumps(out,indent=2));files.add(O/'HANDBACK.json');rows=[rec(p) for p in sorted(files)]
(O/'MANIFEST.json').write_text(json.dumps(dict(records=rows),indent=2));print(O,len(rows),checks,hashlib.sha256((O/'MANIFEST.json').read_bytes()).hexdigest())
