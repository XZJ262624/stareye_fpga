"""Tap + unchanged seven-mode output regression using fixed M5A golden files.
The independent M5A oracle stores min(NMS,255). For H,L in [0,255], comparing
that oracle value to H/L is exactly equivalent to comparing original NMS.
Hardware tap itself uses original 12-bit NMS and is not reconstructed here.
"""
from pathlib import Path
import subprocess,re,json,hashlib
from m5a_streaming_canny_gold import generate
R=Path(__file__).resolve().parents[1];T=R/'tb/m5b1_global_canny';O=R/'reports/m5b1_global_canny_i3/tap';M=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 O.mkdir(exist_ok=True);results=[];lib=O/'work'
 rtl=[p for d in ('rtl/m5b1_global_canny/m5a_copy','rtl/m3_sobel_core','rtl/m32_median_integration','rtl/m4_color_overlay') for p in sorted((R/d).glob('*.v'))]+[T/'tb_m5b1_tap.sv']
 bound=rtl+[Path(__file__),R/'scripts/m5a_streaming_canny_gold.py'];before=[rec(p) for p in bound]
 if not lib.exists():subprocess.run([str(M/'vlib.exe'),str(lib)],check=True,capture_output=True)
 x=subprocess.run([str(M/'vlog.exe'),'-sv','-work',str(lib),*map(str,rtl)],cwd=O,capture_output=True);(O/'compile.log').write_bytes(x.stdout+x.stderr);assert x.returncode==0,x.stdout
 small=[(m,t,e,k) for e in (0,1) for m,t,k in [(0,64,2),(1,0,3),(2,255,4),(3,64,5),(4,64,6),(5,64,7),(6,64,10)]]+[(m,t,e,k) for e in (0,1) for m,t,k in [(4,0,0),(5,0,1),(6,1,8),(4,32,9),(5,255,11),(6,64,12)]]
 configs={'small':small,'stall':[(6,64,1,2),(4,255,0,11),(5,1,1,0),(6,64,1,9)],'720p':[(4,64,1,11),(6,64,1,10)]}
 for name,w,h,ht,vt,hb,vb,vsl,hsc,stall in [('small',240,48,280,62,12,6,2,3,0),('stall',240,48,280,62,12,6,2,3,1),('720p',1280,720,1650,750,260,25,5,40,0)]:
  src=O/'generated'/name;generate(src,w,h,configs[name])
  cases=[list(map(int,l.split())) for l in (src/'cases.txt').read_text().splitlines()]
  dest=O/(name+'_classes.hex');original=[rec(src/'cases.txt')];count=0
  with dest.open('w') as out:
   for frame,(_,threshold,_,_) in enumerate(cases):
    p=src/f'frame_{frame}.hex';original.append(rec(p))
    for l in p.read_text().splitlines():
     q=int(l,16);nms=(q>>19)&255;good=(q>>27)&1
     c=2 if good and nms and nms>=threshold else 1 if good and nms and nms>=threshold//2 else 0
     out.write(str(c)+'\n');count+=1
  assert count==w*h*len(cases)
  args=[f'-g{k}={v}' for k,v in [('WIDTH',w),('HEIGHT',h),('H_TOTAL',ht),('V_TOTAL',vt),('H_BACK',hb),('V_BACK',vb),('VS_LINES',vsl),('HS_CLOCKS',hsc),('FRAMES',len(cases)),('STALL',stall)]]
  log=O/(name+'.log');x=subprocess.run([str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-lib',str(lib),'tb_m5b1_tap',*args,'+DIR='+str(src),'+TAP_FILE='+str(dest),'-do','run -all; quit -f','-l',str(log)],cwd=O,capture_output=True,timeout=4800)
  text=x.stdout.decode(errors='replace');marker=re.search(r'M5B1_TAP_PASS[^\r\n]+',text);legacy=re.search(r'M5A_STREAM_PASS[^\r\n]+',text)
  assert marker and legacy and '** Fatal' not in text and '** Error' not in text,text[-4000:]
  results.append(dict(name=name,tap=marker.group(),regression=legacy.group(),golden_sources=original,classes=rec(dest),log=rec(log)))
  print(marker.group(),legacy.group(),flush=True)
 assert before==[rec(p) for p in bound]
 (O/'results.json').write_text(json.dumps(dict(status='PASS_TAP_AND_DISPLAY_MODEL',tests=results,sources=before),indent=2))
if __name__=='__main__':main()
