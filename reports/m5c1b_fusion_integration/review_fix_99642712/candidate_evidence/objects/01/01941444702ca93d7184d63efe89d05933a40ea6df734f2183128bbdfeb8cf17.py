from pathlib import Path
import json,hashlib
B=Path(__file__).resolve().parent;R=B.parents[3];O=R/'reports/m5c1b_fusion_integration/fresh_i3_build_20261014';p=O/'run_queries.py';s=p.read_text();changes=[]
def change(a,b):
 global s
 assert a in s,a;s=s.replace(a,b);changes.append(dict(old=a,new=b))
change('R=F.parents[2]','R=F.parents[3]')
change("F/'QUERY_DERIVATION.json'","F/sys.argv[1]")
change("previous=json.loads((F/'route/RESULT.json').read_text());assert previous['status']=='PASS_STAGE' and previous['resources']['pass'];verify_previous(previous)","route=json.loads((F/'route/RESULT.json').read_text());assert route['status']=='PASS_STAGE' and route['resources']['pass'];previous=json.loads((F/sys.argv[2]/'RESULT.json').read_text());assert previous['status']=='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION';verify_previous(previous)")
q=B/'run_query_followon.py';q.write_text(s)
(B/'FOLLOWON_RUNNER_DERIVATION.json').write_text(json.dumps(dict(parent_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),current_sha256=hashlib.sha256(q.read_bytes()).hexdigest(),changes=changes,scope='One immutable per-stage plan with prior completed query archive; fresh route resource gate retained; actual I3,1200s,source/db guards and pre/post full archive unchanged.'),indent=2))
