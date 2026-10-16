from pathlib import Path
import json,hashlib,gzip
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016';O=A/'candidate_evidence'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
pack=json.loads((O/'STABLE_OBJECTS_V2.json').read_bytes());byhash={x['original']['sha256']:x['object'] for x in pack['mapping']};rows=[];gaps=[];extra={}
def visit(x):
 if isinstance(x,dict):
  if {'path','bytes','sha256'}<=set(x):yield x
  else:
   for v in x.values():yield from visit(v)
 elif isinstance(x,list):
  for v in x:yield from visit(v)
for m in pack['mapping']:
 n=Path(m['original']['path']).name
 if n not in ['INPUTS.json','RESULT.json','SNAPSHOTS.json']:continue
 z=json.loads(gzip.decompress((R/m['object']['path']).read_bytes()))
 if n=='RESULT.json':z=z.get('inputs',[])
 for x in visit(z):
  sha=x['sha256'];obj=byhash.get(sha);p=Path(x['path']);p=p if p.is_absolute() else R/p
  if obj is None:
   reason=None
   try:
    rel=p.resolve().relative_to(R).as_posix()
    assert not any(s in '/'+rel.lower()+'/' for s in ['/captures/','/hardware_analysis','/hardware_diagnostic/','/.git/','/m3/']), 'EXCLUDED_SCOPE'
    b=p.read_bytes();assert len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==sha,'LIVE_VERSION_DIFFERS_WITH_NO_SNAPSHOT'
    assert len(b)<30_000_000,'EXTERNAL_LARGE_DEPENDENCY'
    q=O/'objects'/sha[:2]/(sha+'.gz');q.parent.mkdir(parents=True,exist_ok=True)
    if not q.exists():q.write_bytes(gzip.compress(b,compresslevel=9,mtime=0))
    assert gzip.decompress(q.read_bytes())==b;obj=rec(q);byhash[sha]=obj;extra[sha]=dict(original=rec(p),object=obj)
   except (OSError,ValueError,AssertionError) as e:reason=str(e)
   if reason:gaps.append(dict(input=x,referenced_by=m['original']['path'],reason=reason));continue
  b=gzip.decompress((R/obj['path']).read_bytes());assert len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==sha
  rows.append(dict(declared_input=x,referenced_by=m['original']['path'],object=obj))
out=dict(status='PASS_SHORT_DECLARED_INPUT_CONTENT_CLOSURE' if not gaps else 'DECLARED_INPUT_GAPS',records=rows,extra_objects=list(extra.values()),gaps=gaps,source_pack=rec(O/'STABLE_OBJECTS_V2.json'),generator=rec(Path(__file__)),boundary='Exact declared native inputs and source snapshots only. Actual runtime commands, imports/includes/golden and final system/physical proof closure require final review; no broader reproducibility claim from JSON count alone.')
p=O/'SHORT_INPUT_CLOSURE.json';assert not p.exists();p.write_text(json.dumps(out,indent=2));print(out['status'],len(rows),'EXTRA',len(extra),'GAPS',len(gaps));print(gaps[:5])
