"""Read-only final diagnostic evidence verifier; never builds or touches hardware/Git index."""
from pathlib import Path
import json,hashlib,re,subprocess,sys,argparse
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'reports/m5b0r_ddr_admission'
def check(v,p=None):
 p=Path(p) if p else ROOT/v['path']
 assert p.stat().st_size==v['bytes'],('size',p)
 assert hashlib.sha256(p.read_bytes()).hexdigest()==v['sha256'],('hash',p)

def verify_candidate_git(root,candidate,parent):
 """Actual candidate gate, also exercised by isolated real Git repositories."""
 root=Path(root);git=['git','-c','safe.directory='+root.as_posix(),'-C',str(root)]
 def out(*args):return subprocess.check_output(git+list(args))
 assert not out('diff','--cached','--name-only'), 'index not empty'
 assert out('rev-parse','HEAD').decode().strip()==candidate, 'candidate is not HEAD'
 assert out('rev-list','--parents','-n','1',candidate).decode().split()==[candidate,parent], 'candidate parent mismatch'
 assert not out('diff','--name-only'), 'tracked workspace differs from candidate'
 manifest='reports/m5b0r_ddr_admission/PROPOSED_GIT_SCOPE.json'
 scope=json.loads((root/manifest).read_text())
 current=[v['path'] for v in scope['files']]+[manifest]
 deleted=scope.get('deleted_paths',[])
 assert len(set(current+deleted))==len(current+deleted), 'duplicate scope path'
 # Disable rename collapsing: both the removed source and added destination
 # must be allowed. NUL separators preserve spaces, tabs and newlines in paths.
 changed=set(out('diff','--no-renames','--name-only','-z',parent,candidate,'--').decode('utf-8').rstrip('\0').split('\0'))-{''}
 outside=changed-set(current+deleted)
 assert not outside, ('candidate changes outside scope',sorted(outside))
 removed=set(out('diff','--no-renames','--diff-filter=D','--name-only','-z',parent,candidate,'--').decode('utf-8').rstrip('\0').split('\0'))-{''}
 assert removed==set(deleted), ('deleted_paths mismatch',sorted(removed),deleted)
 for path in current:
  assert out('show',candidate+':'+path)==(root/path).read_bytes(), ('candidate blob differs',path)
 for path in deleted:
  assert not (root/path).exists(), ('deleted path still in workspace',path)
 return sorted(changed)
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
 neg=json.loads((R/'root_review/NEGATIVE_RESULTS.json').read_text());assert len(neg['cases'])==13
 for v in neg['cases']:
  assert v.get('acceptance_exit_code',v.get('exit_code'))!=0
  for k in ('log','driver_log'):
   if k in v:check(v[k])
 scope_tests=json.loads((R/'root_review/SCOPE_GIT_RESULTS.json').read_text())
 assert scope_tests['status']=='PASS_SCOPE_GIT_ACCEPTANCE'
 assert {v['case'] for v in scope_tests['cases']}=={'allowed_add','allowed_delete','allowed_rename','outside_add','outside_delete','outside_rename_source','outside_rename_destination'}
 for v in scope_tests['cases']:
  assert (v['acceptance_exit_code']==0)==v['expected_accept']
  check(v['log'])
 assert not re.search(r'\*\* (Error|Fatal):',(R/'root_review/arbiter_independent_seed.log').read_text())
 assert 'M5B0R_ARBITER_PASS' in (R/'root_review/arbiter_independent_seed.log').read_text()
 m=json.loads((R/'TIMING_METRICS.json').read_text());assert m['setup_min_ns']>=0 and m['hold_min_ns']>=0
 for n in ['no_clock','unconstrained_internal','multiple_clock']:assert m[n]==0
 git=['git','-c','safe.directory='+ROOT.as_posix(),'-C',str(ROOT)]
 assert not subprocess.check_output(git+['diff','--cached','--name-only'])
 head=subprocess.check_output(git+['rev-parse','HEAD']).decode().strip()
 if args.candidate:
  verify_candidate_git(ROOT,args.candidate,args.parent)
 else:
  assert head==args.parent

 assert subprocess.run(git+['check-ignore','-q',b['bitstream']['path']]).returncode==0
 assert not subprocess.check_output(git+['ls-files','--',b['bitstream']['path']])
 print('M5B0R_FINAL_EVIDENCE_PASS; gate NO_GO; hardware not validated; index empty')
if __name__=='__main__':main()
