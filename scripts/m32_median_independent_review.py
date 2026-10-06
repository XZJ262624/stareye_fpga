"""ROOT-owned independent vectors and spatial sorted[4] model, not delivery gold."""
from pathlib import Path
from collections import deque
import itertools,random,subprocess,json,hashlib,shutil,sys,re
R=Path(__file__).resolve().parents[1];S=R/'handoff/review/m32_median_filter_delivery/task_workspace';O=R/'reports/m32_median_review/independent';O.mkdir(parents=True,exist_ok=True);M=Path('E:/Modelsim_10.1c/win64');commands=[]
def record(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
inputs=[Path(__file__)]+list((S/'rtl').glob('*.v'))+list((S/'tb').glob('*.sv'))+[S/'scripts/run_core.do',S/'scripts/run_stream.do'];before=[record(p) for p in inputs]
def run(cmd,log,good=True):
 with (O/log).open('wb') as f:p=subprocess.run([str(x) for x in cmd],cwd=O,stdout=f,stderr=subprocess.STDOUT,timeout=600)
 t=(O/log).read_text(errors='replace');commands.append(dict(command=list(map(str,cmd)),exit_code=p.returncode,log=log))
 if good:assert p.returncode==0 and not re.search(r'\*\* (Fatal|Error):',t),t[-2000:]
 else:assert p.returncode!=0 and ('MISMATCH' in t),t[-2000:]
 return t
run([M/'vlib.exe','work'],'vlib.log');run([M/'vlog.exe','-sv','-work','work',*sorted((S/'rtl').glob('*.v')),*sorted((S/'tb').glob('*.sv'))],'compile.log')
rng=random.Random(20261006)
def core_rows():
 yield 0,0,*([0]*9)
 yield 1,0,*([0]*9)
 for v in ([0]*9,[255]*9,list(range(1,10)),[128]*9,[0]*8+[255],[255]*8+[0],[0,0,127,128,128,128,255,255,255]):yield 1,1,*v
 for b in range(512):yield 1,1,*[255*((b>>i)&1) for i in range(9)]
 for i,v in enumerate(itertools.permutations(range(1,10))):
  if i and i%50000==0:yield 0,1,*([255]*9)
  if i%101==0:yield 1,0,*([127]*9)
  yield 1,1,*v
 for i in range(20000):yield 1,int(i%7!=0),*[rng.randrange(256) if i%2 else rng.choice((0,127,128,255)) for _ in range(9)]
 for i in range(12):yield 1,0,*([255]*9)
c=0;valid=0;q=deque([(0,0)]*8)
with (O/'core_stim.txt').open('w') as a,(O/'core_gold.txt').open('w') as g:
 for c,row in enumerate(core_rows()):
  sr,iv,*px=row;a.write(' '.join(map(str,row))+'\n')
  if not sr:q=deque([(0,0)]*8);ev,eg=0,0
  else:q.append((int(iv),sorted(px)[4] if iv else 0));ev,eg=q.popleft()
  valid+=ev;g.write(f'{c} {ev} {eg}\n')
core_cycles=c+1
cmd=[M/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_median_core','+STIM='+str(O/'core_stim.txt'),'+GOLD='+str(O/'core_gold.txt'),'+OBS='+str(O/'core_obs.txt'),'-do',S/'scripts/run_core.do'];text=run(cmd,'core.log');assert 'CORE_SELF_CHECK_PASS cycles='+str(core_cycles) in text
# Independent 2-D image ledger and event schedule; no delivery Python imported.
W,H=13,9
samples=[]
def tick(sr=1,iv=0,de=0,hs=1,vs=1,sof=0,gray=0,en=0):samples.append((sr,iv,de,hs,vs,sof,gray,en))
for _ in range(3):tick(sr=0,de=1,gray=255,en=1)
for _ in range(5):tick()
for _ in range(17):tick(iv=1,de=1,gray=199,en=1)
frames=0
for pat in range(10):
 for enable in (0,1):
  frames+=1
  tick(sof=1,vs=0,en=enable)
  for _ in range(3):tick(sof=1,vs=0,en=1-enable)
  for y in range(H):
   tick(hs=0,en=1-enable);tick(hs=1,en=1-enable)
   for x in range(W):
    if (x+y)%5==0:tick(de=1,gray=231,en=1-enable);tick(hs=0,en=1-enable)
    values=[0,255,(x+W*y)%256,255-(x+W*y)%256,255*(x>=W//2),255*(y>=H//2),255*(x>=y),255*((x,y)==(6,4)),255*((x,y)!=(6,4)),rng.choice((0,255,128,128,128,128))]
    tick(iv=1,de=1,gray=values[pat],en=(x+y)%2)
   tick(en=1-enable)
  for _ in range(12):tick(iv=1,de=1,gray=88,en=1-enable)
# Abort an unfinished frame, then reset with queued results and ignore pre-SOF data.
tick(sof=1,vs=0,en=1)
for i in range(40):tick(iv=1,de=1,gray=(i*17)%256,en=0)
tick(sr=0,iv=1,de=1,gray=255,en=1)
for i in range(60):tick(iv=1,de=1,gray=255,en=1)
for enable in (1,0):
 frames+=1;tick(sof=1,vs=0,en=enable)
 for i in range(W*H):tick(iv=1,de=1,gray=rng.randrange(256),en=1-enable)
for _ in range(20):tick()
fields='cycle rst lb_valid win_valid out_valid median_gray raw_gray de hs vs sof mode out_gray x y cx cy p00 p01 p02 p10 p11 p12 p20 p21 p22'.split()
rel=0;armed=False;image=[];prevsof=0;mode=0;pos=(0,0);coords=deque([(0,0)]*9);events={};stream_valid=0
with (O/'stream_stim.txt').open('w') as a,(O/'stream_gold.txt').open('w') as g:
 for c,row in enumerate(samples):
  sr,iv,de,hs,vs,sof,gray,en=row;a.write(' '.join(map(str,row))+'\n');ready=bool(sr and rel==3);rel=((rel<<1)|1)&3 if sr else 0
  e={f:0 for f in fields};e.update(cycle=c,rst=(rel>>1)&1,hs=1,vs=1)
  if not ready:
   armed=False;image=[];prevsof=0;mode=0;pos=(0,0);coords=deque([(0,0)]*9);events={}
  else:
   if sof and not prevsof:mode=en
   prevsof=sof;future=events.setdefault(c+10,{});future.update(raw_gray=gray,de=de,hs=hs,vs=vs,sof=sof,mode=mode)
   coords.append(pos);e['x'],e['y']=coords.popleft()
   if sof:armed=True;image=[]
   elif iv and armed:
    x,y=len(image)%W,len(image)//W;image.append(gray);pos=(x,y);e['lb_valid']=1
    if x>=2 and y>=2:
     taps=[image[(y-2+dy)*W+x-2+dx] for dy in range(3) for dx in range(3)]
     events.setdefault(c+1,{}).update(win_valid=1,**dict(zip(fields[17:],taps)))
     future.update(out_valid=1,median_gray=sorted(taps)[4],cx=x-1,cy=y-1)
    if len(image)==W*H:armed=False
   e.update(events.pop(c,{}));e['out_gray']=(e['median_gray'] if e['mode'] else e['raw_gray']) if e['de'] else 0
  stream_valid+=e['out_valid'];g.write(' '.join(str(e[f]) for f in fields)+'\n')
cmd2=[M/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_median_stream','-gWIDTH=13','-gHEIGHT=9','+STIM='+str(O/'stream_stim.txt'),'+GOLD='+str(O/'stream_gold.txt'),'+OBS='+str(O/'stream_obs.txt'),'-do',S/'scripts/run_stream.do'];text=run(cmd2,'stream.log');assert 'STREAM_SELF_CHECK_PASS cycles='+str(len(samples)) in text
# Real deliberately wrong scalar gold must fail HDL and set nonzero process exit.
lines=(O/'core_gold.txt').read_text().splitlines();j=next(i for i,s in enumerate(lines) if s.split()[1]=='1');v=lines[j].split();v[2]=str(int(v[2])^1);lines[j]=' '.join(v);(O/'bad_core_gold.txt').write_text('\n'.join(lines)+'\n')
negative_cmd=[str(x).replace(str(O/'core_gold.txt'),str(O/'bad_core_gold.txt')).replace(str(O/'core_obs.txt'),str(O/'bad_core_obs.txt')) for x in cmd];run(negative_cmd,'negative_core.log',False)
assert [record(p) for p in inputs]==before
outputs=[record(p) for p in sorted(O.iterdir()) if p.is_file() and p.name!='RESULT.json'];result=dict(status='PASS',golden='ROOT-owned Python sorted[4], independent seed/data/protocol model; no delivery golden import',core_cycles=core_cycles,core_valid_outputs=valid,permutations_1_to_9=362880,binary_exhaustive=512,random_windows=20000,stream_cycles=len(samples),stream_frames=frames,stream_valid_outputs=stream_valid,negative_tests=1,commands=commands,inputs_before=before,inputs_after=[record(p) for p in inputs],outputs=outputs)
(O/'RESULT.json').write_text(json.dumps(result,indent=2));print('ROOT_M32_INDEPENDENT_PASS',json.dumps({k:v for k,v in result.items() if k not in ('commands','inputs_before','inputs_after','outputs')}))
