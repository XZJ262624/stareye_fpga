from pathlib import Path
import datetime,hashlib,json,subprocess,time
R=Path('F:/Projects/stareye_fpga');F=Path(__file__).resolve().parent;M=Path('E:/Modelsim_10.1c/win64');W=F/('multisof_v3_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
base=R/'tb/m5c_pair_diag/tb_pair_selection_lifecycle_pack5.sv'
tb=F/'tb_pair_multisof_v3.sv'
(W/'TOOLS.json').write_text(json.dumps([rec(M/n) for n in ['vlib.exe','vlog.exe','vsim.exe']],indent=2))
package=R/'reports/m5c_pair_admission_20261018/remote_v3/package'
order=json.loads((package/'portable/compile_order.json').read_text())
sources=[(R/p if (R/p).exists() else package/p) for p in order if p.startswith('rtl/')] + [tb]
inputs=[rec(p) for p in sources+[base,Path(__file__)]];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for i,x in enumerate(inputs):(W/'snapshots'/f'{i}_{Path(x["path"]).name}').write_bytes(Path(x['path']).read_bytes())
(W/'DERIVATION.json').write_text(json.dumps(dict(base=rec(base),scope='Real pair capture200x8, full backend publication, actual selected lease, telemetry EOF and two full packets, retained release/drain, current DDR W/B and metadata storage; dimensions reduced, reader A withheld, no fullvideo claim'),indent=2));print(W,flush=True)
steps=[]
commands=[('vlib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv']+[str(W/'snapshots'/f'{i}_{p.name}') for i,p in enumerate(sources)])]+[(f'case{c}',[str(M/'vsim.exe'),'-c','-novopt','-wlf','NUL','work.tb_pair_multisof','-do','run -all; quit -f']) for c in [0]]
for stage,cmd in commands:
 d=W/stage;d.mkdir();cwd=W if stage in ('vlib','compile') else d
 if cwd==d:(d/'modelsim.ini').write_text('[Library]\nwork = '+str(W/'work')+'\n')
 start=time.time()
 with (d/'native.log').open('w') as log:
  p=subprocess.Popen(cmd,cwd=cwd,stdout=log,stderr=subprocess.STDOUT);(d/'OWNER.json').write_text(json.dumps(dict(pid=p.pid,started=datetime.datetime.now().astimezone().isoformat(),command=cmd,cwd=str(cwd)),indent=2));print(stage,p.pid,flush=True);code=p.wait(timeout=600)
 text=(d/'native.log').read_text(errors='replace');ok=code==0 and '** Error' not in text and '** Fatal' not in text and (stage in ('vlib','compile') or 'MULTISOF_PASS' in text)
 steps.append(dict(stage=stage,exit=code,ok=ok,seconds=time.time()-start,log=rec(d/'native.log')));(W/'PROGRESS.json').write_text(json.dumps(steps,indent=2))
 if not ok:print(text[-4000:],flush=True);break
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_FIXED_DEADLINE' if len(steps)==len(commands) and all(x['ok'] for x in steps) else 'NOT_PASS',steps=steps,source_unchanged=inputs==[rec(Path(x['path'])) for x in inputs]),indent=2));print(W,flush=True)
