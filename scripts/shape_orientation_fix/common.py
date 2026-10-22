from pathlib import Path
import json,hashlib,re,subprocess,time,os
R=Path(__file__).resolve().parents[2];O=R/'reports/shape_orientation_fix_20261022';M=Path('E:/Modelsim_10.1c/win64');E=Path('E:/Efinity/2025.1')
def rec(p):return dict(path=p.relative_to(R).as_posix() if p.is_relative_to(R) else str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(p,d):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2),encoding='utf8')
def verify(items):
 for x in items:assert rec(R/x['path'])==x,x['path']
def heartbeat(phase,**kw):save(O/'HEARTBEAT.json',dict(status='RUNNING',running=True,phase=phase,updated_unix=time.time(),hardware_next=False,**kw))
def execute(W,label,cmd,marker=None,timeout=5400):
 W.mkdir(parents=True,exist_ok=True);log=W/(label+'.log');assert not log.exists();start=time.time()
 with log.open('wb') as f:
  p=subprocess.Popen(cmd,cwd=W,stdout=f,stderr=subprocess.STDOUT,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0));owner=dict(pid=p.pid,started=start,command=cmd,running=True);save(W/(label+'_OWNER.json'),owner);print(label,p.pid,flush=True)
  try:code=p.wait(timeout=timeout)
  except subprocess.TimeoutExpired:p.kill();p.wait();code=-1
 owner.update(running=False,exit=code,seconds=time.time()-start);save(W/(label+'_OWNER.json'),owner);text=log.read_text(errors='replace');passed=code==0 and not re.search(r'\*\*\s*(Fatal|Error):|Errors:\s*[1-9]|Error loading design',text) and (not marker or len(re.findall(r'^#?\s*'+re.escape(marker)+r'(?:\s|$)',text,re.M))==1)
 result=dict(passed=bool(passed),exit=code,seconds=owner['seconds'],log=rec(log));save(W/(label+'_RESULT.json'),result);assert passed,text[-5000:];return result
