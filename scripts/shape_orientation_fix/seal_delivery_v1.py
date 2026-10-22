"""Freeze reviewable copies of fresh evidence; never stage or commit."""
from common import *
import shutil, datetime, zlib
F,P=active_pair=(lambda a:(R/a['path'],R/a['project']))(json.loads((O/'ACTIVE_PHYSICAL.json').read_text()))
physical=json.loads((O/'PHYSICAL_CLOSED_RECEIPT.json').read_text());assert physical['passed']
i2c=json.loads((O/'I2C_GATE_RECEIPT.json').read_text());assert i2c['passed'] and i2c['serial_negative']['rejected']
bit=json.loads((O/'pre_candidate/BITSTREAM_METADATA.json').read_text());assert bit['passed']
old=json.loads((O/'PARENT_SOURCE_MANIFEST.json').read_text());new=json.loads((O/'SOURCE_MANIFEST.json').read_text());verify(old);verify(new);assert len(old)==len(new)==91
lookup={x['path']:x for x in old};delta=[]
for x in new:
 parentpath=x['path'].replace('efinity/shape_orientation_fix_i3/','efinity/shape_standalone_i3/');y=lookup[parentpath]
 if x['sha256']!=y['sha256']:
  assert x['path'].endswith('/I2C_AR0135_1280720_Config.v');assert (R/x['path']).read_bytes()==(R/y['path']).read_bytes().replace(b"{16'h3040, 16'h8000}",b"{16'h3040, 16'hC000}");delta.append(dict(parent=y,new=x))
assert len(delta)==1
save(O/'FINAL_SOURCE_DELTA.json',dict(passed=True,parent='973f6cc2bd997a2f375d1bdb4834ffef8435369c',old_count=91,new_count=91,changed=delta,unchanged_count=90,pins_clocks_constraints_top_resolution_unchanged=True,old_input_hashes_preserved=True))
A=O/'candidate_assets';D=O/'candidate_evidence';A.mkdir();(D/'objects').mkdir(parents=True)
image=R/bit['image']['path'];artifacts=[]
for name in ['Ti60_Demo.bit','Ti60_Demo.bit.bin','Ti60_Demo.hex','Ti60_Demo.hex.bin']:
 src=image.parent/name;assert src.is_file();dst=A/name;shutil.copyfile(src,dst);assert src.read_bytes()==dst.read_bytes();artifacts.append(dict(source=rec(src),copy=rec(dst)))
assert bytes.fromhex(''.join((A/'Ti60_Demo.hex').read_text().split()))==(A/'Ti60_Demo.hex.bin').read_bytes()
save(A/'ARTIFACT_METADATA.json',dict(passed=True,artifacts=artifacts,offline_generation=bit,no_hardware_used=True,no_program_option=True,source_manifest=rec(O/'SOURCE_MANIFEST.json'),physical_receipt=rec(F/'FINAL_PHYSICAL_RECEIPT.json')))
# Include human-readable fresh logs, exact queries/map, reports and receipts.
# Opaque databases/libraries and duplicate mirror source copies stay local hash references.
roots=[F,R/json.loads((O/'pre_candidate/ACTIVE_BIT_GENERATION.json').read_text())['path']]
roots += [p for p in O.glob('i2c_*') if p.is_dir()]
files=set(p for root in roots for p in root.rglob('*') if p.is_file())
technical_root_names=['ACTIVE_PHYSICAL.json','CLOCK_AUDIT_V4_DERIVATION.json','COMPILE_SOURCE_FILES.json','FINAL_SOURCE_DELTA.json','FULL_NATIVE_STA_EXECUTION_RECEIPT.json','I2C_GATE_RECEIPT.json','MANAGER_EXCEPTION.json','PARENT_SOURCE_MANIFEST.json','PHYSICAL_CLOSED_RECEIPT.json','PHYSICAL_FINAL_RECEIPT.json','PHYSICAL_STAGE_COMPLETE.json','PROJECT_DERIVATION.json','REVIEW_GUIDE.md','SENSOR_EVIDENCE.md','SOURCE_CLOSURE.json','SOURCE_MANIFEST.json','STANDALONE_EXACT_GROUPS.json','TOOL_DERIVATION.json']
files.update(O/n for n in technical_root_names)
selected=[];excluded=[];objects={}
for p in sorted(files):
 x=rec(p);parts=p.relative_to(O).parts
 if any(v in parts for v in ['work','work_syn','work_pnr','work_query','routed_db_archive_v2']):excluded.append(dict(source=x,reason='Opaque/generated DB kept local'));continue
 if 'mirror' in parts and 'outflow' not in parts and p.suffix.lower()not in ['.txt','.tsv','.sdc']:excluded.append(dict(source=x,reason='Duplicate mirror production source; exact new project is primary scope'));continue
 b=p.read_bytes()
 try:
  if b'\0' in b:raise UnicodeError()
  b.decode('utf-8-sig')
 except UnicodeError:excluded.append(dict(source=x,reason='Native binary kept local'));continue
 # Bit/HEX artefacts are bound separately, not duplicated in text objects.
 if p.suffix in ['.bit','.hex','.bin']:continue
 q=D/'objects'/(x['sha256']+'.txt')
 if not q.exists():q.write_bytes(b)
 y=rec(q);assert x['sha256']==y['sha256'] and x['bytes']==y['bytes'];objects[y['path']]=y;selected.append(dict(source=x,object=y))
