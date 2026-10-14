from pathlib import Path
import json,hashlib,sys,subprocess,time,os,re,shutil,traceback
O=Path(__file__).resolve().parent;R=O.parents[3];plan=json.loads((O/'PLAN.json').read_text());done=[]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def state(status,**kw):
 p=O/'STATE.tmp';p.write_text(json.dumps(dict(status=status,updated=time.time(),completed=done,**kw),indent=2));os.replace(p,O/'STATE.json')
(O/'OWNER.json').write_text(json.dumps(dict(pid=os.getpid(),started_unix=time.time(),command=sys.argv),indent=2))
source=json.loads((O.parent/'regression/SOURCE101.json').read_text())['records'];guards=[rec(Path(__file__)),rec(O/'PLAN.json'),rec(O/'DERIVATION.json')]
try:
 for c in plan['cases']:
  for x in source+guards+c['current_inputs']:assert rec(R/x['path'])==x,x['path']
  W=O/f'case_{c["index"]:02d}';W.mkdir();inputs=c['current_inputs']+guards;snaps=[]
  for i,x in enumerate(inputs):
   p=R/x['path'];q=W/'snapshot'/('%03d_'%i+p.name);q.parent.mkdir(exist_ok=True);shutil.copyfile(p,q);snaps.append(dict(input=x,snapshot=rec(q)))
  (W/'INPUTS.json').write_text(json.dumps(dict(records=inputs,snapshots=snaps,old_commands=c['original_commands'],commands=c['commands']),indent=2));steps=[];state('RUNNING',case=c['index'])
  for step in c['commands']:
   stage=step['stage'];cmd=step['argv'];t=time.time();timed=False;log=W/(stage+'.log')
   with log.open('wb') as out:
    p=subprocess.Popen(cmd,cwd=W,stdout=out,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,command=cmd,cwd=str(W),started_unix=t);(W/(stage+'_OWNER.json')).write_text(json.dumps(owner,indent=2));print('OWNED',c['index'],stage,p.pid,flush=True)
    ps='Get-CimInstance Win32_Process -Filter "ProcessId = '+str(p.pid)+'" | Select-Object ProcessId,ParentProcessId,CreationDate,Name,CommandLine | ConvertTo-Json -Depth 3'
    ci=subprocess.run(['powershell','-NoProfile','-Command',ps],capture_output=True);(W/(stage+'_OWNER_CIM.json')).write_bytes(ci.stdout)
    try:code=p.wait(timeout=c['native_budget']['sim' if stage=='sim' else 'compile'])
    except subprocess.TimeoutExpired:
     timed=True;subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=out,stderr=subprocess.STDOUT);code=p.wait(timeout=30)
   txt=log.read_text(errors='replace');steps.append(dict(stage=stage,exit=code,timeout=timed,seconds=time.time()-t,log=rec(log)));(W/'STEPS.json').write_text(json.dumps(steps,indent=2))
   assert not timed and '** Error:' not in txt
   if stage=='sim' and c['expected_fatal']:
    fs=re.findall(r'^.*\*\* Fatal:.*$',txt,re.M);assert code in [0,1] and len(fs)==1 and '** Fatal: '+c['expected_fatal'] in fs[0],(c['index'],'expectedFatal')
   else:assert code==0 and '** Fatal:' not in txt and (stage!='sim' or c['positive_marker'] in txt),(c['index'],stage)
  for x in inputs+source:assert rec(R/x['path'])==x
  status='PASS_UNIQUE_NAMED_FATAL' if c['expected_fatal'] else 'PASS_CURRENT_LEGACY_CASE';(W/'RESULT.json').write_text(json.dumps(dict(status=status,case=c['case'],source_unchanged=True,steps=steps),indent=2));done.append(dict(index=c['index'],status=status,result=rec(W/'RESULT.json')));state('CASE_COMPLETE');print('COMPLETE',c['index'],status,flush=True)
 state('COMPLETE_REQUIRES_SEAL');(O/'FINAL.json').write_text(json.dumps(dict(status='PASS_NATIVE_23_POSITIVE_23_NAMED_NEGATIVE_PENDING_SEAL',runs=done),indent=2))
except BaseException as e:
 (O/'FAILURE.txt').write_text(traceback.format_exc());state('FAILED_BLOCKED_REMAINING',error=repr(e));raise
