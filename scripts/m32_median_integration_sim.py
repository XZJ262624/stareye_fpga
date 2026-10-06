"""Independent spatial sorting/Sobel oracle; all output restricted to new M32 scope."""
from pathlib import Path
from collections import deque
import random,subprocess,json,hashlib,re,sys
R=Path(__file__).resolve().parents[1];T=R/'tb/m32_median_integration';O=R/'reports/m32_median_integration_i3/sim';O.mkdir(parents=True,exist_ok=True);M=Path('E:/Modelsim_10.1c/win64');commands=[]
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def run(cmd,log):
 with (O/log).open('wb') as f:p=subprocess.run(list(map(str,cmd)),cwd=T,stdout=f,stderr=subprocess.STDOUT,timeout=1200)
 s=(O/log).read_text(errors='replace');commands.append(dict(command=list(map(str,cmd)),exit_code=p.returncode,log=log));assert p.returncode==0 and not re.search(r'\*\* (Fatal|Error):',s),s[-2000:];return s
sources=sorted((R/'rtl/m3_sobel_core').glob('*.v'))+sorted((R/'rtl/m31_sobel_controls').glob('*.v'))+sorted((R/'rtl/m32_median_integration').glob('*.v'))+[T/'tb_m32_stream.sv',T/'run.do',Path(__file__)];before=[rec(p) for p in sources]
if not (T/'work').exists():run([M/'vlib.exe','work'],'vlib.log')
run([M/'vlog.exe','-sv','-work','work',*[p for p in sources if p.suffix in ('.v','.sv')]],'compile.log')
font={'0':'0e 11 13 15 19 11 0e','1':'04 0c 04 04 04 04 0e','2':'0e 11 01 02 04 08 1f','3':'1e 01 01 0e 01 01 1e','4':'02 06 0a 12 1f 02 02 02','5':'1f 10 10 1e 01 01 1e','6':'0e 10 10 1e 11 11 0e','7':'1f 01 02 04 08 08 08','8':'0e 11 11 0e 11 11 0e','9':'0e 11 11 0f 01 01 0e','R':'1e 11 11 1e 14 12 11','A':'0e 11 11 1f 11 11 11','W':'11 11 11 15 15 15 0a','M':'11 1b 15 15 11 11 11','G':'0e 11 10 17 11 11 0e','B':'1e 11 11 1e 11 11 1e','I':'0e 04 04 04 04 04 0e','N':'11 19 19 15 13 13 11','T':'1f 04 04 04 04 04 04',' ':'00 00 00 00 00 00 00'};font={k:[int(v,16) for v in s.split()] for k,s in font.items()}
def overlay(gray,x,y,mode,t):
 if 12<=x<148 and 12<=y<34:
  if 16<=x<144 and 16<=y<30:
   col=(x-16)%16//2;slot=(x-16)//16;row=(y-16)//2;label=('RAW','MAG','BIN')[mode]+' T'+f'{t:03d}'
   if col<5:return 255*((font[label[slot]][row]>>(4-col))&1)
  return 0
 return gray

