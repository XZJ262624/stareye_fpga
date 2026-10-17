# PREPARATION GENERATOR ONLY: writes this local preparation package. Do not execute in a fixed review snapshot. Use scripts/m5c_pair_read_evidence.py for read-only validation.
from pathlib import Path
import json,hashlib,gzip,shutil,collections
R=Path.cwd();B=R/'reports/m5c_pair_capture_20261016';C=B/'candidate_evidence_20261017';F=B/'reason20_repair_20261017/physical_discovery_174324';O=B/'offline_r20_20261017_201835';selected={};mapping=[];external=[]
def ident(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(bytes=n,sha256=h.hexdigest())
def add(p,scope,original=None,expected=None):
 p=Path(p).resolve()
 if not p.is_file():raise AssertionError(('missing',str(p)))
 x=ident(p)
 if expected:assert x['sha256']==expected['sha256'] and x['bytes']==expected.get('bytes',expected.get('size')),str(p)
 name=original or p.relative_to(R).as_posix();key=(scope,name,x['sha256']);selected[key]=(p,x)
def include_tree(d,scope):
 for p in d.rglob('*'):
  if not p.is_file() or any(v in ['work','work_pnr','db','__pycache__','content_archive','mirror'] for v in p.relative_to(d).parts):continue
  if p.suffix.lower() not in ['.json','.py','.sv','.v','.svh','.vh','.hex','.txt','.log','.md','.do','.tcl','.rpt','.sdc','.diff','.bin','.csv']:continue
  add(p,scope)
# Explicit bounded successful/negative and causal gates, not arbitrary history.
groups=['capture_pack5_124003','capture_pack5_extra_125033','controller_pack5_dense_v3_124652','controller_pack5_oracle_v2_124236','controller_pack5_page_123836','decoder_pack5_checks','default_pin_pack5_124818','pack5_negatives_124154','pack5_negatives_124250','qualification_pack5_124016','selection_denied_pack5_125709','selection_fixed_pack5_mutant_125838','selection_lifecycle_pack5_123927','latest_descriptor_185007','latest_descriptor_revision','latest_descriptor_test_v2','wait_owner_181526','wait_owner_negative_182435','request_sid_183553','current_qualification_193802','current_qualification_negative_193948','current_qualification_mutant','settings_path_revision','pack5','pack5_launch_1252','pair_only_oracles','selection_repair_handback','selection_real_telemetry_handback','selection_diagnostic_handback']
for g in groups:
 assert (B/g).is_dir(),g;include_tree(B/g,'short/'+g)
# Immutable manifested diagnosis and final repaired short evidence, including historical source variants.
for rel in ['reason20_repair_20261017/SHORT_MANIFEST.json','pack5_reason20_diagnosis/MANIFEST.json','fifo_service_diagnosis_20261017/MANIFEST.json']:
 p=B/rel;add(p,'manifest/'+rel);z=json.loads(p.read_text());rs=z.get('records',[])
 for x in rs:add(R/x['path'].replace('\\','/'),'manifest/'+rel,expected=x)
for p in (B/'reason20_repair_20261017').glob('*'):
 if p.is_file() and p.suffix in ['.json','.md','.py','.diff']:add(p,'repair/root')
include_tree(B/'reason20_repair_20261017/system_fixture','repair/fullfixture')
# Frozen original portable package + actual received full/compat outputs (not received remote helper programs).
P=B/'remote_pack5_reason20_20261017/package';pm=json.loads((P/'manifest.json').read_text());add(P/'manifest.json','remote/fixedpackage')
for n,x in pm['files'].items():add(P/n,'remote/fixedpackage',original=n,expected=x)
for g in ['compat','full']:
 D=B/'remote_v2_acceptance_20261017'/g
 for n,x in json.loads((D/'export_hashes.json').read_text()).items():add(D/n,'remote/'+g,original=n,expected=x)
 for n in ['export_hashes.json']:add(D/n,'remote/'+g)
for n in ['REPORT.md','ACCEPTANCE.json','verify_received.py','MANIFEST.json','HASH_CHECKS.json','TRUSTED_LOCAL_DEPENDENCIES.json']:
 add(B/'remote_v2_acceptance_20261017'/n,'remote/localverification')
include_tree(B/'remote_v2_acceptance_20261017/local_oracle','remote/localoracle')
# All current physical named audit/helper receipts, and archived reports resolved to original names per stage.
for x in json.loads((F/'PHYSICAL_RECONCILIATION_MANIFEST.json').read_text())['records']:
 p=R/x['path'];parts=p.relative_to(F).parts if p.is_relative_to(F) else ()
 if p.is_relative_to(F) and 'content_archive' not in parts and 'mirror' not in parts:add(p,'physical/named',expected=x)
for stage in ['map','interface','place','route','sta_01_bundle_global_Dsetup','sta_02_scoped_D_CE_SR_RAM_DSP_IO','sta_03_connections','sta_04_DSP_config','sta_05_clock_pairs','sta_06_pair_backend_controls','sta_07_pair_control_connections','sta_08_all_native_FF_controls']:
 for kind in ['PRE_NATIVE_ARCHIVE.json','POST_NATIVE_ARCHIVE.json']:
  p=F/stage/kind
  if not p.exists():continue
  add(p,'physical/'+stage)
  for x in json.loads(p.read_text())['records']:
   n=x['original']['path'];q=R/x['archive']['path'];ext=Path(n).suffix.lower()
   if ext in ['.rpt','.log','.tcl','.json','.sdc','.xml','.py'] and not n.endswith('.map.v'):
    add(q,'physical/'+stage+'/'+kind,original=n,expected=x['archive'])
   else:external.append(dict(scope=stage+'/'+kind,original=x['original'],archive=x['archive'],reason='NativeDB/map/trace/scratch external; not independent wholemappedlogic reconstruction'))
# Offline receipts only; no bit/DB object transport.
for n in ['RESULT.json','INPUT_WHITELIST.json','ACTUAL_GENERATED_OPTIONS.json','NATIVE_EXIT_RECEIPT.json','DERIVATION.json','options_preflight.py','run_conversion.py','ARTIFACT_IGNORE_RECEIPT.json','HANDBACK.json','HANDBACK_MANIFEST.json','PRE_NATIVE_ARCHIVE.json','POST_NATIVE_ARCHIVE.json','tool.log']:
 add(O/n,'offline')
# Constraints/proof origin closures explicitly selected; mapped files external.
for n in ['ALIAS195_PROOF.json','ALIAS195_CANDIDATE.sdc']:
 add(B/'reason20_repair_20261017/physical_discovery_170512'/n,'constraints/195')
for n in ['WORK_V2_FINITE_ACCEPTANCE.md','WORK_CURRENT_PHYSICAL_BOUNDARY_REVIEW.json','WORK_OFFLINE_R20_ACCEPTANCE.json','WORK_ALIAS195_APPROVAL.json']:
 add(B/'work_check'/n,'Work/read_only_acceptance')
# Deterministic content-addressed gzip; stream compression and validation.
for (scope,name,h),(p,x) in sorted(selected.items()):
 obj=C/'objects'/h[:2]/(h+'.gz');obj.parent.mkdir(parents=True,exist_ok=True)
 if not obj.exists():
  with p.open('rb') as src,obj.open('wb') as raw,gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0,compresslevel=6) as dst:shutil.copyfileobj(src,dst,1048576)
 hh=hashlib.sha256();count=0
 with gzip.open(obj,'rb') as f:
  for b in iter(lambda:f.read(1048576),b''):hh.update(b);count+=len(b)
 assert hh.hexdigest()==h and count==x['bytes']
 mapping.append(dict(scope=scope,original_path=name,source=str(p.relative_to(R)),**x,object=obj.relative_to(C).as_posix()))
(C/'TRANSPORT_INDEX.json').write_text(json.dumps(dict(schema=1,mappings=mapping,scope_groups=groups,external=external),indent=2));print('mappings',len(mapping),'objects',len({x['sha256'] for x in mapping}),'logicalbytes',sum(x['bytes'] for x in mapping),'external',len(external))
