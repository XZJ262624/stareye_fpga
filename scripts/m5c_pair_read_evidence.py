"""Read-only evidence transport verifier; optional explicit one-object extraction."""
from pathlib import Path
import argparse,json,gzip,hashlib,sys
ap=argparse.ArgumentParser();ap.add_argument('--package',type=Path,default=Path(__file__).resolve().parents[1]/'reports/m5c_pair_capture_20261016/candidate_evidence_20261017');ap.add_argument('--sha');ap.add_argument('--output',type=Path);a=ap.parse_args();C=a.package.resolve();idx=json.loads((C/'TRANSPORT_INDEX.json').read_text());unique={}
for x in idx['mappings']:
 p=(C/x['object']).resolve();assert p.is_relative_to(C/'objects') and p.suffix=='.gz';h=x['sha256'];assert len(h)==64 and all(c in '0123456789abcdef' for c in h)
 if h in unique:assert unique[h]['bytes']==x['bytes']
 unique[h]=x
if a.output:
 assert a.sha and a.sha in unique and not a.output.exists(),'EXPLICIT_NEW_OUTPUT_AND_KNOWN_SHA_REQUIRED'
 assert not a.output.resolve().is_relative_to(C),'DO_NOT_MODIFY_REVIEWED_PACKAGE'
keys=[a.sha] if a.sha else list(unique);total=0
for h in keys:
 x=unique[h];hh=hashlib.sha256();n=0
 with gzip.open(C/x['object'],'rb') as f:
  for b in iter(lambda:f.read(1048576),b''):hh.update(b);n+=len(b)
 assert hh.hexdigest()==h and n==x['bytes'],x['original_path'];total+=n
if a.output:
 with gzip.open(C/unique[a.sha]['object'],'rb') as src,a.output.open('xb') as dst:
  for b in iter(lambda:src.read(1048576),b''):dst.write(b)
print(json.dumps(dict(status='PASS_EXACT_TRANSPORT_BYTES',mappings=len(idx['mappings']),objects=len(keys),uncompressed_bytes=total,external_hash_references=len(idx['external']),wrote_output=bool(a.output))))
