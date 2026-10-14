from pathlib import Path
import json,hashlib,xml.etree.ElementTree as ET
F=Path(__file__).resolve().parent;R=F.parents[2];B=F.parent/'fresh_i3_build_20261014';P=F/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(n,x):
 p=F/n;assert not p.exists();p.write_text(json.dumps(x,indent=2))
def chk(x):
 z=rec(R/x['path']);assert z['bytes']==x['bytes'] and z['sha256']==x['sha256'],x['path']
for x in json.loads((B/'HANDBACK_MANIFEST.json').read_text())['records']:chk(x)
for x in json.loads((F.parent/'SOURCE_PROTECTION.json').read_text()):chk(x)
inputs=json.loads((F/'INPUT_WHITELIST.json').read_text());xmlchanges={}
for x in inputs['source']+inputs['database']:
 chk(x['original']);q=R/x['copy']['path']
 if q.name!='Ti60_Demo.xml':chk(x['copy']);continue
 a=ET.parse(R/x['original']['path']).getroot();b=ET.parse(q).getroot();allow={'last_change','last_run_flow','last_run_state','sw_version','config_result_in_sync','design_ood','place_ood','route_ood'}
 xmlchanges={k:[a.get(k),b.get(k)] for k in set(a.attrib)|set(b.attrib) if a.get(k)!=b.get(k)};assert set(xmlchanges)<=allow
 for k in allow:a.attrib.pop(k,None);b.attrib.pop(k,None)
 assert ET.tostring(a)==ET.tostring(b)
for n in ['PRE_NATIVE_ARCHIVE.json','POST_NATIVE_ARCHIVE.json']:
 for x in json.loads((F/n).read_text())['records']:chk(x['archive']);assert x['original']['sha256']==x['archive']['sha256']
native=[s for s in (P/'outflow/Ti60_Demo.log').read_text().splitlines() if 'efx_pgm.exe ' in s];assert len(native)==1 and '--source ' in native[0] and '--dest ' in native[0];assert not any(t in native[0].split() for t in ['--program','--usb','--jtag','--flash'])
art=[rec(P/'outflow'/('Ti60_Demo'+s)) for s in ['.bit','.bit.bin','.hex','.hex.bin']]
put('POSTPROCESS_FAILURE_AND_ARTIFACT_RECEIPT.json',dict(status='ARTIFACTS_GENERATED_TOOL_PASS_RAW_PARENT_EXIT_NOT_PERSISTED_NOT_FINAL_GATE',runner_exit=1,native_parent_exit=None,native_exit_boundary='Parent cmd exited and tools printed PASS; exact captured subprocess.returncode was not serialized before subsequent assertion. Do not infer literal native exit0.',error='Native argv was searched in outer tool.log rather than actual outflow/Ti60_Demo.log.',native_command=native,artifacts=art,source101_unchanged=True,protected4465_unchanged=True,sealed_build700_unchanged=True,database8_unchanged=True,xml_metadata_changes=xmlchanges,runner=rec(F/'run_conversion.py')))
plan=json.loads((B/'NEXT_OFFLINE_ARTIFACT_CANDIDATE_PLAN.json').read_text())['candidate_draft'];plan.update(status='PREPARATION_ONLY_NO_GIT_ACTION',artifact_receipt=rec(F/'POSTPROCESS_FAILURE_AND_ARTIFACT_RECEIPT.json'),proposed_metadata_paths=[str((F/n).relative_to(R)).replace('\\','/') for n in ['INPUT_WHITELIST.json','ACTUAL_GENERATED_OPTIONS.json','POSTPROCESS_FAILURE_AND_ARTIFACT_RECEIPT.json']],build_handback=rec(B/'FINAL_HANDBACK.json'),desired_docs_updates=['STATUS: functional17 + offline I3 and artifact exact status; no board claim','HANDOFF: fixed candidate/parent and independent review boundaries after Work approval','DECISIONS: I3-only narrow hold, external7/135, selected source and UART conditional-model scope'],required_attributes=['Keep actual artifacts ignored/untracked; do not change attributes now','Future explicit reviewable text evidence package only; raw archives remain separately bound external evidence','All17 gate index plus focused/default/legacy and historical failure indices remain reviewable; future exact evidence path list requires Work freeze'])
put('CANDIDATE_PREPARATION_PLAN.json',plan)
put('PARTIAL_MANIFEST.json',dict(records=[rec(p) for p in sorted(F.rglob('*')) if p.is_file() and p.name!='PARTIAL_MANIFEST.json']))
print('PRESERVED_FAILURE_AND_ARTIFACTS_NO_RETRY')
