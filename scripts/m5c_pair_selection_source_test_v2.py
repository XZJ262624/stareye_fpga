from pathlib import Path
import datetime,hashlib,json,subprocess,time
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_capture_20261016';W=F/('selection_source_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64')
S=sorted((R/'rtl/m5c_fusion').glob('*.sv'))+sorted((R/'rtl/m5c_fusion/m5a_copy').glob('*.v'))+[R/'tb/m5c_pair_diag/tb_pair_selection_source.sv']
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
inputs=[rec(p) for p in S+[Path(__file__)]];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for i,x in enumerate(inputs):(W/'snapshots'/f'{i}_{Path(x["path"]).name}').write_bytes(Path(x['path']).read_bytes())
steps=[]
for name,cmd in [('vlib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv']+[str(p) for p in S]),('sim',[str(M/'vsim.exe'),'-c','-novopt','-wlf','NUL','work.tb_pair_selection_source','-do','run -all; quit -f'])]:
 with (W/(name+'.log')).open('w') as f:
  p=subprocess.Popen(cmd,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(name+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=cmd,started=time.time())));code=p.wait()
 t=(W/(name+'.log')).read_text(errors='replace');steps.append(dict(stage=name,exit=code,log=rec(W/(name+'.log'))))
 if code or '** Error' in t:break
ok=len(steps)==3 and code==0 and '** Fatal' not in t and '** Error' not in t and 'SOURCE_PHASE_PASS' in t
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_SOURCE_PHASE_ONLY' if ok else 'FAIL',steps=steps,unchanged=inputs==[rec(Path(x['path'])) for x in inputs]),indent=2));print(W,ok);print(t[-1500:])
