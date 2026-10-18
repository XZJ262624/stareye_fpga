"""Explicit sealed-scope packaging; never executes archived code or rewrites evidence."""
from pathlib import Path
import json,hashlib,gzip,shutil
R=Path('F:/Projects/stareye_fpga');A=R/'reports/m5c_pair_admission_20261018';F=Path(__file__).resolve().parent
OLD=R/'reports/m5c_pair_capture_20261016/candidate_evidence_20261017'
def load(p):return json.loads(p.read_text())
def rec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(bytes=n,sha256=h.hexdigest())
rows={};external=[]
def prohibited(name):
 return name.endswith('.map.v') or Path(name).suffix.lower() in {'.vdb','.lbf','.lpf','.ini','.troutingtraces','.io','.bit'} or name.endswith(('.bit.bin','.hex.bin')) or name.startswith('RUNPNR')
def add(p,scope,original=None,expected=None):
 p=Path(p);z=rec(p)
 if expected:assert all(z[k]==expected[k] for k in z),(p,z,expected)
 original=original or p.relative_to(R).as_posix();key=(original,z['sha256'])
 rows[key]=dict(scope=scope,original_path=original,source=p.relative_to(R).as_posix(),**z)
def sealed(name,scope):
 p=A/name;add(p,scope)
 for x in load(p)['records']:add(R/x['path'],scope,expected=x)
sealed('implementation/SHORT_MANIFEST.json','short_repair')
sealed('DIAGNOSIS_MANIFEST.json','causal_diagnosis_exploratory_and_bound')
B=A/'physical_latest_161919'
physical=load(B/'PHYSICAL_RECONCILIATION_MANIFEST.json')['records']
for x in physical:
 p=R/x['path']
 if prohibited(p.name):external.append(dict(scope='external_native_database',**x))
 elif '/content_archive/' not in x['path']:add(p,'current_physical',expected=x)
# Resolve archived version bytes back to actual report/structure/source names, not anonymous blobs.
for ap in sorted(B.glob('*/POST_NATIVE_ARCHIVE.json')):
 add(ap,'stage_archive_index')
 for x in load(ap)['records']:
  o=x['original'];p=R/x['archive']['path'];name=Path(o['path']).name
  if prohibited(name) or Path(name).suffix.lower()=='.bin':
   external.append(dict(scope='external_native_database',**o));continue
  if Path(name).suffix.lower() in {'.rpt','.log','.json','.txt','.tcl','.xml','.sdc','.v','.sv','.vh','.svh'}:add(p,'stage_archived_original',o['path']+'@'+ap.parent.name,expected=o)
P=A/'remote_v3/package';manifest=load(P/'manifest.json');add(P/'manifest.json','fixed_v3_package')
for rel,x in manifest['files'].items():
 if rel.lower().endswith(('.md','.txt')) and ('prompt' in rel.lower() or 'readme' in rel.lower()):continue
 add(P/rel,'fixed_v3_input',expected=dict(bytes=x.get('size',x.get('bytes')),sha256=x['sha256']))
I=A/'remote_v3_acceptance_20261018'
for stage in ['compat','full']:
 D=I/stage
 original=D/'input_manifest.json';d=load(original);removed=d.pop('package');q=F/'derived'/stage/'input_manifest_technical.json';q.parent.mkdir(parents=True,exist_ok=True);q.write_text(json.dumps(dict(derived=True,original_identity=rec(original),removed_fields=['package'],technical=d),indent=2));add(q,'remote_runtime_derived_private_path_removed')
 for name in ['package_manifest.json','result.json','steps.json','tool_environment.json']:add(D/name,'remote_runtime_technical')
 for p in sorted((D/'logs').glob('*.log')):add(p,'remote_native_log')
 for p in sorted((D/'work').iterdir()):
  if p.is_file() and (p.suffix.lower() in {'.json','.hex','.txt'} and p.name not in {'README_CN.md','REMOTE_CODEX_PROMPT_CN.md'}):add(p,'remote_actual_output')
 for p in sorted((D/'work/portable_logs').glob('*.log')):add(p,'actual_compile_sim_software_log')
for name in ['ACCEPTANCE.json','RUNTIME_INPUT_RECONCILIATION.json','FIRST_STRICT_FAILURE.json','REPORT.md','LOCAL_ORACLE.log','verify_received_v3.py','verify_received_v3_reconciled.py','reconcile_runtime_binding.py']:
 add(I/name,'remote_local_revalidation')
for p in sorted((I/'local_oracle').iterdir()):
 if p.is_file():add(p,'trusted_local_oracle_output')
O=A/'offline_v3_20261018_current'
for name in ['HANDBACK.json','HANDBACK_MANIFEST.json','INPUT_WHITELIST.json','DERIVATION.json','RESULT.json','ACTUAL_GENERATED_OPTIONS.json','ARTIFACT_IGNORE_RECEIPT.json','NATIVE_EXIT_RECEIPT.json','PREPARATION_XML_VERSION_NOTE.json','PRE_NATIVE_ARCHIVE.json','POST_NATIVE_ARCHIVE.json','tool.log','prepare.py','run_conversion.py','options_preflight.py','seal.py']:add(O/name,'offline_conversion_metadata')
for name in ['WORK_V3_FINITE_ACCEPTANCE.md','WORK_OFFLINE_V3_APPROVAL.md','WORK_LATEST_REQUEST_IMPLEMENTATION_APPROVAL.md','WORK_FRESH_BUILD_AND_REMOTE_V3_APPROVAL.md','WORK_SHORT_GATE_DECISION.json']:add(A/name,'work_scope_acceptance')
oldindex=load(OLD/'TRANSPORT_INDEX.json');reuse={x['sha256']:OLD/x['object'] for x in oldindex['mappings'] if 'object' in x}
for x in rows.values():
 p=R/x['source'];sha=x['sha256'];q=reuse.get(sha)
 if q and q.is_file():x['object_path']=q.relative_to(R).as_posix();x['inherited_object']=True
 else:
  q=F/'objects'/sha[:2]/(sha+'.gz');q.parent.mkdir(parents=True,exist_ok=True)
  if not q.exists():
   with p.open('rb') as fi,q.open('wb') as fo,gzip.GzipFile(fileobj=fo,mode='wb',mtime=0,filename='') as z:shutil.copyfileobj(fi,z,1048576)
  x['object_path']=q.relative_to(R).as_posix();x['inherited_object']=False
 h=hashlib.sha256();n=0
 with gzip.open(q,'rb') as z:
  for b in iter(lambda:z.read(1048576),b''):n+=len(b);h.update(b)
 assert n==x['bytes'] and h.hexdigest()==sha
out=dict(schema=1,mappings=list(rows.values()),external_references=external,excluded_private='Outer QQ review/workflow/instructions/request/launch/events/bootstrap and user hardware raw are local-only. No archive code executed. Physical raw map/native DB/tool/bit excluded; exact external hashes retained.')
(F/'TRANSPORT_INDEX.json').write_text(json.dumps(out,indent=2))
print(json.dumps(dict(mappings=len(rows),objects=len({x['object_path'] for x in rows.values()}),external=len(external))))
