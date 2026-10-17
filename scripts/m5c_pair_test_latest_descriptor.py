from pathlib import Path
import subprocess,json,hashlib,datetime,time
R=Path.cwd();W=R/'reports/m5c_pair_capture_20261016'/('latest_descriptor_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64')
S=[R/'rtl/m5c_fusion/m5c_pair_lease.sv',R/'rtl/m5c_pair_diag/m5c_pair_diag_lease.sv',R/'tb/m5c_pair_diag/tb_pair_latest_descriptor_v2.sv'];rows=[]
for p in S:
 b=p.read_bytes();q=W/p.name;q.write_bytes(b);rows.append(dict(path=str(p),snapshot=str(q),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b)))
(W/'INPUTS.json').write_text(json.dumps(rows,indent=2));(W/'RUNNER.py').write_bytes(Path(__file__).read_bytes())
results=[]
for n,args in [('lib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv']+[r['snapshot'] for r in rows]),('sim',[str(M/'vsim.exe'),'-c','-novopt','-l',str(W/'native.log'),'-wlf',str(W/'native.wlf'),'work.tb_pair_latest_descriptor_v2','-do','run -all;quit -f'])]:
 with (W/(n+'.log')).open('w') as f:
  p=subprocess.Popen(args,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(n+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=args,time=time.time())));c=p.wait()
 t=(W/(n+'.log')).read_text();ok=c==0 and '** Error' not in t and '** Fatal' not in t;results.append(dict(stage=n,exit=c,pass_gate=ok))
 if not ok:
  (W/'RESULT.json').write_text(json.dumps(dict(status='FAIL_PRESERVED',stages=results),indent=2));print(t);raise SystemExit(1)
assert 'PAIR_LATEST_DESCRIPTOR_PASS' in t
assert all(hashlib.sha256(Path(x['path']).read_bytes()).hexdigest()==x['sha256'] for x in rows)
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_ORIGINAL_CLONE_LEASE_AND_ACCEPTED_DESCRIPTOR_MODEL',stages=results,inputs_unchanged=True,boundary='Original lease public ports and internal state compare each edge. Full-width two-slot reference/one-latest descriptor storage under actual acceptance. Not full backend/video proof.'),indent=2));print(W)
