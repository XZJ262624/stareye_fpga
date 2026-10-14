from pathlib import Path
import argparse,datetime,hashlib,json,subprocess,time,shutil,sys,re
N=Path(__file__).resolve().parent;R=N.parents[3]
ap=argparse.ArgumentParser();ap.add_argument('case');a=ap.parse_args()
c=json.loads((N/'CASES.json').read_text())[a.case]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def check(xs):
 for x in xs:assert rec(R/x['path'])==x,x['path']
source=json.loads((N/'SOURCE101.json').read_text())['records'];check(source);check(c['inputs'])
if c['parameters']['arguments']['mutant']:
 positives=list((N/'runs').glob('aba_v3_positive_*/GATE_HANDBACK.json'))
 assert positives and any(json.loads(p.read_text())['status']=='PASS_CURRENT_FUNCTIONAL_CASE_AND_COMPLETE_WIRE' for p in positives),'Current positive required'
W=N/'runs'/(a.case+'_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));W.mkdir(parents=True)
deps={x['path']:x for x in c['inputs']+source}
for p in [Path(__file__),N/'CASES.json',N/'SOURCE101.json',N/'DERIVATION.json',N/'verify_completed.py']:deps[rec(p)['path']]=rec(p)
inputs=list(deps.values());snap=W/'source_snapshot';snap.mkdir();snapshots=[]
for i,x in enumerate(inputs):
 p=R/x['path'];q=snap/f'{i:03d}_{p.name}';shutil.copyfile(p,q);snapshots.append(dict(source=x,snapshot=rec(q)))
(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'SNAPSHOTS.json').write_text(json.dumps(snapshots,indent=2));(W/'PARAMETERS.json').write_text(json.dumps(c['parameters'],indent=2));(W/'DERIVATION.json').write_text(json.dumps(c,indent=2))
steps=[]
for item in c['commands']:
 stage=item['stage'];cmd=item['command'];limit=c['parameters']['wall_timeout'] if stage=='sim' else 180;start=time.time()
 check(inputs)
 with (W/(stage+'.log')).open('w') as log:
  p=subprocess.Popen(cmd,cwd=W,stdout=log,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,command=cmd,cwd=str(W),started_unix=start,started=datetime.datetime.now().astimezone().isoformat());(W/(stage+'_OWNER.json')).write_text(json.dumps(owner,indent=2));print('OWNED',stage,p.pid,str(W),flush=True)
  try:code=p.wait(timeout=limit);timed=False
  except subprocess.TimeoutExpired:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],capture_output=True);code=p.wait();timed=True
 steps.append(dict(stage=stage,exit=code,timed_out=timed,seconds=time.time()-start,owner=owner,log=rec(W/(stage+'.log'))));(W/'STEPS.json').write_text(json.dumps(steps,indent=2))
 if code or timed:break
unchanged=all(rec(R/x['path'])==x for x in inputs);text=(W/'sim.log').read_text(errors='replace') if (W/'sim.log').exists() else '';fatal=[s for s in text.splitlines() if '** Fatal:' in s];errors=[s for s in text.splitlines() if '** Error:' in s]
args=c['parameters']['arguments'];ok=len(steps)==3 and not any(s['timed_out'] for s in steps) and steps[1]['exit']==0 and unchanged and not errors
if args['mutant']:
 ok=ok and len(fatal)==1 and 'SYSTEM_UI_SIGNATURE_REJECT_ACQUIRE' in fatal[0];status='PASS_EXPECTED_ABA_WRONGFUL_ACQUIRE_FATAL'
else:
 ok=ok and all(s['exit']==0 for s in steps) and not fatal and 'M5C1B_PASS' in text;status='PASS_COLD_TERMINAL_ONLY_UART_ABORT_SCOPED' if args['kind']=='cold' else 'PASS_SIM_PENDING_INDEPENDENT_SOFTWARE'
(W/'RESULT.json').write_text(json.dumps(dict(status=status if ok else 'FAIL',source_unchanged=unchanged,steps=steps,fatals=fatal,errors=errors),indent=2));print(status if ok else 'FAIL',str(W),flush=True)
if not ok:raise SystemExit(1)
p=subprocess.run([sys.executable,'-B',str(N/'verify_completed.py'),str(W)],capture_output=True);(W/'verification_dispatch.log').write_bytes(p.stdout+p.stderr);print(p.stdout.decode(errors='replace'),p.stderr.decode(errors='replace'),flush=True);raise SystemExit(p.returncode)
