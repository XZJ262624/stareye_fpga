from pathlib import Path
import json,hashlib,shutil,collections
F=Path(__file__).resolve().parent;R=F.parents[2];M=F.parent/'selected_final_matrix_20261013_071300';O=M/'replay_end_v2'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(n,x):
 p=F/n;assert not p.exists();p.write_text(json.dumps(x,indent=2));return rec(p)
base=json.loads((F/'SOURCE_PACKAGE_MAPPING.json').read_text());bysha={x['package']['sha256']:x['package'] for x in base['records']};extra=[];disposition=[]
def add(p,label):
 x=rec(p)
 if x['sha256'] not in bysha:
  q=F/'objects'/x['sha256'][:2]/(x['sha256']+p.suffix.lower());q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q);bysha[x['sha256']]=rec(q)
 extra.append(dict(original=x,package=bysha[x['sha256']],scope=label));return x
cases=[('original_final_snapshot_race',M/'fixture_end_race_092114','Old finish could omit final accepted INPUT;8 owned tests aborted, phase11 failed strict oracle. Replacement end_protocol_v1 proof and replay_end_v2 all current gates.'),('ABA_fullquiet_boundary',O/'runs/aba_positive_131555','FAIL ABA_BOUNDARY_NOT_TRULY_DRAINED; two-fence real controls fixture revision, replaced ultimately by aba_v3_positive_211252.'),('ABA_repeated_margin_guard',O/'runs/aba_two_fence_positive_183827','FAIL ABA_NATURAL_WINDOW_TOO_SHORT after genuine rejection while waiting job2; v3 limits first-window margin to first rejection and retains TTL checks throughout.'),('queued_starvation_rearm',O/'runs/starvation7_153356','Failed old fixture trigger/rearm; sticky armed pre-accept pending proof replacement starvation_retry_172533.'),('owned_service1632',O/'runs/fault1_131557','Old fixture terminal age qualification failed; real lastR age1632 revised fixture, exact1632_retry_172504.'),('mixed_required_plusarg',O/'runs/mixed_positive_131556','Initial fixture omitted required type1 expected plusarg; replaced mixed_v2_131715 with actual full256 independent scalar and CRC-valid mutants.'),('tap26versus28',M/'legacy_remaining_v1/run_091740/tap_small','Old input26 vs TB28 fixture mismatch; derived tap28 preservesfirst26 and adds2 independently computed frames, currentlegacy37 proof.'),('focused_windows_path_limit',M/'focused_replay','Old preparation native path-length/compile errors not counted oracle PASS; flat snapshots and actual namedFatal replacements currentfocused64.')]
for label,d,cause in cases:
 assert d.exists(),d;records=[]
 for p in sorted(d.iterdir()):
  if p.is_file() and p.suffix in ['.json','.log','.py','.sv','.v','.md'] and p.stat().st_size<10000000:records.append(add(p,label))
 snap=d/'source_snapshot'
 if snap.exists():
  for p in sorted(snap.rglob('*')):
   if p.is_file() and p.suffix in ['.sv','.v','.svh','.py','.json'] and p.stat().st_size<1000000:records.append(add(p,label+'_source'))
 disposition.append(dict(case=label,cause=cause,records=records,status='HISTORICAL_FAILURE_NOT_PASS'))
for p in [O/'ABA_FAILURE_CAUSAL_1727.json',O/'FAULT1_SERVICE_FAILURE_1537.json',O/'STARVATION_STARTUP_FAILURE_1534.json',O/'aba_witness_2025/WINDOW_GUARD_CAUSAL.json']:
 assert p.exists();add(p,'historical_causal_receipt')
