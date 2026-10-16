from pathlib import Path
import json,hashlib,subprocess,time
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/bridge_regression_v2';B.mkdir();N=Path('E:/Modelsim_10.1c/win64');src=R/'rtl/m5c_diagnostics/m5c_diag_record_bridge.sv';tb=R/'reports/m5c_shadow_stats_20261016/bridge_fixture_v2/tb_diag_bridge_guard.sv'
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
data=src.read_bytes();old=b'(ui_done||ui_cancel)';new=b'(ui_ready||ui_cancel)';assert data.count(old)==1;mut=B/'bridge_early_ack.sv';mut.write_bytes(data.replace(old,new));assert mut.read_bytes().replace(new,old)==data
results=[]
for name,rtl,fatal in [('positive',src,None),('early_ack',mut,'BRIDGE_EARLY_ACK')]:
 d=B/name;d.mkdir();inputs=[rec(p) for p in [src,rtl,tb,Path(__file__)]];(d/'INPUTS.json').write_text(json.dumps(inputs,indent=2));steps=[]
 for i,cmd in enumerate([[str(N/'vlib.exe'),'work'],[str(N/'vlog.exe'),'-sv',str(rtl),str(tb)],[str(N/'vsim.exe'),'-c','-novopt','tb_diag_bridge','-l','sim.log','-do','run -all; quit -code 0']]):
  with (d/f'step{i}.log').open('wb') as f:
   p=subprocess.Popen(cmd,cwd=d,stdout=f,stderr=subprocess.STDOUT);(d/f'OWNER{i}.json').write_text(json.dumps(dict(pid=p.pid,start=time.time(),cmd=cmd),indent=2));steps.append(p.wait(timeout=60))
  if steps[-1] or '** Error:' in (d/f'step{i}.log').read_text(errors='replace'):break
 log=(d/'sim.log').read_text(errors='replace') if (d/'sim.log').exists() else '';fs=[x for x in log.splitlines() if '** Fatal:' in x]
 ok=len(steps)==3 and steps[:2]==[0,0] and '** Error:' not in log and inputs==[rec(Path(x['path'])) for x in inputs]
 ok=ok and (len(fs)==1 and fatal in fs[0] if fatal else not fs and 'DIAG_BRIDGE_PASS' in log)
 z=dict(status='PASS' if ok else 'FAIL',steps=steps,actual_fatal=fs,expected=fatal);(d/'RESULT.json').write_text(json.dumps(z,indent=2));results.append(z);assert ok,z
(B/'RESULT.json').write_text(json.dumps(dict(status='PASS_CURRENT_UNCHANGED_BRIDGE_AND_EARLY_ACK_SENSITIVITY',cases=results,mutation=dict(old=old.decode(),new=new.decode(),inverse_byte_exact=True),scope='Actual320-byte data mapping, trueDONE ACK, cancel/resetpending/stoppedUIclock/recovery; no observer schema payload assumptions.'),indent=2));print('PASS_BRIDGE')
