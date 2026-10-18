from pathlib import Path
import json,hashlib,shutil,subprocess
R=Path('F:/Projects/stareye_fpga');F=Path(__file__).resolve().parent;OLD=R/'reports/m5c_pair_capture_20261016/candidate_evidence_20261017'
def rec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=n,sha256=h.hexdigest())
def put(n,x):(F/n).write_text(json.dumps(x,indent=2))
d=json.loads((F/'TRANSPORT_INDEX.json').read_text());direct=[];paths=set()
key={'SHORT_HANDBACK.json','RESULT.json','REPORT.md','backend.diff','ACCEPTANCE.json','RUNTIME_INPUT_RECONCILIATION.json','FIRST_STRICT_FAILURE.json','PORTABLE_FINAL_RECEIPT.json','PAIR_SOFTWARE_ORACLE.json','CURRENT_PLL_SR_BOUNDARY.json','LATEST_REQUEST_CONTROL_COVERAGE.json','LATEST_REQUEST_NORMAL_TIMING_SCOPE.json','PHYSICAL_RECONCILIATION_HANDOFF.json','HANDBACK.json','ACTUAL_GENERATED_OPTIONS.json','normal_setup.rpt','normal_hold.rpt','repair_tail_ledger.txt','pair_events.txt','end_events.txt','selection_ledger.txt'}
for x in d['mappings']:
 p=R/x['source'];name=Path(x['original_path'].split('@')[0]).name
 select=name in key or (x['scope']=='short_repair' and p.suffix in {'.sv','.v','.py'} and x['bytes']<300000) or (x['scope'] in {'short_repair','remote_native_log','actual_compile_sim_software_log','work_scope_acceptance'} and p.suffix in {'.log','.md'} and x['bytes']<300000)
 if select and x['bytes']<1000000:
  q=F/'direct_review'/x['sha256'][:12]/name;q.parent.mkdir(parents=True,exist_ok=True)
  if not q.exists():shutil.copyfile(p,q)
  z=rec(q);assert z['sha256']==x['sha256'];direct.append(dict(original_path=x['original_path'],original_sha256=x['sha256'],original_bytes=x['bytes'],kind='complete_original_bytes',copy=z));paths.add(z['path'])
 paths.add(x['object_path'])
put('direct_review/INDEX.json',dict(records=direct,full_original=len(direct),excerpts=0,scope='Exact small original text; derived input-manifest technical file explicitly tagged derived separately. Large reports remain lossless compressed, not claimed fully reviewed by text-only B.'))
for name in ['TRANSPORT_INDEX.json','KNOWN_LIMITS.md','WORK_REVIEW_GATE.md','verify_transport.py','prepare_transport.py','prepare_scope.py','.gitattributes','direct_review/INDEX.json']:paths.add((F/name).relative_to(R).as_posix())
for x in d['mappings']:
 if x['scope']=='remote_runtime_derived_private_path_removed':paths.add(x['source'])
backend='rtl/m5c_pair_diag/m5c_pair_backend.sv';paths.add(backend)
parent=json.loads((OLD/'CANDIDATE_SCOPE.json').read_text());inherited=set(parent['snapshot_paths']);snap=paths|inherited
# Scope records are byte identities; parent technical snapshot gives reproducible historical dependency closure.
records=[rec(R/p) for p in sorted(snap)]
by_path={x['path']:x for x in records};checked=0
for x in parent['records']:
 if x['path']==backend:continue
 assert by_path[x['path']]==x,('parent_dependency_modified',x['path']);checked+=1
put('PARENT_DEPENDENCY_CHECK.json',dict(status='PASS_PARENT_RECORDED_BYTES_UNCHANGED',checked=checked,only_functional_exception=backend,parent_scope=rec(OLD/'CANDIDATE_SCOPE.json')))
head=subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga','rev-parse','HEAD'],cwd=R,text=True).strip();assert head=='3c693037b79b4129856a2c43f2bcfe54ce18d623'
tracked=set(subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga','ls-tree','-r','--name-only',head],cwd=R,text=True).splitlines())
changed=sorted((paths-tracked)|{backend})
assert not any('/work_check/' in p or '/work_review_' in p for p in changed)
put('PROPOSED_SCOPE.json',dict(status='PROPOSED_TECHNICAL_SCOPE_NO_GIT_AUTHORIZATION',branch='codex/m5c-fusion-prototype',parent=head,changed_count=len(changed),snapshot_count=len(snap),changed_paths=changed,snapshot_paths=sorted(snap),records=records,inherited_count=len(snap)-len(changed),self_excluded=True))
put('PREPARATION_HANDBACK.json',dict(scope=rec(F/'PROPOSED_SCOPE.json'),transport=rec(F/'TRANSPORT_INDEX.json'),mappings=len(d['mappings']),unique_objects=len({x['object_path'] for x in d['mappings']}),direct_original=len(direct),snapshot_bytes=sum(x['bytes'] for x in records),largest=sorted(records,key=lambda x:x['bytes'],reverse=True)[:12],note='PROPOSED_SCOPE and this handback excluded. Final one CANDIDATE_SCOPE would add one changed/snapshot path only on explicit Work authorization; records remain non-self-hashing. Old V1 draft orphan compressed objects not selected unless listed.'))
print(json.dumps(dict(changed=len(changed),snapshot=len(snap),direct=len(direct),scope=rec(F/'PROPOSED_SCOPE.json'))))
