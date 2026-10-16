"""Bounded native row oracle; independent stimulus/expected-bit construction."""
from pathlib import Path
import datetime,json,hashlib,subprocess,time,shutil
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016'/('rows_'+datetime.datetime.now().strftime('%H%M%S'));B.mkdir()
N=Path('E:/Modelsim_10.1c/win64');W=1280
classes=[];expected=[]
for row in range(12):
 ref=[(x+row)%3 for x in range(W)];cur=ref.copy()
 changes=[[],[63],[64],[127],[128],[1279],[0,63,64,127,128,1215,1216,1279],[255],[1279],[62,63,64,65],[127,128,129],[]][row]
 for x in changes:cur[x]=(ref[x]+1)%3
 if row==7:ref[255]=2;cur[255]=0
 if row==8:cur[1279]=3
 flags=[all(cur[x]==ref[x] and cur[x]!=3 and ref[x]!=3 for x in range(k*64,(k+1)*64)) for k in range(20)]
 exp=sum(int(v)<<k for k,v in enumerate(flags))|(int(any(a==2 and b!=2 for a,b in zip(ref,cur)))<<20)|(int(3 in cur or 3 in ref)<<21)|(int(all(flags))<<22)
 expected.append(exp);classes.extend((a<<2)|b for a,b in zip(ref,cur))
(B/'classes.hex').write_text('\n'.join(f'{v:x}' for v in classes)+'\n');(B/'expected.hex').write_text('\n'.join(f'{v:06x}' for v in expected)+'\n')
sources=[R/'rtl/m5c_fusion/m5c_row_fusion.sv',R/'rtl/m5c_fusion/m5a_copy/m5a_packet_delay.v',R/'tb/m5c_diagnostics/tb_shadow_rows.sv']
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
inputs=[rec(p) for p in sources+[Path(__file__),B/'classes.hex',B/'expected.hex']];(B/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(B/'snapshots').mkdir()
for x in inputs:shutil.copyfile(x['path'],B/'snapshots'/Path(x['path']).name)
cmds=[[str(N/'vlib.exe'),'work'],[str(N/'vlog.exe'),'-sv',*[str(p) for p in sources]],[str(N/'vsim.exe'),'-c','-novopt','tb_shadow_rows','+CLASSES='+str(B/'classes.hex'),'+EXPECTED='+str(B/'expected.hex'),'-l','sim.log','-do','run -all; quit -code 0']]
steps=[]
for i,cmd in enumerate(cmds):
 start=time.time();p=subprocess.Popen(cmd,cwd=B,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(B/f'OWNER{i}.json').write_text(json.dumps(dict(pid=p.pid,start=start,cmd=cmd,cwd=str(B)),indent=2));print('STAGE',i,'PID',p.pid,'DIR',B,flush=True)
 try:log=p.communicate(timeout=120)[0];timeout=False
 except subprocess.TimeoutExpired:
  timeout=True;subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],capture_output=True);log=p.communicate()[0]
 (B/f'step{i}.log').write_bytes(log);steps.append(dict(exit=p.returncode,timeout=timeout,seconds=time.time()-start))
 if timeout or p.returncode or b'** Error:' in log:break
text=(B/'sim.log').read_text(errors='replace') if (B/'sim.log').exists() else ''
unchanged=inputs==[rec(Path(v['path'])) for v in inputs];ok=len(steps)==3 and all(s['exit']==0 and not s['timeout'] for s in steps) and 'SHADOW_ROWS_PASS checks=15360' in text and '** Fatal:' not in text and unchanged
(B/'RESULT.json').write_text(json.dumps(dict(status='PASS_ROWS_SOFTWARE_VECTORS_NATIVE' if ok else 'FAIL',steps=steps,source_unchanged=unchanged,inputs=inputs,scope='Standalone row-shadow comparator,12 fullwidth rows, no full720p/video/UART claim.'),indent=2));print('RESULT',ok,B,flush=True)
