"""Lossless packaging of the exact technical selection; never runs archived code."""
from pathlib import Path
import json,hashlib,gzip,shutil
R=Path('F:/Projects/stareye_fpga');F=Path(__file__).resolve().parent
def load(p):return json.loads(p.read_text())
def rec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(bytes=n,sha256=h.hexdigest())
d=load(F/'SELECTION.json');reuse={}
for rel in ['reports/m5c_pair_capture_20261016/candidate_evidence_20261017','reports/m5c_pair_admission_20261018/candidate_evidence_20261018']:
 P=R/rel
 for x in load(P/'TRANSPORT_INDEX.json')['mappings']:
  q=R/x['object_path'] if 'object_path' in x else P/x['object'];reuse[x['sha256']]=q
done=set();direct=[]
keys={'normal_setup.rpt','normal_hold.rpt','DEADLINE_NORMAL_COVERAGE.json','DEADLINE_COMBINATIONAL_SCOPE.json','CURRENT_PLL_SR_BOUNDARY.json','PHYSICAL_RECONCILIATION_HANDOFF.json','SHORT_HANDBACK.md','SHORT_WIRE_CHECK.json','HANDBACK.json','ACTUAL_GENERATED_OPTIONS.json','NATIVE_EXIT_RECEIPT.json','CURRENT_INPUTS_FULL_PRE.json','CURRENT_INPUTS_FULL_POST.json','PORTABLE_FINAL_RECEIPT.json','PAIR_SOFTWARE_ORACLE.json','WORK_ACCEPTANCE.json','STAGE_IMPORT.diff','IMPORT_FAILURE_BOUNDARY.md','CURRENT_INPUTS_COMPAT_PRE.json','CURRENT_INPUTS_COMPAT_POST.json','pair_events.txt','end_events.txt','repair_tail_ledger.txt','selection_ledger.txt'}
keys.update({'XML_CHANGE_RECONCILIATION.json','WORK_OFFLINE_DEADLINE_REVIEW.json'})
for x in d['mappings']:
 p=R/x['source'];sha=x['sha256'];q=reuse.get(sha)
 if q and q.is_file():x['inherited_object']=True
 else:
  q=F/'objects'/sha[:2]/(sha+'.gz');q.parent.mkdir(parents=True,exist_ok=True);x['inherited_object']=False
  if not q.exists():
   assert rec(p)==dict(bytes=x['bytes'],sha256=sha),p
   with p.open('rb') as fi,q.open('wb') as fo,gzip.GzipFile(fileobj=fo,mode='wb',mtime=0,filename='') as z:shutil.copyfileobj(fi,z,1048576)
 x['object_path']=q.relative_to(R).as_posix()
 if sha not in done:
  h=hashlib.sha256();n=0
  with gzip.open(q,'rb') as z:
   for b in iter(lambda:z.read(1048576),b''):n+=len(b);h.update(b)
  assert (n,h.hexdigest())==(x['bytes'],sha),p;done.add(sha)
 name=Path(x['original_path'].split('@')[0]).name
 isshort=x['scope']=='short_repair_all_original_results'
 islog=x['scope'] in {'remote_native_log','actual_compile_sim_software_log','v4_import_failure_and_v41_local_validation','technical_acceptance_and_derivation','work_remote_technical_acceptance','offline_conversion_metadata'}
 if name in keys or (isshort and p.suffix in {'.sv','.py','.log','.md','.json'}) or (islog and p.suffix in {'.log','.md','.json','.py','.diff'} and x['bytes']<1000000):
  target=F/'direct_review'/sha[:12]/name;target.parent.mkdir(parents=True,exist_ok=True)
  if not target.exists():shutil.copyfile(p,target)
  assert rec(target)==dict(bytes=x['bytes'],sha256=sha)
  direct.append(dict(original_path=x['original_path'],scope=x['scope'],kind='complete_original_bytes' if 'derived' not in x['scope'] else 'explicit_derived_technical_bytes',copy=dict(path=target.relative_to(R).as_posix(),**rec(target))))
d['status']='LOSSLESS_TECHNICAL_TRANSPORT_NOT_A_VALIDATION_CLAIM'
(F/'TRANSPORT_INDEX.json').write_text(json.dumps(d,indent=2)+'\n')
(F/'direct_review/INDEX.json').write_text(json.dumps(dict(records=direct,excerpts=0,normal_setup_and_hold='Complete original bytes without size cap',deadline='Complete 2670-row original coverage; not an abbreviated summary'),indent=2)+'\n')
print(json.dumps(dict(mappings=len(d['mappings']),objects=len(done),direct=len(direct),external=len(d['external_references']))))
