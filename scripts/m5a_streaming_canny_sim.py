"""Execute ModelSim with independent image gold and source/log/data bindings."""
from pathlib import Path
import hashlib,json,re,subprocess,sys
from m5a_streaming_canny_gold import generate,generate_windows,osd
R=Path(__file__).resolve().parents[1];T=R/'tb/m5a_streaming_canny';O=R/'reports/m5a_streaming_canny_i3/sim';G=O/'generated';M=Path('E:/Modelsim_10.1c/win64')
commands=[]
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def run(cmd,name):
 O.mkdir(parents=True,exist_ok=True);log=O/(name+'.log')
 with log.open('wb') as f:p=subprocess.run(list(map(str,cmd)),cwd=T,stdout=f,stderr=subprocess.STDOUT,timeout=4800)
 s=log.read_text(errors='replace');commands.append(dict(command=list(map(str,cmd)),exit_code=p.returncode,log=rec(log)))
 if p.returncode or re.search(r'\*\* (Error|Fatal):',s):raise AssertionError(name+'\n'+s[-5000:])
 return s
def sources():
 return [p for d in ('rtl/m5a_streaming_canny','rtl/m3_sobel_core','rtl/m32_median_integration','rtl/m4_color_overlay','tb/m5a_streaming_canny') for p in sorted((R/d).glob('*')) if p.suffix in ('.v','.sv','.do')]+[Path(__file__),R/'scripts/m5a_streaming_canny_gold.py']
def main():
 mode=sys.argv[1] if len(sys.argv)>1 else 'all';src=sources();before=[rec(p) for p in src]
 if not(T/'work').exists():run([M/'vlib.exe','work'],'vlib')
 run([M/'vlog.exe','-sv','-work','work',*[p for p in src if p.suffix in ('.v','.sv')]],'compile')
 stats=[]
 if mode in ('unit','all'):
  wg=generate_windows(G/'windows')
  for top,marker in [('tb_m5a_units','M5A_UNITS_PASS'),('tb_m5a_windows','M5A_WINDOWS_PASS'),('tb_m5a_controls','M5A_CONTROLS_PASS'),('tb_m5a_realtime','M5A_REALTIME_PASS'),('tb_m5a_osd','M5A_OSD_PASS')]:
   s=run([M/'vsim.exe','-c','-novopt','-onfinish','stop','work.'+top,'+DIR='+str(G/'windows'),'-do',T/'run.do'],top);assert marker in s
   row=dict(name=top,summary=next(l for l in s.splitlines() if marker in l))
   if top=='tb_m5a_windows':row.update(gold=wg,inputs=[rec(p) for p in sorted((G/'windows').glob('*.hex'))])
   if top=='tb_m5a_osd':
    count=0;dump=T/'m5a_osd_pixels.txt'
    for line in dump.read_text().splitlines():
     t,x,y,value=map(int,line.split());m=t%7;raw=(x+3*y+t)%256;bg=0xff0000 if m==3 else raw*0x010101
     assert value==osd(bg,x,y,m,t),(t,x,y,value);count+=1
    assert count>760000;row.update(font_pixels_checked=count,artifact=rec(dump))
   stats.append(row);print(marker,flush=True)
 jobs=[]
 if mode in ('smoke','all','small'):
  cases=[(m,t,e,k) for e in (0,1) for m,t,k in [(0,64,2),(1,0,3),(2,255,4),(3,64,5),(4,64,6),(5,64,7),(6,64,10)]]
  if mode=='smoke':cases=[(6,64,1,2)]
  else:cases += [(m,t,e,k) for e in (0,1) for m,t,k in [(4,0,0),(5,0,1),(6,1,8),(4,32,9),(5,255,11),(6,64,12)]]
  jobs.append(('small',240,48,280,62,12,6,2,3,cases,0))
 if mode in ('stall','all'):jobs.append(('stall',240,48,280,62,12,6,2,3,[(6,64,1,2),(4,255,0,11),(5,1,1,0),(6,64,1,9)],1))
 if mode in ('720p','all'):jobs.append(('720p',1280,720,1650,750,260,25,5,40,[(4,64,1,11),(6,64,1,10)],0))
 for name,w,h,ht,vt,hb,vb,vsl,hsc,cases,stall in jobs:
  d=G/name;gold=generate(d,w,h,cases)
  print('M5A_GOLD_READY',name,'frames',len(cases),flush=True)
  args=[f'-g{k}={v}' for k,v in [('WIDTH',w),('HEIGHT',h),('H_TOTAL',ht),('V_TOTAL',vt),('H_BACK',hb),('V_BACK',vb),('VS_LINES',vsl),('HS_CLOCKS',hsc),('FRAMES',len(cases)),('STALL',stall)]]
  s=run([M/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_m5a_stream',*args,'+DIR='+str(d),'-do',T/'run.do'],name)
  match=re.search(r'M5A_STREAM_PASS cycles=(\d+) frames=(\d+) pixels=(\d+) canny=(\d+) stalls=(\d+) regression=(\d+),(\d+),(\d+),(\d+) latency=(\d+)',s);assert match,s[-4000:]
  values=list(map(int,match.groups()));assert values[1]==len(cases) and values[2]==w*h*len(cases) and values[-1]==4*ht+26
  stats.append(dict(name=name,cycles=values[0],frames=values[1],pixels=values[2],canny_pixels=values[3],stalls=values[4],legacy_regression=values[5:9],latency=values[9],gold=gold,inputs=[rec(p) for p in sorted(d.iterdir()) if p.is_file()]))
  print('M5A_SIM_CASE_PASS',name,values,flush=True)
 assert before==[rec(p) for p in src]
 (O/(mode+'_binding.json')).write_text(json.dumps(dict(status='PASS',sources_before=before,sources_after=before,commands=commands,cases=stats),indent=2))
 print('M5A_SIM_PASS',mode,flush=True)
if __name__=='__main__':main()
