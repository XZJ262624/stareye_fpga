from pathlib import Path
import json,hashlib,subprocess,sys,re
N=Path(__file__).resolve().parent;R=N.parents[3];O=R/'reports/m5c1b_fusion_integration/selected_final_matrix_20261013_071300/replay_end_v2';M=O.parent;W=Path(sys.argv[1]).resolve();assert W.parent==N/'runs'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
r=json.loads((W/'RESULT.json').read_text());par=json.loads((W/'PARAMETERS.json').read_text());kind=par['arguments']['kind'];mutant=par['arguments']['mutant'];checks=0;records={}
for x in json.loads((W/'INPUTS.json').read_text()):
 assert rec(R/x['path'])==x;records[x['path']]=x;checks+=1
for x in json.loads((W/'SNAPSHOTS.json').read_text()):
 y=x['snapshot'];assert rec(R/y['path'])==y;records[y['path']]=y;checks+=1
assert r['source_unchanged'];assert next(s for s in r['steps'] if s['stage']=='compile')['exit']==0
assert not any(s['timed_out'] for s in r['steps'])
if mutant:assert r['status']=='PASS_EXPECTED_ABA_WRONGFUL_ACQUIRE_FATAL'
elif kind=='cold':
 assert r['status']=='PASS_COLD_TERMINAL_ONLY_UART_ABORT_SCOPED'
 text=(W/'sim.log').read_text();assert 'M5C1B_PASS REAL_SYSTEM_HARDSTOP scenario=4 ' in text
 rows={key:[line for line in text.splitlines() if line.startswith('# '+key+' ')] for key in ['V4_EXPECTED_BAD_R','V7_FIRST4','V7_WATCHDOG_4_TO_1','V6_NEXT_NORMAL_R']}
 assert all(len(v)==1 for v in rows.values()),rows
 fields=lambda line:{k:int(v) for k,v in re.findall(r'(\w+)=([0-9]+)',line)}
 first=fields(rows['V7_FIRST4'][0]);later=fields(rows['V7_WATCHDOG_4_TO_1'][0]);normal=fields(rows['V6_NEXT_NORMAL_R'][0])
 assert first['reason']==4 and first['quarantine']==first['reset_request']==first['busy']==1
 assert later['preage']==later['TX_LIMIT']-1 and later['age']==later['TX_LIMIT'] and later['owner']==first['owner'] and later['outstanding']==1
 assert normal['rresp']==0
 (W/'COLD_CAUSAL_ORACLE.json').write_text(json.dumps(dict(status='PASS_COLD_FIRST4_SAME_OWNER_WATCHDOG1_ONLY',events=rows,boundary='Retained-owner hard stop; interrupted UART and outstanding transaction deliberately not certified as normal drain or warm recovery.'),indent=2))
else:
 assert r['status']=='PASS_SIM_PENDING_INDEPENDENT_SOFTWARE'
 assert not (W/'END_SOFTWARE_ORACLE.json').exists(),'Already verified: preserve outputs'
 commands=[('end',O/'common/check_end_protocol.py')]
 if kind=='nonzero':commands.append(('nonzero',M/'nonzero_reject/check_nonzero_wire.py'))
 if kind=='mixed':commands.append(('type1',M/'mixed_type1_v1/check_type1_wire.py'))
 for name,script in commands:
  p=subprocess.run([sys.executable,'-B',str(script),str(W)],capture_output=True);(W/('software_'+name+'.log')).write_bytes(p.stdout+p.stderr)
  if p.returncode:
   (W/'SOFTWARE_FAILURE.json').write_text(json.dumps(dict(status='FAIL_INDEPENDENT_SOFTWARE_GATE',gate=name,exit=p.returncode,script=rec(script),log=rec(W/('software_'+name+'.log'))),indent=2));print('FAIL',name,p.stderr.decode(errors='replace')[-1000:]);sys.exit(1)
 for x in json.loads((W/'INPUTS.json').read_text()):assert rec(R/x['path'])==x
status='PASS_NAMED_ABA_SENSITIVITY_ONLY' if mutant else 'PASS_COLD_TERMINAL_ONLY_UART_ABORT_SCOPED' if kind=='cold' else 'PASS_CURRENT_FUNCTIONAL_CASE_AND_COMPLETE_WIRE'
(W/'GATE_HANDBACK.json').write_text(json.dumps(dict(status=status,kind=kind,parameters=rec(W/'PARAMETERS.json'),input_snapshot_checks=checks,mismatches=0,native_result=rec(W/'RESULT.json'),boundary='Current source-specific finite case. Cold explicitly excludes complete UART/source drain; no physical/build/board qualification.'),indent=2))
for p in W.rglob('*'):
 if p.is_file() and 'work' not in p.relative_to(W).parts and p.name!='GATE_MANIFEST.json':records[rec(p)['path']]=rec(p)
records[rec(Path(__file__))['path']]=rec(Path(__file__))
(W/'GATE_MANIFEST.json').write_text(json.dumps(dict(records=list(records.values())),indent=2));print(status,checks,len(records),rec(W/'GATE_MANIFEST.json'))
