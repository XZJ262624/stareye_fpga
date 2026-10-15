from pathlib import Path
import json,hashlib,gzip
R=Path(__file__).resolve().parents[3];D=R/'reports/m5c_diagnostics/candidate_evidence_stage2_20261015'
f=R/'reports/m5c1b_fusion_integration/golden_v2/GOLDEN_FREEZE.json';a=json.loads(f.read_text());b=f.read_bytes()
records=a['sources']+a['files']+[dict(path=str(f.relative_to(R)).replace('\\','/'),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())]
old={x['original_sha256']:x for x in json.loads((D/'OBJECTS.json').read_text())['objects']};objects=[];mapping=[]
for x in records:
 b=(R/x['path']).read_bytes();sha=hashlib.sha256(b).hexdigest();assert len(b)==x['bytes'] and sha==x['sha256']
 if sha in old:o=old[sha]
 else:
  z=gzip.compress(b,compresslevel=6,mtime=0);p=D/'objects'/sha[:2]/(sha+'.gz');p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(z);assert gzip.decompress(z)==b
  o=dict(path=p.relative_to(R).as_posix(),bytes=len(z),sha256=hashlib.sha256(z).hexdigest(),original_bytes=len(b),original_sha256=sha,actual_source=x['path']);objects.append(o)
 mapping.append(dict(original_path=x['path'],original_bytes=len(b),original_sha256=sha,object=o['path']))
(D/'GOLDEN_CLOSURE.json').write_text(json.dumps(dict(scope='Actual production synthetic golden_v2 generator/import sources and complete four-file corpus; not user camera capture',objects=objects,mapping=mapping),indent=2));print(len(objects),len(mapping))
