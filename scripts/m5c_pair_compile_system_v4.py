from pathlib import Path
import subprocess,json,hashlib,datetime,time
R=Path.cwd();F=R/'reports/m5c_pair_capture_20261016/system_fixture_v4';W=F/('compile_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64')
S=sorted((R/'rtl/m5c_fusion').glob('*.sv'))+sorted((R/'rtl/m5c_fusion/m5a_copy').glob('*.v'))+sorted((R/'rtl/m5c_pair_diag').glob('*.sv'))+[F/'tb_pair_system.sv',R/'tb/m5c_fusion/m5c1b_ddr_service_model.sv',R/'efinity/m5c_fusion_i3/src/lcd_driver.v',R/'reports/m5c1b_fusion_integration/osd_reference/m5a_osd_baseline_reference.v']
def rec(p):b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
inputs=[rec(p) for p in S+[F/'end_declarations.svh',F/'end_protocol.svh',R/'efinity/m5c_fusion_i3/src/lcd_para.v',Path(__file__).resolve()]];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for i,x in enumerate(inputs):(W/'snapshots'/f'{i}_{Path(x["path"]).name}').write_bytes(Path(x['path']).read_bytes())
commands=[[str(M/'vlib.exe'),'work'],[str(M/'vlog.exe'),'-sv','-work','work','+incdir+'+str(R/'rtl/m5c_fusion'),'+incdir+'+str(R/'efinity/m5c_fusion_i3/src'),'+incdir+'+str(F)]+[str(p) for p in S],[str(M/'vsim.exe'),'-c','-novopt','-l',str(W/'native.log'),'-wlf',str(W/'compile.wlf'),'work.tb_pair_system','-do','quit -f']]
steps=[]
for i,c in enumerate(commands):
 with (W/f'{i}.log').open('wb') as f:
  p=subprocess.Popen(c,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/f'OWNER{i}.json').write_text(json.dumps(dict(pid=p.pid,start=time.time(),command=c)));code=p.wait()
 t=(W/f'{i}.log').read_text(errors='replace');steps.append(dict(command=c,exit=code,log=rec(W/f'{i}.log')));print(i,code,flush=True)
 if code or '** Error' in t:print(t[-10000:]);break
ok=len(steps)==3 and all(x['exit']==0 for x in steps) and '** Error' not in t
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_COMPILE_ELAB_ONLY' if ok else 'FAIL_COMPILE_ELAB',steps=steps,unchanged=inputs==[rec(Path(x['path'])) for x in inputs]),indent=2));print(W)
raise SystemExit(0 if ok else 1)
