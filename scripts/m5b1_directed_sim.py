"""Source-bound protocol, CDC, capture, prefill and production baud regressions."""
from pathlib import Path
import subprocess,json,hashlib
from m5b1_uart_decode import parse,selftest
R=Path(__file__).resolve().parents[1];T=R/'tb/m5b1_global_canny';O=R/'reports/m5b1_global_canny_i3/review_fix_264962e0/final/directed';M=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 O.mkdir(parents=True,exist_ok=True);lib=O/'work';cases=['arbiter','cdc','capture','prefill','uart']
 src=sorted((R/'rtl/m5b1_global_canny').glob('*.sv'))+[T/f'tb_m5b1_{c}.sv' for c in cases]
 bound=src+[Path(__file__),R/'scripts/m5b1_uart_decode.py'];before=[rec(p) for p in bound]
 if not lib.exists():subprocess.run([str(M/'vlib.exe'),str(lib)],check=True,capture_output=True)
 x=subprocess.run([str(M/'vlog.exe'),'-sv','-work',str(lib),*map(str,src)],cwd=O,capture_output=True);(O/'compile.log').write_bytes(x.stdout+x.stderr);assert x.returncode==0,x.stdout
 results=[]
 for case in cases:
  log=O/(case+'.log');x=subprocess.run([str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-lib',str(lib),'tb_m5b1_'+case,'-do','run -all; quit -f','-l',str(log)],cwd=O,capture_output=True,timeout=1200)
  s=x.stdout.decode(errors='replace');summaries=[v for v in s.splitlines() if 'PASS' in v]
  assert summaries and '** Fatal' not in s and '** Error' not in s,s[-4000:]
  row=dict(case=case,summary=summaries,log=rec(log))
  if case=='uart':
   raw=bytes.fromhex((O/'uart_packet.hex').read_text());packets=parse(raw)
   assert len(raw)==580 and len(packets)==1 and packets[0]['payload']==bytes((i&255)^0xa5 for i in range(512))
   row.update(baud=460800,clock_hz=96000000,bytes=len(raw),crc='PASS',payload='EXACT',uart_sha256=hashlib.sha256(raw).hexdigest())
  results.append(row);print(case,summaries,flush=True)
 selftest()
 assert before==[rec(p) for p in bound]
 (O/'results.json').write_text(json.dumps(dict(status='PASS',sources=before,cases=results),indent=2))
if __name__=='__main__':main()
