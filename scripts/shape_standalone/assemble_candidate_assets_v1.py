"""Create deterministic gold archive and source-mapped readable evidence objects.
Writes only new candidate_assets/candidate_evidence and current pre-candidate management.
Does not execute simulation, P&R, STA, Git, programmer, or golden generators.
"""
from common import *
import zipfile,zlib,shutil,datetime,collections
W=O/'pre_candidate';A=O/'candidate_assets';D=O/'candidate_evidence'
assert not A.exists()and not D.exists();A.mkdir();D.mkdir();(D/'objects').mkdir()
def phase(n,**kw):
 save(W/'PRE_CANDIDATE_HEARTBEAT.json',dict(status='RUNNING',running=True,phase=n,updated_unix=time.time(),manager_pid=os.getpid(),**kw))
 d=json.loads((W/'PRE_CANDIDATE_RESULT.json').read_text(encoding='utf-8-sig'));d.update(status='RUNNING',running=True,phase=n,updated_unix=time.time());save(W/'PRE_CANDIDATE_RESULT.json',d)
def archive(path,items):
 # Stable order, fixed timestamp/mode, identical unmodified input bytes.
 with zipfile.ZipFile(path,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=6,allowZip64=True)as z:
  for i,x in enumerate(items):
   q=R/x['path'];assert rec(q)==x
   zi=zipfile.ZipInfo(x['path'],(2026,10,21,0,0,0));zi.compress_type=zipfile.ZIP_DEFLATED;zi.create_system=3;zi.external_attr=0o100644<<16
   with q.open('rb')as src,z.open(zi,'w',force_zip64=True)as dst:shutil.copyfileobj(src,dst,1024*1024)
   if i%50==0:phase('GOLD_ARCHIVE_WRITE',completed=i,total=len(items))
 with zipfile.ZipFile(path)as z:
  assert z.namelist()==[x['path']for x in items]
  for i,x in enumerate(items):
   h=hashlib.sha256();n=0
   with z.open(x['path'])as src:
    while True:
     b=src.read(1024*1024)
     if not b:break
     h.update(b);n+=len(b)
   assert n==x['bytes']and h.hexdigest()==x['sha256'],x['path']
   if i%100==0:phase('GOLD_ARCHIVE_BYTE_VERIFICATION',completed=i,total=len(items))
 return rec(path)
