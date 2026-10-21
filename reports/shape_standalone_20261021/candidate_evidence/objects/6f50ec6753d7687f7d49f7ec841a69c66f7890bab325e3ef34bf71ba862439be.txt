"""Read original-path evidence through byte-exact content-addressed objects.
No import or execution of reviewed sources. Default operation is read-only.
"""
from pathlib import Path
import argparse,json,hashlib,sys
R=Path(__file__).resolve().parents[2];D=R/'reports/shape_standalone_20261021/candidate_evidence'
p=argparse.ArgumentParser();p.add_argument('--path',required=True);opt=p.parse_args();rows=[]
for name in ['SOURCE_TO_OBJECT_INDEX.json','SUPPLEMENTAL_OBJECT_INDEX.json']:
 q=D/name
 if q.exists():rows+=json.loads(q.read_text())['records']
found=[x for x in rows if x['source']['path']==opt.path];assert found,'No readable object supplied for requested original path'
assert len({x['source']['sha256']for x in found})==1,'Multiple historical versions; inspect index explicitly'
x=found[0];q=R/x['object']['path'];b=q.read_bytes();assert len(b)==x['source']['bytes']and hashlib.sha256(b).hexdigest()==x['source']['sha256'];sys.stdout.buffer.write(b)
