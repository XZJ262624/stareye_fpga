from pathlib import Path
import json,hashlib,subprocess,time,datetime
R=Path(__file__).resolve().parents[1];W=R/'reports/m5c_pair_capture_20261016/fifo_service_diagnosis_20261017'/('run_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
paths=['rtl/m5c_fusion/'+x+'.sv' for x in ['m5b1_mailbox','m5b1_async_fifo','m5b1_transfer','m5c_mask_reader','m5c_bg_mux']]+['rtl/m5c_pair_diag/'+x+'.sv' for x in ['m5c_pair_capture','m5c_pair_controller','m5c_pair_arbiter']]+['tb/m5c_fusion/m5c1b_ddr_service_model.sv','tb/m5c_pair_diag/tb_pair_fifo_service.sv']
S=[R/x for x in paths]
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
inputs=[rec(p) for p in S];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for p in S:(W/'snapshots'/p.name).write_bytes(p.read_bytes())
(W/'RUNNER.py').write_bytes(Path(__file__).read_bytes());M=Path('E:/Modelsim_10.1c/win64')
def run(label,args,cwd):
 with (W/(label+'.log')).open('w') as f:
  t=time.time();p=subprocess.Popen(args,cwd=cwd,stdout=f,stderr=subprocess.STDOUT);(W/(label+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=args,cwd=str(cwd),started_unix=t),indent=2));code=p.wait()
 return code,(W/(label+'.log')).read_text(errors='replace')
print(W,flush=True)
code,log=run('vlib',[str(M/'vlib.exe'),'work'],W);assert code==0
code,log=run('vlog',[str(M/'vlog.exe'),'-sv','-work','work']+[str(W/'snapshots'/p.name) for p in S],W)
(W/'COMPILE.json').write_text(json.dumps(dict(exit=code,pass_gate=code==0 and '** Error' not in log)))
assert code==0 and '** Error' not in log,log
results=[]
for i in range(3):
 C=W/('case'+str(i));C.mkdir()
 code,log=run('case'+str(i),[str(M/'vsim.exe'),'-c','-novopt','-lib',str(W/'work'),'-l',str(C/'sim.log'),'-wlf',str(C/'sim.wlf'),'tb_pair_fifo_service','-gCASE='+str(i),'-do','run -all; quit -f'],C)
 ok=code==0 and 'SERVICE_DIAG_COMPLETE' in log and '** Fatal' not in log and '** Error' not in log
 results.append(dict(case=i,exit=code,completed_without_protocol_failure=ok));(W/'RESULT.json').write_text(json.dumps(dict(status='COMPLETE' if len(results)==3 and all(x['completed_without_protocol_failure'] for x in results) else 'INCOMPLETE_OR_FAIL',results=results,inputs_unchanged=inputs==[rec(p) for p in S]),indent=2));print(i,ok,flush=True)
 if not ok:print(log,flush=True);break
