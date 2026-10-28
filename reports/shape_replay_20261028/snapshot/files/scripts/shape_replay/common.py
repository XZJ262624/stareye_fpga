from pathlib import Path
import json,hashlib,re,subprocess,time,os
R=Path(__file__).resolve().parents[2];O=R/'reports/shape_replay_20261028';P=R/'efinity/shape_replay_i3';T=R/'rtl/shape_replay';M=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def put(p,s):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf8')
def verify(xs):
 for x in xs:assert rec(R/x['path'])==x,x['path']
def execute(W,label,cmd,marker=None,timeout=7200,cwd=None):
 W.mkdir(parents=True,exist_ok=True);log=W/(label+'.log');assert not log.exists();start=time.time()
 with log.open('wb') as f:
  p=subprocess.Popen(cmd,cwd=cwd or W,stdout=f,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
  owner=dict(pid=p.pid,command=cmd,cwd=str(cwd or W),started=start);save(W/(label+'_OWNER.json'),owner);print(label,p.pid,flush=True)
  while p.poll() is None:
   if time.time()-start>timeout:p.kill();p.wait();break
   save(O/'HEARTBEAT.json',dict(status='RUNNING',phase=label,native_pid=p.pid,updated_unix=time.time()));time.sleep(5)
 owner.update(running=False,exit=p.returncode,seconds=time.time()-start);save(W/(label+'_OWNER.json'),owner)
 txt=log.read_text(errors='replace');passed=p.returncode==0 and not re.search(r'\*\*\s*(Fatal|Error):|Errors:\s*[1-9]|Error loading design|^\s*(?:ERROR|Error):',txt,re.M) and (marker is None or marker in txt)
 result=dict(passed=bool(passed),exit=p.returncode,seconds=owner['seconds'],log=rec(log));save(W/(label+'_RESULT.json'),result);assert passed,txt[-5000:];return result
def watch(W,name,result):
 save(result,dict(status='RUNNING',running=True,job=name))
 q=subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(R/'scripts/work_notifications/start_watch_v2.ps1'),'-ResultPath',str(result),'-StatePath',str(W/'NOTIFICATION_STATE.json'),'-JobName',name,'-TimeoutMinutes','120'],capture_output=True,text=True,creationflags=subprocess.CREATE_NO_WINDOW,timeout=30)
 put(W/'watch_start.log',q.stdout+q.stderr);print(q.stdout,flush=True);assert q.returncode==0,'WATCHER_START_FAILED'
