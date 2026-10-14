from pathlib import Path
import hashlib,json,subprocess,time,sys
F=Path(__file__).resolve().parent;R=F.parents[4];N=Path('E:/Modelsim_10.1c/win64');W=F/('model_preflight_'+time.strftime('%H%M%S'));W.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
deps=[F/'tb_model_preflight.sv',F/'selected_fault_ddr_model_retry.sv',F/'DERIVATION.json',Path(__file__)];inputs=[rec(p) for p in deps];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));steps=[];ok=True
for stage,cmd in [('vlib',[N/'vlib.exe','work']),('compile',[N/'vlog.exe','-sv','-work','work',*deps[:2]]),('sim',[N/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_model_preflight','-do','run -all; quit -code 0'])]:
 t=time.time()
 with (W/(stage+'.log')).open('wb') as f:
  p=subprocess.Popen(list(map(str,cmd)),cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(stage+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=list(map(str,cmd)),started=t)));code=p.wait(timeout=120)
 text=(W/(stage+'.log')).read_text();ok=code==0 and '** Fatal:' not in text and '** Error:' not in text and (stage!='sim' or 'PASS_MODEL_PREFLIGHT_ONLY' in text);steps.append(dict(stage=stage,exit=code,log=rec(W/(stage+'.log'))))
 if not ok:break
assert inputs==[rec(p) for p in deps]
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_BOUNDED_MODEL_PREFLIGHT_ONLY' if ok else 'FAIL',steps=steps),indent=2));print(W,ok);sys.exit(0 if ok else 1)
