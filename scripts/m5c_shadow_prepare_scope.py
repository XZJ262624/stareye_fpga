"""Prepare an exact technical-only proposal, never stage or commit anything."""
from pathlib import Path
import json,hashlib,subprocess
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016';O=A/'candidate_evidence'
HEAD='1786858c7ae9a0c756cc37c43beceb93eca92b9e'
def git(*args):return subprocess.check_output(['git','-c','safe.directory='+R.as_posix(),*args],cwd=R)
def rec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=n,sha256=h.hexdigest())
def objects(v):
 if isinstance(v,dict):
  if 'object' in v and isinstance(v['object'],dict) and 'path' in v['object']:yield v['object']
  for x in v.values():yield from objects(x)
 elif isinstance(v,list):
  for x in v:yield from objects(x)
def main():
 assert git('rev-parse','HEAD').decode().strip()==HEAD
 assert not git('diff','--cached','--name-only')
 assert json.loads((A/'system_134939/run/final_seal/GATE_HANDBACK.json').read_bytes())['status']=='PASS_CURRENT_SCHEMA2_SYSTEM_FINAL_SEALED'
 assert json.loads((A/'physical_133645/FULL_PHYSICAL_QUALIFICATION.json').read_bytes())['status']=='PASS_CURRENT_I3_PHYSICAL_ONLY'
 indexes=['STABLE_OBJECTS_V2.json','SHORT_INPUT_CLOSURE.json','STRUCTURAL_TRANSPORT.json','INHERITED_TRANSPORT_OBJECTS.json','SCHEMA_COMPATIBILITY_SOURCE_CLOSURE.json','PHYSICAL_OBJECTS.json','OFFLINE_METADATA_OBJECTS.json','GOLDEN_AND_ORIGINAL_CHECKER_CLOSURE.json','SYSTEM_OBJECTS.json']
 extra=['STABLE_DRAFT_SCOPE_CORRECTION.json','SHORT_COMMAND_INVENTORY.json','SHORT_COMMAND_INVENTORY_V2.json','SHORT_COMMAND_INVENTORY_V3.json','COMMAND_INVENTORY_DERIVATION.json','TRANSPORT_PREPARATION_CHECK.json','DIRECT_REVIEW_PATH_CORRECTION.json']
 selected=set();bound_objects={}
 for n in indexes:
  p=O/n;selected.add(p)
  for x in objects(json.loads(p.read_bytes())):
   assert rec(R/x['path'])==x,x['path'];selected.add(R/x['path']);bound_objects[x['path']]=x
 for n in extra:selected.add(O/n)
 direct_index=O/'direct_review_v2/INDEX.json';selected.add(direct_index)
 for x in json.loads(direct_index.read_bytes())['records']:
  assert rec(R/x['direct']['path'])==x['direct'];selected.add(R/x['direct']['path'])
 for n in ['WORK_REVIEW_GATE.md','KNOWN_LIMITS.md']:selected.add(O/n)
 selected.update((R/'scripts').glob('m5c_shadow_*.py'))
 selected.update((R/'tb/m5c_diagnostics').glob('tb_shadow_*.sv'))
 for n in ['rtl/m5c_fusion/m5c_row_fusion.sv','rtl/m5c_fusion/m5c_fusion_display.sv','rtl/m5c_diagnostics/m5c_diag_observer_v3.sv','efinity/m5c_fusion_i3/example_top.v','efinity/m5c_fusion_i3/Ti60_Demo.xml','scripts/.gitattributes']:
  selected.add(R/n)
 for n in ['.gitattributes','DIRECT_REVIEW.md','COVERAGE_PROGRESS.md','WORK_IMPLEMENTATION_FREEZE.md','WORK_CANDIDATE_PREPARATION_BOUNDARY.md','TECHNICAL_BASELINE.json','BASELINE_FIXED_BLOB_PROOF.json','IMPLEMENTATION_DERIVATION.json','SYSTEM_WATCHDOG_METADATA_RECONCILIATION.json','OBSERVER_NEGATIVE_ACTUAL_WORDS.json','row_sensitivities/ROW_END_RECONCILIATION.json','UNCHANGED_TRANSPORT_INHERITANCE.json']:
  selected.add(A/n)
 # The 104 exact current build inputs are a small, explicit technical closure.
 for x in json.loads((A/'physical_133645/COPY_MANIFEST.json').read_bytes())['records']:
  assert rec(R/x['source']['path'])==x['source'];selected.add(R/x['source']['path'])
 tree={}
 for entry in git('ls-tree','-rz',HEAD).split(b'\0'):
  if not entry:continue
  header,path=entry.split(b'\t',1);tree[path.decode()]=header.split()[2].decode()
 records=[];changed=[];parent=[]
 for p in sorted(selected):
  v=rec(p);n=v['path'];low='/'+n.lower()+'/'
  assert not any(x in low for x in ['/work_review/','/captures/','/hardware_analysis','/hardware_diagnostic/','/content_archive/','/mirror/','/.git/','/m3/']),n
  assert p.suffix not in ['.bit','.vdb','.lbf','.troutingtraces','.exe','.dll'],n
  assert not n.startswith('docs/') and n not in ['.gitattributes','.gitignore']
  blob=tree.get(n)
  if blob and hashlib.sha256(git('cat-file','blob',blob)).hexdigest()==v['sha256']:parent.append(n)
  else:changed.append(n)
  records.append(v)
 out=dict(status='PROPOSED_NOT_AUTHORIZED_FOR_GIT',parent=HEAD,branch=git('branch','--show-current').decode().strip(),changed_paths=changed,changed_count=len(changed),snapshot_paths=[x['path'] for x in records],snapshot_count=len(records),records=records,parent_inherited_paths=parent,object_count=len(bound_objects),bytes=sum(x['bytes'] for x in records),boundary='Exact selected technical files only. No root management/M3/root attributes/ignore/user captures/compiled libraries/tool binaries/bit/DB. Fixed parent dependencies included only where current bytes exactly match parent blob; historical versions remain separate mapped objects. Scope self-reference excluded.')
 p=O/'PROPOSED_SCOPE.json';assert not p.exists();p.write_text(json.dumps(out,indent=2));print('PROPOSED_SCOPE',len(changed),len(records),out['bytes'],rec(p))
if __name__=='__main__':main()
