"""Bounded edge-hole candidate assessment; synthetic data, not sensor RAW."""
from pathlib import Path
from collections import deque,defaultdict
from array import array
import sys,json,hashlib,math,importlib.util,time,random
sys.dont_write_bytecode=True
R=Path(__file__).resolve().parents[2];O=R/'reports/part_count_edge_20261027';O.mkdir(exist_ok=True)
def load(name,path):
 s=importlib.util.spec_from_file_location(name,R/path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
ev=load('edge_eval','scripts/canny_split_thresholds/evaluate.py')
gold=load('edge_gold','scripts/canny_gaussian_standalone/gold.py')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(n,x):(O/n).write_text(json.dumps(x,indent=2)+'\n',encoding='utf8')
def closing(edge,w,h):
 d=ev.dilate(edge,w,h,1);out=bytearray(w*h)
 for y in range(1,h-1):
  for x in range(1,w-1):
   i=y*w+x
   if d[i] and all(d[i+k] for k in (-w-1,-w,-w+1,-1,1,w-1,w,w+1)):out[i]=1
 return out
def holes(edge,w,h):
 labels=array('i',[-1])*(w*h);stats=[]
 for seed in range(w*h):
  if edge[seed] or labels[seed]>=0:continue
  n=len(stats);labels[seed]=n;q=deque([seed]);a=0;x0=w;y0=h;x1=y1=0;border=False
  while q:
   i=q.popleft();y,x=divmod(i,w);a+=1;x0=min(x0,x);x1=max(x1,x);y0=min(y0,y);y1=max(y1,y);border|=x==0 or x==w-1 or y==0 or y==h-1
   for v in ((i-1 if x else -1),(i+1 if x<w-1 else -1),(i-w if y else -1),(i+w if y<h-1 else -1)):
    if v>=0 and not edge[v] and labels[v]<0:labels[v]=n;q.append(v)
  stats.append((a,x0,x1,y0,y1,border))
 return labels,stats
def rle_labels(edge,w,h):
 runs=[];rows=[];par=[];rank=[]
 def root(i):
  while par[i]!=i:i=par[i]
  return i
 def union(i,j):
  i=root(i);j=root(j)
  if i==j:return
  if rank[i]<rank[j]:i,j=j,i
  par[j]=i
  if rank[i]==rank[j]:rank[i]+=1
 for y in range(h):
  ids=[];x=0
  while x<w:
   if edge[y*w+x]:x+=1;continue
   start=x
   while x<w and not edge[y*w+x]:x+=1
   i=len(runs);runs.append((y,start,x-1));par.append(i);rank.append(0);ids.append(i)
  rows.append(ids)
  if y:
   prev=rows[y-1];j=0
   for i in ids:
    a,b=runs[i][1:]
    while j<len(prev) and runs[prev[j]][2]<a:j+=1
    k=j
    while k<len(prev) and runs[prev[k]][1]<=b:union(i,prev[k]);k+=1
 stats={};label=array('i',[-1])*(w*h)
 for i,(y,x0,x1) in enumerate(runs):
  k=root(i)
  if k not in stats:stats[k]=[0,w,0,h,0,False]
  s=stats[k];s[0]+=x1-x0+1;s[1]=min(s[1],x0);s[2]=max(s[2],x1);s[3]=min(s[3],y);s[4]=max(s[4],y);s[5]|=x0==0 or x1==w-1 or y==0 or y==h-1
  for x in range(x0,x1+1):label[y*w+x]=k
 keys=list(stats);mapping={k:i for i,k in enumerate(keys)}
 for i,k in enumerate(label):
  if k>=0:label[i]=mapping[k]
 return label,[tuple(stats[k]) for k in keys],dict(runs=len(runs),row_max=max(map(len,rows)))
def classify(edge,w,h,bridge=1,explain_radius=1):
 labs,stats=holes(edge,w,h);rl,rs,capacity=rle_labels(edge,w,h)
 assert sorted(stats)==sorted(rs),'BFS_RLE_COMPONENT_STATS'
 # Compare roots through canonical first pixel, independent of label allocation.
 mapping={}
 for a,b in zip(labs,rl):
  if a>=0:
   if a in mapping:assert mapping[a]==b
   else:mapping[a]=b
 parents=list(range(len(stats)))
 def root(k):
  while parents[k]!=k:k=parents[k]
  return k
 contacts=0
 # Only an uninterrupted edge-only straight bridge, never through external background.
 for i,on in enumerate(edge):
  if not on:continue
  y,x=divmod(i,w)
  for dx,dy in ((1,0),(0,1)):
   px=x-dx;py=y-dy
   if not (0<=px<w and 0<=py<h):continue
   left=labs[py*w+px]
   if left<0 or stats[left][5]:continue
   for length in range(1,bridge+1):
    nx=x+dx*length;ny=y+dy*length
    if not (0<=nx<w and 0<=ny<h):break
    j=ny*w+nx;right=labs[j]
    if right>=0:
     if not stats[right][5]:
      a=root(left);b=root(right)
      if a!=b:parents[b]=a;contacts+=1
     break
    if not edge[j]:raise AssertionError('nonlabel nonedge')
 merged={}
 for k,s in enumerate(stats):
  if s[5]:continue
  r=root(k)
  if r not in merged:merged[r]=[0,w,0,h,0]
  v=merged[r];v[0]+=s[0];v[1]=min(v[1],s[1]);v[2]=max(v[2],s[2]);v[3]=min(v[3],s[3]);v[4]=max(v[4],s[4])
 candidates=[];small=0;unknown=[]
 for a,x0,x1,y0,y1 in merged.values():
  bw=x1-x0+1;bh=y1-y0+1;d2=bw*bw+bh*bh
  if a<=16:small+=a
  elif 2800<=a<=7000 and 96<=max(bw,bh)<=176 and 12000<=d2<=36000:candidates.append((a,x0,x1,y0,y1))
  else:unknown.append(dict(area=a,w=bw,h=bh,d2=d2))
 unexplained=0
 for i,on in enumerate(edge):
  if not on:continue
  y,x=divmod(i,w);explained=False
  for dy in range(-explain_radius,explain_radius+1):
   if not 0<=y+dy<h:continue
   for dx in range(-explain_radius,explain_radius+1):
    if not 0<=x+dx<w:continue
    k=labs[(y+dy)*w+x+dx]
    if k>=0 and not stats[k][5]:explained=True;break
   if explained:break
  unexplained+=not explained
 border_edge=any(edge[y*w+x] and (x<8 or x>=w-8 or y<8 or y>=h-8) for y in range(h) for x in range(w))
 reason='CAPACITY' if capacity['runs']>4096 or capacity['row_max']>128 else 'BORDER' if border_edge else 'UNKNOWN_HOLE' if unknown else 'UNEXPLAINED_EDGE' if unexplained>64 else 'NOISE_HOLE' if small>64 else 'COUNT_OVER10' if len(candidates)>10 else 'VALID'
 return dict(status=reason,count=len(candidates) if reason=='VALID' else None,raw_holes=sum(not s[5] for s in stats),merged_holes=len(merged),candidates=candidates,unknown=unknown,small_hole_area=small,unexplained=unexplained,contacts=contacts,**capacity)
def screw(w,h,cx,cy,angle=0,style='plain',background=160,foreground=32):
 a=bytearray([background])*(w*h);co=math.cos(math.radians(angle));si=math.sin(math.radians(angle))
 for y in range(max(0,cy-105),min(h,cy+106)):
  for x in range(max(0,cx-105),min(w,cx+106)):
   u=(x-cx)*co+(y-cy)*si+64;v=-(x-cx)*si+(y-cy)*co
   inside=(u-27)**2+v*v<=27**2 or (27<=u<=127 and abs(v)<=17)
   if inside:
    value=foreground
    if style in ('slot','texture') and 15<u<39 and abs(v)<2:value=foreground+85
    if style=='texture' and 48<u<119 and abs(v)<13 and int(u)%12<3:value=foreground+90
    if style=='hole' and (u-27)**2+v*v<8**2:value=background
    a[y*w+x]=value
 return a
def combine(w,h,objects,background=160):
 a=bytearray([background])*(w*h)
 for obj in objects:
  q=screw(w,h,*obj,background=background)
  for i,v in enumerate(q):a[i]=min(a[i],v)
 return a
def frontend(a,w,h):return ev.local(ev.classify(ev.frontend(a,w,h),48),w,h)
def main():
 parent=R/'reports/part_count_weaknoise_20261027/review_snapshot_v2/MANIFEST.json';assert rec(parent)['sha256']=='d953cbc9789947bf84a0064ba3a67db3496775eaa2be808fa4977256914b7002'
 for row in json.loads(parent.read_text())['records']:
  for k in ('original','snapshot'):assert rec(R/row[k]['path'])==row[k],row[k]['path']
 save('PARENT_PROTECTION_INITIAL.json',dict(passed=True,manifest=rec(parent),checks=784))
 results=[];started=time.time();V=R/'tb/part_count_edge/assessment_vectors';V.mkdir(parents=True,exist_ok=True)
 # Bounds frozen before these evaluations; no fitting to a photographed mask.
 save('CANDIDATE_PLAN.json',dict(thresholds=[48,24],gaussian=True,closing_radius=1,background_connectivity=4,edge_connectivity=8,bridge_candidates=[1,2],explain_radius=1,unexplained_cap=64,small_hole_area_cap=64,area=[2800,7000],max_side=[96,176],d2=[12000,36000],source='Geometry is provisional from broad old filled scale; not calibrated edge perimeter.',separation='At least8px resolved edge gap for demonstration; tighter pairs must correctly count or reject.'))
 def case(name,a,w,h,n,kind='production_oracle'):
  edge=frontend(a,w,h);closed=closing(edge,w,h);one=classify(closed,w,h,1);two=classify(closed,w,h,2)
  row=dict(name=name,width=w,height=h,expected=n,kind=kind,edge_pixels=sum(edge),closed_pixels=sum(closed),one=one,two=two,seconds=time.time()-started);results.append(row)
  print(name,'edge',sum(edge),'one',one['status'],one['count'],'two',two['status'],two['count'],'runs',two['runs'],'unexplained',two['unexplained'],flush=True)
  if name in ('single_texture_33','near_pair_gap8'):
   words,alt=gold.spatial(list(a),w,h,2,48,5);assert bytearray(alt)==edge,'INDEPENDENT_FRONTEND_ORACLE'
   (V/(name+'.hex')).write_text(''.join(f'{int(a[i])|int(edge[i])<<8|int((words[i]>>28)&1)<<9:03x}\n' for i in range(w*h)))
   row['native_vector']=rec(V/(name+'.hex'))
  save('ASSESSMENT_RUNNING.json',dict(running=True,results=results))
  return edge,closed
 for angle in (0,33,67,90,137):
  case('single_plain_'+str(angle),screw(320,240,160,120,angle),320,240,1)
 for style in ('slot','texture','hole'):
  for angle in (0,33):case('single_'+style+'_'+str(angle),screw(320,240,160,120,angle,style),320,240,1)
 for n in (0,1,2,5,8,10,11):
  objects=[(105+(i%5)*185,140+(i//5)*220,(i%4)*45,'texture') for i in range(min(n,10))]
  if n==11:objects.append((480,250,0,'plain'))
  case('count_'+str(n),combine(960,540,objects),960,540,n if n<=10 else 'REJECT')
 # Parallel near pair, local Canny resolved contour gap based on source54px head extent.
 for gap in (8,2,0):case('near_pair_gap'+str(gap),combine(400,320,[(200,110,0,'texture'),(200,164+gap,0,'texture')]),400,320,2 if gap==8 else 'COUNT2_OR_REJECT')
 # Ideal edge fixtures separate from real grayscale -> production edge.
 base=bytearray(320*240)
 for x in range(90,231):base[80*320+x]=base[140*320+x]=1
 for y in range(80,141):base[y*320+90]=base[y*320+230]=1
 for gap in (0,1,2,3,6):
  e=base[:]
  for x in range(150,150+gap):e[80*320+x]=0
  c=closing(e,320,240);results.append(dict(name='ideal_gap'+str(gap),kind='ideal_edge_fixture',expected='1_OR_GEOMETRY_REJECT' if gap<=2 else 'REJECT',one=classify(c,320,240,1),two=classify(c,320,240,2)))
 e=base[:]
 for x in range(110,211):e[80*320+x]=0
 for x in range(150,154):e[139*320+x]=e[143*320+x]=1
 for y in range(139,144):e[y*320+150]=e[y*320+153]=1
 c=closing(e,320,240);results.append(dict(name='long_open_plus_small_ring',kind='ideal_edge_fixture',expected='REJECT',one=classify(c,320,240,1),two=classify(c,320,240,2)))
 save('ASSESSMENT_V1.json',dict(status='EVALUATION_NOT_PRODUCTION_GO',running=False,results=results,script=rec(Path(__file__)),elapsed=time.time()-started,limits='Synthetic grayscale and explicitly separate ideal contour fixtures. No real sensor RAW or actual counts inferred from phone image.'))
 print('ASSESSMENT_DONE',len(results),time.time()-started,flush=True)
if __name__=='__main__':main()
