from pathlib import Path
import subprocess,json,hashlib,datetime,time,shutil,sys
R=Path(__file__).resolve().parents[1];D=R/'reports/m5c_shadow_stats_20261016'/('headercoupled_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));D.mkdir()
N=Path('E:/Modelsim_10.1c/win64')
sources=sorted((R/'rtl/m5c_fusion').glob('*.sv'))+sorted((R/'rtl/m5c_fusion/m5a_copy').glob('*.v'))+list((R/'rtl/m5c_diagnostics').glob('*v3.sv'))+[R/'rtl/m5c_diagnostics/m5c_diag_record_bridge.sv',R/'rtl/m5c_diagnostics/m5c_diag_slot_guard.sv',R/'reports/m5c_shadow_stats_20261016/header_fixture/tb_shadow_header_coupled.sv']
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
inputs=[rec(p) for p in sources+[Path(__file__)]];(D/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(D/'snapshots').mkdir()
for x in inputs:shutil.copyfile(x['path'],D/'snapshots'/Path(x['path']).name)
commands=[[str(N/'vlib.exe'),'work'],[str(N/'vlog.exe'),'-sv','-work','work','+incdir+'+str(R/'rtl/m5c_fusion')]+[str(p) for p in sources],[str(N/'vsim.exe'),'-c','-novopt','-lib','work','tb_shadow_header_coupled','+PHASE=2','+OUT='+D.as_posix(),'-l','sim.log','-do','run -all; quit -code 0']]
commands[-1][7:7]=sys.argv[1:]
steps=[]
for i,cmd in enumerate(commands):
 start=time.time();proc=subprocess.Popen(cmd,cwd=D,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(D/f'OWNER_{i}.json').write_text(json.dumps(dict(pid=proc.pid,start=start,cmd=cmd,cwd=str(D)),indent=2));print('STAGE',i,'PID',proc.pid,'DIR',D,flush=True)
 timeout=False
 try:log=proc.communicate(timeout=180)[0]
 except subprocess.TimeoutExpired:
  timeout=True;subprocess.run(['taskkill','/PID',str(proc.pid),'/T','/F'],capture_output=True);log=proc.communicate()[0]
 (D/f'step{i}.log').write_bytes(log);steps.append(dict(exit=proc.returncode,timeout=timeout,seconds=time.time()-start,log=rec(D/f'step{i}.log')))
 if timeout or proc.returncode or b'** Error:' in log:break
unchanged=inputs==[rec(Path(x['path'])) for x in inputs];text=(D/'sim.log').read_text(errors='replace') if (D/'sim.log').exists() else ''
ok=len(steps)==3 and all(x['exit']==0 and not x['timeout'] for x in steps) and 'CACHE_CONTEXT_PASS' in text and '** Fatal:' not in text and '** Error:' not in text and unchanged
(D/'RESULT.json').write_text(json.dumps(dict(status='PASS_SIM_PENDING_SOFTWARE' if ok else 'FAIL',steps=steps,inputs_unchanged=unchanged),indent=2));print('RESULT',ok,D,flush=True)
