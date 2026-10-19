"""Generate a concrete byte whitelist; no index writes or commits."""
from pathlib import Path
import json,hashlib,subprocess,difflib
R=Path('F:/Projects/stareye_fpga');F=Path(__file__).resolve().parent;P=R/'reports/m5c_pair_admission_20261018/candidate_evidence_20261018'
PARENT='99ea359c6a5f5432296e992ec76495e441c9d1a0';BACKEND='rtl/m5c_pair_diag/m5c_pair_backend.sv'
def rec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=n,sha256=h.hexdigest())
def put(n,x):(F/n).write_text(json.dumps(x,indent=2)+'\n')
def git(*args):return subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga',*args],cwd=R)
assert git('rev-parse','HEAD').decode().strip()==PARENT
assert git('branch','--show-current').decode().strip()=='codex/m5c-fusion-prototype'
assert not git('diff','--cached','--name-only').strip()
old=git('show',PARENT+':'+BACKEND);new=(R/BACKEND).read_bytes()
assert hashlib.sha256(new).hexdigest()=='8a78aa7030d6bdcd27d8e50c1e633e3d9353709c1ae2cfb814606fe37a18c82c'
assert new.replace(b'!pair_wait_expired&&',b'',1)==old
(F/'backend.diff').write_text(''.join(difflib.unified_diff(old.decode().splitlines(True),new.decode().splitlines(True),fromfile=PARENT+'/'+BACKEND,tofile='candidate/'+BACKEND)))
parent=json.loads((P/'CANDIDATE_SCOPE.json').read_text());checked=0
for x in parent['records']:
 if x['path']==BACKEND:continue
 assert rec(R/x['path'])==x,('parent_dependency_changed',x['path']);checked+=1
put('PARENT_DEPENDENCY_CHECK.json',dict(status='PASS_PARENT_RECORDED_BYTES_UNCHANGED',parent_commit=PARENT,checked=checked,exception=BACKEND,parent_scope=rec(P/'CANDIDATE_SCOPE.json'),parent_scope_blob_sha256=hashlib.sha256(git('show',PARENT+':'+(P/'CANDIDATE_SCOPE.json').relative_to(R).as_posix())).hexdigest()))
d=json.loads((F/'TRANSPORT_INDEX.json').read_text());paths={x['object_path'] for x in d['mappings']}
for x in json.loads((F/'direct_review/INDEX.json').read_text())['records']:paths.add(x['copy']['path'])
for x in d['mappings']:
 if 'derived_private' in x['scope']:paths.add(x['source'])
for n in ['SELECTION.json','TRANSPORT_INDEX.json','KNOWN_LIMITS.md','WORK_REVIEW_GATE.md','verify_transport.py','prepare_transport.py','prepare_scope.py','.gitattributes','direct_review/INDEX.json','PARENT_DEPENDENCY_CHECK.json','backend.diff']:
 paths.add((F/n).relative_to(R).as_posix())
paths.add(BACKEND);snap=paths|set(parent['snapshot_paths'])
tracked=set(git('ls-tree','-r','--name-only',PARENT).decode().splitlines());changed=sorted((paths-tracked)|{BACKEND})
assert all(p==BACKEND or p.startswith(F.relative_to(R).as_posix()+'/') for p in changed)
records=[rec(R/p) for p in sorted(snap)]
put('PROPOSED_SCOPE.json',dict(schema=1,status='EXACT_WHITELIST_PENDING_WORK_APPROVAL_NO_GIT_AUTHORIZATION',branch='codex/m5c-fusion-prototype',parent=PARENT,changed_count=len(changed),snapshot_count=len(snap),changed_paths=changed,snapshot_paths=sorted(snap),records=records,inherited_count=len(snap)-len(changed),self_excluded=True,scope_finalization='Final CANDIDATE_SCOPE adds itself as one changed/snapshot path; scope does not self-hash. PROPOSED_SCOPE and PREPARATION_HANDBACK are external Work gate receipts.'))
normal=[x for x in json.loads((F/'direct_review/INDEX.json').read_text())['records'] if Path(x['original_path'].split('@')[0]).name in {'normal_setup.rpt','normal_hold.rpt','DEADLINE_NORMAL_COVERAGE.json'}]
assert {'normal_setup.rpt','normal_hold.rpt','DEADLINE_NORMAL_COVERAGE.json'}<={Path(x['original_path'].split('@')[0]).name for x in normal}
put('PREPARATION_HANDBACK.json',dict(status='READY_FOR_WORK_SCOPE_REVIEW_NO_STAGE',scope=rec(F/'PROPOSED_SCOPE.json'),transport=rec(F/'TRANSPORT_INDEX.json'),changed_count=len(changed),snapshot_count=len(snap),snapshot_bytes=sum(x['bytes'] for x in records),mappings=len(d['mappings']),unique_objects=len({x['object_path'] for x in d['mappings']}),direct_records=len(json.loads((F/'direct_review/INDEX.json').read_text())['records']),external=len(d['external_references']),normal_and_deadline_direct=normal,known_limits=rec(F/'KNOWN_LIMITS.md')))
print(json.dumps(dict(changed=len(changed),snapshot=len(snap),bytes=sum(x['bytes'] for x in records),scope=rec(F/'PROPOSED_SCOPE.json'))))
