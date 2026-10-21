"""Freeze actual proposed paths for Work; no staging/commit or technical reruns."""
from common import *
import datetime
W=O/'pre_candidate';A=O/'candidate_assets';D=O/'candidate_evidence';F=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path']
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
assert read(W/'ASSET_ASSEMBLY_RECEIPT.json')['passed'];restore=O/'restore_candidate_v1';r=read(restore/'RESTORE_RESULT.json');assert r['passed']and r['compile100us_executed']and not r['full72_executed']and not r['physical_reexecuted']
save(A/'MATERIALIZATION_AND_COMPILE100US.json',dict(passed=True,scope='Exact114+727 materialized to new isolated root and current unchanged cleanrunner compiled/elaborated100us. No72/P&R/STA repetition.',restore_result=rec(restore/'RESTORE_RESULT.json'),actual_result=r,compile_runner=rec(R/'scripts/shape_standalone/run_video.py'),restore_helper=rec(R/'scripts/shape_standalone/restore_candidate_assets_v1.py')))
supp=[];objects={x['path']:x for x in read(D/'OBJECT_MANIFEST.json')['records']}
def collect(q,origin):
 x=rec(q);b=q.read_bytes();b.decode('utf-8-sig');t=D/'objects'/(x['sha256']+'.txt')
 if not t.exists():t.write_bytes(b)
 y=rec(t);assert y['bytes']==x['bytes']and y['sha256']==x['sha256'];objects[y['path']]=y;supp.append(dict(source=x,object=y,origin=origin))
for q in sorted(restore.rglob('*')):
 if q.is_file()and(q.name=='RESTORE_RESULT.json'or q==restore/'compile100us.log'or q.is_relative_to(restore/'reports/shape_standalone_20261021/video_current_probe_20261021_185952')):
  if 'work'not in q.relative_to(restore).parts:collect(q,'isolated_materialization_compile100us')
support=['generate_offline_image_v1.py','assemble_candidate_assets_v1.py','restore_candidate_assets_v1.py','read_candidate_evidence_v1.py','seal_candidate_scope_v1.py']
for n in support:collect(R/'scripts/shape_standalone'/n,'candidate_support_helper')
collect(A/'MATERIALIZATION_AND_COMPILE100US.json','isolated_materialization_summary')
save(D/'SUPPLEMENTAL_OBJECT_INDEX.json',dict(count=len(supp),records=supp,scope='Additions only. Original sealed3213 inputs/records and first source-to-object index are unchanged.'))
index=read(D/'SOURCE_TO_OBJECT_INDEX.json');excluded=read(D/'EXCLUDED_DATABASE_REFERENCES.json')['records'];base={x['source']['path']:x for x in index['records']if x['origin']=='sealed_3213'};exc={x['source']['path']:x for x in excluded};full=read(O/'FINAL_EVIDENCE_MANIFEST.json')['records'];assert set(base).isdisjoint(exc)and set(base)|set(exc)=={x['path']for x in full}
for x in index['records']+supp:
 y=rec(R/x['object']['path']);assert y==x['object']and y['bytes']==x['source']['bytes']and y['sha256']==x['source']['sha256']
required=[O/n for n in ['OFFLINE_FINAL_RECEIPT.json','FULL720P_FINAL_RECEIPT.json','PHYSICAL_CLOSED_RECEIPT.json','FULL_NATIVE_STA_EXECUTION_RECEIPT.json','CORE_GATE_RECEIPT.json','COMPONENT_GATE_RECEIPT.json','SYSTEM720P_KEY_POLARITY_FIXTURE_RECOVERY.json','FAILED_VIDEO_SCOPE_FACTS_V2.json','RUNNER_HELPER_RECONCILIATION.json','SOURCE_MANIFEST.json','PROTECTED_INPUTS_POST.json']]
required += [F/n for n in ['FINAL_PHYSICAL_RECEIPT.json','NATIVE_PRIMITIVE_CLOCK_COVERAGE_V3.json','NATIVE_ALL_FF_COVERAGE.json','METADATA_FIELD_MAPPING.json','METADATA_TIMING_COVERAGE.json','SHAPE_RAM_ADDRESS_MAPPING.json','EXTERNAL_BOUNDARY_CONTINUITY.json','STANDALONE_PIXEL_MAPPED_CONES_V2.json']]
required += [O/n for n in ['system720p_72_173637/native.log','system720p_72_173637/native_RESULT.json','system720p_72_175528/native.log','system720p_72_175528/INPUTS_PRE.json','system720p_72_175528/INPUTS_POST.json','med_sample_assessment/RESULT.json','physical_recovery_v3_20261021_173903/COLLECTION_RETURN_REVOCATION/REVOKED.json']]
requirements=[]
for q in required:
 name=q.relative_to(R).as_posix();assert name in base,name;requirements.append(dict(source=base[name]['source'],object=base[name]['object']))
