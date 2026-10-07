"""Independent 2-D array oracle: convolution, image slicing and neighbor sets.

No RTL state machine, line buffer, or pipeline implementation is reproduced.
"""
import numpy as np
from numpy.lib.stride_tricks import sliding_window_view
FONT={
 '0':[14,17,19,21,25,17,14],'1':[4,12,4,4,4,4,14],'2':[14,17,1,2,4,8,31],'3':[30,1,1,14,1,1,30],
 '4':[2,6,10,18,31,2,2],'5':[31,16,16,30,1,1,30],'6':[14,16,16,30,17,17,14],'7':[31,1,2,4,8,8,8],
 '8':[14,17,17,14,17,17,14],'9':[14,17,17,15,1,1,14],
 'R':[30,17,17,30,20,18,17],'A':[14,17,17,31,17,17,17],'W':[17,17,17,21,21,21,10],
 'M':[17,27,21,21,17,17,17],'G':[14,17,16,23,17,17,14],'B':[30,17,17,30,17,17,30],
 'I':[14,4,4,4,4,4,14],'N':[17,25,25,21,19,19,17],'T':[31,4,4,4,4,4,4],
 'O':[14,17,17,17,17,17,14],'V':[17,17,17,17,17,10,4],
 'S':[15,16,16,14,1,1,30],'C':[14,17,16,16,16,17,14],'Y':[17,17,10,4,4,4,4],
 'H':[17,17,17,31,17,17,17],'L':[16,16,16,16,16,16,31],' ':[0]*7}
def osd(rgb,x,y,mode,high):
 end=148 if mode<4 else 228
 if not(12<=x<end and 12<=y<34):return rgb
 if not(16<=x<end-4 and 16<=y<30):return 0
 label=('RAW','MAG','BIN','OVR','NMS','CNY','COV')[mode]+(' T' if mode<4 else ' H')+f'{high:03d}'
 if mode>=4:label+=' L'+f'{high//2:03d}'
 slot=(x-16)//16;col=((x-16)%16)//2;row=(y-16)//2
 return 0xffffff if col<5 and FONT[label[slot]][row]&(16>>col) else 0
