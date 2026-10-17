from pathlib import Path
import json,subprocess,hashlib,time
R=Path.cwd();B=R/'reports/m5c_pair_capture_20261016';F=B/'system_fixture_pack5';W=F/'compile_preflight';W.mkdir(exist_ok=False)
steps=json.loads((B/'system_selection_fixed_0109/RESULT.json').read_text())['steps'];commands=[x['command'] for x in steps[:2]]
commands=[[s.replace('system_fixture_selection_fixed','system_fixture_pack5') for s in cmd] for cmd in commands]
results=[]
for i,cmd in enumerate(commands):
 with (W/f'step{i}.log').open('w') as f:
  p=subprocess.Popen(cmd,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/f'OWNER{i}.json').write_text(json.dumps(dict(pid=p.pid,started=time.time(),command=cmd)));code=p.wait()
 text=(W/f'step{i}.log').read_text();results.append(dict(exit=code,errors='** Error' in text));assert code==0 and '** Error' not in text,text[-4000:]
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_COMPILE_ONLY_NO_NATIVE_SYSTEM',steps=results),indent=2));print('compile PASS')