def image(w,h,k):
 rng=random.Random(620610+k);a=[]
 for y in range(h):
  for x in range(w):
   patterns=(0,255,(x+3*y)%256,255*(x>w//2),255*(y>h//2),255*(x>y),255*((x,y)==(w//2,h//2)),rng.choice((0,255,128,128,128,128)),rng.randrange(256))
   a.append(patterns[k%9])
 return a

def filtered(a,w,h):
 b=[0]*len(a)
 for y in range(1,h-1):
  for x in range(1,w-1):b[y*w+x]=sorted(a[(y+dy)*w+x+dx] for dy in (-1,0,1) for dx in (-1,0,1))[4]
 return b

def frames(w,h,ht,full=False):
 # row tuple followed by independent expected scalar fields.
 def blank(sr=1,hs=1,vs=1,sof=0,req=0,t=64,m=0):return (sr,0,0,hs,vs,sof,req,t,m),None
 for i in range(3):yield blank(sr=0)
 for i in range(8):yield blank()
 n=2 if full else 18
 for k in range(n):
  if not full and k==9:
   # asynchronous reset with prior outputs in flight; then a new complete SOF.
   for i in range(3):yield blank(sr=0)
   for i in range(8):yield blank()
  en=k%2;mode=2 if full else k%3;t=(64,96,128,0,255)[k%5]
  a=image(w,h,7 if full else k);b=filtered(a,w,h) if en else a
  vsync=5 if full else 2;vb=25 if full else 4;hb=260 if full else 12;vt=h+30 if full else h+8
  for v in range(vt):
   for z in range(ht):
    hs=int(z>=40) if full else int(z>=3);vs=int(v>=vsync);sof=1-vs
    # Exercise requests changing throughout a frame; only SOF rising may apply.
    req=en if v<vsync else 1-en
    if vb<=v<vb+h and hb<=z<hb+w:
     x=z-hb;y=v-vb;valid=int(x>=2 and y>=2 and (not en or (3<=x<=w-2 and 3<=y<=h-2)))
     mag=0
     if valid:
      p=[[b[(y-2+dy)*w+x-2+dx] for dx in range(3)] for dy in range(3)]
      gx=-p[0][0]+p[0][2]-2*p[1][0]+2*p[1][2]-p[2][0]+p[2][2];gy=p[0][0]+2*p[0][1]+p[0][2]-p[2][0]-2*p[2][1]-p[2][2];mag=min(255,abs(gx)+abs(gy))
     binary=int(valid and mag>=t);gray=a[y*w+x];out=gray if mode==0 else mag if mode==1 else binary*255
     e=[out,gray,mag,binary,valid,1,hs,vs,en,t,mode,x,y,(x-1 if valid else 0),(y-1 if valid else 0),overlay(out,x,y,mode,t)]
     yield (1,gray,1,hs,vs,sof,req,t,mode),e
    else:yield blank(hs=hs,vs=vs,sof=sof,req=req,t=t,m=mode)
 for _ in range(ht+25):yield blank()

def compare(gold,obs,delay):
 bypass=0;valid=0;de=0;old=deque([(0,0,1,1)]*(delay+1));count=0
 with gold.open() as f,obs.open() as a:
  for count,(g,line) in enumerate(zip(f,a),1):
   expect=list(map(int,g.split()));s=line.split();assert all(re.fullmatch(r'-?\d+',v) for v in s),('X/Z',count,line);v=list(map(int,s));assert len(v)==25 and v[0]==count-1
   now=v[1:16];osd=v[16:20];old.append(tuple(v[20:24]));oldnow=old.popleft()
   # Coordinates only promise meaningful raster positions on DE, otherwise hold.
   assert now[:11]==expect[:11],('M32_MISMATCH',count,now,expect)
   if expect[5]:assert now[11:]==expect[11:15],('COORD',count,now,expect)
   assert osd==expect[15:19],('OSD',count,osd,expect)
   if count>delay+15 and expect[8]==0 and expect[5]:assert tuple(osd)==oldnow,('BYPASS',count,osd,oldnow);bypass+=1
   valid+=expect[4];de+=expect[5]
  assert not f.read() and not a.read(),'truncated trace'
 return dict(cycles=count,valid_outputs=valid,de_pixels=de,bypass_osd_equivalence_pixels=bypass)

stats=[]
for name,w,h,ht,full in [('small',160,40,200,False),('720p',1280,720,1650,True)]:
 d=ht+11;lat=d+5;neutral=[0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0];q=deque([neutral.copy() for _ in range(lat)]);oq=deque([neutral.copy() for _ in range(lat+1)]);rel=0;active=0;last_sof=0
 stim=O/(name+'_stim.txt');gold=O/(name+'_gold.txt');obs=O/(name+'_obs.txt');cycles=0
 with stim.open('w') as a,gold.open('w') as g:
  for cycles,(row,e) in enumerate(frames(w,h,ht,full),1):
   a.write(' '.join(map(str,row))+'\n');sr,gray,de,hs,vs,sof,req,t,m=row;ready=bool(sr and rel==3);rel=((rel<<1)|1)&3 if sr else 0
   if not sr:q=deque([neutral.copy() for _ in range(lat)]);oq=deque([neutral.copy() for _ in range(lat+1)]);active=0;last_sof=0
   if ready:
    if sof and not last_sof:active=req
    last_sof=sof
    if e is None:e=[0,gray,0,0,0,de,hs,vs,active,t,m,0,0,0,0,0]
    q.append(e);oq.append(e)
   else:q.append(neutral.copy());oq.append(neutral.copy())
   out=q.popleft();od=oq.popleft();g.write(' '.join(map(str,out[:15]+[od[15],od[5],od[6],od[7]]))+'\n')
 print('GENERATED',name,cycles,flush=True)
 command=[M/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_m32_stream','-gWIDTH='+str(w),'-gHEIGHT='+str(h),'-gH_TOTAL='+str(ht),'+STIM='+str(stim),'+OBS='+str(obs),'-do',T/'run.do']
 s=run(command,name+'.log');assert 'M32_STREAM_COMPLETE cycles='+str(cycles) in s
 result=compare(gold,obs,d);assert result['cycles']==cycles;result.update(name=name,frames=2 if full else 18);stats.append(result);print('PASS',name,result,flush=True)
 # Negative pixel golden comparison must detect actual corruption.
 bad=O/(name+'_bad_gold.txt');data=gold.read_text().splitlines();j=next(i for i,line in enumerate(data) if line.split()[5]=='1');v=data[j].split();v[0]=str(int(v[0])^1);data[j]=' '.join(v);bad.write_text('\n'.join(data)+'\n')
 try:compare(bad,obs,d)
 except AssertionError as e:assert 'M32_MISMATCH' in str(e);print('NEGATIVE_DETECTED',name,flush=True)
 else:raise AssertionError('negative control silently passed')
 bad.unlink()
assert before==[rec(p) for p in sources]
(O/'binding.json').write_text(json.dumps(dict(status='PASS',sources_before=before,sources_after=[rec(p) for p in sources],commands=commands,cases=stats,negative_tests=2,artifacts=[rec(p) for p in sorted(O.iterdir()) if p.is_file() and p.name!='binding.json']),indent=2))
print('M32_INTEGRATED_SIM_PASS',json.dumps(stats))
