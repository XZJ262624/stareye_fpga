from pathlib import Path
import json,hashlib,subprocess,datetime,time
R=Path.cwd();W=R/'reports/m5c_pair_capture_20261016'/('wait_owner_negative_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64')
S=[R/'rtl/m5c_fusion/m5c_pair_lease.sv',R/'rtl/m5c_pair_diag/m5c_pair_controller.sv',R/'tb/m5c_pair_diag/tb_pair_wait_owner.sv'];backend=R/'rtl/m5c_pair_diag/m5c_pair_backend.sv';text=backend.read_text();assert '(pair_retain_owner?pair_release:fusion_release)' in text and '(pair_retain_owner?pair_retire:fusion_retire)' in text
S+=[backend];inputs=[]
original=S[1].read_bytes();text=original.decode();old='assign retain_owner=hold&&(acquired||(state==ACQ&&acquire_ack));';new='assign retain_owner=hold;';assert text.count(old)==1;mutant=W/'mutant_controller.sv';mutant.write_text(text.replace(old,new));assert mutant.read_text().replace(new,old)==text;S[1]=mutant
(W/'MUTATION.json').write_text(json.dumps(dict(original_sha256=hashlib.sha256(original).hexdigest(),mutant_sha256=hashlib.sha256(mutant.read_bytes()).hexdigest(),old=old,new=new,inverse_text_exact=True),indent=2))
for p in S:
 b=p.read_bytes();(W/p.name).write_bytes(b);inputs.append(dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest()))
(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'RUNNER.py').write_bytes(Path(__file__).read_bytes())
def run(n,args):
 with (W/(n+'.log')).open('w') as f:
  p=subprocess.Popen(args,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(n+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=args,started_unix=time.time())));c=p.wait()
 return c,(W/(n+'.log')).read_text()
assert run('lib',[str(M/'vlib.exe'),'work'])[0]==0
c,t=run('compile',[str(M/'vlog.exe'),'-sv']+[str(p) for p in S[:3]]);assert c==0 and '** Error' not in t,t
results=[]
for i in [2]:
 c,t=run('phase'+str(i),[str(M/'vsim.exe'),'-c','-novopt','-l',str(W/('sim'+str(i)+'.log')),'-wlf',str(W/('sim'+str(i)+'.wlf')),'work.tb_pair_wait_owner','-gPHASE='+str(i),'-do','run -all;quit -f']);fatals=[line for line in t.splitlines() if '** Fatal:' in line];ok=c==0 and len(fatals)==1 and 'UNSELECTED_WAIT_TIMEOUT_LEASE_LEAK' in fatals[0] and '** Error' not in t;results.append(dict(phase=i,exit=c,pass_gate=ok));print(i,ok,flush=True);assert ok,t
assert all(hashlib.sha256(Path(x['path']).read_bytes()).hexdigest()==x['sha256'] for x in inputs)
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_EXPECTED_SINGLE_HOLD_RETENTION_MUTANT',results=results,scope='Real lease reserve/bind/publication/acquire and release before/same/after expiry. Backend mux exact source checked; not full backend/video lifecycle.',inputs_unchanged=True),indent=2));print(W)
