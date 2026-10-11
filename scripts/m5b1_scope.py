"""Exact repair diff plus complete review closure; no Git mutation is performed."""
import argparse,json,hashlib,shutil,subprocess
from functools import lru_cache
from pathlib import Path
from m5b1_evidence import R,B,O,F,W,P,BRANCH,BUILD,GROUPS,SUITES,CASES,rec,load,git,same
M=O/'PROPOSED_GIT_SCOPE.json'

def allowed(p):
 return p in ['.gitignore','.gitattributes',*('docs/'+n+'.md' for n in ['PROJECT_BRIEF','STATUS','DECISIONS','HANDOFF'])] or p.startswith(('efinity/m5b1_global_canny_i3/','rtl/m5b1_global_canny/','tb/m5b1_global_canny/','scripts/m5b1_','reports/m5b1_global_canny_i3/'))

def clean_path(p):
 assert (R/p).is_file(),p
 assert not any(v in Path(p).parts for v in ('work','outflow','work_pnr','work_syn','ipm','cache')) and not any(v.startswith('work_') for v in Path(p).parts),p
 assert Path(p).suffix.lower() not in ('.log','.out','.bit','.vcd','.wlf','.exe','.dll','.zip','.pyc'),p

@lru_cache(None)
def parent_paths(parent):return set(git('ls-tree','-r','--name-only',parent).decode().splitlines())

@lru_cache(None)
def parent_has_crlf(parent,p):return p in parent_paths(parent) and b'\r\n' in git('show',parent+':'+p)

def blob_oid(p):
 # Ordinary git add preserves CRLF when the existing index blob already
 # contains it. hash-object's clean/renormalize path is different. Preserve
 # that existing representation; staged verification still reads the actual
 # blob and checks every byte, never merely trusting this prediction.
 if parent_has_crlf(P,p):
  raw=(R/p).read_bytes();return hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()
 return git('hash-object','--path='+p,p).decode().strip()
def blob_row(p):
 raw=(R/p).read_bytes();oid=blob_oid(p)
 # Prove the candidate byte representation by matching Git's actual clean
 # object ID. Never assume Windows newline normalization silently.
 matches=[b for b in (raw,raw.replace(b'\r\n',b'\n')) if hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()==oid]
 assert matches,'Unsupported Git clean filter for '+p
 b=matches[0]
 return dict(path=p,bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),blob_oid=oid,working_bytes=len(raw),working_sha256=hashlib.sha256(raw).hexdigest())

def verify(candidate=None,staged=False):
 scope=load(M);assert scope['required_parent']==P and scope['branch']==BRANCH
 assert git('branch','--show-current').decode().strip()==BRANCH
 if candidate:
  assert git('rev-parse','HEAD').decode().strip()==candidate
  assert git('rev-list','--parents','-n','1',candidate).decode().split()==[candidate,P]
  assert not git('diff','--cached','--name-only') and not git('diff','--name-only')
  actual=set(git('diff','--name-only','--no-renames',P,candidate).decode().splitlines())
  for row in scope['files']:assert git('rev-parse',candidate+':'+row['path']).decode().strip()==row['blob_oid'],row['path']
 elif staged:
  assert git('rev-parse','HEAD').decode().strip()==P and not git('diff','--name-only')
  actual=set(git('diff','--cached','--name-only','--no-renames').decode().splitlines())
  for row in scope['files']:assert git('rev-parse',':'+row['path']).decode().strip()==row['blob_oid'],row['path']
 else:raise AssertionError('Choose fixed candidate or staged verification')
 assert actual==set(scope['changed_paths']),(sorted(actual-set(scope['changed_paths'])),sorted(set(scope['changed_paths'])-actual))
 for row in scope['files']:
  assert blob_oid(row['path'])==row['blob_oid'],row['path']
  raw=(R/row['path']).read_bytes();assert len(raw)==row.get('working_bytes',row['bytes']) and hashlib.sha256(raw).hexdigest()==row.get('working_sha256',row['sha256']),row['path']
  blob=git('cat-file','blob',(candidate or '')+':'+row['path'])
  assert len(blob)==row['bytes'] and hashlib.sha256(blob).hexdigest()==row['sha256'],row['path']
 print('EXACT_SCOPE_PASS',len(actual),'changed paths',len(scope['files']),'technical files')

