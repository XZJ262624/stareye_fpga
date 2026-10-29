from pathlib import Path
import json,hashlib,re,subprocess,time,os
R=Path(__file__).resolve().parents[2];O=R/'reports/part_count_edge_keys_20261028';P=R/'efinity/part_count_edge_keys_i3';E=Path('E:/Efinity/2025.1');M=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def verify(xs):
 for x in xs:assert rec(R/x['path'])==x,x['path']
def heartbeat(phase,**kw):save(O/'HEARTBEAT.json',dict(status='RUNNING',running=True,phase=phase,updated_unix=time.time(),hardware_next=False,development_model='gpt-6-astra',reasoning='high',codex_live_status='unconfirmed',**kw))
def execute(W,label,cmd,marker=None,timeout=7200,cwd=None):
 W.mkdir(parents=True,exist_ok=True);log=W/(label+'.log');assert not log.exists();start=time.time()
 with log.open('wb') as f:
  p=subprocess.Popen(cmd,cwd=cwd or W,stdout=f,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
  owner=dict(pid=p.pid,command=cmd,cwd=str(cwd or W),running=True,started=start);save(W/(label+'_OWNER.json'),owner);print(label,p.pid,flush=True)
  while p.poll() is None:
   if time.time()-start>timeout:p.kill();p.wait();break
   heartbeat(label,native_pid=p.pid);time.sleep(5)
 owner.update(running=False,exit=p.returncode,seconds=time.time()-start);save(W/(label+'_OWNER.json'),owner)
 text=log.read_text(errors='replace');passed=p.returncode==0 and not re.search(r'\*\*\s*(Fatal|Error):|Errors:\s*[1-9]|Error loading design|^\s*(?:ERROR|Error):',text,re.M) and (marker is None or marker in text)
 result=dict(passed=bool(passed),exit=p.returncode,seconds=owner['seconds'],log=rec(log));save(W/(label+'_RESULT.json'),result);assert passed,text[-5000:];return result
