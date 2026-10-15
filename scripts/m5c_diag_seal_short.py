from pathlib import Path
import json,hashlib,datetime,re
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_diagnostics';O=B/('stage2_short_seal_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));O.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
names=['stage2_coupled_20261015_151939','stage2_coupled_20261015_152522','stage2_coupled_20261015_152933','stage2_ack_positive_20261015_154336','stage2_slot_20261015_152737','stage2_slot_20261015_152802','stage2_slot_20261015_152809','stage2_slot_20261015_153145','stage2_slot_20261015_153159','stage2_bridge_20261015_154239','stage2_mixed_20261015_154501','stage2_v2reg_20261015_153956','stage2_v2reg_20261015_154128','stage2_invalid_20261015_154131','stage2_negative_budget_20261015_153854','stage2_negative_window_20261015_153900','stage2_negative_earlyack_20261015_154349','stage2_negative_earlyack_20261015_154714']
records={};gates=[];historical=[]
for name in names:
 d=B/name;assert d.exists()
 for p in d.rglob('*'):
  if p.is_file() and 'work' not in p.relative_to(d).parts and p.suffix not in ['.wlf'] and p.name!='transcript':records[rec(p)['path']]=rec(p)
 for p in d.rglob('RESULT.json'):
  r=json.loads(p.read_text());gates.append(dict(result=rec(p),status=r['status']))
  steps=r.get('steps',[])
  for step in steps:
   log=step.get('log');
   if log:
    q=Path(log['path']);q=q if q.is_absolute() else R/q;assert rec(q)['sha256']==log['sha256']
  if r['status'].startswith('PASS_EXPECTED'):
   log=(p.parent/'sim.log').read_text();assert len(re.findall(r'\*\* Fatal:',log))==1
 for inp in d.rglob('INPUTS.json'):
  xs=json.loads(inp.read_text())
  if not isinstance(xs,list):continue
  for i,x in enumerate(xs):
   src=Path(x['path']);src=src if src.is_absolute() else R/src
   if src.exists() and rec(src)['sha256']!=x['sha256']:
    candidates=list((inp.parent/'snapshots').glob('*'+src.name))+list((inp.parent/'input_snapshot').glob('*'+src.name))
    assert any(rec(q)['sha256']==x['sha256'] for q in candidates),(inp,src)
    historical.append(dict(run=inp.parent.name,original_path=str(src),executed_sha=x['sha256'],current_sha=rec(src)['sha256'],scope='Historical source-specific run; exact executed bytes retained in snapshot. Not current-path identity.'))
for p in list((R/'rtl/m5c_diagnostics').glob('*.sv'))+list((R/'tb/m5c_diagnostics').glob('*.sv'))+list((R/'scripts').glob('m5c_diag_*.py'))+list((B/'stage2_binding').glob('*.json'))+list((B/'stage2_binding').glob('*.md')):
 records[rec(p)['path']]=rec(p)
report=dict(status='PASS_SHORT_ENABLED_GATES_WITH_RETAINED_DERIVATION_FAILURES_ONLY',gates=gates,historical_source_versions=historical,scope='9 current observer positives/4 named sensitivities; real720p reader/cache/fusion/OSD/324B tests; 5 actual backend slot comparisons; asynchronous bridge; default finite five-packet mixed serializer; three transport guard/ACK sensitivities. Full system enabled smoke and finite64 running separately; no resource/physical/board PASS.',known_failures=['Initial identity mutant malformed begin/end: compile failure, repaired separate retry','Initial earlyACK mutant missing lexical separator: compile failure, repaired separate retry','Earlier coupled fixture failures retained outside these selected success scopes, never relabelled'])
(O/'HANDBACK.json').write_text(json.dumps(report,indent=2));records[rec(O/'HANDBACK.json')['path']]=rec(O/'HANDBACK.json');(O/'MANIFEST.json').write_text(json.dumps(dict(records=list(records.values())),indent=2));print(O,len(records),rec(O/'MANIFEST.json')['sha256'])