try:
 phase('GOLD_ARCHIVE_PRE_VERIFY')
 gold=json.loads((W/'EXTERNAL_TEST_DEPENDENCIES.json').read_text())['records'];assert len(gold)==727
 gold=sorted(gold,key=lambda x:x['path']);save(A/'GOLD_MANIFEST.json',dict(schema='shape_standalone_gold_v1',count=727,bytes=sum(x['bytes']for x in gold),records=gold,source='Exact runtime frozen dependencies recorded in actual gates, no golden re-generation.'))
 g=archive(A/'frozen_test_assets.zip',gold)
 # Reference model/provenance sources are reviewable code, not executed generators.
 provenance=[
 'scripts/gaussian_integration/stage2/spatial_gold.py',
 'scripts/gaussian_integration/cap_host_v1/model_b.py',
 'scripts/gaussian_integration/cap_host_v1/generate_gray.py',
 'scripts/gaussian_integration/cap_host_v1/freeze_definitions.py',
 'scripts/shape_recognition/model.py',
 'scripts/gaussian_integration/shape_model_frozen.py',
 'scripts/gaussian_cap_integration/generate_new128_gold.py',
 'reports/gaussian_cap_remote_v2_20261021/package/gaussian_matrix_gold/CASES.json',
 'reports/gaussian_integration_20261020/cap_host_gate_20261020/DEFINITIONS_BEFORE_MODEL_GOLD.json',
 'reports/gaussian_integration_20261020/stage2_components_20261020_180220/CASES.json']
 proof=[];(A/'oracle_sources').mkdir()
 for n in provenance:
  q=R/n;x=rec(q);dest=A/'oracle_sources'/(x['sha256']+'_'+q.name);shutil.copyfile(q,dest);assert dest.read_bytes()==q.read_bytes();proof.append(dict(source=x,copy=rec(dest)))
 save(A/'ORACLE_PROVENANCE.json',dict(records=proof,scope='Independent reference model, original definitions and selected case metadata, read-only provenance. Models/generators are not run or retuned. Runtime closure remains727 exact assets. Imported old scripts may depend on original layout; reproduction restores declared assets, and current native RTL runners consume frozen gold directly.'))
 phase('SEALED_EVIDENCE_OBJECT_COLLECTION')
 sealed_manifest=json.loads((O/'FINAL_EVIDENCE_MANIFEST.json').read_text());entries=sealed_manifest['records'];assert len(entries)==3213
 selected=[];excluded=[];objects={};stats=collections.Counter()
 def collect(x,origin):
  q=R/x['path'];assert rec(q)==x,x['path'];parts=q.relative_to(O).parts
  if any(s in parts for s in ['work','work_syn','work_pnr','work_query','routed_db_archive_v2']):
   excluded.append(dict(source=x,reason='Generated simulator/native database tree; archive hash reference only'));return
  b=q.read_bytes()
  try:
   if b'\0'in b:raise UnicodeError('NUL')
   b.decode('utf-8-sig')
  except UnicodeError:
   excluded.append(dict(source=x,reason='Native binary/generated object, not reviewable text; archive hash reference only'));return
  # Immutable content-addressed text objects preserve full original bytes and names via index.
  target=D/'objects'/(x['sha256']+'.txt')
  if not target.exists():target.write_bytes(b)
  obj=rec(target);assert obj['bytes']==x['bytes']and obj['sha256']==x['sha256'];objects[obj['path']]=obj
  selected.append(dict(source=x,object=obj,origin=origin));stats[origin]+=1
 for i,x in enumerate(entries):
  collect(x,'sealed_3213')
  if i%250==0:phase('SEALED_EVIDENCE_OBJECT_COLLECTION',completed=i,total=3213)
 collect(rec(O/'FINAL_EVIDENCE_MANIFEST.json'),'sealed_manifest')
 # Every current/historical local helper is source-mapped evidence. Only chosen current
 # primary helpers are standalone executable entries; no historical one is relabelled.
 for q in sorted((R/'scripts/shape_standalone').glob('*.py')):
  x=rec(q);b=q.read_bytes();target=D/'objects'/(x['sha256']+'.txt');target.write_bytes(b);obj=rec(target);objects[obj['path']]=obj;selected.append(dict(source=x,object=obj,origin='standalone_helper_provenance'))
 bit=json.loads((W/'BITSTREAM_METADATA.json').read_text());assert bit['passed'];image=R/bit['image']['path'];(A/'artifacts').mkdir()
 copied=[]
 for n in ['Ti60_Demo.hex','Ti60_Demo.hex.bin']:
  q=image.parent/n;t=A/'artifacts'/n;shutil.copyfile(q,t);assert q.read_bytes()==t.read_bytes();copied.append(dict(source=rec(q),copy=rec(t),crc32_file_bytes=f'{zlib.crc32(t.read_bytes())&0xffffffff:08x}'))
 hexbytes=bytes.fromhex(''.join(image.read_text().split()));binary=image.with_name('Ti60_Demo.hex.bin').read_bytes();assert hexbytes==binary
 bitrecord=dict(status='PASS_ACTUAL_ARTIFACT_COPY_HEX_PAYLOAD_EQUALS_BINARY',passed=True,original_bit_generation=bit,artifacts=copied,payload_bytes=len(binary),payload_sha256=hashlib.sha256(binary).hexdigest(),payload_crc32=f'{zlib.crc32(binary)&0xffffffff:08x}',note='File CRC of ASCII HEX differs from decoded payload CRC. Both are explicitly reported. No hardware or program command used.')
 save(A/'ARTIFACT_METADATA.json',bitrecord)
 B=(R/json.loads((W/'ACTIVE_BIT_GENERATION.json').read_text())['path'])
 for q in sorted(B.iterdir()):
  if q.is_file():collect(rec(q),'offline_pgm_run')
 for n in ['Ti60_Demo.pgm.out','Ti60_Demo.log']:
  collect(rec(image.parent/n),'offline_pgm_tool_output')
 save(D/'SOURCE_TO_OBJECT_INDEX.json',dict(schema='shape_standalone_readable_evidence_v1',records=selected,count=len(selected),unique_objects=len(objects),object_bytes=sum(x['bytes']for x in objects.values()),scope_counts=stats,excluded_count=len(excluded),notes=['Every selected byte equals original source, including original FAIL, pending, revoked selectors and finalPASS.','Excluded binary DBs/simulator libraries are archival hashes only, not present in fixed review scope.','Primary source formal project is separately included in candidate. Content-addressed text avoids deep Windows paths and duplicate records.','Original full3213 manifest is included as a readable object; no claim excluded files are in candidate.']))
 save(D/'EXCLUDED_DATABASE_REFERENCES.json',dict(records=excluded,count=len(excluded),scope='Reference only. No opaque binary DB is shipped as readable proof or hidden in a tool bundle.'))
 save(D/'OBJECT_MANIFEST.json',dict(records=sorted(objects.values(),key=lambda x:x['path']),count=len(objects),bytes=sum(x['bytes']for x in objects.values())))
 verify(json.loads((O/'SOURCE_MANIFEST.json').read_text()));verify(gold)
 save(A/'ARCHIVE_VERIFICATION.json',dict(passed=True,archive=g,manifest=rec(A/'GOLD_MANIFEST.json'),verified_entries=727,verified_uncompressed_bytes=sum(x['bytes']for x in gold),method='ZIP every entry streamed through SHA256/size and ZIP CRC; exact ordered manifest match. Isolated materialization check performed separately.',source_bytes_unchanged=True,model_or_truth_regenerated=False))
 save(W/'ASSET_ASSEMBLY_RECEIPT.json',dict(passed=True,running=False,manager_pid=os.getpid(),gold_archive=g,artifact_metadata=rec(A/'ARTIFACT_METADATA.json'),evidence_index=rec(D/'SOURCE_TO_OBJECT_INDEX.json'),evidence_objects=rec(D/'OBJECT_MANIFEST.json'),excluded_db_references=rec(D/'EXCLUDED_DATABASE_REFERENCES.json'),gold_count=727,evidence_selected=len(selected),unique_objects=len(objects),scope='Assembly only; current final stage remainsRUNNING until materialization, exactcandidate inventory andclosure finish.',hardware_used=False,git_mutated=False))
 phase('ASSET_ASSEMBLED_AWAIT_MATERIALIZATION_AND_EXACT_SCOPE');print('STANDALONE_CANDIDATE_ASSETS_ASSEMBLED',len(selected),len(objects),g['bytes'],flush=True)
except Exception as e:
 save(W/'ASSET_ASSEMBLY_RECEIPT.json',dict(passed=False,running=False,error=repr(e)));save(W/'PRE_CANDIDATE_RESULT.json',dict(status='FAIL_CANDIDATE_ASSET_ASSEMBLY',passed=False,running=False,error=repr(e),hardware_next=False));raise