def prepare():
 assert git('rev-parse','HEAD').decode().strip()==P and not git('diff','--cached','--name-only')
 receipt=load(O/'OFFLINE_ACCEPTANCE.json');assert receipt['required_parent']==P and receipt['status']=='PASS_OFFLINE_PENDING_INDEPENDENT_REVIEWS_AND_HARDWARE'
 # All committed technical baseline inputs stay in the full closure, even
 # when the new candidate only changes a smaller subset.
 parent=git('ls-tree','-r','--name-only',P).decode().splitlines()
 paths={p for p in parent if p.startswith(('efinity/m5b1_global_canny_i3/','rtl/m5b1_global_canny/','tb/m5b1_global_canny/','scripts/m5b1_','reports/m5b1_global_canny_i3/'))}
 paths.update(['.gitignore','.gitattributes',*('docs/'+n+'.md' for n in ['PROJECT_BRIEF','STATUS','DECISIONS','HANDOFF'])])
 # Include only the explicitly introduced repair tools/benches. Historical
 # untracked initialization and patch helpers are neither replay inputs nor
 # candidate material; a filename glob must not silently adopt them.
 paths.update('scripts/m5b1_'+n+'.py' for n in ['evidence','repair_extra_sim','repair_report','review_repro','review_suite','scope_negative'])
 paths.update('tb/m5b1_global_canny/tb_m5b1_'+n+'.sv' for n in ['backend_edges','cancel_recovery','capture_drain','default_timeout','engine_abort','review_cancel','review_connection','tag_qualification','transfer_cancel'])
 paths.update('reports/m5b1_global_canny_i3/'+n for n in ['CODEX_A_REVIEW_264962E0.md','DEEPSEEK_B_REVIEW_264962E0.md','REVIEW_FIX_SPEC_264962E0.md'])
 for p in O.rglob('*'):
  if p.is_file() and p.suffix.lower() in ('.json','.md','.rpt','.tcl') and not any(v=='work' or v.startswith('work_') for v in p.relative_to(O).parts):paths.add(p.relative_to(R).as_posix())
 paths.discard(M.relative_to(R).as_posix())
 for n in ('project_before.xml','project_after.xml'):paths.add((BUILD/n).relative_to(R).as_posix())
 copies=load(B/'M5A_INPUT_COPY.json');reference={v['source']['path']:v['source'] for v in copies['files']}
 for directory in GROUPS.values():
  for row in load(F/directory/'results.json')['sources']:
   if not allowed(row['path']):reference[row['path']]=row
 # Source-specific golden dependency used by actual production-connection TB.
 q=R/'scripts/m5a_streaming_canny_gold.py';reference[q.relative_to(R).as_posix()]=rec(q)
 for row in reference.values():same(row)
 deps=dict(required_parent=P,unchanged_reference_files=sorted(reference.values(),key=lambda x:x['path']),privacy_exclusion='Work omits BASELINE_PROTECTION.json and the historical raw/untracked material from external snapshots; only fixed technical Git blobs are sent.',external_tools=['Efinity 2025.1.110.5.9','ModelSim SE-64 10.1c','Python with NumPy'])
 d=O/'TECHNICAL_DEPENDENCIES.json';d.write_text(json.dumps(deps,indent=2));paths.add(d.relative_to(R).as_posix());paths.update(reference)
 for p in paths:clean_path(p)
 rows=[blob_row(p) for p in sorted(paths)]
 tracked_changes=set(git('diff','--name-only','--no-renames',P).decode().splitlines())
 assert all(allowed(p) and p in paths for p in tracked_changes),tracked_changes-paths
 selected=tracked_changes|{p for p in paths if p not in parent}|{M.relative_to(R).as_posix()}
 assert all(allowed(p) for p in selected)
 data=dict(branch=BRANCH,required_parent=P,changed_paths=sorted(selected),files=rows,self_not_hashed=M.relative_to(R).as_posix(),content_policy='bytes/SHA256/blob_oid describe exact Git candidate blobs, independently proven against Git clean object IDs; working_bytes/working_sha256 retain the working-file binding. Source/report paths have -text; management docs may use Git newline normalization.',excluded='Generated binaries/bitstreams/databases/raw logs, unknown untracked material and tools; original history is preserved locally.')
 M.write_text(json.dumps(data,indent=2));scratch=O/'work';scratch.mkdir(exist_ok=True)
 (scratch/'stage_paths.nul').write_bytes(b'\0'.join(p.encode() for p in sorted(selected))+b'\0')
 print('REPAIR_SCOPE',len(selected),'changed paths',len(rows),'technical files')

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--candidate');ap.add_argument('--staged',action='store_true');a=ap.parse_args()
 if a.candidate or a.staged:verify(a.candidate,a.staged)
 else:prepare()
if __name__=='__main__':main()
