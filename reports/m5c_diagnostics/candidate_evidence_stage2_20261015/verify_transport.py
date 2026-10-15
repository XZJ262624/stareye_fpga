"""Read-only by default and by design: verify gzip transport and every version mapping."""
from pathlib import Path
import json,gzip,hashlib
R=Path(__file__).resolve().parents[3];D=Path(__file__).resolve().parent
objects=json.loads((D/'OBJECTS.json').read_text())['objects'];mapping=json.loads((D/'VERSION_MAPPING.json').read_text())['mapping']
bysha={};total=0
for x in objects:
 p=R/x['path'];z=p.read_bytes();assert len(z)==x['bytes'] and hashlib.sha256(z).hexdigest()==x['sha256']
 b=gzip.decompress(z);assert len(b)==x['original_bytes'] and hashlib.sha256(b).hexdigest()==x['original_sha256']
 assert x['original_sha256'] not in bysha;bysha[x['original_sha256']]=x;total+=len(b)
for x in mapping:
 o=bysha[x['original_sha256']];assert x['original_bytes']==o['original_bytes'] and x['object']==o['path']
assert json.loads((D/'GAPS.json').read_text())['records']==[]
print(json.dumps(dict(status='PASS_LOSSLESS_TRANSPORT_ONLY',objects=len(objects),mapping=len(mapping),uncompressed_unique_bytes=total,no_restore_or_other_writes=True)))
