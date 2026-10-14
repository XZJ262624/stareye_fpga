from pathlib import Path
import json,hashlib,re
R=Path.cwd();F=R/'reports/m5c1b_fusion_integration/review_fix_99642712';O=F/'legacy46_current_220203';rows={};count=0
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def add(x):
 global count
 assert rec(R/x['path'])==x,x['path'];rows[x['path']]=x;count+=1
final=json.loads((O/'FINAL.json').read_text());assert final['status']=='PASS_NATIVE_23_POSITIVE_23_NAMED_NEGATIVE_PENDING_SEAL' and len(final['runs'])==46;plan=json.loads((O/'PLAN.json').read_text());results=[]
for c,row in zip(plan['cases'],final['runs']):
 assert c['index']==row['index'];W=O/f'case_{c["index"]:02d}';add(row['result']);r=json.loads((W/'RESULT.json').read_text());assert r['source_unchanged'];assert next(s for s in r['steps'] if s['stage']=='compile')['exit']==0;assert not any(s['timeout'] for s in r['steps'])
 for s in r['steps']:add(s['log'])
 inputs=json.loads((W/'INPUTS.json').read_text())
 for x in inputs['records']:add(x)
 for x in inputs['snapshots']:add(x['input']);add(x['snapshot'])
 text=(W/'sim.log').read_text(errors='replace');assert '** Error:' not in text;fs=re.findall(r'^.*\*\* Fatal:.*$',text,re.M)
 if c['expected_fatal']:assert len(fs)==1 and '** Fatal: '+c['expected_fatal'] in fs[0] and r['status']=='PASS_UNIQUE_NAMED_FATAL'
 else:assert not fs and c['positive_marker'] in text and r['status']=='PASS_CURRENT_LEGACY_CASE' and all(s['exit']==0 for s in r['steps'])
 for p in W.iterdir():
  if p.is_file() and p.suffix in ['.json','.log','.txt','.hex','.bin','.csv']:add(rec(p))
 results.append(dict(index=c['index'],status=r['status'],sim_exit=next(s['exit'] for s in r['steps'] if s['stage']=='sim'),expected_fatal=c['expected_fatal'],result=rec(W/'RESULT.json')))
for x in json.loads((F/'regression/SOURCE101.json').read_text())['records']:add(x)
for p in O.iterdir():
 if p.is_file():add(rec(p))
for p in [Path(__file__),F/'WORK_LEGACY46_FREEZE.md',F/'resource_diagnostic/prepare_legacy46_current.py',F/'resource_diagnostic/prepare_legacy46_current_v2.py']:add(rec(p))
h=O/'GATE_HANDBACK.json';assert not h.exists();h.write_text(json.dumps(dict(status='PASS23_POSITIVE_23_UNIQUE_NAMED_NEGATIVE_CURRENT_SOURCE',checks=count,source101_unchanged=True,runs=results,boundary='Module/component semantic regressions with current backend; negative rawexit may0 and only compile0+specifiedassertion is acceptance. Original earlyIDLEexport CHECK2 excluded/replaced by newextended960M. No hardware/warmrecovery/resource/timing claim.'),indent=2));add(rec(h));p=O/'GATE_MANIFEST.json';p.write_text(json.dumps(dict(records=list(rows.values())),indent=2));print(len(rows),count,rec(p))
