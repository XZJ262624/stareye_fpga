from pathlib import Path
import json,hashlib,difflib,subprocess,os
F=Path(__file__).resolve().parent;R=F.parents[2];B=F.parent/'fresh_i3_build_20261014';OLD=F.parent/'offline_artifact_20261014'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(n,x):
 p=F/n;assert not p.exists();p.write_text(json.dumps(x,indent=2));return rec(p)
def chk(x):
 z=rec(R/x['path']);assert z['bytes']==x['bytes'] and z['sha256']==x['sha256'];return z
assert json.loads((F/'RESULT.json').read_text())['status']=='PASS_OFFLINE_CONVERSION_ONLY'
assert json.loads((F/'NATIVE_EXIT_RECEIPT.json').read_text())['exit']==0
assert json.loads((F/'EXIT_NATIVE_CIM.json').read_text(encoding='utf-8-sig'))==[]
counts={}
for label,p in [('fresh700',B/'HANDBACK_MANIFEST.json'),('old_attempt',OLD/'PARTIAL_MANIFEST.json')]:
 xs=json.loads(p.read_text())['records'];[chk(x) for x in xs];counts[label]=len(xs)
protection=json.loads((F.parent/'SOURCE_PROTECTION.json').read_text());[chk(x) for x in protection];counts['protected']=len(protection)
selected=json.loads((F.parent/'final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json').read_text())['records'];[chk(x['adopted']) for x in selected];counts['selected']=len(selected)
pre=json.loads((B/'PREFLIGHT.json').read_text());proof=[];total=0
for p in pre['proofs']:
 chk(p['manifest']);q=R/p['manifest']['path'];xs=json.loads(q.read_text())['records'];[chk(x) for x in xs];total+=len(xs);proof.append(dict(manifest=rec(q),records=len(xs)))
assert total==9569;counts['functional_and_focused_records']=total
for n in ['PRE_NATIVE_ARCHIVE.json','POST_NATIVE_ARCHIVE.json']:
 for x in json.loads((F/n).read_text())['records']:chk(x['archive']);assert x['archive']['sha256']==x['original']['sha256']
old=(OLD/'run_conversion.py').read_text();new=(F/'run_conversion.py').read_text();put('RETRY_DERIVATION.json',dict(freeze=rec(F.parent/'OFFLINE_CONVERSION_RECEIPT_RETRY_20261014.md'),parent_runner=rec(OLD/'run_conversion.py'),current_runner=rec(F/'run_conversion.py'),diff=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True))),same_prepare_bytes=(OLD/'prepare.py').read_bytes()==(F/'prepare.py').read_bytes(),same_option_parser_bytes=(OLD/'options_preflight.py').read_bytes()==(F/'options_preflight.py').read_bytes(),original_attempt_status='NOT_FINAL_GATE_UNCHANGED'))
os.environ['GIT_OPTIONAL_LOCKS']='0';git=['git','-c','safe.directory=F:/Projects/stareye_fpga'];head=subprocess.check_output(git+['rev-parse','HEAD'],cwd=R,text=True).strip();assert head==pre['head'];assert not subprocess.check_output(git+['diff','--cached','--name-only'],cwd=R,text=True).strip()
result=json.loads((F/'RESULT.json').read_text());arts=result['artifacts'];ignore=subprocess.run(git+['check-ignore','--']+[x['path'] for x in arts],cwd=R,text=True,capture_output=True);assert ignore.returncode==0 and len(ignore.stdout.splitlines())==4
technical=[chk(x['adopted']) for x in selected];evidence=[]
names=['FINAL_HANDBACK.json','HANDBACK_MANIFEST.json','TIMING_CURRENT_AUDIT.json','GLOBAL_D_COVERAGE_CURRENT.json','CONTROL_COVERAGE_CURRENT.json','BUNDLE_CURRENT_AUDIT.json','EXTERNAL_IO_BOUNDARY.json','CURRENT_SDC_ALIAS_RECEIPT.json','RAM_PHYSICAL_CONSTANT_DIFFERENCES.json','ARCHIVE_CHAIN_AUDIT.json','PROTECTION_FINAL.json','MAPPED_AUDIT_GATE.json','CURRENT_SCOPED_TARGETS.json','AUDIT_V1_FAILURE_RECEIPT.json','AUDIT_V2_DERIVATION.json','AUDIT_V3_DERIVATION.json','audit_current_timing_v3.py','run_stage.py','run_queries.py','prepare.py']
evidence += [rec(B/n) for n in names]
for p in pre['proofs']:
 q=R/p['manifest']['path'];evidence.append(rec(q))
 for n in ['GATE_HANDBACK.json','FINAL_HANDBACK.json','RESULT.json']:
  if (q.parent/n).is_file():evidence.append(rec(q.parent/n))
