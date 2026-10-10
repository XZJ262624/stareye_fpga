"""The actual FIFO/bus oracle must reject the frozen 17us counterexample."""
from pathlib import Path
import subprocess,hashlib,json
R=Path(__file__).resolve().parents[1];T=R/'tb/m5b1_global_canny';O=R/'reports/m5b1_global_canny_i3/qos_negative';M=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 O.mkdir(exist_ok=True);lib=O/'work';src=sorted((R/'rtl/m5b1_global_canny').glob('*.sv'))+[T/'tb_m5b1_video.sv'];bound=src+[Path(__file__)];before=[rec(p) for p in bound]
 if not lib.exists():subprocess.run([str(M/'vlib.exe'),str(lib)],check=True,capture_output=True)
 x=subprocess.run([str(M/'vlog.exe'),'-sv','-work',str(lib),*map(str,src)],cwd=O,capture_output=True);(O/'compile.log').write_bytes(x.stdout+x.stderr);assert x.returncode==0
 log=O/'17us.log';x=subprocess.run([str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-lib',str(lib),'tb_m5b1_video','+DELAY=1632','+SEED=50708','-do','run -all; quit -f','-l',str(log)],cwd=O,capture_output=True,timeout=1800)
 s=x.stdout.decode(errors='replace');fatal=next((l for l in s.splitlines() if '** Fatal:' in l),None)
 assert fatal and 'VIDEO_PROTOCOL_FAULT' in fatal and 'camfault=1' in fatal and 'M5B1_VIDEO_PASS' not in s,s[-3000:]
 assert before==[rec(p) for p in bound]
 (O/'results.json').write_text(json.dumps(dict(status='PASS_17US_REJECTED',service_ui_cycles=1632,failure=fatal,sources=before,log=rec(log)),indent=2));print(fatal,flush=True)
if __name__=='__main__':main()
