"""Directed actual bus fault, stale capture, export abort and result-slot lease."""
from pathlib import Path
import subprocess,json,hashlib,struct
from m5b1_uart_decode import parse,verify
R=Path(__file__).resolve().parents[1];T=R/'tb/m5b1_global_canny';O=R/'reports/m5b1_global_canny_i3/system_faults';M=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 O.mkdir(exist_ok=True);src=sorted((R/'rtl/m5b1_global_canny').glob('*.sv'))+[T/'tb_m5b1_system.sv',Path(__file__),R/'scripts/m5b1_uart_decode.py'];before=[rec(p) for p in src]
 x=subprocess.run([str(M/'vlog.exe'),'-sv','-work',str(T/'work'),*map(str,src[:-2])],cwd=T,capture_output=True);(O/'compile.log').write_bytes(x.stdout+x.stderr);assert x.returncode==0
 cases=[]
 for mode,label,marker in [(2,'stuck_owner','M5B1_SYSTEM_FAULT_PASS'),(3,'capture_epoch','M5B1_SYSTEM_EPOCH_PASS'),(1,'export_timeout','M5B1_SYSTEM_EXPORT_TIMEOUT_PASS'),(4,'export_recovery','M5B1_SYSTEM_EXPORT_RECOVERY_PASS'),(5,'result_lease','M5B1_SYSTEM_PASS')]:
  log=O/(label+'.log');x=subprocess.run([str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-lib',str(T/'work'),'tb_m5b1_system',f'-gTESTMODE={mode}','+DELAY=378','-do','run -all; quit -f','-l',str(log)],cwd=T,capture_output=True,timeout=1800)
  text=x.stdout.decode(errors='replace');assert marker in text and '** Fatal' not in text and '** Error' not in text,text[-4000:]
  raw=bytes.fromhex((T/'system_uart.hex').read_text());diagnostics=[];packets=parse(raw,resync=mode==4,allow_trailing_partial=mode==1,diagnostics=diagnostics)
  if mode==2:
   assert len(packets)==1 and packets[0]['type']==1 and struct.unpack_from('<I',packets[0]['payload'],128)[0]==1
  if mode==3:assert len(packets)==1 and not packets[0]['descriptor']['capture_success']
  if mode==1:assert [p['type'] for p in packets]==[1] and diagnostics
  if mode==4:assert [p['type'] for p in packets]==[1,1] and diagnostics and packets[0]['descriptor']['frame_id']!=packets[1]['descriptor']['frame_id']
  if mode==5:assert [p['type'] for p in packets]==[1,2,3,1] and verify(packets)['pixels']==921600
  row=dict(case=label,mode=mode,summary=next(l for l in text.splitlines() if marker in l),log=rec(log),uart_bytes=len(raw),uart_sha256=hashlib.sha256(raw).hexdigest(),crc_valid_packets=len(packets),partial_intervals=diagnostics)
  cases.append(row);print(row['summary'],flush=True)
 assert before==[rec(p) for p in src]
 (O/'results.json').write_text(json.dumps(dict(status='PASS',sources=before,cases=cases),indent=2))
if __name__=='__main__':main()
