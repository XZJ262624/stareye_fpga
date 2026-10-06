"""Independent spatial median/Sobel/RGB/OSD oracle and actual HDL regression."""
from pathlib import Path
import hashlib,json,random,re,subprocess,sys
R=Path(__file__).resolve().parents[1];T=R/'tb/m4_color_overlay';O=R/'reports/m4_color_overlay_i3/sim';G=O/'generated';G.mkdir(parents=True,exist_ok=True)
M=Path('E:/Modelsim_10.1c/win64');commands=[]
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def run(cmd,name):
 p=O/(name+'.log')
 with p.open('wb') as f:x=subprocess.run(list(map(str,cmd)),cwd=T,stdout=f,stderr=subprocess.STDOUT,timeout=2400)
 s=p.read_text(errors='replace');commands.append(dict(command=list(map(str,cmd)),exit_code=x.returncode,log=rec(p)))
 if x.returncode or re.search(r'\*\* (Error|Fatal):',s) or 'Fatal:' in s:raise AssertionError(s[-3000:])
 return s
FONT={
 '0':[14,17,19,21,25,17,14],'1':[4,12,4,4,4,4,14],'2':[14,17,1,2,4,8,31],'3':[30,1,1,14,1,1,30],
 '4':[2,6,10,18,31,2,2],'5':[31,16,16,30,1,1,30],'6':[14,16,16,30,17,17,14],'7':[31,1,2,4,8,8,8],
 '8':[14,17,17,14,17,17,14],'9':[14,17,17,15,1,1,14],
 'R':[30,17,17,30,20,18,17],'A':[14,17,17,31,17,17,17],'W':[17,17,17,21,21,21,10],
 'M':[17,27,21,21,17,17,17],'G':[14,17,16,23,17,17,14],'B':[30,17,17,30,17,17,30],
 'I':[14,4,4,4,4,4,14],'N':[17,25,25,21,19,19,17],'T':[31,4,4,4,4,4,4],
 'O':[14,17,17,17,17,17,14],'V':[17,17,17,17,17,10,4],' ':[0]*7}
def osd(rgb,x,y,mode,threshold):
 if not (12<=x<148 and 12<=y<34):return rgb
 if not (16<=x<144 and 16<=y<30):return 0
 slot=(x-16)//16;col=((x-16)%16)//2;row=(y-16)//2
 label=('RAW','MAG','BIN','OVR')[mode]+' T'+f'{threshold:03d}'
 return 0xffffff if col<5 and (FONT[label[slot]][row]>>(4-col))&1 else 0
