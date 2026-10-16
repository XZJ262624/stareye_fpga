"""Direct full-width alias stress; state injection is explicit, not a real reset claim."""
from pathlib import Path
import json,hashlib,subprocess,time,shutil
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/cookie_alias';B.mkdir();N=Path('E:/Modelsim_10.1c/win64')
tb=R/'tb/m5c_diagnostics/tb_shadow_rows.sv';s=tb.read_text().replace('tb_shadow_rows','tb_shadow_cookie')
needle='  // New SOF invalidates old banks before each receives its new full row.'
insert='''  // No SOF/clear: preserve the completed old bank and low32, change high32 only.
  @(negedge clk);fy=11;fx=1279;dut.frame_cookie=dut.frame_cookie^64'h0000000100000000;
  #1;if(!complete||sv)$fatal(1,"SHADOW_HIGH_COOKIE_ALIAS");
  dut.frame_cookie=dut.frame_cookie^64'h0000000100000000;
  #1;if(!sv)$fatal(1,"SHADOW_COOKIE_RESTORE");
'''
assert needle in s;s=s.replace(needle,insert+needle);t=B/'tb_shadow_cookie.sv';t.write_text(s)
src=R/'rtl/m5c_fusion/m5c_row_fusion.sv';orig=src.read_text();old='assign diag_shadow_valid=shadow_geometry&&row_complete[obank]&&row_y[obank]==final_y&&row_cookie[obank]==frame_cookie;'
new='assign diag_shadow_valid=shadow_geometry&&row_complete[obank]&&row_y[obank]==final_y&&row_cookie[obank][31:0]==frame_cookie[31:0];'
assert orig.count(old)==1;mut=B/'row_cookie_low32_mutant.sv';mut.write_text(orig.replace(old,new));assert mut.read_text().replace(new,old)==orig
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
results=[]
for name,rtl,expected in [('positive',src,None),('low32_mutant',mut,'SHADOW_HIGH_COOKIE_ALIAS')]:
 d=B/name;d.mkdir();sources=[rtl,R/'rtl/m5c_fusion/m5a_copy/m5a_packet_delay.v',t]
 vec=R/'reports/m5c_shadow_stats_20261016/rows_133043';inputs=[rec(p) for p in sources+[Path(__file__),vec/'classes.hex',vec/'expected.hex']]
 (d/'INPUTS.json').write_text(json.dumps(inputs,indent=2));steps=[]
 cmds=[[str(N/'vlib.exe'),'work'],[str(N/'vlog.exe'),'-sv',*[str(p) for p in sources]],[str(N/'vsim.exe'),'-c','-novopt','tb_shadow_cookie','+CLASSES='+str(vec/'classes.hex'),'+EXPECTED='+str(vec/'expected.hex'),'-l','sim.log','-do','run -all; quit -code 0']]
 for i,cmd in enumerate(cmds):
  with (d/f'step{i}.log').open('wb') as f:
   p=subprocess.Popen(cmd,cwd=d,stdout=f,stderr=subprocess.STDOUT);(d/f'OWNER{i}.json').write_text(json.dumps(dict(pid=p.pid,start=time.time(),cmd=cmd),indent=2));code=p.wait(timeout=120)
  steps.append(code)
  if code or '** Error:' in (d/f'step{i}.log').read_text(errors='replace'):break
 log=(d/'sim.log').read_text(errors='replace') if (d/'sim.log').exists() else ''
 fatal=[line for line in log.splitlines() if '** Fatal:' in line];ok=len(steps)==3 and steps[:2]==[0,0] and '** Error:' not in log and inputs==[rec(Path(x['path'])) for x in inputs]
 ok=ok and ((len(fatal)==1 and expected in fatal[0]) if expected else not fatal and 'SHADOW_ROWS_PASS checks=15360' in log)
 result=dict(case=name,status='PASS' if ok else 'FAIL',raw_exits=steps,expected_fatal=expected,actual_fatal=fatal,bindings=inputs);(d/'RESULT.json').write_text(json.dumps(result,indent=2));results.append(result);assert ok,result
(B/'RESULT.json').write_text(json.dumps(dict(status='PASS_FULL_HIGH_COOKIE_AND_SENSITIVITY',cases=results,mutant_inverse_text_exact=True,parent_tb=rec(tb),scope='Actual completed bank retained; high32 change with low32 equal, no SOF invalidation. Explicit state-injected finite alias test.'),indent=2));print('PASS_HIGH_COOKIE',flush=True)
