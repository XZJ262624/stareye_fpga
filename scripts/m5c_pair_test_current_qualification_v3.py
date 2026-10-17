from pathlib import Path
import sys,json,hashlib,subprocess,time,datetime
R=Path(__file__).resolve().parents[1];base=R/'reports/m5c_pair_capture_20261016';W=base/('current_qualification_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
S=[R/'rtl/m5c_fusion/m5b1_mailbox.sv',R/'rtl/m5c_fusion/m5b1_async_fifo.sv',R/'rtl/m5c_pair_diag/m5c_pair_capture.sv',R/'tb/m5c_pair_diag/tb_pair_current_qualification_v3.sv']
def rec(p):b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(W/'RUNNER_SNAPSHOT.py').write_bytes(Path(__file__).read_bytes());inputs=[rec(p) for p in S];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for p in S:(W/'snapshots'/p.name).write_bytes(p.read_bytes())
M=Path('E:/Modelsim_10.1c/win64');results=[]
def run(label,args):
 with (W/(label+'.log')).open('w') as log:
  t=time.time();p=subprocess.Popen(args,cwd=W,stdout=log,stderr=subprocess.STDOUT);(W/(label+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=args,cwd=str(W),started_unix=t),indent=2));code=p.wait()
 return code,(W/(label+'.log')).read_text(errors='replace')
code,log=run('vlib',[str(M/'vlib.exe'),'work']);assert code==0
code,log=run('vlog',[str(M/'vlog.exe'),'-sv','-work','work']+[str(p) for p in S]);assert code==0 and '** Error' not in log,log
for i in range(7):
 code,log=run('case'+str(i),[str(M/'vsim.exe'),'-c','-novopt','-l',str(W/('sim'+str(i)+'.log')),'-wlf',str(W/('sim'+str(i)+'.wlf')),'work.tb_pair_current_qualification_v3','-gCASE='+str(i),'-do','run -all; quit -f'])
 ok=code==0 and 'PAIR_CURRENT_QUALIFICATION_PASS' in log and '** Fatal' not in log and '** Error' not in log
 results.append(dict(case=i,exit=code,pass_gate=ok));(W/'RESULT.json').write_text(json.dumps(dict(status='PASS' if all(x['pass_gate'] for x in results) and len(results)==7 else 'INCOMPLETE_OR_FAIL',results=results,inputs_unchanged=inputs==[rec(p) for p in S]),indent=2));print(i,ok,flush=True)
 if not ok:print(log,flush=True);sys.exit(1)
print(W,flush=True)

