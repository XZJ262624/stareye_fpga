"""Default read-only validation; never imports, executes, extracts, or edits evidence."""
from pathlib import Path
import argparse,json,hashlib,gzip
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[3]);a=p.parse_args();R=a.root.resolve();F=Path(__file__).resolve().parent
d=json.loads((F/'TRANSPORT_INDEX.json').read_text());seen=set();total=0
def check(path,n,sha,compressed=False):
 path=(R/path).resolve();assert path.is_relative_to(R),path
 h=hashlib.sha256();count=0
 with (gzip.open(path,'rb') if compressed else path.open('rb')) as z:
  for b in iter(lambda:z.read(1048576),b''):count+=len(b);h.update(b)
 assert (count,h.hexdigest())==(n,sha),path
for x in d['mappings']:
 key=(x['object_path'],x['sha256'],x['bytes'])
 if key in seen:continue
 seen.add(key);check(key[0],key[2],key[1],True);total+=key[2]
direct=json.loads((F/'direct_review/INDEX.json').read_text())['records']
for x in direct:
 z=x['copy'];check(z['path'],z['bytes'],z['sha256'])
scope=F/'CANDIDATE_SCOPE.json'
if not scope.exists():scope=F/'PROPOSED_SCOPE.json'
if scope.exists():
 for x in json.loads(scope.read_text())['records']:check(x['path'],x['bytes'],x['sha256'])
print(json.dumps(dict(status='PASS_READ_ONLY_TRANSPORT',mappings=len(d['mappings']),objects=len(seen),original_bytes=total,direct=len(direct),external_references=len(d['external_references']),hardware_or_simulator_executed=False)))