put('HISTORICAL_FAILURE_DISPOSITION.json',dict(records=disposition,mapping=extra,scope='Selected actual fixture failures/aborts relevant to qualified replacements. Compilation errors are not named-oracle rejection; old failures never relabelled. Earlier unselected architecture experiments are not included.'))
put('KNOWN_LIMITS.json',dict(limits=['Actual I3 only: setup+0.173ns, hold+0.016ns; no multi-PVT/board margin certification.','7 input/135 output external timing boundary explicitly enumerated; actual internal check no_clock/unconstrained/multiple_clock all0.','Full-system simulation service/camera/controls are conditional models; accelerated UART CLOCK960000 while production CLOCK96000000/BAUD460800 unchanged.','Default first full class+mask payload345600B at460800 8N1 lower bound7.5s exceeds approximately2s source TTL; startup availability requires later publication and hardware measurement, not an established real-time guarantee.','Historical row heuristic and frame/config identity protections are tested finite cases, not a formal exhaustive proof.','Cold badR scenario verifies cold terminal quarantine/watchdog cause transition with retained owner; not warm recovery or full clean UART termination.','No current board, JTAG/Flash, warm reset or multi-PVT verification. Artifacts are offline only.','827876321-byte cold cause trace remains external exacthash evidence; package includes causal output and generator, but complete replay of this trace oracle needs the external file.','Original absolute tool paths and runners preserved. Restore helper recreates bytes only; runners require approved isolated path rebasing and installed licensed Efinity/ModelSim, so package is not claimed turnkey portable.','Original conversion raw-exit receipt gap remains NOT_FINAL_GATE; accepted isolated retry has recorded exit0.','Generic structural parser unresolved labels retained; actual timing/native and explicit cut/constant/vendor boundary evidence resolve qualification separately, not by deleting labels.']))
# Inventory every hash-bearing nested reference without pretending omitted historical bytes are present.
refs={}
def walk(x):
 if isinstance(x,dict):
  if isinstance(x.get('path'),str) and isinstance(x.get('sha256'),str) and isinstance(x.get('bytes'),int):refs[(x['path'],x['sha256'],x['bytes'])]=x
  for v in x.values():walk(v)
 elif isinstance(x,list):
  for v in x:walk(v)
for x in list(bysha.values()):
 p=R/x['path']
 if p.suffix=='.json':
  try:walk(json.loads(p.read_text()))
  except (UnicodeError,json.JSONDecodeError):pass
directsha={x['sha256']:x for x in base['direct']};resolved=[];external=[]
for (path,sha,size),x in refs.items():
 package=bysha.get(sha) or directsha.get(sha)
 if package and package['bytes']==size:resolved.append(dict(reference=dict(path=path,sha256=sha,bytes=size),candidate=package))
 else:external.append(dict(reference=dict(path=path,sha256=sha,bytes=size),classification='NOT_IN_CANDIDATE_HISTORICAL_OR_LOCAL_EXTERNAL_REFERENCE',claim='No bytes-presence/reproduction claim. Current primary gate records have their separate complete mapping; nested archive/previous-source/tool references may remain external.'))
put('NESTED_REFERENCE_BOUNDARY.json',dict(resolved=resolved,external=external,resolved_count=len(resolved),external_count=len(external),scope='Hash identity resolver for all nested metadata refs, not automatic admission of external prior proof or tool/DB bytes.'))
records=base['direct']+[rec(p) for p in sorted(F.rglob('*')) if p.is_file() and p.name not in ['CANDIDATE_ALLOWLIST_V2.json']]
put('CANDIDATE_ALLOWLIST_V2.json',dict(status='PROPOSED_EXACT_SCOPE_NOT_STAGED',records=records,count=len(records),total_bytes=sum(x['bytes'] for x in records),largest=sorted(records,key=lambda x:x['bytes'],reverse=True)[:25],supersedes_scope_only=rec(F/'CANDIDATE_ALLOWLIST.json'),note='Includes original proposal, supplemental exact history/source mapping and explicit nested external-reference inventory. Neither list has been staged. Work must select final scope and decide remaining external dependencies.'))
print('FINAL_PROPOSED',len(records),sum(x['bytes'] for x in records),'nestedresolved',len(resolved),'external',len(external),flush=True)
