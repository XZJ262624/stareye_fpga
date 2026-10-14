from pathlib import Path
import json,hashlib,difflib
F=Path(__file__).resolve().parent
p=F/'audit_current_timing_v2.py';old=p.read_text()
new=old.replace("assert name=='GLOBAL_D_COVERAGE_CURRENT.json' and json.loads(p.read_text())==a;return","assert name in ['GLOBAL_D_COVERAGE_CURRENT.json','CONTROL_COVERAGE_CURRENT.json'] and json.loads(p.read_text())==a;return")
new=new.replace("assert log.count(start)==1 and log.count(end)==1;ex=log.split(start,1)[1].split(end,1)[0]","assert log.splitlines().count(start)==1 and log.splitlines().count(end)==1;ex=log.split(start+'\\n',1)[1].split(end+'\\n',1)[0]")
assert new!=old
q=F/'audit_current_timing_v3.py';assert not q.exists();q.write_text(new)
def rec(x):
 b=x.read_bytes();return dict(path=x.name,bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
r=F/'AUDIT_V3_DERIVATION.json';assert not r.exists();r.write_text(json.dumps(dict(parent=rec(p),derived=rec(q),prior_failure='V2 literal substring count for report marker 2 also counted markers 20..29. No missing native output; use exact full-line marker occurrence and newline-delimited slicing.',diff=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True))),scope='RAM36 override unchanged; all timing gates unchanged; existing global/control evidence JSON equality checked without rewriting.'),indent=2))
