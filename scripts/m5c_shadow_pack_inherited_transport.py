from pathlib import Path
import json,hashlib,gzip
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016';O=A/'candidate_evidence'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
proof=json.loads((A/'UNCHANGED_TRANSPORT_INHERITANCE.json').read_bytes());assert proof['status']=='PASS_EXPLICIT_UNCHANGED_TRANSPORT_ONLY_INHERITANCE'
mapping=[]
for case in proof['cases']:
 w=R/'reports/m5c_diagnostics'/case['case'];files=[p for p in w.iterdir() if p.is_file() and p.name not in ['transcript']]+list((w/'snapshots').glob('*'))
 for p in sorted(files):
  assert p.is_file() and p.suffix not in ['.bit','.bin','.wlf','.vdb','.lbf','.troutingtraces']
  x=rec(p);b=p.read_bytes();q=O/'objects'/x['sha256'][:2]/(x['sha256']+'.gz');q.parent.mkdir(parents=True,exist_ok=True)
  if not q.exists():q.write_bytes(gzip.compress(b,mtime=0))
  assert gzip.decompress(q.read_bytes())==b;mapping.append(dict(original=x,object=rec(q)))
p=O/'INHERITED_TRANSPORT_OBJECTS.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_SELECTED_HISTORICAL_TRANSPORT_BYTES_PRESERVED',mapping=mapping,proof=rec(A/'UNCHANGED_TRANSPORT_INHERITANCE.json'),generator=rec(Path(__file__)),boundary='Six historical finite transport/slot cases only, not new native executions or current shadow/observer tests. No user capture. Snapshot versions remain distinct from live current source.'),indent=2));print('HISTORICAL_TRANSPORT_OBJECTS',len(mapping),len({x['object']['path'] for x in mapping}))