def image(w,h,k):
 y,x=np.indices((h,w));rng=np.random.default_rng(51006+k)
 if k==0:a=np.zeros((h,w),dtype=np.int32)
 elif k==1:a=np.full((h,w),255,dtype=np.int32)
 elif k==2:a=30+180*(x>=w//2)
 elif k==3:a=30+180*(y>=h//2)
 elif k==4:a=30+180*(x*h>=y*w)
 elif k==5:a=30+180*((w-1-x)*h>=y*w)
 elif k==6:a=30+120*((x>w//4)&(x<3*w//4)&(y>h//4)&(y<3*h//4))
 elif k==7:a=30+120*((x-w//2)**2+(y-h//2)**2<(h//3)**2)
 elif k==8:a=np.where((x==w//2)&(y==h//2),255,0)
 elif k==9:a=rng.choice([0,255,80,80,80,80,80],(h,w))
 elif k==10:a=np.where(x<w//2,10+8*(x>w//4),90+80*(y>h//2))
 elif k==11:a=rng.integers(0,256,(h,w))
 else:a=(x*2+y*3)%96+32
 return a.astype(np.int32)
def support(w,h,r):
 y,x=np.indices((h,w));return (x>=r)&(x<w-r)&(y>=r)&(y<h-r)
def direction(gx,gy):
 # Fraction cross-products implement the rational specification independently.
 ax,ay=np.abs(gx),np.abs(gy)
 return np.where(ay*128<=ax*53,0,np.where(ax*128<=ay*53,2,np.where(gx*gy>=0,1,3))).astype(np.int32)
def spatial(a,enable,high):
 h,w=a.shape;b=a.copy();radius=2 if enable else 1
 if enable:
  b=np.zeros_like(a);b[1:-1,1:-1]=np.median(sliding_window_view(a,(3,3)),axis=(-2,-1)).astype(np.int32)
 patches=sliding_window_view(b,(3,3))
 gx=np.zeros_like(a);gy=np.zeros_like(a)
 gx[1:-1,1:-1]=np.einsum('yxij,ij->yx',patches,np.array([[-1,0,1],[-2,0,2],[-1,0,1]]))
 gy[1:-1,1:-1]=np.einsum('yxij,ij->yx',patches,np.array([[1,2,1],[0,0,0],[-1,-2,-1]]))
 ok=support(w,h,radius);mag=np.where(ok,np.abs(gx)+np.abs(gy),0);dirs=np.where(ok,direction(gx,gy),0)
 nms=np.zeros_like(a);ns=support(w,h,radius+1)
 # Each pair is negative and positive image-coordinate neighbor.
 for d,((dy0,dx0),(dy1,dx1)) in enumerate([((0,-1),(0,1)),((-1,1),(1,-1)),((-1,0),(1,0)),((-1,-1),(1,1))]):
  neg=np.roll(mag,(-dy0,-dx0),(0,1));pos=np.roll(mag,(-dy1,-dx1),(0,1))
  keep=ns&(dirs==d)&(mag>neg)&(mag>=pos);nms[keep]=mag[keep]
 strong=(nms!=0)&(nms>=high);weak=(nms!=0)&(nms>=high//2)&(nms<high)
 nearby=np.zeros_like(ok)
 for dy in (-1,0,1):
  for dx in (-1,0,1):
   if (dy,dx)!=(0,0):nearby|=np.roll(strong,(dy,dx),(0,1))
 cs=support(w,h,radius+2);canny=cs&(strong|(weak&nearby))
 legacy_mag=np.zeros_like(a);legacy_mag[1:,1:]=np.minimum(mag[:-1,:-1],255)
 legacy_ok=np.zeros_like(ok);legacy_ok[1:,1:]=ok[:-1,:-1]
 legacy_bin=legacy_ok&(legacy_mag>=high);overlay=ok&(mag>=high)
 return dict(raw=a,mag=mag,direction=dirs,support=ok,legacy_mag=legacy_mag,legacy_bin=legacy_bin,overlay=overlay,
  nms=nms,nms_support=ns,canny=canny,canny_support=cs,strong=strong,weak=weak)
def generate(directory,w,h,cases):
 directory.mkdir(parents=True,exist_ok=True)
 (directory/'cases.txt').write_text(''.join(f'{m} {t} {e} {k}\n' for m,t,e,k in cases))
 stats=[]
 for f,(mode,high,en,k) in enumerate(cases):
  q=spatial(image(w,h,k),en,high);ng=np.minimum(q['nms'],255)
  rgb=np.choose(mode,[q['raw']*0x010101,q['legacy_mag']*0x010101,q['legacy_bin']*0xffffff,
   np.where(q['overlay'],0xff0000,q['raw']*0x010101),ng*0x010101,q['canny']*0xffffff,
   np.where(q['canny'],0xff0000,q['raw']*0x010101)])
  with (directory/f'frame_{f}.hex').open('w') as out:
   for y in range(h):
    for x in range(w):
     v=int(q['raw'][y,x])|(int(q['legacy_mag'][y,x])<<8)|(int(q['legacy_bin'][y,x])<<16)
     v|=int(q['support'][y,x])<<17|int(q['overlay'][y,x])<<18|int(ng[y,x])<<19
     v|=int(q['nms_support'][y,x])<<27|int(q['canny_support'][y,x])<<28|int(q['canny'][y,x])<<29
     v|=int(q['mag'][y,x])<<30|int(q['direction'][y,x])<<42|int(rgb[y,x])<<44
     v|=osd(int(rgb[y,x]),x,y,mode,high)<<68;out.write(f'{v:023x}\n')
  stats.append(dict(mode=mode,high=high,median=en,pattern=k,gradient_nonzero=int(np.count_nonzero(q['mag'])),nms_nonzero=int(np.count_nonzero(q['nms'])),canny_pixels=int(np.count_nonzero(q['canny']))))
 return stats

def generate_windows(directory):
 directory.mkdir(parents=True,exist_ok=True);w,h=19,17;y,x=np.indices((h,w));rng=np.random.default_rng(5517);stats=[]
 offsets=[(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
 for f in range(25):
  dirs=np.full((h,w),f%4);ok=np.ones((h,w),bool)
  distance=[x-9,x-y-1,y-8,x+y-17][f%4]
  mag=np.where(np.abs(distance)<=1,100,np.where(np.abs(distance)==2,50,0))
  if f>=4:mag=rng.integers(0,1531,(h,w));dirs=rng.integers(0,4,(h,w))
  if f==5:mag[:]=100
  if f==6:mag[:]=0;mag[8,9]=200
  if f==7:mag[:]=100;mag[8,9]=80
  strong=np.zeros((h,w),bool);weak=np.zeros((h,w),bool)
  if f<8:
   weak[8,9]=1;dy,dx=offsets[f];strong[8+dy,9+dx]=1
  elif f==8:weak[8,9]=1
  elif f==9:strong[8,4]=1;weak[8,5:14]=1
  elif f==10:strong[:]=1
  elif f in (11,12):weak[:]=1
  else:
   tags=rng.integers(0,3,(h,w));strong=tags==2;weak=tags==1
  if f==17:ok[6:9,7:10]=0
  ns=support(w,h,1)
  for dy in (-1,0,1):
   for dx in (-1,0,1):ns&=np.roll(ok,(dy,dx),(0,1))
  nms=np.zeros_like(mag)
  for d,(a,b) in enumerate([((0,-1),(0,1)),((-1,1),(1,-1)),((-1,0),(1,0)),((-1,-1),(1,1))]):
   keep=ns&(dirs==d)&(mag>np.roll(mag,(-a[0],-a[1]),(0,1)))&(mag>=np.roll(mag,(-b[0],-b[1]),(0,1)));nms[keep]=mag[keep]
  nearby=np.zeros_like(ok)
  for dy,dx in offsets:nearby|=np.roll(strong,(dy,dx),(0,1))
  edge=ns&(strong|(weak&nearby))
  if f<4:assert 0<np.count_nonzero(nms)<np.count_nonzero(mag),('width thinning',f)
  if f<8:assert edge[8,9],('eight neighbors',f)
  if f in (8,11,12):assert not edge.any(),('weak rejection/frame leak',f)
  if f==9:assert edge.sum()==2 and edge[8,4] and edge[8,5] and not edge[8,6]
  if f==5:assert not nms.any(),'constant plateau strict-side suppression'
  with (directory/f'window_{f}.hex').open('w') as out:
   for yy in range(h):
    for xx in range(w):
     inp=(int(ok[yy,xx])<<16)|(int(strong[yy,xx])<<15)|(int(weak[yy,xx])<<14)|(int(dirs[yy,xx])<<12)|int(mag[yy,xx])
     exp=(int(ns[yy,xx])<<14)|(int(nms[yy,xx])<<2)|(int(ns[yy,xx])<<1)|int(edge[yy,xx])
     out.write(f'{(exp<<17)|inp:011x}\n')
  stats.append(dict(frame=f,nms_nonzero=int(np.count_nonzero(nms)),input_nonzero=int(np.count_nonzero(mag)),edges=int(edge.sum())))
 return stats
