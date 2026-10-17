from pathlib import Path
import hashlib,json,re,datetime
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_capture_20261016';O=F/'selection_diagnostic_handback';O.mkdir(exist_ok=True)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
rows=[];bindings=[]
for name,cases in [('selection_coupled_233103',range(5)),('selection_coupled_233401',[5,6,8,9,10,11,12,13,14]),('selection_coupled_233545',[3])]:
 d=F/name;steps=json.loads((d/'PROGRESS.json').read_text());compiled=next(x for x in steps if x['stage']=='compile');assert compiled['exit']==0 and compiled['ok']
 inputs=json.loads((d/'INPUTS.json').read_text());assert all(rec(Path(x['path']))['sha256']==x['sha256'] and rec(Path(x['path']))['bytes']==x['bytes'] for x in inputs)
 for case in cases:
  step=next(x for x in steps if x['stage']==f'case{case}');assert step['exit']==0 and step['ok']
  p=d/f'case{case}';log=(p/'native.log').read_text();assert '** Fatal' not in log and '** Error' not in log
  markers=re.findall(r'SELECTION_DIAG_PASS case=(\d+) pubs=(\d+) metadataB=(\d+) ACK=(\d+) selected=(\d+) consumed=(\d+) stale=(\d+) matchingRejected=(\d+)',log);assert len(markers)==1
  values=list(map(int,markers[0]));assert values[:4]==[case,1,1,1]
  ev=(p/'events.txt').read_text();ui=[]
  for line in ev.splitlines():
   if not line.startswith('UI '):continue
   z=dict(re.findall(r'(\w+)=([^ ]+)',line));ui.append(z)
  selected=[x for x in ui if x['selected']=='1'];ack=[x for x in ui if x['ack']=='1'];takes=[x for x in ui if x['take']=='1']
  assert len(selected)==values[4] and len(ack)==1 and len(takes)==values[5]
  for x in selected:
   assert x['pairSID']==x['activeSID'] and x['acq']=='1' and x['fresh']=='1' and x['eq']=='1'
   assert all(x[k]=='0' for k in ['state','tx','eng','arm','writer','packet','start','hold','terminal'])
  blocked=[]
  for x in takes:
   if x['selected']=='1':why='selected'
   elif int(x['pairSID'],16)<int(x['activeSID'],16):why='stale'
   else:
    assert x['pairSID']==x['activeSID'] and x['acq']=='1'
    why='matching-but-ineligible';blocked=[k for k in ['state','tx','eng','arm','writer','packet','start','hold','terminal'] if x[k]!='0']
    assert blocked or x['fresh']!='1' or x['eq']!='1'
   x['independent_event_class']=why
  if case==5:assert blocked==['state','packet']
  rows.append(dict(run=name,case=case,counts=dict(zip(['case','publications','metadata_B','actual_lease_ACK','selected','consumed','stale','matching_rejected'],values)),blocked=blocked,events=ui,seconds=step['seconds']))
 for p in d.rglob('*'):
  if p.is_file() and 'work' not in p.relative_to(d).parts and p.suffix in ['.json','.log','.txt','.sv','.py']:bindings.append(rec(p))
src=F/'selection_source_233735';s=json.loads((src/'RESULT.json').read_text());assert s['status']=='PASS_SOURCE_PHASE_ONLY' and s['unchanged'];text=(src/'sim.log').read_text();assert '** Fatal' not in text
source_events=re.findall(r'SOURCE_REQUEST frame=(\d+) seq=(\d+) mode=(\d+) pending=(\d+) cov=(\d+)',text);assert len(source_events)==14
for f,seq,mode,pending,cov in source_events:assert int(seq)==int(f)+1 and mode==pending and int(cov)==int(mode=='6')
for p in src.rglob('*'):
 if p.is_file() and 'work' not in p.relative_to(src).parts and p.suffix in ['.json','.log','.sv','.py','.v']:bindings.append(rec(p))
active=json.loads((F/'system_qualified_resume_2103/INPUTS.json').read_text());assert len(active)==63 and all(rec(Path(x['path']))['sha256']==x['sha256'] and rec(Path(x['path']))['bytes']==x['bytes'] for x in active)
summary=dict(status='PASS_BOUNDED_DIAGNOSTIC_EVIDENCE_NOT_ORIGINAL_RUN_CAUSE',completed=datetime.datetime.now().astimezone().isoformat(),coupled_native_cases=len(rows),source_requests=14,active_inputs_checked=63,active_mismatches=0,rows=rows,limitations=['No changes/stops to original long simulation.','Backend current class input is synthetic all-zero 720p; publication uses actual capture/engine/transfer/arbiter/B and lease.','Reader bus held unaccepted; checks stop after lease ACK, not full reader/capture/release lifecycle.','Coupled request/mode/telemetry stimuli are external test inputs. Separate real controls+fusion_display source-phase test covers seven modes but no video raster.','case5 deliberately allows session telemetry_pending=0 while packet remains active; this is a boundary stimulus, not evidence original production telemetry can take that combination.','Original long run lacks selection-predicate ledger. Root cause remains unconfirmed.'])
(O/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n');bindings += [rec(O/'SUMMARY.json'),rec(Path(__file__)),rec(F/'system_qualified_resume_2103/INPUTS.json')]
bindings.append(rec(O/'REPORT.md'))
for name in ['selection_coupled_233045','selection_source_233716']:
 for p in (F/name).rglob('*'):
  if p.is_file() and 'work' not in p.relative_to(F/name).parts and p.suffix in ['.json','.log','.sv','.py','.v']:bindings.append(rec(p))
unique={x['path']:x for x in bindings};(O/'MANIFEST.json').write_text(json.dumps(list(unique.values()),indent=2)+'\n');print(O,len(unique),len(rows))
