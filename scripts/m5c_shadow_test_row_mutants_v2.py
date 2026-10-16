from pathlib import Path
import json,hashlib,subprocess,time
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/row_sensitivities_v2';B.mkdir();N=Path('E:/Modelsim_10.1c/win64')
src=R/'rtl/m5c_fusion/m5c_row_fusion.sv';original=src.read_text();tb=R/'tb/m5c_diagnostics/tb_shadow_rows.sv';vec=R/'reports/m5c_shadow_stats_20261016/rows_133043'
cases=[
 ('block_end',"if(!pixel_equal)shadow_tiles[bank][tap_x[10:6]]<=0;","if(!pixel_equal&&tap_x[5:0]!=63)shadow_tiles[bank][tap_x[10:6]]<=0;",'SHADOW64_ORACLE row=1 x=0'),
 ('row_end',"if(!pixel_equal)shadow_tiles[bank][tap_x[10:6]]<=0;","if(!pixel_equal&&tap_x!=1279)shadow_tiles[bank][tap_x[10:6]]<=0;",'SHADOW64_ORACLE row=5 x=1216'),
 ('index64','shadow_tiles[obank][final_x[10:6]]',"shadow_tiles[obank][final_x[10:6]^5'd1]",'SHADOW64_ORACLE row=1 x=0'),
 ('index128',"{final_x[10:7],1'b0}]&&shadow_tiles[obank][{final_x[10:7],1'b1}","{final_x[10:7]^4'd1,1'b0}]&&shadow_tiles[obank][{final_x[10:7]^4'd1,1'b1}",'SHADOW128_ORACLE row=1 x=0'),
 ('complete','diag_shadow_valid=shadow_geometry&&row_complete[obank]&&','diag_shadow_valid=shadow_geometry&&','SHADOW_EARLY_COMPLETE')]
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
results=[]
for name,old,new,fatal in cases[2:]:
 d=B/name;d.mkdir();assert original.count(old)==1;mut=d/'row_mutant.sv';mut.write_text(original.replace(old,new));assert mut.read_text().replace(new,old)==original
 sources=[mut,R/'rtl/m5c_fusion/m5a_copy/m5a_packet_delay.v',tb];inputs=[rec(p) for p in sources+[src,Path(__file__),vec/'classes.hex',vec/'expected.hex']];(d/'INPUTS.json').write_text(json.dumps(inputs,indent=2))
 cmds=[[str(N/'vlib.exe'),'work'],[str(N/'vlog.exe'),'-sv',*[str(p) for p in sources]],[str(N/'vsim.exe'),'-c','-novopt','tb_shadow_rows','+CLASSES='+str(vec/'classes.hex'),'+EXPECTED='+str(vec/'expected.hex'),'-l','sim.log','-do','run -all; quit -code 0']];steps=[]
 for i,cmd in enumerate(cmds):
  with (d/f'step{i}.log').open('wb') as f:
   p=subprocess.Popen(cmd,cwd=d,stdout=f,stderr=subprocess.STDOUT);(d/f'OWNER{i}.json').write_text(json.dumps(dict(pid=p.pid,start=time.time(),cmd=cmd),indent=2));code=p.wait(timeout=120)
  steps.append(code)
  if code or '** Error:' in (d/f'step{i}.log').read_text(errors='replace'):break
 log=(d/'sim.log').read_text(errors='replace') if (d/'sim.log').exists() else '';actual=[x for x in log.splitlines() if '** Fatal:' in x]
 ok=len(steps)==3 and steps[:2]==[0,0] and len(actual)==1 and fatal in actual[0] and '** Error:' not in log and inputs==[rec(Path(x['path'])) for x in inputs]
 z=dict(status='PASS_EXPECTED_CAUSAL_FATAL' if ok else 'FAIL',case=name,expected=fatal,actual=actual,steps=steps,old=old,new=new,inverse_text_exact=True);(d/'RESULT.json').write_text(json.dumps(z,indent=2));results.append(z);print(name,z['status'],flush=True);assert ok,z
(B/'RESULT.json').write_text(json.dumps(dict(status='PASS_ALL_ROW_SENSITIVITIES',cases=results),indent=2))
