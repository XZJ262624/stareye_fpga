from pathlib import Path
import hashlib,json
O=Path(__file__).resolve().parent;F=O.parent;A=F/'resource_area_bound';R=F.parents[2]
def rec(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=h.hexdigest())
d={x['path']:x for x in json.loads((F/'work_management_2337/MANAGEMENT_DELTA.json').read_text())['records']};rows=[]
for x in json.loads((A/'PHYSICAL_HANDBACK_MANIFEST.json').read_text())['records']:
 z=rec(R/x['path'])
 if x['path'] in d:assert x['sha256']==d[x['path']]['before_sha256'] and z['sha256']==d[x['path']]['after_sha256']
 else:assert z==x,x['path']
 rows.append(z)
for x in json.loads((F/'regression/SOURCE101.json').read_text())['records']:assert rec(R/x['path'])==x
p=O/'QUALIFIED_INPUTS_PRECONVERSION.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_QUALIFIED_CURRENT_WITH_EXACT_MANAGEMENT2337_DELTA',records=rows,management_delta=rec(F/'work_management_2337/MANAGEMENT_DELTA.json'),historical_physical_manifest=rec(A/'PHYSICAL_HANDBACK_MANIFEST.json'),source101_unchanged=True),indent=2));print('QUALIFIED_BOUND',len(rows))
