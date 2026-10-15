"""Print one transported text version; never overwrite original or restored paths."""
from pathlib import Path
import argparse,json,gzip,hashlib,sys
R=Path(__file__).resolve().parents[3];D=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('original_path');p.add_argument('--sha256');args=p.parse_args()
rows=json.loads((D/'VERSION_MAPPING.json').read_text())['mapping']+json.loads((D/'GOLDEN_CLOSURE.json').read_text())['mapping']
name=args.original_path.replace('\\','/');matches={x['original_sha256']:x for x in rows if x['original_path'].replace('\\','/')==name and (args.sha256 is None or x['original_sha256']==args.sha256)}
if len(matches)!=1:p.error('Expected one version; pass --sha256 from mapping. Available: '+','.join(matches))
x=next(iter(matches.values()));b=gzip.decompress((R/x['object']).read_bytes());assert len(b)==x['original_bytes'] and hashlib.sha256(b).hexdigest()==x['original_sha256']
try:text=b.decode('utf-8-sig')
except UnicodeDecodeError:p.error('Binary evidence: use gzip and the exact object mapping for independent read-only analysis.')
sys.stdout.write(text)
