"""Exercise the actual candidate Git gate on isolated, committed fixtures."""
from pathlib import Path
import json,subprocess,sys,tempfile,hashlib
from m5b0r_evidence_verify import verify_candidate_git
ROOT=Path(__file__).resolve().parents[1]
R=ROOT/'reports/m5b0r_ddr_admission/root_review'

def main():
 R.mkdir(parents=True,exist_ok=True);results=[]
 # Keep fixtures locally as evidence, without deleting any pre-existing data.
 base=Path(tempfile.mkdtemp(prefix='scope_git_',dir=R))
 for name,kind,expect in [('allowed_add','add',True),('allowed_delete','delete',True),('allowed_rename','rename',True),('outside_add','add',False),('outside_delete','delete',False),('outside_rename_source','rename',False),('outside_rename_destination','rename',False)]:
  repo=base/name;repo.mkdir()
  git=['git','-c','safe.directory='+repo.as_posix(),'-c','core.autocrlf=false','-c','user.name=Fixture','-c','user.email=fixture@example.invalid','-C',str(repo)]
  def run(*args):return subprocess.check_output(git+list(args),stderr=subprocess.STDOUT)
  run('init','-q')
  manifest=repo/'reports/m5b0r_ddr_admission/PROPOSED_GIT_SCOPE.json';manifest.parent.mkdir(parents=True)
  old=repo/'old name.txt';old.write_text('fixture payload\n')
  manifest.write_text(json.dumps({'files':[{'path':'old name.txt'}]}))
  run('add','--','old name.txt',manifest.relative_to(repo).as_posix());run('commit','-qm','fixture parent')
  parent=run('rev-parse','HEAD').decode().strip()
  current=['old name.txt'];deleted=[]
  if kind=='add':
   (repo/'extra.txt').write_text('additional committed file\n');run('add','--','extra.txt')
   if expect:current.append('extra.txt')
  elif kind=='delete':
   run('rm','--','old name.txt');current=[]
   if expect:deleted=['old name.txt']
  else:
   run('mv','--','old name.txt','new name.txt');current=['new name.txt'];deleted=['old name.txt']
   if name=='outside_rename_source':deleted=[]
   if name=='outside_rename_destination':current=[]
  manifest.write_text(json.dumps({'files':[{'path':p} for p in current],'deleted_paths':deleted}))
  run('add','--',manifest.relative_to(repo).as_posix());run('commit','-qm',name)
  candidate=run('rev-parse','HEAD').decode().strip()
  # A subprocess invokes precisely the production verifier's candidate gate.
  driver="import sys;sys.path.insert(0,"+repr(str(ROOT/'scripts'))+");from m5b0r_evidence_verify import verify_candidate_git;verify_candidate_git("+repr(str(repo))+","+repr(candidate)+","+repr(parent)+");print('CANDIDATE_GIT_PASS')"
  p=subprocess.run([sys.executable,'-B','-c',driver],capture_output=True)
  log=repo/'gate.log';log.write_bytes(p.stdout+p.stderr)
  text=(p.stdout+p.stderr).decode(errors='replace')
  assert (p.returncode==0)==expect,(name,text)
  if not expect:assert 'candidate changes outside scope' in text,(name,text)
  results.append(dict(case=name,expected_accept=expect,acceptance_exit_code=p.returncode,parent=parent,candidate=candidate,log=dict(path=log.relative_to(ROOT).as_posix(),bytes=log.stat().st_size,sha256=hashlib.sha256(log.read_bytes()).hexdigest())))
 (R/'SCOPE_GIT_RESULTS.json').write_text(json.dumps(dict(status='PASS_SCOPE_GIT_ACCEPTANCE',cases=results),indent=2))
 print('SCOPE_GIT_ACCEPTANCE_PASS',len(results),'actual Git candidate fixtures')

if __name__=='__main__':main()