save(D/'SOURCE_TO_OBJECT_INDEX.json',dict(records=selected,count=len(selected),unique_objects=len(objects),bytes=sum(x['bytes']for x in objects.values()),scope='Fresh run only, including real logs/query text and actual mapped/native endpoint evidence. Parent full-video evidence remains in parent commit. All objects preserve exact original bytes.'))
save(D/'EXCLUDED_LOCAL_REFERENCES.json',dict(records=excluded,count=len(excluded),scope='Generated databases and duplicate mirror sources; no hidden bundle or private user file.'))
final=json.loads((F/'FINAL_PHYSICAL_RECEIPT.json').read_text());native=json.loads((F/'NATIVE_ALL_FF_COVERAGE.json').read_text())
delivery=dict(status='PASS_OFFLINE_ORIENTATION_FIX_AWAIT_WORK_SCOPE_AND_FIXED_CANDIDATE_REVIEWS',passed=True,running=False,branch='codex/m5c-fusion-prototype',HEAD='973f6cc2bd997a2f375d1bdb4834ffef8435369c',HEAD_parent='821387c43a3999acb25438cd8982619b09a0a019',candidate=None,candidate_parent='973f6cc2bd997a2f375d1bdb4834ffef8435369c',technical_change='LUT18 R3040 8000 -> C000, XOR4000 only',source_delta=rec(O/'FINAL_SOURCE_DELTA.json'),sensor_evidence=rec(O/'SENSOR_EVIDENCE.md'),tests=rec(O/'I2C_GATE_RECEIPT.json'),physical=rec(O/'PHYSICAL_CLOSED_RECEIPT.json'),resource=final['resource'],normal=final['normal'],native_FFs=native['native_FF_count'],encrypted_DDR_FFs=native['encrypted_partition_FF_count'],legacy_PLL_async_SR_UNTIMED_NOT_PASS=final['legacy_PLL_async_SR_UNTIMED_NOT_PASS'],artifact_metadata=rec(A/'ARTIFACT_METADATA.json'),evidence_index=rec(D/'SOURCE_TO_OBJECT_INDEX.json'),hardware_next=False,git_mutated=False,limits=['Sensor identity and corrected physical scene direction still require user hardware verification after independent review.','Parent 72-frame evidence retained; no repeated/new video qualification claimed.','Six inherited PLL async SR untimed records, external 7 inputs/135 outputs, PVT and warm-reset restrictions remain.','No Programmer/JTAG/Flash operation. No independent review has been performed by this writer.'])
save(O/'OFFLINE_FINAL_RECEIPT.json',delivery)
primary=sorted([p for root in [R/'efinity/shape_orientation_fix_i3',R/'tb/shape_orientation_fix',R/'scripts/shape_orientation_fix']for p in root.rglob('*')if p.is_file()and '__pycache__'not in p.parts])
evidence=sorted([p for root in [A,D]for p in root.rglob('*')if p.is_file()])
reports=[O/n for n in ['OFFLINE_FINAL_RECEIPT.json','REVIEW_GUIDE.md','SENSOR_EVIDENCE.md','FINAL_SOURCE_DELTA.json','I2C_GATE_RECEIPT.json','SOURCE_MANIFEST.json','PARENT_SOURCE_MANIFEST.json','PROJECT_DERIVATION.json','TOOL_DERIVATION.json','PHYSICAL_CLOSED_RECEIPT.json','evidence/jevois_ar0135_pinned.c','evidence/jevois_commit.txt','evidence/jevois_linux_COPYING.txt']]
scope=[rec(p)for p in sorted(set(primary+evidence+reports))]
save(O/'REVIEW_SCOPE_PROPOSAL.json',dict(status='PROPOSED_EXACT_FILES_NOT_STAGED',count=len(scope),bytes=sum(x['bytes']for x in scope),records=scope,private_files_included=False,opaque_tool_databases_included=False,git_action='None; Work approves explicit list and new candidate before independent reviews.'))
(O/'STAGE_PATHS_PROPOSED.txt').write_text(''.join(x['path']+'\n'for x in scope),encoding='utf8')
save(O/'HEARTBEAT.json',dict(status='PASS',running=False,phase='OFFLINE_COMPLETE_AWAIT_WORK',updated_unix=time.time(),native_running=False,hardware_next=False))
d=json.loads((O/'PHASE_RESULT.json').read_text());d.update(status='PASS',passed=True,running=False,phase='OFFLINE_COMPLETE_AWAIT_WORK_SCOPE_AND_FIXED_CANDIDATE_REVIEWS',final_receipt=rec(O/'OFFLINE_FINAL_RECEIPT.json'),scope_proposal=rec(O/'REVIEW_SCOPE_PROPOSAL.json'),hardware_next=False);save(O/'PHASE_RESULT.json',d)
print('ORIENTATION_OFFLINE_DELIVERY_READY',len(scope),sum(x['bytes']for x in scope),flush=True)
