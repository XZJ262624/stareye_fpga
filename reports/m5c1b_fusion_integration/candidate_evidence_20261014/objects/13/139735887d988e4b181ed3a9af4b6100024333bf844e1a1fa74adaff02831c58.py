from pathlib import Path
import json,hashlib,subprocess,time,re,sys
F=Path(__file__).resolve().parent;O=F.parent;R=O.parents[3];N=Path('E:/Modelsim_10.1c/win64');records=[];okall=True
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
identity=R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json'
for x in json.loads(identity.read_text())['records']:assert rec(R/x['adopted']['path'])==x['adopted']
deriv=F/'DERIVATION.json'
for x in json.loads(deriv.read_text())['derived']:assert rec(R/x['path'])==x
deps=[F/'tb_guard_lifecycle.sv',F/'tb_aba_two_fence_v3.sv',deriv,Path(__file__),O/'derive_aba_v3.py',identity,O.parent.parent/'ABA_WINDOW_GUARD_RETRY_FREEZE_20261013_2107.md'];inputs=[rec(p) for p in deps]
for case in [0,1,2]:
 W=F/('guard_'+str(case)+'_'+time.strftime('%H%M%S'));W.mkdir();(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));steps=[];ok=True
 for stage,cmd in [('vlib',[N/'vlib.exe','work']),('compile',[N/'vlog.exe','-sv','-work','work',deps[0]]),('sim',[N/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_guard_lifecycle','-gCASE='+str(case),'-do','run -all; quit -code 0'])]:
  timed=False
  with (W/(stage+'.log')).open('wb') as f:
   p=subprocess.Popen(list(map(str,cmd)),cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(stage+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=list(map(str,cmd)),started=time.time())))
   try:code=p.wait(timeout=120)
   except subprocess.TimeoutExpired:
    timed=True;subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=f,stderr=subprocess.STDOUT);code=p.wait(timeout=30)
  txt=(W/(stage+'.log')).read_text();fs=re.findall(r'\*\* Fatal: ([^\r\n]+)',txt);want={1:'ABA_NATURAL_WINDOW_TOO_SHORT',2:'ABA_REAL_A1_TTL'}.get(case)
  ok=not timed and code==0 and '** Error:' not in txt and (fs==[want] if stage=='sim' and case else not fs and (stage!='sim' or 'PASS_GUARD_LIFECYCLE_ONLY' in txt))
  if stage=='sim' and ok:
   events=re.findall(r'GUARD_REJECTION case=(\d+) count=(\d+) tick=(\d+) frame_age=(\d+)',txt)
   ok=events==([('0','1','40000000','10'),('0','2','90000000','10')] if case==0 else [] if case==1 else [('2','1','40000000','10')])
  steps.append(dict(stage=stage,exit=code,timed_out=timed,log=rec(W/(stage+'.log'))))
  if not ok:break
 assert inputs==[rec(p) for p in deps]
 p=W/'RESULT.json';p.write_text(json.dumps(dict(status='PASS_GUARD_LIFECYCLE_CASE_ONLY' if ok else 'FAIL',case=case,steps=steps),indent=2));records += [rec(p),rec(W/'INPUTS.json')]+[rec(W/(n+'.log')) for n in ['compile','sim'] if (W/(n+'.log')).exists()];print(W,ok,flush=True)
 if not ok:okall=False;break
q=F/('PREFLIGHT_'+time.strftime('%H%M%S')+'.json');q.write_text(json.dumps(dict(status='PASS_THREE_GUARD_LIFECYCLE_CASES' if okall else 'FAIL',records=records,inputs=inputs,scope='Synthetic guard lifecycle only. Controls proof unchanged and not repeated. Negative rawexit0 with unique expectedFatal explicitly required.'),indent=2));print(rec(q));sys.exit(0 if okall else 1)
