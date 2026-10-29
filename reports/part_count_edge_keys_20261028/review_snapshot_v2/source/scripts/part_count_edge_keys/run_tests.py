from pathlib import Path
import sys,json,subprocess,time,hashlib,re,datetime
R=Path(__file__).resolve().parents[2];O=R/'reports/part_count_edge_keys_20261028';M=Path('E:/Modelsim_10.1c/win64')
names=sys.argv[1:] or ['unit','core'];W=O/('tests_'+time.strftime('%Y%m%d_%H%M%S'));W.mkdir();print('RUN_DIR',W,flush=True)
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(n,v):(W/n).write_text(json.dumps(v,indent=2,ensure_ascii=False)+'\n',encoding='utf8')
sources=sorted((R/'rtl/part_count_edge_keys').glob('*.sv'))+sorted((R/'rtl/part_count_edge_open').glob('*.sv'))+sorted((R/'rtl/shape_standalone/gaussian_m5a').glob('*.v'))+sorted((R/'rtl/shape_standalone/filter').glob('*.v'))+[R/f'tb/part_count_edge_keys/tb_keys_{n}.sv' for n in names]
inputs=[rec(p) for p in sources+list((R/'tb/part_count_edge_keys').glob('*.hex'))+([R/'tb/part_count_edge_keys/osd_ext.mem'] if 'osd' in names else [])+[R/'rtl/part_count_edge_open/part_open_font.svh']];save('INPUTS_PRE.json',inputs)
save('FINAL_RESULT.json',dict(status='RUNNING',running=True));save('CONTEXT.json',dict(job='part_edge_keys_tests',codex_checked_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),codex_observation='待确认（开发模型 Astra High）',hardware_next='否，尚须 Work 核定及用户独立 A'))
p=subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(R/'scripts/work_notifications/start_watch_v2.ps1'),'-ResultPath',str(W/'FINAL_RESULT.json'),'-StatePath',str(W/'NOTIFICATION_STATE.json'),'-JobName','part_edge_keys_tests','-TimeoutMinutes','120','-ContextPath',str(W/'CONTEXT.json')],capture_output=True,text=True,creationflags=subprocess.CREATE_NO_WINDOW,timeout=30)
(W/'watch_start.log').write_text(p.stdout+p.stderr,encoding='utf8');assert p.returncode==0,p.stderr;print(p.stdout,flush=True)
results=[]
def run(n,args,marker=None,timeout=7200):
 start=time.time()
 with (W/(n+'.log')).open('wb') as f:
  p=subprocess.Popen(args,cwd=W,stdout=f,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW);save(n+'_OWNER.json',dict(pid=p.pid,command=args,running=True));p.wait(timeout=timeout)
 text=(W/(n+'.log')).read_text(errors='replace');ok=p.returncode==0 and not re.search(r'\*\*\s*(?:Error|Fatal):|Errors:\s*[1-9]',text) and (marker is None or marker in text)
 save(n+'_OWNER.json',dict(pid=p.pid,command=args,running=False,exit=p.returncode));results.append(dict(name=n,passed=bool(ok),exit=p.returncode,seconds=time.time()-start,log=rec(W/(n+'.log'))));assert ok,text[-5000:];print('PASS',n,round(time.time()-start,1),flush=True)
try:
 run('vlib',[str(M/'vlib.exe'),'work']);run('vmap',[str(M/'vmap.exe'),'-c']);run('compile',[str(M/'vlog.exe'),'-sv','+incdir+'+str(R/'rtl/part_count_edge_open'),*map(str,sources)])
 (W/'run.do').write_text('onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n')
 for n in names:run(n,[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','tb_keys_'+n,'+DATA='+str(R/'tb/part_count_edge_keys'),'-wlf','NUL','-do','do {'+(W/'run.do').as_posix()+'}'],'PASS_KEYS_'+n.upper())
 for row in inputs:assert rec(R/row['path'])==row,row['path']
 save('FINAL_RESULT.json',dict(status='PASS_DIRECTED_TESTS',passed=True,running=False,inputs=inputs,results=results));print('PASS_KEYS_TESTS',W,flush=True)
except Exception as e:
 save('FINAL_RESULT.json',dict(status='FAIL_REQUIRES_WRITER',passed=False,running=False,inputs=inputs,results=results,error=str(e)));raise
