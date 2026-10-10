"""Full physical-interface coexistence: mixed capture, engine, leases and export."""
from pathlib import Path
import subprocess, hashlib, json, re, shutil, struct
from m5b1_uart_decode import parse, verify
R=Path(__file__).resolve().parents[1]; T=R/'tb/m5b1_global_canny'
O=R/'reports/m5b1_global_canny_i3/system'; M=Path('E:/Modelsim_10.1c/win64')
def rec(p):
 return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 O.mkdir(exist_ok=True)
 src=sorted((R/'rtl/m5b1_global_canny').glob('*.sv'))+[T/'tb_m5b1_system.sv',Path(__file__),R/'scripts/m5b1_uart_decode.py']
 before=[rec(p) for p in src]
 x=subprocess.run([str(M/'vlog.exe'),'-sv','-work',str(T/'work'),*map(str,src[:-2])],cwd=T,capture_output=True)
 (O/'compile.log').write_bytes(x.stdout+x.stderr); assert x.returncode==0,x.stdout
 cases=[]
 for seed in (50708,60401,7919,1009,20261008,20261009):
  log=O/f'seed_{seed}.log'
  x=subprocess.run([str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-lib',str(T/'work'),'tb_m5b1_system',f'+SEED={seed}','+DELAY=378','-do','run -all; quit -f','-l',str(log)],cwd=T,capture_output=True,timeout=1800)
  text=x.stdout.decode(errors='replace'); match=re.search(r'M5B1_SYSTEM_PASS[^\r\n]+',text)
  assert match and '** Fatal' not in text and '** Error' not in text,text[-4000:]
  raw=bytes.fromhex((T/'system_uart.hex').read_text()); packets=parse(raw); golden=verify(packets)
  assert golden['pixels']==921600 and 0<golden['edge_pixels']<921600
  assert [p['type'] for p in packets]==[1,2,3]
  cases.append(dict(seed=seed,camera_phase_ns=0.1+(seed%97)/10,pixel_phase_ns=0.2+(seed%79)/10,summary=match.group(),stats_words=list(struct.unpack('<64I',packets[0]['payload'])),export=golden,uart_bytes=len(raw),uart_sha256=hashlib.sha256(raw).hexdigest(),log=rec(log)))
  print(match.group(),golden['edge_pixels'],flush=True)
 assert before==[rec(p) for p in src]
 (O/'results.json').write_text(json.dumps(dict(status='PASS_CONDITIONAL_FULL_SYSTEM',condition='accepted transaction <=384 UI cycles; accelerated UART serializer, all actual bytes/CRC and independent BFS checked',sources=before,cases=cases),indent=2))
if __name__=='__main__':main()
