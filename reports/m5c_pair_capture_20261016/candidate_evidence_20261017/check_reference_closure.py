# PREPARATION GENERATOR ONLY: writes this local preparation package. Do not execute in a fixed review snapshot. Use scripts/m5c_pair_read_evidence.py for read-only validation.
from pathlib import Path
import json,hashlib,gzip,shutil
R=Path.cwd();C=R/'reports/m5c_pair_capture_20261016/candidate_evidence_20261017';idx=json.loads((C/'TRANSPORT_INDEX.json').read_text());by={x['sha256']:x for x in idx['mappings']};external_sha={x['original']['sha256'] for x in idx['external']};todo=[];seen=set();resolved=[];external=[];missing=[]
def walk(v):
 if isinstance(v,dict):
  if isinstance(v.get('path'),str) and isinstance(v.get('sha256'),str) and len(v['sha256'])==64:yield v
  for x in v.values():yield from walk(x)
 elif isinstance(v,list):
  for x in v:yield from walk(x)
for x in list(by.values()):
 if x['original_path'].endswith('.json') and x['bytes']<8000000:
  p=R/x['source']
  try:todo.extend(walk(json.loads(p.read_text(encoding='utf-8-sig'))))
  except (ValueError,UnicodeError):pass
for r in todo:
 n=r['path'].replace('\\','/');h=r['sha256'];key=(n,h)
 if key in seen:continue
 seen.add(key)
 if h in by:resolved.append(dict(path=n,sha256=h,object=by[h]['object']));continue
 if h in external_sha:external.append(dict(path=n,sha256=h,reason='explicit native external boundary'));continue
 p=Path(n);p=p if p.is_absolute() else R/p
 if not p.is_relative_to(R) or any(k in n.lower() for k in ['hardware_analysis','file_tim','/work_check/','/tools/','/efinity/2025','/modelsim','/work_pnr/','troutingtraces']) or p.suffix.lower() in ['.bit','.vdb','.lbf','.wlf','.zip','.dll','.exe'] or n.endswith('.map.v'):
  external.append(dict(path=n,sha256=h,reason='tool/native/archive or excluded scope; hash reference only'));continue
 if p.is_file():
  b=p.read_bytes()
  if hashlib.sha256(b).hexdigest()==h:
   o=C/'objects'/h[:2]/(h+'.gz');o.parent.mkdir(parents=True,exist_ok=True)
   with o.open('wb') as f,gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0,compresslevel=6) as z:z.write(b)
   x=dict(scope='closure/explicit_hash_reference',original_path=n,source=p.relative_to(R).as_posix(),bytes=len(b),sha256=h,object=o.relative_to(C).as_posix());idx['mappings'].append(x);by[h]=x;resolved.append(dict(path=n,sha256=h,object=x['object']));continue
 missing.append(dict(path=n,sha256=h,reason='historical or absent original bytes not yet resolved'))
(C/'TRANSPORT_INDEX.json').write_text(json.dumps(idx,indent=2));(C/'REFERENCE_CLOSURE_AUDIT.json').write_text(json.dumps(dict(status='AUDIT_PENDING_GAP_DISPOSITION',resolved=resolved,external=external,missing=missing),indent=2));print('resolved',len(resolved),'external',len(external),'missing',len(missing));print('\n'.join(x['path'] for x in missing[:30]))
