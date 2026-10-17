from pathlib import Path
import xml.etree.ElementTree as ET,subprocess,json,hashlib,datetime,time
R=Path(__file__).resolve().parents[1];P=R/'efinity/m5c_pair_diag_i3';W=R/'reports/m5c_pair_capture_20261016'/('integration_compile_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64')
S=[]
for e in ET.parse(P/'Ti60_Demo.xml').iter():
 if e.tag.endswith('design_file'):
  p=(P/e.attrib['name']).resolve()
  if '/rtl/' in p.as_posix():S.append(p)
S+= [P/'example_top.v']
inputs=[];snap=W/'sources';snap.mkdir()
for i,p in enumerate(S):
 b=p.read_bytes();q=snap/(str(i)+'_'+p.name);q.write_bytes(b);inputs.append(dict(path=str(p),snapshot=str(q),bytes=len(b),sha256=hashlib.sha256(b).hexdigest()))
(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'RUNNER.py').write_bytes(Path(__file__).read_bytes())
for name,args in [('vlib',[str(M/'vlib.exe'),'work']),('vlog',[str(M/'vlog.exe'),'-sv','-work','work']+[r['snapshot'] for r in inputs]),('elaborate',[str(M/'vsim.exe'),'-c','-novopt','-l',str(W/'native.log'),'-wlf',str(W/'compile.wlf'),'work.m5c_pair_system','-do','quit -f'])]:
 with (W/(name+'.log')).open('w') as f:
  t=time.time();p=subprocess.Popen(args,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(name+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,started=t,args=args),indent=2));code=p.wait()
 log=(W/(name+'.log')).read_text(errors='replace');print(name,code,flush=True)
 if code or '** Error' in log:print(log[-7000:]);(W/'RESULT.json').write_text(json.dumps(dict(status='FAIL_COMPILE_OR_ELAB',stage=name,exit=code)));raise SystemExit(1)
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_COMPILE_AND_ELAB_ONLY',inputs_unchanged=all(hashlib.sha256(Path(r['path']).read_bytes()).hexdigest()==r['sha256'] for r in inputs))));print(W)
