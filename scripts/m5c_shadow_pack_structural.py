from pathlib import Path
import gzip,hashlib,json,shutil
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016';P=A/'physical_133645';O=A/'candidate_evidence';rows=[]
def streamrec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=n,sha256=h.hexdigest())
for rel in ['full_inventory/PHYSICAL_SEQUENTIAL_INPUTS.json','mapped_inventory/SEQUENTIAL_BOUNDARIES.json','diag_inventory_v2/DIAGNOSTIC_INVENTORY.json','ROW_SHADOW_CONTROL_TARGETS.json']:
 p=P/rel;x=streamrec(p);q=O/'objects'/x['sha256'][:2]/(x['sha256']+'.gz');q.parent.mkdir(parents=True,exist_ok=True)
 if not q.exists():
  with p.open('rb') as src,q.open('wb') as dest,gzip.GzipFile(filename='',mode='wb',fileobj=dest,compresslevel=6,mtime=0) as gz:shutil.copyfileobj(src,gz,1048576)
 h=hashlib.sha256();n=0
 with gzip.open(q,'rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 assert n==x['bytes'] and h.hexdigest()==x['sha256']
 assert streamrec(p)==x
 rows.append(dict(original=x,object=streamrec(q),decoded_bytes=n,decoded_sha256=h.hexdigest(),byte_exact=True))
out=O/'STRUCTURAL_TRANSPORT.json';assert not out.exists()
out.write_text(json.dumps(dict(status='PASS_STREAMED_LOSSLESS_STRUCTURE_TRANSPORT',records=rows,generator=streamrec(Path(__file__)),boundary='Byte-exact transport of the complete named structural inventories, preserving all objects and fields. Not complete mapped logic/LUT masks, vendor models, routed databases or timing qualification. Those remain separately bound evidence/external limits.'),indent=2))
print('STREAM_STRUCTURAL_TRANSPORT',[(x['original']['bytes'],x['object']['bytes']) for x in rows])
