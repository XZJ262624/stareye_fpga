"""Review repair regressions. Preserve the first failures and use isolated libraries.

The connection TB uses the actual production LCD and M5A modules; the C2 TB
retains the actual system/arbiter/transfer and only controls the admission input.
"""
from pathlib import Path
import argparse, subprocess, json, hashlib, re
R=Path(__file__).resolve().parents[1]
M=Path('E:/Modelsim_10.1c/win64')
O=R/'reports/m5b1_global_canny_i3/review_fix_264962e0'
def rec(p):
 return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--name',required=True);ap.add_argument('--case',choices=['connection','cancel','transfer_cancel','backend_edges','engine_abort','tag_qualification','default_timeout'],required=True);ap.add_argument('--mode',type=int,default=0);ap.add_argument('--expect-failure');ap.add_argument('--mutant',choices=['lcd_register','unqualified_tap','no_local_cancel','abort_zero_payload','live_metadata','freeze_take_race']);a=ap.parse_args()
 dest=O/a.name
 assert not (dest/'result.json').exists(),'Never replace a completed review experiment'
 dest.mkdir(parents=True,exist_ok=True);lib=dest/'work'
 src=sorted((R/'rtl/m5b1_global_canny').glob('*.sv'))
 if a.case in ('connection','tag_qualification'):
  src+=sorted((R/'rtl/m5b1_global_canny/m5a_copy').glob('*.v'))
  src+=[R/'efinity/m5b1_global_canny_i3/src/lcd_driver.v']
 top='tb_m5b1_'+a.case if a.case in ('transfer_cancel','backend_edges','engine_abort','tag_qualification','default_timeout') else 'tb_m5b1_review_'+a.case
 src+=[R/f'tb/m5b1_global_canny/{top}.sv']
 bound=src+[Path(__file__),R/'scripts/m5b1_uart_decode.py'];extra=[]
 if a.case=='connection':
  from m5a_streaming_canny_gold import spatial
  import numpy as np
  bound += [R/'scripts/m5a_streaming_canny_gold.py',R/'efinity/m5b1_global_canny_i3/src/lcd_para.v']
  gold=dest/'connection_gold.hex';y,x=np.indices((720,1280));pos=y*1280+x
  with gold.open('w') as f:
   for blank in (False,True):
    raw=np.zeros((720,1280),dtype=np.int32) if blank else ((0x35^(pos*13)^y)&255)
    q=spatial(raw,1,64)
    v=(q['raw'].astype(np.uint64)|(q['legacy_mag'].astype(np.uint64)<<8)|(q['legacy_bin'].astype(np.uint64)<<16)
       |(q['support'].astype(np.uint64)<<17)|(q['overlay'].astype(np.uint64)<<18)|(np.minimum(q['nms'],255).astype(np.uint64)<<19)
       |(q['nms_support'].astype(np.uint64)<<27)|(q['canny_support'].astype(np.uint64)<<28)|(q['canny'].astype(np.uint64)<<29)
       |((q['strong'].astype(np.uint64)*2+q['weak'].astype(np.uint64))<<30))
    f.writelines(f'{int(n):08x}\n' for n in v.flat)
  extra=['+GOLD='+str(gold)]
 before=[rec(p) for p in bound]
 mutation=None
 if a.mutant:
  edits={
   'lcd_register':('m5b1_video_dma.sv','output [7:0] pix_data','output reg [7:0] pix_data'),
   'unqualified_tap':('m5a_stream_top.v','assign tap_valid=tap_raster_valid&&frame_tags[tag_read[2:0]][192];','assign tap_valid=tap_raster_valid;'),
   'no_local_cancel':('m5b1_backend.sv','.cancel(transfer_cancel)','.cancel(1\'b0)'),
   'abort_zero_payload':('m5b1_global_engine.sv','case(state==ABORT?drain_state:state)','case(state)'),
   'live_metadata':('m5b1_global_engine.sv',"2:tx_wdata={16'b0,metadata_elapsed,pairs,desc[319:256]};", "2:tx_wdata={16'b0,elapsed,pairs,desc[319:256]};"),
   'freeze_take_race':('m5b1_backend.sv','FREEZE:if(descriptor_valid&&!capture_timeout)','FREEZE:if(descriptor_valid)')}
  name,old,new=edits[a.mutant];original=next(p for p in src if p.name==name);s=original.read_text();assert s.count(old)==1;s=s.replace(old,new)
  if a.mutant=='lcd_register':
   old="assign pix_data=pix_qualified?display_head[unpack_pos*8+:8]:8'd0;"
   assert s.count(old)==1;s=s.replace(old,"always @(posedge pix_clk or negedge prst_n)if(!prst_n)pix_data<=0;else pix_data<=pix_qualified?display_head[unpack_pos*8+:8]:8'd0;")
  target=dest/name;target.write_text(s);src=[target if p==original else p for p in src];mutation=dict(name=a.mutant,original=rec(original),mutated=rec(target))
 if not lib.exists():subprocess.run([str(M/'vlib.exe'),str(lib)],check=True,capture_output=True)
 c=subprocess.run([str(M/'vlog.exe'),'-sv','-work',str(lib),'+incdir+'+str(R/'efinity/m5b1_global_canny_i3/src'),*map(str,src)],cwd=dest,capture_output=True)
 (dest/'compile.log').write_bytes(c.stdout+c.stderr);assert c.returncode==0,c.stdout.decode(errors='replace')
 log=dest/'simulation.log'
 params=[] if a.case in ('transfer_cancel','backend_edges','engine_abort','tag_qualification') else [f'-gCHECK={a.mode}']
 command=[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-lib',str(lib),top,*params,*extra,'-do','run -all; quit -f','-l',str(log)]
 stdout_path=dest/'simulator_stdout.log';stderr_path=dest/'simulator_stderr.log';exit_path=dest/'simulator_exit.json'
 try:
  p=subprocess.run(command,cwd=dest,capture_output=True,timeout=7200)
 except (subprocess.TimeoutExpired,OSError) as error:
  stdout_path.write_bytes(getattr(error,'stdout',None) or b'')
  stderr_path.write_bytes(getattr(error,'stderr',None) or b'')
  exit_path.write_text(json.dumps(dict(command=command,status='TIMEOUT' if isinstance(error,subprocess.TimeoutExpired) else 'LAUNCH_ERROR',returncode=None,error=str(error),stdout=rec(stdout_path),stderr=rec(stderr_path)),indent=2))
  raise
 stdout_path.write_bytes(p.stdout);stderr_path.write_bytes(p.stderr)
 exit_path.write_text(json.dumps(dict(command=command,status='EXITED',returncode=p.returncode,stdout=rec(stdout_path),stderr=rec(stderr_path)),indent=2))
 s=p.stdout.decode(errors='replace');print(s[-5000:],flush=True)
 good=(a.expect_failure in s and '** Fatal' in s) if a.expect_failure else (p.returncode==0 and 'REVIEW_PASS' in s and '** Fatal' not in s and '** Error' not in s)
 assert before==[rec(p) for p in bound]
 host=None
 if good and not a.expect_failure and a.case in ('cancel','default_timeout'):
  from m5b1_uart_decode import parse
  import struct
  raw=bytes.fromhex((dest/'system_uart.hex').read_text());diagnostics=[];packets=parse(raw,resync=True,diagnostics=diagnostics)
  assert packets and packets[-1]['type']==1
  words=struct.unpack('<64I',packets[-1]['payload']);assert words[22]&8 and words[33]>0
  host=dict(bytes=len(raw),crc_valid_stats=sum(p['type']==1 for p in packets),last_job_fault_flags=words[22],local_cancels=words[33],resync=diagnostics,sha256=hashlib.sha256(raw).hexdigest())
 (dest/'result.json').write_text(json.dumps(dict(status='EXPECTED_REPRODUCTION' if a.expect_failure and good else 'PASS' if good else 'FAIL',case=a.case,mode=a.mode,expected_failure=a.expect_failure,mutation=mutation,host=host,sources=before,log=rec(log) if log.exists() else None,simulator_exit=rec(exit_path)),indent=2))
 assert good,'Review regression did not meet its explicit oracle'
if __name__=='__main__':main()
