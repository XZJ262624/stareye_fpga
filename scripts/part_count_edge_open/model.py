"""Independent background BFS and actual-edge hole unions; E4/E5 deliberately absent."""
from common import holes,rle_labels
from collections import deque
def classify(edge,w,h,bridge=2,explain_radius=2):
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
 candidates=[];candidate_roots=set();small=0;unknown=[]
 for merged_root,(a,x0,x1,y0,y1) in merged.items():
  bw=x1-x0+1;bh=y1-y0+1;d2=bw*bw+bh*bh
  if a<=16:small+=a
  elif 2800<=a<=7000 and 96<=max(bw,bh)<=176 and 12000<=d2<=36000:candidates.append((a,x0,x1,y0,y1));candidate_roots.add(merged_root)
  else:unknown.append(dict(area=a,w=bw,h=bh,d2=d2))
 reason='CAPACITY' if capacity['runs']>5120 or capacity['row_max']>128 else 'UNKNOWN_HOLE' if unknown else 'COUNT_OVER10' if len(candidates)>10 else 'VALID'
 return dict(status=reason,count=len(candidates) if reason=='VALID' else None,raw_holes=sum(not s[5] for s in stats),merged_holes=len(merged),candidates=candidates,unknown=unknown,small_hole_area=small,edge_pixels=sum(edge),contacts=contacts,**capacity)
