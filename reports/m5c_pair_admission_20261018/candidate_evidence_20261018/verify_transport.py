"""Read-only transport validation; does not execute embedded historical scripts."""
from pathlib import Path
import argparse,json,gzip,hashlib
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[3]);a=p.parse_args()
F=Path(__file__).resolve().parent;data=json.loads((F/'TRANSPORT_INDEX.json').read_text());seen=set();total=0
for x in data['mappings']:
 key=(x['object_path'],x['sha256'],x['bytes'])
 if key in seen:continue
 seen.add(key);path=(a.root/x['object_path']).resolve();assert path.is_relative_to(a.root.resolve())
 h=hashlib.sha256();n=0
 with gzip.open(path,'rb') as z:
  for b in iter(lambda:z.read(1048576),b''):n+=len(b);h.update(b)
 assert n==x['bytes'] and h.hexdigest()==x['sha256'],x['original_path'];total+=n
print(json.dumps(dict(status='PASS_READ_ONLY_TRANSPORT',mappings=len(data['mappings']),objects=len(seen),original_bytes=total,external_references=len(data['external_references']))))
