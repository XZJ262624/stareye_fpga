from pathlib import Path
import json,hashlib
A=Path(__file__).resolve().parent;R=A.parents[3];src=A/'full_inventory/ALL_SEQUENTIAL_INPUTS.json';a=json.loads(src.read_text());groups={};rows=[]
for x in a['pins']:
 s=json.dumps(x['sources'],separators=(',',':'));k=hashlib.sha256(s.encode()).hexdigest()
 if k in groups:assert groups[k]==x['sources']
 else:groups[k]=x['sources']
 rows.append({**{n:v for n,v in x.items() if n!='sources'},'sources_id':k})
out=dict(map_sha256=a['map_sha256'],raw=dict(path=src.relative_to(R).as_posix(),bytes=src.stat().st_size,sha256=hashlib.sha256(src.read_bytes()).hexdigest()),generator=dict(path=Path(__file__).relative_to(R).as_posix(),sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),pins=rows,source_sets=groups,counts=a['counts'],scope='Lossless current structural inventory, not timing classification PASS. Every original source vector preserved once and exactly recoverable; native physical endpoint/timing reconciliation is separate.')
p=A/'CURRENT_INVENTORY_COMPACT.json';assert not p.exists();p.write_text(json.dumps(out,separators=(',',':')));b=json.loads(p.read_text());restored=[{**{n:v for n,v in x.items() if n!='sources_id'},'sources':b['source_sets'][x['sources_id']]} for x in b['pins']];assert restored==a['pins'];(A/'CURRENT_INVENTORY_COMPACT_RECEIPT.json').write_text(json.dumps(dict(status='PASS_LOSSLESS_STRUCTURAL_DERIVATION_NOT_TIMING',pins=len(rows),unique_source_sets=len(groups),original=out['raw'],compact=dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()),exact_reconstruction=True),indent=2));print(len(rows),len(groups),src.stat().st_size,p.stat().st_size)