evidence += [rec(F/n) for n in ['INPUT_WHITELIST.json','ACTUAL_GENERATED_OPTIONS.json','NATIVE_EXIT_RECEIPT.json','RESULT.json','RETRY_DERIVATION.json','prepare.py','options_preflight.py','run_conversion.py','seal.py']]
put('CANDIDATE_PREPARATION_PLAN.json',dict(status='EXACT_PROPOSED_LIST_PLAN_ONLY_REQUIRES_WORK_SCOPE_FREEZE',technical101=technical,proposed_reproducible_evidence_index=list({x['path']:x for x in evidence}.values()),proof_indices=proof,artifact_metadata=arts,excluded=['Programming artifacts remain ignored/untracked; separately distributed hash-bound evidence only','Multi-GB content archives, raw pixel/UART traces and ModelSim libraries excluded from proposed Git scope; referenced by exact external manifests','Copied toolkits, secrets, unrelated files and unselected experiments excluded','Historical failures preserved in original locations, never relabelled PASS'],remaining_packaging_decision='This list is a compact technical+evidence-index proposal. Work must freeze how external raw proof and exact fixture source dependencies are made available to independent reviewers before candidate staging; this plan does not claim the index alone reproduces all17 tests.',desired_docs_updates=['STATUS/HANDOFF/DECISIONS:17 functional scopes, actual I3/source identity, artifact hashes and no board/PVT claim','Record default-UART startup inference, model acceleration boundary, cold-only fault, narrow hold and external7/135 boundary','Fixed candidate parent and independent A/B review instructions only after exact candidate approved'],required_attributes='No current attributes modification. Future Work review should preserve binary DDR ROM bytes and deterministic text handling, exclude build artifacts, and approve any attributes path explicitly.',git_actions='NONE'))
hand=put('FINAL_HANDBACK.json',dict(status='PASS_OFFLINE_ARTIFACT_GENERATION_STOP_FOR_WORK_CANDIDATE_SCOPE',branch=pre['branch'],head=head,parent=pre['parent'],candidate=None,artifacts=arts,native_exit=rec(F/'NATIVE_EXIT_RECEIPT.json'),tool_options=rec(F/'ACTUAL_GENERATED_OPTIONS.json'),input_database_binding=rec(F/'INPUT_WHITELIST.json'),qualified_build=rec(B/'FINAL_HANDBACK.json'),device='Ti60F225',family='Titanium',timing_model='I3',seed=1,resource=json.loads((B/'FINAL_HANDBACK.json').read_text())['resources'],protection=counts,owned_native_exited=True,ignored_artifacts=ignore.stdout.splitlines(),limits=['Offline conversion only. No programmer/device/JTAG/Flash/serial connection or hardware acceptance.','I3-only qualified timing; hold +0.016ns remains narrow, not multi-PVT qualification.','Original conversion missing exit receipt remains NOT_FINAL_GATE; new repeat exit0 is independently captured.','Disabled security emits IV warning; no encryption/auth enabled or keys changed.','No Git or main management-document mutation. Candidate plan is not a candidate commit.']))
man=put('HANDBACK_MANIFEST.json',dict(records=[rec(p) for p in sorted(F.rglob('*')) if p.is_file() and p.name!='HANDBACK_MANIFEST.json']))
print(json.dumps(dict(handback=hand,manifest=man,counts=counts)),flush=True)
