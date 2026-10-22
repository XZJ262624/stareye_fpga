"""Independent image-coordinate integer oracle; no RTL state/pipeline imports."""
from pathlib import Path
import json,hashlib
def spatial(a,w,h,f,hi,mode):
 n=w*h;z=lambda:[0]*n;b=a[:] if f==0 else z();r=1 if f==0 else 2
 if f in (1,2):
  for y in range(1,h-1):
   for x in range(1,w-1):
    i=y*w+x;v=[a[(y+dy)*w+x+dx] for dy in (-1,0,1) for dx in (-1,0,1)]
    b[i]=sorted(v)[4] if f==1 else (sum(p*k for p,k in zip(v,(1,2,1,2,4,2,1,2,1)))+8)//16
 mag=z();dr=z();ok=z();ns=z();nm=z();cs=z();edge=z();strong=z();weak=z();cl=z()
 for y in range(r,h-r):
  for x in range(r,w-r):
   i=y*w+x
   gx=sum(b[(y+dy)*w+x+dx]*k for dy,dx,k in [(-1,-1,-1),(-1,1,1),(0,-1,-2),(0,1,2),(1,-1,-1),(1,1,1)])
   gy=sum(b[(y+dy)*w+x+dx]*k for dy,dx,k in [(-1,-1,1),(-1,0,2),(-1,1,1),(1,-1,-1),(1,0,-2),(1,1,-1)])
   ax,ay=abs(gx),abs(gy);mag[i]=ax+ay;ok[i]=1
   dr[i]=0 if ay*128<=ax*53 else 2 if ax*128<=ay*53 else 1 if gx*gy>=0 else 3
 offsets=[(-1,1,-1,-1),(-1,-1,1,1)]
 pairs=[((0,-1),(0,1)),((-1,1),(1,-1)),((-1,0),(1,0)),((-1,-1),(1,1))]
 for y in range(r+1,h-r-1):
  for x in range(r+1,w-r-1):
   i=y*w+x;ns[i]=1;p,q=pairs[dr[i]]
   if mag[i]>mag[(y+p[0])*w+x+p[1]] and mag[i]>=mag[(y+q[0])*w+x+q[1]]:nm[i]=mag[i]
   strong[i]=int(nm[i]!=0 and nm[i]>=hi);weak[i]=int(nm[i]!=0 and hi//2<=nm[i]<hi);cl[i]=2 if strong[i] else 1 if weak[i] else 0
 for y in range(r+2,h-r-2):
  for x in range(r+2,w-r-2):
   i=y*w+x;cs[i]=1;edge[i]=int(strong[i] or weak[i] and any(strong[(y+dy)*w+x+dx] for dy in (-1,0,1) for dx in (-1,0,1) if dy or dx))
 words=[]
 for y in range(h):
  for x in range(w):
   i=y*w+x;j=(y-1)*w+x-1;lm=min(255,mag[j]) if x and y else 0;lb=int(bool(x and y and ok[j] and lm>=hi));ov=int(ok[i] and mag[i]>=hi);ng=min(nm[i],255)
   rgb=[a[i]*0x010101,lm*0x010101,lb*0xffffff,0xff0000 if ov else a[i]*0x010101,ng*0x010101,edge[i]*0xffffff,0xff0000 if edge[i] else a[i]*0x010101][mode]
   v=a[i]|lm<<8|lb<<16|ok[i]<<17|ov<<18|ng<<19|ns[i]<<27|cs[i]<<28|edge[i]<<29|mag[i]<<30|dr[i]<<42|rgb<<44|cl[i]<<92
   words.append(v)
 return words,edge
def image(w,h,k):return [(x*17+y*31+((x*y+k*73)^((x//7)*91))+k*19)&255 for y in range(h) for x in range(w)]
def prepare(out,w,h,cases):
 out.mkdir(parents=True,exist_ok=False);records=[]
 for j,(mode,f,hi,k) in enumerate(cases):
  words,edges=spatial(image(w,h,k),w,h,f,hi,mode);p=out/f'frame_{j}.hex';p.write_text(''.join(f'{v:024x}\n' for v in words));records.append(dict(frame=j,mode=mode,filter=f,high=hi,pattern=k,pixels=w*h,edges=sum(edges),sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
 (out/'cases.txt').write_text(''.join(f'{m} {f} {h} {k}\n' for m,f,h,k in cases));(out/'MANIFEST.json').write_text(json.dumps(dict(width=w,height=h,frames=records),indent=2));return records
if __name__=='__main__':
 import sys
 root=Path(__file__).resolve().parents[2]/'reports/gaussian_integration_20261020/data'
 cases=[(m,1 if m<4 else 2,64,m) for m in range(7)]+[(6,0,0,8),(3,1,255,9),(4,2,80,10),(0,1,64,11)]
 print(prepare(root/'small',64,48,cases),flush=True)
 print(prepare(root/'720p',1280,720,[(6,2,64,11)]),flush=True)