reports=[x for x in full if x['path'].startswith(F.relative_to(R).as_posix()+'/mirror/')and x['path'].endswith('.rpt')];assert reports and all(x['path']in base for x in reports)
save(D/'COVERAGE_ASSERTIONS.json',dict(passed=True,sealed_manifest_entries=3213,selected_original_text_entries=len(base),excluded_database_entries=len(exc),every_original_entry_classified_once=True,all_selected_object_bytes_verified=True,current_physical_raw_report_count=len(reports),all_current_physical_raw_reports_included=True,required_original_fail_pending_pass_and_boundaries=requirements,additional_isolated_probe_records=len(supp),scope='Evidence existence/byte closure, not a second independent technical review. No timing or classification assertions are relaxed.'))
primary=read(W/'PRIMARY_CANDIDATE_FILES.json')['records'];verify(primary);verify(read(W/'EXTERNAL_TEST_DEPENDENCIES.json')['records'])
payload={x['path']:x for x in primary}
for n in support:
 x=rec(R/'scripts/shape_standalone'/n);payload[x['path']]=x
for folder in [A,D]:
 for q in sorted(folder.rglob('*')):
  if q.is_file():x=rec(q);payload[x['path']]=x
# Explicit small management set; live watcher/context, raw mirrors, restore tree excluded.
for n in ['PROJECT_ROOT_EQUIVALENCE.json','BITSTREAM_METADATA.json','ASSET_ASSEMBLY_RECEIPT.json','REVIEW_PROMPT_A_READY.txt','REVIEW_PROMPT_B_READY.txt']:
 x=rec(W/n);payload[x['path']]=x
records=sorted(payload.values(),key=lambda x:x['path']);assert all(not any(part in Path(x['path']).parts for part in ['work','work_pnr','restore_candidate_v1'])for x in records)
save(W/'CANDIDATE_CONTENT_MANIFEST.json',dict(status='EXACT_PROPOSED_FILES_AWAIT_WORK_NO_STAGE',count=len(records),bytes=sum(x['bytes']for x in records),records=records,primary_files=114,support_helpers=len(support),scope='114 primary, five supporting stdlib helpers, exact frozenasset archive+models+actual artifacts, complete source-mapped readable evidence, and five explicit management files. No old working tree files, tool bundle, simulator library, binary P&R DB or1.65GB materialization tree included.',management_self_reference_note='This manifest and STAGE_PATHS.txt/PRE_CANDIDATE_RESULT.json are additional three literal paths, listed in STAGE_PATHS without recursive hash cycles. Work must hash them independently before stage.'))
stage=[x['path']for x in records]+[(W/n).relative_to(R).as_posix()for n in ['CANDIDATE_CONTENT_MANIFEST.json','STAGE_PATHS.txt','PRE_CANDIDATE_RESULT.json']];assert len(stage)==len(set(stage));(W/'STAGE_PATHS.txt').write_text('\n'.join(sorted(stage))+'\n',encoding='utf8')
save(W/'PRE_CANDIDATE_RESULT.json',dict(status='PASS_OFFLINE_IMAGE_ASSETS_EVIDENCE_AWAIT_WORK_EXACT_SCOPE',passed=True,running=False,phase='READY_FOR_WORK_SCOPE_APPROVAL_NO_STAGE_NO_COMMIT',updated_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),candidate_payload=rec(W/'CANDIDATE_CONTENT_MANIFEST.json'),exact_literal_stage_paths=rec(W/'STAGE_PATHS.txt'),proposed_file_count=len(stage),payload_bytes=sum(x['bytes']for x in records),actual_bit_metadata=rec(A/'ARTIFACT_METADATA.json'),gold_verification=rec(A/'ARCHIVE_VERIFICATION.json'),materialization_compile100us=rec(A/'MATERIALIZATION_AND_COMPILE100US.json'),full_readable_evidence_coverage=rec(D/'COVERAGE_ASSERTIONS.json'),candidate_commit=None,git_staged=False,git_committed=False,hardware_used=False,hardware_next=False,independent_reviews_started=False,protected_source91_unchanged=True,original3213_files_unchanged=True,scope='Work technical acceptance and exact candidate scope next. Independent A/B and separate hardware gates still required.'))
print('STANDALONE_PRE_CANDIDATE_READY',len(stage),sum(x['bytes']for x in records),flush=True)
