from pathlib import Path
import json,hashlib,collections
R=Path(__file__).resolve().parents[3];O=Path(__file__).resolve().parent
sources=[
 'reports/m5c_diagnostics/stage2_short_seal_20261015_160426/MANIFEST.json',
 'reports/m5c_diagnostics/stage2_finite_seal_20261015_165653/MANIFEST.json',
 'reports/m5c_diagnostics/stage2_adoption_preparation_20261015/final_system_seal/MANIFEST.json',
 'reports/m5c_diagnostics/stage2_resource_bound_v3_20261015_181411/FULL_PHYSICAL_MANIFEST.json',
 'reports/m5c_diagnostics/stage2_offline_parent_20261015_211613/HANDBACK_MANIFEST.json']
seen={};manifests=[]
for name in sources:
 p=R/name;b=p.read_bytes();a=json.loads(b)['records'];manifests.append(dict(path=name,records=len(a),bytes=len(b),sha256=hashlib.sha256(b).hexdigest()))
 for x in a:
  path=Path(x['path']);path=path if path.is_absolute() else R/path
  try:rel=path.relative_to(R).as_posix()
  except ValueError:rel=str(path)
  key=(rel,x['sha256']);item=seen.setdefault(key,dict(path=rel,bytes=x['bytes'],sha256=x['sha256'],from_manifests=[]));item['from_manifests'].append(name)
def classify(x):
 s=x['path'].lower();n=Path(s).name
 if not str(R).lower().replace('\\','/') in s and (':/' in s or ':\\' in s):return 'EXTERNAL_TOOL_OR_ABSOLUTE_BOUNDARY'
 if any(t in s for t in ['/content_archive/','/work_pnr/','/outflow/','/work/']):return 'NATIVE_OUTPUT_OR_ARCHIVE_EXTERNAL_BOUNDARY_REQUIRES_EXACT_SELECTION'
 if n.endswith(('.bit','.bit.bin','.hex.bin','.vdb','.lbf','.wlf','.troutingtraces','.dll','.exe')):return 'EXCLUDED_NATIVE_PROGRAMMING_OR_DATABASE'
 if '/hardware_analysis' in s:return 'EXCLUDED_USER_CAPTURE'
 if '/snapshots/' in s:return 'VERSIONED_INPUT_OBJECT_DEDUP_CANDIDATE'
 if n.endswith(('.sv','.v','.svh','.vh','.py','.tcl','.sdc','.xml','.json','.log','.txt','.rpt','.hex','.bin','.diff','.md','.gitignore')):return 'REVIEW_REQUIRED_SELECTED_SOURCE_OR_EVIDENCE'
 return 'UNCLASSIFIED_REQUIRES_DECISION'
records=sorted(seen.values(),key=lambda x:(x['path'],x['sha256']))
for x in records:x['classification']=classify(x)
summary={}
for x in records:
 v=summary.setdefault(x['classification'],dict(count=0,bytes=0));v['count']+=1;v['bytes']+=x['bytes']
out=dict(status='SCOPE_INVENTORY_NOT_COMMIT_ALLOWLIST',manifests=manifests,unique_path_sha_records=len(records),total_bytes=sum(x['bytes'] for x in records),classification=summary,largest=sorted(records,key=lambda x:x['bytes'],reverse=True)[:20],records=records,
 boundary='No recursive tree collection or copying. Historical source paths may have changed after approved adoption; original byte versions must be transported using existing snapshots/archives. Native map/trace/database excluded by default, not silently included from manifests. Synthetic regression gold is distinct from forbidden user camera images.')
(O/'EVIDENCE_SCOPE_INVENTORY.json').write_text(json.dumps(out,indent=2));print(json.dumps(dict(records=len(records),summary=summary)))
