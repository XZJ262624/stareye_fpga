"""Record an honest resumable checkpoint; never overwrite historical evidence."""
from pathlib import Path
import json,hashlib,subprocess,datetime
R=Path(__file__).resolve().parents[1];O=R/'reports/m5b1_global_canny_i3'
P='c0102ee1c9a0a8aa802c398755d4a7b3139c7ffd'
def git(*a):return subprocess.check_output(['git','-c','safe.directory='+R.as_posix(),*a],cwd=R).decode().strip()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 baseline=json.loads((O/'BASELINE_PROTECTION.json').read_text());allowed={'.gitattributes','.gitignore'}
 changed=[r['path'] for r in baseline['tracked'] if r['path'] not in allowed and (not (R/r['path']).exists() or rec(R/r['path'])!=r)]
 missing=[p for p in baseline['untracked'] if not (R/p).exists()]
 assert git('rev-parse','HEAD')==P and not git('diff','--cached','--name-only')
 assert not changed and not missing,(changed,missing)
 tests={}
 for name in ('global_final','system','system_faults','directed','mutations','qos_negative','tap'):
  p=O/name/'results.json'
  if p.exists():
   v=json.loads(p.read_text());mismatch=[r['path'] for r in v.get('sources',[]) if not (R/r['path']).exists() or rec(R/r['path'])!=r]
   tests[name]=dict(status=v.get('status'),source_mismatches=mismatch,evidence=rec(p))
 builds=[]
 for d in sorted(O.glob('build_*')):
  p=d/'result.json'
  builds.append(dict(directory=d.name,exit_code=json.loads(p.read_text())['exit_code'] if p.exists() else None))
 result=dict(status='IN_PROGRESS_NOT_CANDIDATE',timestamp=datetime.datetime.now().isoformat(),branch=git('branch','--show-current'),HEAD=P,candidate=None,protected_tracked_checked=len(baseline['tracked']),protected_changes=changed,historical_untracked_checked=len(baseline['untracked']),historical_untracked_missing=missing,
 historical_resource_failure='blocked_build_evidence preserved; 57635 XLR failed; later RAM design below 48640; final build/STA required',builds=builds,tests=tests,
 pending=['Complete final-source full build and all I3 STA/physical CDC audits','Complete active source-bound algorithm/system/fault/mutation regressions','Final source/input/bit and protected-copy binding, warnings/scope/docs, candidate only after all gates'],
 resume_commands=['E:/ANACONDA/python.exe scripts/m5b1_checkpoint.py','E:/ANACONDA/python.exe scripts/m5b1_constraints.py (after map; SDC must remain byte-identical to final build)','E:/ANACONDA/python.exe scripts/m5b1_sta.py (after full build)','E:/ANACONDA/python.exe scripts/m5b1_global_sim.py','E:/ANACONDA/python.exe scripts/m5b1_system_sim.py','E:/ANACONDA/python.exe scripts/m5b1_system_faults.py','E:/ANACONDA/python.exe scripts/m5b1_mutations.py'],hardware='NOT_RUN; fail-stop/no synthetic ACK; cold reconfiguration required after fault')
 acceptance=O/'OFFLINE_ACCEPTANCE.json'
 if acceptance.exists() and len(tests)==7 and all(not v['source_mismatches'] for v in tests.values()):
  result['status']='OFFLINE_PASSED_AWAITING_CANDIDATE';result['acceptance']=rec(acceptance)
  result['pending']=['Exact scope and staged blob validation','Candidate direct parent c0102ee1, then immediate writer stop; Work independent reviews and hardware remain pending']
 (O/'DEVELOPMENT_CHECKPOINT.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
if __name__=='__main__':main()
