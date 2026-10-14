"""Verify deduplicated evidence and optionally restore it into a NEW isolated directory.
No test/tool invocation. Originals/manifests are never rewritten.
Usage: python -B verify_and_restore.py [--restore NEW_ABSOLUTE_DIRECTORY]
"""
from pathlib import Path
import argparse,json,hashlib,shutil
F=Path(__file__).resolve().parent;R=F.parents[2]
p=argparse.ArgumentParser();p.add_argument('--restore');a=p.parse_args()
m=json.loads((F/'SOURCE_PACKAGE_MAPPING.json').read_text());cache={}
def verify(x):
 q=R/x['path'];assert q.resolve().is_relative_to(R)
 if x['path'] not in cache:cache[x['path']]=(q.stat().st_size,hashlib.sha256(q.read_bytes()).hexdigest())
 assert cache[x['path']]==(x['bytes'],x['sha256']);return q
for x in m['records']:verify(x['package']);assert x['original']['sha256']==x['package']['sha256']
for x in m['direct']:verify(x)
if a.restore:
 d=Path(a.restore).resolve();assert d.is_absolute() and not d.exists() and d!=R;d.mkdir(parents=True)
 for x in m['records']:
  q=d/x['original']['path'];assert q.resolve().is_relative_to(d);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(verify(x['package']),q)
 for x in m['direct']:
  q=d/x['path'];assert q.resolve().is_relative_to(d);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(verify(x),q)
 print('RESTORED exact bytes, NOT portable runner validation. Original F:/ absolute commands need explicit rebasing in a future isolated runner. No execution performed.')
compact=json.loads((F/'COMPLETE_ENDPOINTS_COMPACT.json').read_text());s=compact['strings'];cols=compact['columns'];ends=set()
for row in compact['rows']:
 x={k:s[v] for k,v in zip(cols[:-1],row[:-1])};x['sources']=[[s[v] for v in source] for source in compact['source_sets'][row[-1]]];assert x['endpoint'] not in ends;ends.add(x['endpoint'])
assert len(ends)==61480
print('VERIFIED',len(m['records']),'mapped original paths;',len(cache),'unique packaged/direct objects; 61480 complete endpoints; external dependencies',len(m['external']))
