"""Isolated assessment, no production writes, no new RTL claims.

All geometry truths are set before prediction. Frozen cases keep their truth.
The component stage models complete 8-connectivity, then applies conservative
bounds; it is an algorithm oracle, not a cycle-accurate streaming implementation.
"""
from pathlib import Path
import math, json, hashlib, subprocess, time

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
HEAD='9dea12d9f0d29f57aa6d3acb75695da9e0d53d2c'
SOURCES=['rtl/shape_standalone/shape/shape_recognizer_epoch.sv',
 'rtl/shape_standalone/shape/shape_osd.sv',
 'rtl/shape_standalone/shape/shape_stream_adapter_contract_v2.sv',
 'efinity/shape_orientation_fix_i3/Ti60_Demo.xml',
 'reports/shape_standalone_20261021/candidate_assets/oracle_sources/a98c1ed325c3c896062fe12110c79296f01376f63ac4637dec6d6c581aa5bb0b_model_b.py',
 'reports/shape_standalone_20261021/candidate_assets/GOLD_MANIFEST.json']
def save(name,data):
 (OUT/name).write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(ROOT).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def heartbeat(activity):save('HEARTBEAT.json',dict(status='RUNNING',running=True,updated_unix=time.time(),activity=activity,hardware_next=False))
def bbox(p):
 return min(x for x,y in p),min(y for x,y in p),max(x for x,y in p),max(y for x,y in p)
def chord(b):
 n=16*(4096-(2*b+1-64)**2);r=math.isqrt(n);return r+int((2*r+1)**2<=4*n)

