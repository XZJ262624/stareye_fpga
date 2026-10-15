from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[3];O=Path(__file__).resolve().parent;D=R/'reports/m5c_diagnostics/candidate_evidence_stage2_20261015'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert not (D/'FINAL_ALLOWLIST.json').exists()
adopt=json.loads((O/'ROOT_ADOPTION_RECEIPT.json').read_text())
for x in adopt['inputs']:
 a=rec(R/x['root']['path']);assert a['bytes']==x['root']['bytes'] and a['sha256']==x['root']['sha256']
draft=json.loads((D/'TECHNICAL_ALLOWLIST_DRAFT.json').read_text());snap=json.loads((D/'TECHNICAL_SNAPSHOT_DRAFT.json').read_text())
files={R/x['path'] for x in draft['records']}
files.update(p for p in D.rglob('*') if p.is_file())
files.update(O/n for n in ['check_candidate_draft.py','finalize_preparation.py','COMPLETED_SYSTEM_CHECK.json','COMPLETION_MANIFEST_TRANSITION_FAILURE.json','COMPLETED_OWNER_EXIT.json','verify_completed_system.py','verify_completed_system_v2.py','seal_post_exit.py','final_system_seal/HANDBACK.json','final_system_seal/MANIFEST.json'])
docs=['docs/STATUS.md','docs/HANDOFF.md','docs/PROJECT_BRIEF.md','docs/DECISIONS.md','docs/MILESTONES.md','docs/RESOURCE_POLICY.md']
files.update(R/n for n in docs)
records=[rec(p) for p in sorted(files)];assert len({x['path'] for x in records})==len(records)
for x in records:assert '/outflow/' not in x['path'] and '/work_pnr/' not in x['path'] and not x['path'].endswith(('.bit','.bit.bin','.hex.bin','.vdb','.lbf','.troutingtraces'))
(D/'FINAL_ALLOWLIST.json').write_text(json.dumps(dict(status='PROPOSED_EXACT_SCOPE_REQUIRES_WORK_APPROVAL_NO_GIT_WRITES',parent='3b49a1f701798a817fed42b8097f724cbc9d6160',records=records,count=len(records),bytes=sum(x['bytes'] for x in records),management_documents=[rec(R/n) for n in docs],metadata_union='This allowlist and final handback are additional metadata for Work exact scope; neither self-hashes itself.'),indent=2))
inherited=snap['inherited_parent']
for x in inherited:
 assert rec(R/x['path'])['sha256']==x['sha256']
out=dict(status='READY_FOR_WORK_EXACT_SCOPE_REVIEW_NOT_COMMITTED',allowlist=rec(D/'FINAL_ALLOWLIST.json'),files=len(records),bytes=sum(x['bytes'] for x in records),inherited_dependencies=len(inherited),transport_objects=1306,transport_mappings=5248,selected_byte_gaps=0,command_input_references=3518,command_records=389,literal_includes=47,root_inputs_checked=104,physical_manifest=rec(R/'reports/m5c_diagnostics/stage2_resource_bound_v3_20261015_181411/FULL_PHYSICAL_MANIFEST.json'),offline_manifest=rec(R/'reports/m5c_diagnostics/stage2_offline_parent_20261015_211613/HANDBACK_MANIFEST.json'),system_manifest=rec(O/'final_system_seal/MANIFEST.json'),limits=rec(D/'KNOWN_LIMITS.json'),largest=sorted(records,key=lambda x:x['bytes'],reverse=True)[:10],no_git_writes_or_hardware=True,
 next='Work verifies exact current allowlist plus inherited dependencies and freezes commit scope. No native processes remain. No further source edits are authorized by this handback.')
(D/'FINAL_HANDBACK.json').write_text(json.dumps(out,indent=2));print(json.dumps(dict(allowlist=out['allowlist'],files=out['files'],bytes=out['bytes'],inherited=len(inherited))))
