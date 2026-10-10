"""Compile broken copies and require the real HDL acceptance oracle to fail."""
from pathlib import Path
import subprocess,hashlib,json,datetime
R=Path(__file__).resolve().parents[1];T=R/'tb/m5b1_global_canny';M=Path('E:/Modelsim_10.1c/win64');O=R/'reports/m5b1_global_canny_i3/mutations'
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
CASES=[
 ('ack_isolation','arbiter',[('&&!ddr_reset_ack','')],'arbiter',[],'ACK'),
 ('real_B_fence','arbiter',[("B:if(bvalid&&bready)","B:if(1'b1)")],'arbiter',[],'watchdog or framing error'),
 ('request_epoch','arbiter',[("c_epoch[choice*64+:64]==epoch &&","1'b1 &&")],'arbiter',[],'illegal request rejection'),
 ('4KiB','arbiter',[("(selected_address[11:0]+(({5'b0,selected_len}+13'd1)<<4))<=4096 &&","1'b1 &&")],'arbiter',[],'A protocol'),
 ('range_permission','arbiter',[("&&bg_range_ok(selected_address,selected_end,c_atype[2])","&&1'b1")],'arbiter',[],'illegal request rejection'),
 ('changed_reduction','global_engine',[("pair_changed<=1;","pair_changed<=0;")],'global_engine',['+FIRST=16','+TESTS=1'],'last-pixel changed reduction'),
 ('changed_last_pixel','global_engine',[("pair_changed<=1;","if(!(last_column&&last_row))pair_changed<=1;")],'global_engine',['+FIRST=16','+TESTS=1'],'last-pixel changed reduction'),
 ('pending_result_lease','backend',[(".result_available(latest_valid?(latest_slot?2'b01:2'b10):2'b11)",".result_available(2'b11)")],'system',['-gTESTMODE=5','+DELAY=378'],'reserved pending result'),
 ('prefill','video_dma',[("display_rc>=256","1'b1")],'prefill',[],'prefill barrier'),
 ('capture_epoch','capture',[("tap_epoch!=desc[63:0]||",''),("tap_epoch!=arm_data[63:0]||",'')],'capture',[],'descriptor identity/status'),
]
def main():
 O.mkdir(exist_ok=True);src=sorted((R/'rtl/m5b1_global_canny').glob('*.sv'));tracked=src+sorted(T.glob('*.sv'))+[Path(__file__)];before=[rec(p) for p in tracked];cases=[]
 run=O/('work_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));run.mkdir()
 for name,module,replacements,test,args,expected in CASES:
  C=run/name;C.mkdir();original=R/f'rtl/m5b1_global_canny/m5b1_{module}.sv';s=original.read_text()
  for old,new in replacements:assert old in s,(name,old);s=s.replace(old,new)
  changed=C/original.name;changed.write_text(s)
  x=subprocess.run([str(M/'vlib.exe'),str(C/'work')],capture_output=True);assert x.returncode==0
  compile_src=[changed if p==original else p for p in src]+[T/f'tb_m5b1_{test}.sv']
  x=subprocess.run([str(M/'vlog.exe'),'-sv','-work',str(C/'work'),*map(str,compile_src)],cwd=C,capture_output=True)
  (C/'compile.log').write_bytes(x.stdout+x.stderr);assert x.returncode==0,(name,x.stdout[-3000:])
  log=O/(name+'.log');x=subprocess.run([str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-lib',str(C/'work'),f'tb_m5b1_{test}',*args,'-do','run -all; quit -f','-l',str(log)],cwd=C,capture_output=True,timeout=1800)
  out=x.stdout.decode(errors='replace');fatal=next((l for l in out.splitlines() if '** Fatal:' in l),None)
  assert fatal is not None,(name,'mutant survived',out[-2000:])
  assert expected.lower() in fatal.lower(),(name,'unrelated failure',fatal)
  row=dict(name=name,original=rec(original),mutant=rec(changed),testbench=rec(T/f'tb_m5b1_{test}.sv'),failure=fatal,log=rec(log));cases.append(row);print(name,fatal,flush=True)
 assert before==[rec(p) for p in tracked]
 (O/'results.json').write_text(json.dumps(dict(status='PASS_ALL_BROKEN_COPIES_REJECTED',sources=before,cases=cases),indent=2))
if __name__=='__main__':main()
