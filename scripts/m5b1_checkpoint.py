"""Write a repair checkpoint without promoting incomplete evidence to PASS."""
import json,datetime
from m5b1_evidence import R,B,O,F,P,BUILD,GROUPS,SUITES,CASES,rec,load,git

def main():
 assert git('rev-parse','HEAD').decode().strip()==P and not git('diff','--cached','--name-only')
 rows=[]
 paths=[F/v/'results.json' for v in GROUPS.values()]+[F/v for v in SUITES.values()]+[O/v/'result.json' for v in CASES.values()]
 for p in paths:
  if not p.exists():rows.append(dict(path=p.relative_to(R).as_posix(),status='MISSING'));continue
  d=load(p);mismatch=[v['path'] for v in d.get('sources',[]) if not (R/v['path']).exists() or rec(R/v['path'])!=v]
  rows.append(dict(evidence=rec(p),status=d.get('status'),source_mismatches=mismatch))
 d=dict(status='IN_PROGRESS_NOT_CANDIDATE',timestamp=datetime.datetime.now().isoformat(),HEAD=P,candidate=None,evidence=rows,build=rec(BUILD/'result.json'),pending=['Complete all source-bound frozen and repair gates','Validate input/STA/bit/protection, reports and exact scope','Append candidate directly to264 and stop all writes immediately'],hardware='NOT_RUN; no Programmer/download/Flash')
 acceptance=O/'OFFLINE_ACCEPTANCE.json'
 if acceptance.exists():
  a=load(acceptance)
  if a.get('required_parent')==P and a.get('status')=='PASS_OFFLINE_PENDING_INDEPENDENT_REVIEWS_AND_HARDWARE' and all(x.get('status','').startswith('PASS') and not x.get('source_mismatches') for x in rows):
   d['status']='OFFLINE_RECEIPT_EXISTS_AWAITING_SCOPE_AND_CANDIDATE';d['acceptance']=rec(acceptance)
 (O/'DEVELOPMENT_CHECKPOINT.json').write_text(json.dumps(d,indent=2));print(d['status'])
if __name__=='__main__':main()
