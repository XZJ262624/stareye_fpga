from pathlib import Path
import json,hashlib,gzip,collections
R=Path(__file__).resolve().parents[3];O=Path(__file__).resolve().parent
D=R/'reports/m5c_diagnostics/candidate_evidence_stage2_20261015';D.mkdir(exist_ok=False)
inventory=json.loads((O/'EVIDENCE_SCOPE_INVENTORY.json').read_text());allrows=inventory['records'];bysha=collections.defaultdict(list)
for x in allrows:bysha[x['sha256']].append(x)
selected=[];excluded=[]
for x in allrows:
 s=x['path'];c=x['classification'];n=Path(s).name
 allow=c in ['REVIEW_REQUIRED_SELECTED_SOURCE_OR_EVIDENCE','VERSIONED_INPUT_OBJECT_DEDUP_CANDIDATE']
 if '/outflow/' in s and n.endswith('.rpt'):allow=True
 if n=='RUNMAP_Ti60_Demo':allow=True
 if allow:selected.append(x)
 else:excluded.append(x)
for name in [x['path'] for x in inventory['manifests']]+['reports/m5c_diagnostics/stage2_adoption_preparation_20261015/ROOT_ADOPTION_RECEIPT.json']:
 p=R/name;b=p.read_bytes();x=dict(path=name,bytes=len(b),sha256=hashlib.sha256(b).hexdigest());selected.append(x);bysha[x['sha256']].append(x)
objects={};mapping=[];gaps=[]
for x in selected:
 sha=x['sha256']
 if sha not in objects:
  found=None
  for alternative in [x]+bysha[sha]:
   p=R/alternative['path']
   if p.exists() and p.stat().st_size==x['bytes']:
    b=p.read_bytes()
    if hashlib.sha256(b).hexdigest()==sha:found=p;break
  if found is None:
   gaps.append(x);continue
  z=gzip.compress(b,compresslevel=6,mtime=0);dest=D/'objects'/sha[:2]/(sha+'.gz');dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(z)
  assert gzip.decompress(dest.read_bytes())==b
  objects[sha]=dict(path=str(dest.relative_to(R)).replace('\\','/'),bytes=len(z),sha256=hashlib.sha256(z).hexdigest(),original_bytes=len(b),original_sha256=sha,actual_source=str(found.relative_to(R)).replace('\\','/'))
 mapping.append(dict(original_path=x['path'],original_bytes=x['bytes'],original_sha256=sha,object=objects[sha]['path']))
(D/'OBJECTS.json').write_text(json.dumps(dict(status='PREPARATION_TRANSPORT_NOT_ALLOWLIST',objects=list(objects.values())),indent=2))
(D/'VERSION_MAPPING.json').write_text(json.dumps(dict(mapping=mapping),indent=2))
(D/'EXTERNAL_BOUNDARIES.json').write_text(json.dumps(dict(scope='Not transported from sealed manifests; no complete native map/trace/database reconstruction claimed',records=excluded),indent=2))
(D/'GAPS.json').write_text(json.dumps(dict(status='GAPS_PRESENT' if gaps else 'NO_SELECTED_BYTE_GAPS',records=gaps),indent=2))
(D/'SUMMARY.json').write_text(json.dumps(dict(status='PREPARATION_NOT_FINAL_CANDIDATE',mapping=len(mapping),objects=len(objects),compressed_bytes=sum(x['bytes'] for x in objects.values()),original_unique_bytes=sum(x['original_bytes'] for x in objects.values()),gaps=len(gaps),raw_report_path_versions=sum('/outflow/' in x['original_path'] and x['original_path'].endswith('.rpt') for x in mapping),source_inventory=str(O/'EVIDENCE_SCOPE_INVENTORY.json')),indent=2))
print((D/'SUMMARY.json').read_text())
