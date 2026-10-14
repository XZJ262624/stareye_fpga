from pathlib import Path
import json,hashlib,subprocess,time,re,sys
F=Path(__file__).resolve().parent;O=F.parent;R=O.parents[3];N=Path('E:/Modelsim_10.1c/win64');allok=True;results=[]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
manifest=F/'MANIFEST.json'
for x in json.loads(manifest.read_text())['records']:assert rec(R/x['path'])==x
identity=R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json'
for x in json.loads(identity.read_text())['records']:assert rec(R/x['adopted']['path'])==x['adopted']
sources=[R/'rtl/m5c_fusion/m5a_copy/m5a_controls.v',F/'tb_controls_preflight.sv'];deps=sources+[Path(__file__),manifest,identity,O.parent.parent/'ABA_TWO_FENCE_EXECUTION_FREEZE_20261013_1834.md'];inputs=[rec(p) for p in deps]
for mutant in [0,1]:
 W=F/('controls_'+str(mutant)+'_'+time.strftime('%H%M%S'));W.mkdir();(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));steps=[];ok=True
 for stage,cmd in [('vlib',[N/'vlib.exe','work']),('compile',[N/'vlog.exe','-sv','-work','work',*sources]),('sim',[N/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_controls_preflight','-gWRONG_EDGE='+str(mutant),'-do','run -all; quit -code 0'])]:
  timed=False
  with (W/(stage+'.log')).open('wb') as f:
   p=subprocess.Popen(list(map(str,cmd)),cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(stage+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=list(map(str,cmd)),started=time.time())))
   try:code=p.wait(timeout=120)
   except subprocess.TimeoutExpired:
    timed=True;subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=f,stderr=subprocess.STDOUT);code=p.wait(timeout=30)
  text=(W/(stage+'.log')).read_text();fatals=re.findall(r'\*\* Fatal: ([^\r\n]+)',text)
  ok=not timed and code==0 and '** Error:' not in text and (fatals==['ABA_PREFLIGHT_WRONG_CONFIG_EDGE'] if stage=='sim' and mutant else not fatals and (stage!='sim' or 'PASS_CONTROLS_PREFLIGHT_ONLY' in text))
  steps.append(dict(stage=stage,exit=code,timed_out=timed,log=rec(W/(stage+'.log'))))
  if not ok:break
 assert inputs==[rec(p) for p in deps]
 result=dict(status=('PASS_NAMED_WRONG_EDGE_SENSITIVITY' if mutant else 'PASS_ACTUAL_CONTROLS_PREFLIGHT_ONLY') if ok else 'FAIL',mutant=mutant,steps=steps,scope='Real controls; scripted context and telemetry occupancy, not production ABA proof. CE constant1, debounce4/long64 accelerated.');(W/'RESULT.json').write_text(json.dumps(result,indent=2));results.append(rec(W/'RESULT.json'));print(W,result['status'],flush=True)
 if not ok:allok=False;break
for x in json.loads(identity.read_text())['records']:assert rec(R/x['adopted']['path'])==x['adopted']
q=F/('CONTROLS_PREFLIGHT_'+time.strftime('%H%M%S')+'.json');q.write_text(json.dumps(dict(status='PASS_STAGE_A_ONLY' if allok else 'FAIL_STAGE_A',results=results,inputs=inputs),indent=2));print(rec(q));sys.exit(0 if allok else 1)
