"""Read-only final diagnostic evidence verifier; never builds or touches hardware/Git index."""
from pathlib import Path
import json,hashlib,re,subprocess,sys,argparse
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'reports/m5b0r_ddr_admission'
def check(v,p=None):
 p=Path(p) if p else ROOT/v['path']
 assert p.stat().st_size==v['bytes'],('size',p)
 assert hashlib.sha256(p.read_bytes()).hexdigest()==v['sha256'],('hash',p)
def main():
 parser=argparse.ArgumentParser()
 parser.add_argument('--candidate',help='Post-commit verification: exact candidate, must equal HEAD')
 parser.add_argument('--parent',required=True,help='Expected sole parent, or expected HEAD before commit')
 args=parser.parse_args()
 b=json.loads((R/'EVIDENCE_BINDING.json').read_text())
 assert b['status']=='PASS_FINAL_DIAGNOSTIC_BINDING' and b['gate']=='NO_GO'
 for key in ('build_inputs','implementation_outputs','sta_reports','offline_verification'):
  for v in b[key]:check(v)
 check(b['bitstream']);check(b['final_sta_binding']);check(b['warning_classification'])
 audit=json.loads((R/'final_audit/binding.json').read_text())
 assert audit['original_unchanged'] and audit['exit_code']==0 and len(audit['reports'])==112
 for v in audit['reports']:check(v,R/'final_audit'/v['path'])
 log=(R/'final_audit/audit.log').read_text();assert log.count('VERIFIED_ASYNC_SR')==20
 for mode,count in [('diagnostic',54),('arbiter',5),('monitor',1)]:
  result=json.loads((R/'sim'/(mode+'_results.json')).read_text());assert len(result['cases'])==count
  for v in result['sources']:check(v)
  for v in result['cases']:check(v['log'])
 replay=json.loads((R/'root_review/REPLAY_RESULTS.json').read_text());assert replay['diagnostic_cases']==54
 for v in replay['sources']:check(v)
 neg=json.loads((R/'root_review/NEGATIVE_RESULTS.json').read_text());assert len(neg['cases'])==9
 for v in neg['cases']:
  assert v.get('acceptance_exit_code',v.get('exit_code'))!=0
  for k in ('log','driver_log'):
   if k in v:check(v[k])
 assert not re.search(r'\*\* (Error|Fatal):',(R/'root_review/arbiter_independent_seed.log').read_text())
 assert 'M5B0R_ARBITER_PASS' in (R/'root_review/arbiter_independent_seed.log').read_text()
 m=json.loads((R/'TIMING_METRICS.json').read_text());assert m['setup_min_ns']>=0 and m['hold_min_ns']>=0
 for n in ['no_clock','unconstrained_internal','multiple_clock']:assert m[n]==0
 git=['git','-c','safe.directory='+ROOT.as_posix(),'-C',str(ROOT)]
 assert not subprocess.check_output(git+['diff','--cached','--name-only'])
 head=subprocess.check_output(git+['rev-parse','HEAD']).decode().strip()
 if args.candidate:
  assert head==args.candidate
  assert subprocess.check_output(git+['rev-list','--parents','-n','1',head]).decode().split()==[head,args.parent]
  assert not subprocess.check_output(git+['diff','--name-only']), 'tracked workspace differs from candidate'
  scope=json.loads((R/'PROPOSED_GIT_SCOPE.json').read_text())
  for path in [v['path'] for v in scope['files']]+['reports/m5b0r_ddr_admission/PROPOSED_GIT_SCOPE.json']:
   assert subprocess.check_output(git+['show',head+':'+path])==(ROOT/path).read_bytes(),path
 else:
  assert head==args.parent

 assert subprocess.run(git+['check-ignore','-q',b['bitstream']['path']]).returncode==0
 assert not subprocess.check_output(git+['ls-files','--',b['bitstream']['path']])
 print('M5B0R_FINAL_EVIDENCE_PASS; gate NO_GO; hardware not validated; index empty')
if __name__=='__main__':main()
