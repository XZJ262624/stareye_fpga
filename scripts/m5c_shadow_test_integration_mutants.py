from pathlib import Path
import json,hashlib,subprocess,time
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/integration_sensitivities';B.mkdir();N=Path('E:/Modelsim_10.1c/win64')
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
results=[]
for case in ['shadow_missing','shadow_production_gate']:
 d=B/case;d.mkdir()
 if case=='shadow_missing':
  parent=R/'tb/m5c_diagnostics/tb_shadow_observer.sv';old='.shadow_valid(complete&&rtag)';new=".shadow_valid(1'b0)";mut=d/parent.name;top='tb_shadow_observer';expected='SHADOW_VALID_MISSING'
  sources=[R/'rtl/m5c_diagnostics/m5c_diag_observer_v3.sv',R/'rtl/m5c_fusion/m5a_copy/m5a_osd.v',mut]
 else:
  parent=R/'rtl/m5c_fusion/m5c_row_fusion.sv';old='row_complete[obank]&&row_equal[obank]&&row_y[obank]==final_y';new='row_complete[obank]&&diag_shadow64&&row_y[obank]==final_y';mut=d/parent.name;top='tb_shadow_coupled';expected='REAL_PIPELINE_PIXEL'
  sources=[mut if p==parent else p for p in sorted((R/'rtl/m5c_fusion').glob('*.sv'))]+sorted((R/'rtl/m5c_fusion/m5a_copy').glob('*.v'))+[R/'rtl/m5c_diagnostics/m5c_diag_observer_v3.sv',R/'rtl/m5c_diagnostics/m5c_diag_record_bridge.sv',R/'rtl/m5c_diagnostics/m5c_diag_slot_guard.sv',R/'tb/m5c_diagnostics/tb_shadow_coupled.sv']
 data=parent.read_bytes();assert data.count(old.encode())==1;changed=data.replace(old.encode(),new.encode());assert changed.replace(new.encode(),old.encode())==data;mut.write_bytes(changed)
 inputs=[rec(p) for p in sources+[parent,Path(__file__)]];(d/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(d/'DERIVATION.json').write_text(json.dumps(dict(parent=rec(parent),mutant=rec(mut),before=old,after=new,inverse_byte_exact=True,expected=expected),indent=2))
 cmds=[[str(N/'vlib.exe'),'work'],[str(N/'vlog.exe'),'-sv','+incdir+'+str(R/'rtl/m5c_fusion'),*[str(p) for p in sources]],[str(N/'vsim.exe'),'-c','-novopt',top,'+OUT='+d.as_posix(),'-l','sim.log','-do','run -all; quit -code 0']];steps=[]
 for i,cmd in enumerate(cmds):
  with (d/f'step{i}.log').open('wb') as f:
   p=subprocess.Popen(cmd,cwd=d,stdout=f,stderr=subprocess.STDOUT);(d/f'OWNER{i}.json').write_text(json.dumps(dict(pid=p.pid,start=time.time(),cmd=cmd),indent=2));code=p.wait(timeout=180)
  steps.append(code)
  if code or '** Error:' in (d/f'step{i}.log').read_text(errors='replace'):break
 log=(d/'sim.log').read_text(errors='replace') if (d/'sim.log').exists() else '';fatal=[x for x in log.splitlines() if '** Fatal:' in x]
 ok=len(steps)==3 and steps[:2]==[0,0] and len(fatal)==1 and expected in fatal[0] and '** Error:' not in log and inputs==[rec(Path(x['path'])) for x in inputs]
 z=dict(status='PASS_EXPECTED_CAUSAL_FATAL' if ok else 'FAIL',steps=steps,expected=expected,actual=fatal);(d/'RESULT.json').write_text(json.dumps(z,indent=2));results.append(z);print(case,z['status'],flush=True);assert ok,z
(B/'RESULT.json').write_text(json.dumps(dict(status='PASS_TWO_INTEGRATION_SENSITIVITIES',cases=results),indent=2))