def image(w,h,k):
 rng=random.Random(41006+k);a=[]
 for y in range(h):
  row=[]
  for x in range(w):
   if k==0:z=0
   elif k==1:z=255
   elif k==2:z=(x*3+y*7)%256
   elif k==3:z=30+180*(x>=w//2)
   elif k==4:z=30+180*(y>=h//2)
   elif k==5:z=30+180*(x*h>=y*w)
   elif k==6:z=255*((x,y)==(w//2,h//2))
   elif k==7:z=rng.choice([0,255,80,80,80,80,80])
   elif k==8:z=rng.randrange(256)
   else:z=(x*2+y*3)%96+32
   row.append(z)
  a.append(row)
 return a
def filtered(a,w,h):
 b=[[0]*w for _ in range(h)]
 for y in range(1,h-1):
  for x in range(1,w-1):b[y][x]=sorted(a[y+dy][x+dx] for dy in (-1,0,1) for dx in (-1,0,1))[4]
 return b
def magnitude(a,x,y):
 p=[[a[y+dy][x+dx] for dx in (-1,0,1)] for dy in (-1,0,1)]
 gx=p[0][2]-p[0][0]+2*(p[1][2]-p[1][0])+p[2][2]-p[2][0]
 gy=p[0][0]+2*p[0][1]+p[0][2]-p[2][0]-2*p[2][1]-p[2][2]
 return min(255,abs(gx)+abs(gy))
def generate(name,w,h,cases):
 d=G/name;d.mkdir(exist_ok=True);reds=[]
 (d/'cases.txt').write_text(''.join(f'{m} {t} {e} {k}\n' for m,t,e,k in cases))
 for i,(m,t,en,k) in enumerate(cases):
  a=image(w,h,k);b=filtered(a,w,h) if en else a;count=0
  with (d/f'frame_{i}.hex').open('w') as f:
   for y in range(h):
    for x in range(w):
     support=(2<=x<=w-3 and 2<=y<=h-3) if en else (1<=x<=w-2 and 1<=y<=h-2)
     edge=bool(support and magnitude(b,x,y)>=t);count+=edge
     old_valid=x>=2 and y>=2 and (not en or (3<=x<=w-2 and 3<=y<=h-2))
     old_mag=magnitude(b,x-1,y-1) if old_valid else 0
     old_bin=bool(old_valid and old_mag>=t);raw=a[y][x]
     value=raw if m==0 else old_mag if m==1 else old_bin*255
     rgb=(value*0x010101) if m<3 else (0xff0000 if edge else raw*0x010101)
     packed=(osd(rgb,x,y,m,t)<<34)|(rgb<<10)|(raw<<2)|(support<<1)|edge
     f.write(f'{packed:015x}\n')
  reds.append(count)
  print('M4_GOLD',name,'frame',i,'mode',m,'threshold',t,'median',en,'edges',count,flush=True)
 return d,reds
def main():
 sources=sorted((R/'rtl/m3_sobel_core').glob('*.v'))+sorted((R/'rtl/m32_median_integration').glob('*.v'))+sorted((R/'rtl/m4_color_overlay').glob('*.v'))+[R/'rtl/m31_sobel_controls/m31_osd.v']+[R/'efinity/m4_color_overlay_i3/src/hdmi_ip'/n for n in ('rgb2dvi.v','tmds_channel.v')]+sorted(T.glob('*.sv'))+[T/'run.do',Path(__file__)]
 before=[rec(p) for p in sources]
 if not (T/'work').exists():run([M/'vlib.exe','work'],'vlib')
 run([M/'vlog.exe','-sv','-work','work',*[p for p in sources if p.suffix in ('.v','.sv')]],'compile')
 stats=[]
 for top,marker in [('tb_m4_controls','M4_CONTROLS_PASS'),('tb_m4_realtime','M4_REALTIME_PASS'),('tb_m4_colorize','M4_COLORIZE_PASS'),('tb_m4_osd','M4_OSD_PASS'),('tb_m4_recovery','M4_RECOVERY_PASS'),('tb_m4_hdmi_channels','M4_HDMI_CHANNELS_PASS')]:
  s=run([M/'vsim.exe','-c','-novopt','-onfinish','stop','work.'+top,'-do',T/'run.do'],top);assert marker in s
  stats.append(dict(name=top,summary=next(l for l in s.splitlines() if marker in l)))
  if top=='tb_m4_osd':
   dump=T/'m4_osd_pixels.txt';count=0
   for line in dump.read_text().splitlines():
    t,x,y,value=map(int,line.split());raw=(x+3*y+t)%256;m=t%4;bg=0xff0000 if m==3 else raw*0x010101
    assert value==osd(bg,x,y,m,t),(t,x,y,value);count+=1
   assert count==256*136*22;stats[-1].update(font_pixels_checked=count,artifact=rec(dump))
 cases=[(m,t,e,k) for e in (0,1) for m in range(4) for t,k in [(0,2),(64,3),(255,7)]]
 cases+=[(3,t,1,9) for t in (0,64,96,128,255)]+[(1,t,1,9) for t in (0,255)]
 full=[(0,64,1,3),(1,96,1,4),(2,128,1,5),(3,64,1,7)]
 for name,w,h,ht,vt,hb,vb,vsl,hsc,rows in [('small',160,40,200,48,12,4,2,3,cases),('720p',1280,720,1650,750,260,25,5,40,full)]:
  d,reds=generate(name,w,h,rows)
  args=[f'-g{k}={v}' for k,v in [('WIDTH',w),('HEIGHT',h),('H_TOTAL',ht),('V_TOTAL',vt),('H_BACK',hb),('V_BACK',vb),('VS_LINES',vsl),('HS_CLOCKS',hsc),('FRAMES',len(rows))]]
  s=run([M/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_m4_stream',*args,'+DIR='+str(d),'-do',T/'run.do'],name)
  match=re.search(r'M4_STREAM_PASS cycles=(\d+) frames=(\d+) pixels=(\d+) red=(\d+) regression=(\d+),(\d+),(\d+) latency=(\d+)',s);assert match,s[-3000:]
  n=list(map(int,match.groups()));assert n[1]==len(rows) and n[2]==len(rows)*w*h and n[-1]==2*ht+18 and all(z>0 for z in n[4:7]);stats.append(dict(name=name,cycles=n[0],frames=n[1],pixels=n[2],edge_pixels=n[3],legacy_regression=n[4:7],latency=n[7],spatial_gold_edges=reds,generated_inputs=[rec(p) for p in sorted(d.iterdir()) if p.is_file()]))
 assert before==[rec(p) for p in sources]
 result=dict(status='PASS',sources_before=before,sources_after=before,commands=commands,cases=stats)
 (O/'binding.json').write_text(json.dumps(result,indent=2));print('M4_SIM_PASS',json.dumps(stats),flush=True)
if __name__=='__main__':main()
