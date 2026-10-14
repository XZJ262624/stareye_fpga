"""Verify exact versioned evidence. Optional --manifest ORIGINAL_PATH --restore NEW_DIR.
Restore is byte reconstruction only, never tool execution or automatic path rebasing.
"""
from pathlib import Path
import argparse,json,hashlib,gzip,shutil
E=Path(__file__).resolve().parent;F=E.parent;R=F.parents[2];m=json.loads((E/'SOURCE_PACKAGE_MAPPING_V2.json').read_text());cache={}
def verify(x):
 p=(R/x['path']).resolve();assert p.is_relative_to(R)
 if p not in cache:
  b=p.read_bytes();cache[p]=(len(b),hashlib.sha256(b).hexdigest())
 assert cache[p]==(x['bytes'],x['sha256']),x;return p
for x in m['records']:verify(x['package']);assert (x['original']['sha256'],x['original']['bytes'])==(x['package']['sha256'],x['package']['bytes'])
for x in m['direct']:verify(x)
prefix=F.relative_to(R).as_posix()+'/resource_area_bound/'
def original(name):
 xs=[x for x in m['records'] if x['original']['path']==prefix+name];assert len(xs)==1;return verify(xs[0]['package'])
g=json.loads(original('CURRENT_INVENTORY_GZIP_RECEIPT.json').read_text());b=gzip.decompress(original('CURRENT_INVENTORY_COMPACT.json.gz').read_bytes());assert len(b)==g['uncompressed_bytes'] and hashlib.sha256(b).hexdigest()==g['uncompressed_sha256'];c=json.loads(b);assert len(c['pins'])==61048 and len({x['endpoint'] for x in c['pins']})==61048
for k,vector in c['source_sets'].items():assert hashlib.sha256(json.dumps(vector,separators=(',',':')).encode()).hexdigest()==k
for p in c['pins']:assert p['sources_id'] in c['source_sets']
ap=argparse.ArgumentParser();ap.add_argument('--manifest');ap.add_argument('--restore');args=ap.parse_args();assert bool(args.manifest)==bool(args.restore)
if args.restore:
 ref=args.manifest.replace('\\','/');matches=[x for x in m['records'] if x['original']['path']==ref];assert len(matches)==1,'Choose an unambiguous versioned primary manifest'
 rows=json.loads(verify(matches[0]['package']).read_text())['records'];bykey={(x['original']['path'],x['original']['sha256']):x for x in m['records']};chosen=[];destinations={}
 for x in rows:
  key=(x['path'],x['sha256']);assert key in bykey,('Explicit external required, cannot restore complete scope',key);pkg=bykey[key]['package'];verify(pkg)
  assert x['path'] not in destinations or destinations[x['path']]==x['sha256'],'Conflicting versions need separate restores';destinations[x['path']]=x['sha256'];chosen.append((x,pkg))
 d=Path(args.restore).resolve();assert d.is_absolute() and not d.exists() and not d.is_relative_to(R);d.mkdir(parents=True)
 for x,pkg in chosen:
  q=d/x['path'];assert q.resolve().is_relative_to(d);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(verify(pkg),q)
 print('RESTORED_SCOPE_BYTES_ONLY',len(chosen),'No native execution; absolute command paths require explicit isolated rebase.')
print('VERIFIED_VERSIONED_MAPPING',len(m['records']),'UNIQUE_OBJECTS',len(cache),'COMPLETE_STRUCTURAL_PINS',len(c['pins']),'EXTERNAL',len(m['external']))
