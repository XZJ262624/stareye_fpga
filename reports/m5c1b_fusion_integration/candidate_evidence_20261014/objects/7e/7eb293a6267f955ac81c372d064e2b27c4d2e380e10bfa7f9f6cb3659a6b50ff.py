from pathlib import Path
import json,hashlib,subprocess,time,sys,re,shutil
O=Path(__file__).resolve().parent;R=O.parents[3];MS=Path('E:/Modelsim_10.1c/win64');cases=json.loads((O/'CASES.json').read_text());results=[]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
for case_index,c in enumerate(cases):
 W=O/('v3_case_%02d'%case_index);W.mkdir();sources=[R/p for p in c['sources']];deps=sources+[Path(__file__),O/'CASES.json',O/'DERIVATION.json',O/'check_trace.py']+[O/q[0] for q in c['checkers']];inputs=[rec(p) for p in deps];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2))
 snapshots=[]
 for dep_index,p in enumerate(deps):
  q=W/'source_snapshot'/('%02d_'%dep_index+p.name);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q);snapshots.append(dict(input=rec(p),actual_compiled_path=str(p) if p in sources else None,snapshot=rec(q)))
 (W/'SNAPSHOTS.json').write_text(json.dumps(snapshots,indent=2))
 commands=[('vlib',[MS/'vlib.exe','work']),('compile',[MS/'vlog.exe','-sv','-work','work',*sources]),('sim',[MS/'vsim.exe','-c','-novopt','-onfinish','stop','work.'+c['top'],*c['args'],'-do','onbreak {quit -code 1}; onerror {quit -code 2}; run -all; quit -code 0'])];steps=[];passed=True
 for stage,cmd in commands:
  cmd=list(map(str,cmd));started=time.time();timeout=False
  with (W/(stage+'.log')).open('wb') as f:
   p=subprocess.Popen(cmd,cwd=W,stdout=f,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,command=cmd,started_unix=started);(W/(stage+'_OWNER.json')).write_text(json.dumps(owner,indent=2));print('OWNED',c['name'],stage,p.pid,flush=True)
   try:code=p.wait(timeout=1200)
   except subprocess.TimeoutExpired:
    timeout=True
    if p.poll() is None:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=f,stderr=subprocess.STDOUT)
    code=p.wait(timeout=30)
  text=(W/(stage+'.log')).read_text(errors='replace');steps.append(dict(stage=stage,exit=code,timeout=timeout,seconds=time.time()-started,log=rec(W/(stage+'.log'))))
  if stage=='sim' and c['expected']:passed=not timeout and code in [0,1] and len(re.findall(r'\*\* Fatal:',text))==1 and '** Fatal: '+c['expected'] in text
  else:passed=not timeout and code==0 and not re.search(r'\*\* (Error|Fatal):',text) and (stage!='sim' or c['positive_marker'] in text)
  if not passed:break
 if passed and not c['expected']:
  for i,ck in enumerate(c['checkers']):
   cmd=[sys.executable,'-B',str(O/ck[0]),str(W),*ck[1:]];v=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);log=W/f'checker{i}.log';log.write_bytes(v.stdout);steps.append(dict(stage='software',exit=v.returncode,command=cmd,log=rec(log)));passed=passed and v.returncode==0
 unchanged=inputs==[rec(p) for p in deps];r=dict(status=('PASS_EXPECTED_NAMED_FATAL' if c['expected'] else 'PASS_CURRENT_FOCUSED') if passed and unchanged else 'FAIL',case=c,source_unchanged=unchanged,steps=steps);(W/'RESULT.json').write_text(json.dumps(r,indent=2));results.append(dict(case=c['name'],status=r['status'],result=rec(W/'RESULT.json')));(O/'PROGRESS_V3.json').write_text(json.dumps(results,indent=2));print('CASE_DONE',c['name'],r['status'],flush=True)
 if not passed or not unchanged:sys.exit(1)
(O/'RESULT_V3.json').write_text(json.dumps(dict(status='PASS_46_CURRENT_POSITIVE_18_NAMED_NEGATIVE',runs=results),indent=2));print('ALL_CURRENT_FOCUSED_PASS',len(results),flush=True)
