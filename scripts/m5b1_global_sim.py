"""Source-bound global algorithm regression, including last-pixel convergence."""
from pathlib import Path
import subprocess,json,hashlib,re
R=Path(__file__).resolve().parents[1];T=R/'tb/m5b1_global_canny';O=R/'reports/m5b1_global_canny_i3/review_fix_264962e0/final/global';M=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 O.mkdir(parents=True,exist_ok=True);lib=O/'work'
 if not lib.exists():subprocess.run([str(M/'vlib.exe'),str(lib)],check=True,capture_output=True)
 engine=R/'rtl/m5b1_global_canny/m5b1_global_engine.sv';tb=T/'tb_m5b1_global_engine.sv';snake=R/'reports/m5b1_global_canny_i3/patterns/snake_vertical_1280x720.hex'
 src=[engine,tb,snake,Path(__file__)];before=[rec(p) for p in src]
 x=subprocess.run([str(M/'vlog.exe'),'-sv','-work',str(lib),str(engine),str(tb)],cwd=O,capture_output=True);(O/'compile.log').write_bytes(x.stdout+x.stderr);assert x.returncode==0
 full=['-gWIDTH=1280','-gHEIGHT=720'];chain=full+[f'+INPUT={snake}','+TESTS=1']
 cases=[('small30',[], 'M5B1_GLOBAL_PASS cases=30 pixels=122880'),('720p15',full+['+TESTS=15'],'M5B1_GLOBAL_PASS cases=15 pixels=13824000'),('exhaustive',full+['+FIRST=15','+TESTS=1'],'M5B1_EXHAUSTIVE_PASS ternary_3x3=19683'),('last_pixel',['+FIRST=16','+TESTS=1'],'pairs=2 scans=4'),('snake642',chain+['-gMAX_PAIRS=1024','-gWALL_CYCLES=2000000000','+EXPECT_SCANS=642'],'pairs=321 scans=642'),('wall_default',chain+['+EXPECT_FAIL=1'],'M5B1_TIMEOUT_PASS'),('pair_default',chain+['-gWALL_CYCLES=2000000000','+EXPECT_FAIL=1'],'M5B1_TIMEOUT_PASS pairs=64 scans=128')]
 results=[]
 for name,args,marker in cases:
  log=O/(name+'.log');x=subprocess.run([str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-lib',str(lib),'tb_m5b1_global_engine',*args,'-do','run -all; quit -f','-l',str(log)],cwd=O,capture_output=True,timeout=14400)
  s=x.stdout.decode(errors='replace');assert marker in s and '** Fatal' not in s and '** Error' not in s,(name,s[-4000:])
  summaries=[line for line in s.splitlines() if 'M5B1_' in line or 'GLOBAL_CASE_PASS' in line]
  results.append(dict(name=name,arguments=args,summaries=summaries,log=rec(log)));print(name,summaries[-1],flush=True)
  (O/'progress.json').write_text(json.dumps(results,indent=2))
 assert before==[rec(p) for p in src]
 (O/'results.json').write_text(json.dumps(dict(status='PASS',sources=before,cases=results),indent=2))
if __name__=='__main__':main()
