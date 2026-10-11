"""Exercise fixed-candidate scope checks with actual isolated local Git histories.

Never changes the project repository/index. Owned fixtures remain under work.
"""
from pathlib import Path
import subprocess,json,hashlib,datetime
import m5b1_scope as checker
from m5b1_evidence import R,O,F,rec

def main():
 scratch=O/'work'/('scope_git_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));scratch.mkdir(parents=True)
 rows=[]
 for variant in ('positive','extra_file','missing_path','wrong_blob','dirty_index'):
  root=scratch/variant;root.mkdir();a='docs/DECISIONS.md';m='reports/m5b1_global_canny_i3/review_fix_264962e0/PROPOSED_GIT_SCOPE.json'
  def git(*args):return subprocess.check_output(['git','-c','safe.directory='+root.as_posix(),'-c','user.name=Isolated scope test','-c','user.email=offline@example.invalid',*args],cwd=root,stderr=subprocess.PIPE)
  git('init','-b','codex/scope-fixture');(root/a).parent.mkdir(parents=True);(root/m).parent.mkdir(parents=True)
  git('config','core.autocrlf','false')
  mixed=b'# retained mixed rule\r\n# second line\n';(root/'.gitattributes').write_bytes(mixed)
  (root/a).write_bytes(b'baseline\r\n');(root/m).write_text('{}');git('add','--',a,m,'.gitattributes');git('commit','-m','Isolated baseline');parent=git('rev-parse','HEAD').decode().strip()
  git('config','core.autocrlf','true')
  rule_oid=git('rev-parse',parent+':.gitattributes').decode().strip()
  assert git('hash-object','--path=.gitattributes','.gitattributes').decode().strip()!=rule_oid
  rule=dict(path='.gitattributes',bytes=len(mixed),sha256=hashlib.sha256(mixed).hexdigest(),blob_oid=rule_oid)
  (root/a).write_bytes(b'candidate\r\n');data=(root/a).read_bytes()
  row=dict(path=a,bytes=len(data),sha256=hashlib.sha256(data).hexdigest(),blob_oid=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest())
  assert git('hash-object','--path='+a,a).decode().strip()!=row['blob_oid']
  if variant=='wrong_blob':row['blob_oid']='0'*40
  paths=[m] if variant=='missing_path' else [a,m]
  scope=dict(required_parent=parent,branch='codex/scope-fixture',changed_paths=paths,files=[row,rule]);(root/m).write_text(json.dumps(scope))
  git('add','--',a,m)
  if variant=='extra_file':(root/'unexpected.txt').write_text('extra committed path');git('add','--','unexpected.txt')
  git('commit','-m','Isolated candidate');candidate=git('rev-parse','HEAD').decode().strip()
  if variant=='dirty_index':(root/a).write_bytes(b'// dirty staged\n');git('add','--',a)
  def local_rec(p):
   b=p.read_bytes();return dict(path=p.relative_to(root).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
  checker.R=root;checker.P=parent;checker.BRANCH='codex/scope-fixture';checker.M=root/m;checker.git=git;checker.rec=local_rec
  failed=False
  try:checker.verify(candidate=candidate)
  except AssertionError:failed=True
  assert failed==(variant!='positive'),variant
  rows.append(dict(case=variant,expected_rejection=variant!='positive',rejected=failed,parent=parent,candidate=candidate,retained_mixed_rule_blob=True))
 report=dict(status='PASS_REAL_GIT_SCOPE_GATES',cases=rows,sources=[rec(Path(__file__)),rec(R/'scripts/m5b1_scope.py'),rec(R/'scripts/m5b1_evidence.py')],scope='Five owned isolated Git fixture repositories; project HEAD/index never modified')
 (F/'SCOPE_NEGATIVE.json').write_text(json.dumps(report,indent=2));print('REAL_GIT_SCOPE_GATES_PASS',len(rows))
if __name__=='__main__':main()
