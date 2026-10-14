from pathlib import Path
import json,hashlib,datetime
D=Path(__file__).resolve().parent;F=D.parent;R=F.parents[2];N=F/'regression'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def check(x):assert rec(R/x['path'])==x,x['path']
state=json.loads((N/'SCHEDULER_STATE.json').read_text());rows=[];count=0
for case,item in state['completed'].items():
 W=Path(item['run']);result=json.loads((W/'RESULT.json').read_text());assert result['source_unchanged'];steps=result['steps'];assert next(x for x in steps if x['stage']=='compile')['exit']==0 and not any(x.get('timeout',x.get('timed_out',False)) for x in steps)
 for x in steps:check(x['log']);count+=1
 raw=(W/'sim.log').read_text(errors='replace');fatals=[s for s in raw.splitlines() if '** Fatal:' in s];assert '** Error:' not in raw
 if case=='default960M':
  assert result['status']=='PASS_FOCUSED_RECOVERY' and all(x['exit']==0 for x in steps) and not fatals and 'REVIEW_PASS UART_RECOVERY' in raw
  sim=next(x for x in steps if x['stage']=='sim');assert '-gEXPORT_LIMIT=960000000' in sim['owner']['command']
  inp=json.loads((W/'INPUTS.json').read_text());xs=inp['records']+inp['snapshots'];category='DEFAULT960M_BACKEND_LEASE_RECOVERY_NOT_FULL_PIXEL_READER'
 else:
  gate=json.loads((W/'GATE_HANDBACK.json').read_text());manifest=json.loads((W/'GATE_MANIFEST.json').read_text());xs=manifest['records'];category=gate['status']
  if case.startswith('aba_generation_negative'):
   assert category=='PASS_NAMED_ABA_SENSITIVITY_ONLY' and len(fatals)==1 and 'SYSTEM_UI_SIGNATURE_REJECT_ACQUIRE' in fatals[0]
  elif case.startswith('cold4'):
   assert category=='PASS_COLD_TERMINAL_ONLY_UART_ABORT_SCOPED' and not fatals and json.loads((W/'COLD_CAUSAL_ORACLE.json').read_text())['status']=='PASS_COLD_FIRST4_SAME_OWNER_WATCHDOG1_ONLY'
  else:
   assert category=='PASS_CURRENT_FUNCTIONAL_CASE_AND_COMPLETE_WIRE' and not fatals and all(x['exit']==0 for x in steps);assert (W/'END_SOFTWARE_ORACLE.json').exists()
 for x in xs:check(x);count+=1
 rows.append(dict(case=case,status=category,native_sim_exit=next(x['exit'] for x in steps if x['stage']=='sim'),result=rec(W/'RESULT.json'),gate=rec(W/'GATE_HANDBACK.json') if (W/'GATE_HANDBACK.json').exists() else None,checks=len(xs)+len(steps)))
for x in json.loads((N/'SOURCE101.json').read_text())['records']:check(x);count+=1
done=len(rows)==18 and not state['active'] and not state['pending'];name='REGRESSION18_SEALED_SUMMARY.json' if done else 'REGRESSION_PARTIAL_'+datetime.datetime.now().strftime('%H%M%S')+'.json';p=D/name;assert not p.exists()
p.write_text(json.dumps(dict(status='PASS18_DISTINCT_SCOPED_GATES' if done else 'PARTIAL_COMPLETE_GATES_LAST_CASE_RUNNING',checked_records=count,completed=len(rows),gates=rows,active=list(state['active']),pending=state['pending'],source101=rec(N/'SOURCE101.json'),boundary='ExpectedFatal is sensitivity only; cold excludes normalUART/drain/warm recovery; default is component recovery. 64focused and46legacy still not executed. No resource/timing/hardware acceptance.'),indent=2));print(rec(p),count)