def classify(p,W=960,H=540,maximum=440,legacy_counter=False):
 if not p:return 0,dict(reason='blank')
 l,t,r,b=bbox(p);w=r-l+1;h=b-t+1
 if l<16 or r>W-17 or t<16 or b>H-17 or not(80<=w<=maximum and 80<=h<=maximum):
  return 0,dict(reason='domain',bbox=[l,t,w,h])
 rows={y:[] for y in range(t,b+1)}
 for x,y in p:rows[y].append(x)
 for a in rows.values():a.sort()
 a=rows[t+h//2];ref=a[-1]-a[0]+1 if a else 0
 n=rg=cg=err=top=bottom=fragments=0;bad=False;capbad=False;k=(h+63)//64
 for y,a in rows.items():
  if not a:bad=True;continue
  rel=y-t;rw=a[-1]-a[0]+1;segments=1+sum(v-u>=4 for u,v in zip(a,a[1:]));center=abs(a[-1]+a[0]-l-r)
  expected=(w*chord(min(63,(rel*64+32)//h))+128)//256;ce=abs(rw-expected)
  middle=h<=rel*10<h*9;outer=rel<k or h-1-rel<k
  if segments>2:
   if not outer or center>16:capbad=True
   if outer:fragments=min(7,fragments+1) if legacy_counter else fragments+1
   if outer and rw>expected and ce*10>w:capbad=True
  if middle and (segments>2 or center>16):bad=True
  density=min(7,(len(a)*8+rw//2)//rw);bar=rw*density//8
  if rel*10<h:top+=bar
  if (h-1-rel)*10<h:bottom+=bar
  if middle:
   n+=1;rg+=abs(rw-ref)<=3 or abs(rw-ref)*100<=ref*4;cg+=ce*10<=w;err+=ce
 rect=n>0 and rg*10>=n*9 and top*4>=ref*3 and bottom*4>=ref*3 and w*2>=h and h*2>=w
 circle=not capbad and fragments<=k and n>0 and cg*10>=n*9 and err*100<=n*w*6 and h*90<=w*100<=h*110
 return (0 if bad or rect==circle else 2 if rect else 1),dict(bbox=[l,t,w,h],contour_bad=bad,rectangle=rect,circle=circle,cap_fragments=fragments,cap_limit=k)

def components(p):
 remaining=set(p);result=[]
 while remaining:
  point=min(remaining,key=lambda q:(q[1],q[0]));remaining.remove(point);pending=[point];component={point}
  while pending:
   x,y=pending.pop()
   for dy in (-1,0,1):
    for dx in (-1,0,1):
     q=x+dx,y+dy
     if q in remaining:remaining.remove(q);component.add(q);pending.append(q)
  result.append(component)
 return result

def max_runs(p):
 rows={}
 for x,y in p:rows.setdefault(y,[]).append(x)
 return max((1+sum(v-u>1 for u,v in zip(a,a[1:])) for a in (sorted(a) for a in rows.values())),default=0)

def select(p,W=960,H=540):
 """Retain all substantial contours, never choose the largest one alone.

 Ignore only <=4 exterior components, each bbox <=24x24 and <=64 pixels,
 total <=128 pixels, with >=8 empty columns/rows from retained union bbox.
 Any small contour inside or near the retained bbox remains in classifier.
 ROI-edge contacts, >128 components or >8 exact runs/row fail closed.
 """
 if not p:return p,dict(reason='blank',removed=0)
 cc=components(p);runs=max_runs(p)
 if len(cc)>128 or runs>8:return set(),dict(reason='capacity',components=len(cc),max_runs=runs,removed=0)
 if any(x in (0,W-1) or y in (0,H-1) for x,y in p):return set(),dict(reason='roi_boundary_contact',removed=0)
 small=[];large=[]
 for c in cc:
  l,t,r,b=bbox(c)
  (small if len(c)<=64 and r-l+1<=24 and b-t+1<=24 else large).append(c)
 if not large:return p,dict(reason='no_seed',removed=0,components=len(cc),max_runs=runs)
 retained=set().union(*large);l,t,r,b=bbox(retained);remove=[]
 for c in small:
  ll,tt,rr,bb=bbox(c)
  if rr<=l-9 or ll>=r+9 or bb<=t-9 or tt>=b+9:remove.append(c)
  else:retained.update(c)
 count=sum(map(len,remove))
 if len(remove)>4 or count>128:return set(),dict(reason='noise_budget',removed=0,eligible_components=len(remove),eligible_pixels=count)
 return retained,dict(reason='filtered' if count else 'unchanged',removed=count,removed_components=len(remove),components=len(cc),max_runs=runs)

def filled(kind,w,h,cx=480,cy=270):
 # Explicit filled pixel-domain widths: odd/even dimensions have exact bbox.
 l=cx-w//2;t=cy-h//2;result=set()
 for yy in range(h):
  for xx in range(w):
   u=(2*xx-(w-1))/w;v=(2*yy-(h-1))/h
   inside=(u*u+v*v<=1) if kind in ('circle','ellipse','ring') else True
   if kind=='triangle':inside=abs(u)<(v+1)/2
   if kind=='ring':inside=inside and u*u+v*v>=.64*.64
   if kind=='text':inside=abs(u-.6)<.14 or abs(u+.6)<.14 or abs(v)<.14
   if inside:result.add((l+xx,t+yy))
 return result
def edge(mask):return {(x,y) for x,y in mask if any(q not in mask for q in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)))}
def line(x,y,n,dx=1,dy=0):return {(x+i*dx,y+i*dy) for i in range(n)}
def crop_translate(p,l,t,W,H):return {(x-l,y-t) for x,y in p if l<=x<l+W and t<=y<t+H}

def synthetic():
 definitions=[];images=[]
 def add(name,p,truth,group,**extra):
  definitions.append(dict(id=len(definitions),name=name,truth=truth,group=group,**extra));images.append(p)
 for kind,truth in [('circle',1),('rect',2)]:
  for size in (79,80,82,160,278,280,281,320,384,420,439,440,441):
   p=edge(filled(kind,size,size))
   add(f'{kind}_scale_{size}',p,truth if 80<=size<=440 else 0,'scale',semantic_shape=truth,requested_width=size)
  for cx,cy in [(56,56),(120,270),(480,56),(840,270),(904,484),(55,56),(905,484),(10,270)]:
   p=edge(filled(kind,80,80,cx,cy));label=truth if 56<=cx<=904 and 56<=cy<=484 else 0
   add(f'{kind}_position_{cx}_{cy}',p,label,'position',clipped_source=any(not(0<=x<960 and 0<=y<540) for x,y in p))
  target=edge(filled(kind,200,200));l,t,r,b=bbox(target)
  for direction,(dx,dy) in [('horizontal',(1,0)),('vertical',(0,1)),('diagonal',(1,1))]:
   for length in (1,4,12,24,25,48):
    add(f'{kind}_external_{direction}_{length}',target|line(r+20,t+65,length,dx,dy),truth if length<=24 else 0,'external_noise',noise_extent=length)
  for gap in (0,1,2,4,7,8,9):
   # All near/touch cases are explicit rejection probes; retained target
   # evidence may still accept tiny changes, which remains reported failure.
   add(f'{kind}_gap_{gap}',target|line(r+gap+1,t+80,12,0,1),truth if gap>=8 else 0,'gap')
  for n in (2,4,5):
   noise=set().union(*(line(r+20+30*i,t+80,12,0,1) for i in range(n)))
   add(f'{kind}_noise_count_{n}',target|noise,truth if n<=4 else 0,'noise_count')
  add(f'{kind}_interior_stripe',target|line(480,250,24,0,1),0,'inside_or_touch')
  add(f'{kind}_cross_horizontal',target|line(l-20,270,240),0,'inside_or_touch')
  add(f'{kind}_cross_vertical',target|line(480,t-20,240,0,1),0,'inside_or_touch')
  add(f'{kind}_attached_short',target|line(r,270,12),0,'inside_or_touch')
  add(f'{kind}_tiny_attached_one',target|{(r+1,270)},0,'inside_or_touch')
  add(f'{kind}_small_inside_circle_bbox',target|line(415,185,4),0,'inside_or_touch')
  add(f'{kind}_outside_roi',target|line(965,270,12),truth,'outside_roi')
 for kind in ('triangle','ellipse','ring','text'):
  for size in (84,200,320,440):
   p=edge(filled(kind,size,round(size*.7) if kind=='ellipse' else size))
   add(f'negative_{kind}_{size}',p,0,'negative')
   add(f'negative_{kind}_{size}_plus_noise',p|line(750,80,12),0,'negative_noise')
 for size in (84,160):
  add(f'double_circle_{size}',edge(filled('circle',size,size,360,270))|edge(filled('circle',size,size,600,270)),0,'negative')
  add(f'circle_plus_rect_{size}',edge(filled('circle',size,size,360,270))|edge(filled('rect',size,size,600,270)),0,'negative')
 add('blank',set(),0,'negative')
 add('noise_only',line(480,270,24),0,'negative')
 # Save before any classifier is evaluated, including intentionally difficult cases.
 save('SYNTHETIC_DEFINITIONS.json',dict(domain='Binary ideal boundaries; not grayscale/Canny or real-camera evidence',definitions=definitions,truth_policy='Outside guard small clutter supported; near/inside/contact/crossing are conservative UNKNOWN probes, not claims of observability. Original labels never changed.'))
 results=[]
 for d,p in zip(definitions,images):
  p=crop_translate(p,0,0,960,540);clean,s=select(p)
  old=classify(crop_translate(p,224,78,512,384),512,384,280)[0]
  wide=classify(p)[0];new,feat=classify(clean)
  medium=classify(crop_translate(p,96,14,768,512),768,512,440)[0]
  cc=components(p);largest=max(cc,key=len) if cc else set();naive=classify(largest)[0]
  results.append(dict(**d,old512=old,wide960_no_filter=wide,medium768_no_filter=medium,guarded=new,largest_only=naive,filter=s,features=feat,correct=new==d['truth']))
 return results

def unpack_rows(path):
 points=set()
 for y,line_ in enumerate(path.read_text().splitlines()):
  word=int(line_,16)
  while word:
   bit=word&-word;points.add((bit.bit_length()-1,y));word-=bit
 return points

def frozen():
 results=[];inputs=[]
 manifest=json.loads((ROOT/SOURCES[-1]).read_text())['records'];gold={r['path']:r for r in manifest}
 for group in ('fixed100','new128'):
  binding=ROOT/f'reports/gaussian_cap_remote_v2_20261021/package/cap_cases/{group}/MODEL_BINDING.json'
  assert rec(binding)==gold[binding.relative_to(ROOT).as_posix()]
  inputs.append(rec(binding));records=json.loads(binding.read_text())['records']
  for record in records:
   if 'edges' in record:
    p=ROOT/record['edges']['path'];assert rec(p)==record['edges'];points=unpack_rows(p);inputs.append(rec(p))
   else:
    p=ROOT/record['original_gold']['path'];assert rec(p)==record['original_gold'];inputs.append(rec(p));points=set()
    packaged=f'reports/gaussian_cap_remote_v2_20261021/package/cap_cases/{group}/gray_gold_{record["id"]:03d}.hex'
    assert inputs[-1]['sha256']==gold[packaged]['sha256'] and inputs[-1]['bytes']==gold[packaged]['bytes']
    for idx,line_ in enumerate(p.read_text().splitlines()):
     y,x=divmod(idx,544)
     if 16<=x<528 and 16<=y<400 and int(line_[-8],16)&2:points.add((x-16,y-16))
   original,f=classify(points,512,384,280,True)
   assert original==record['prediction'],(group,record['id'],original,record['prediction'])
   translated={(x+224,y+78) for x,y in points};clean,selection=select(translated)
   new,features=classify(clean)
   cc=components(translated);largest=max(cc,key=len) if cc else set()
   results.append(dict(group=group,id=record['id'],kind=record.get('kind','frozen'),truth=record['truth'],frozen_prediction=record['prediction'],recomputed_original=original,wide_no_filter=classify(translated)[0],guarded=new,largest_only=classify(largest)[0],selection=selection,features=features,source=inputs[-1]))
   if record['id']%20==0:heartbeat(f'Frozen {group} {record["id"]}/{len(records)}')
 return results,inputs

def score(records,key):
 p=[x for x in records if x['truth']];n=[x for x in records if not x['truth']]
 return dict(positive_correct=sum(x[key]==x['truth'] for x in p),positive_total=len(p),negative_false_accept=sum(x[key]!=0 for x in n),negative_total=len(n),false_accept_ids=[x.get('name',str(x.get('group'))+':'+str(x.get('id'))) for x in n if x[key]!=0],miss_ids=[x.get('name',str(x.get('group'))+':'+str(x.get('id'))) for x in p if x[key]!=x['truth']])

def main():
 heartbeat('Binding production sources to fixed candidate')
 bindings=[]
 for name in SOURCES:
  original=subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga','show',HEAD+':'+name],cwd=ROOT)
  current=(ROOT/name).read_bytes();assert current==original,name
  bindings.append(rec(ROOT/name))
 save('SOURCE_BINDING_PRE.json',dict(head=HEAD,sources=bindings))
 syn=synthetic();save('SYNTHETIC_RESULTS.json',syn)
 fr,inputs=frozen();save('FROZEN_RESULTS.json',fr);save('FROZEN_INPUT_BINDINGS.json',inputs)
 assert all(rec(ROOT/x['path'])==x for x in bindings)
 save('SOURCE_BINDING_POST.json',dict(head=HEAD,sources=bindings))
 summary=dict(status='ASSESSMENT_MODELS_COMPLETE_NOT_RTL_QUALIFICATION',synthetic=dict(count=len(syn),scores={k:score(syn,k) for k in ('old512','wide960_no_filter','medium768_no_filter','guarded','largest_only')},by_group={g:score([x for x in syn if x['group']==g],'guarded') for g in sorted({x['group'] for x in syn})}),frozen={g:{k:score([x for x in fr if x['group']==g],k) for k in ('recomputed_original','wide_no_filter','guarded','largest_only')} for g in ('fixed100','new128')},limitations=['Ideal synthetic binary edges; no new grayscale or RTL/STA/physical qualification','Finite synthetic rejects include intentionally unobservable tiny contact counterexamples','Streaming CCL scheduling, provisional label bounds and run capacity need RTL proof'])
 save('MODEL_SUMMARY.json',summary);print(json.dumps(summary,ensure_ascii=False),flush=True)

if __name__=='__main__':main()
