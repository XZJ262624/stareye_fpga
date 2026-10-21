"""Image-coordinate integer convolution oracle; no pipeline/RTL state imports."""
def spatial(a,w,h,f,hi,mode=6):
 n=w*h;zero=lambda:[0]*n;b=a[:] if f==0 else zero();r=1 if f==0 else 2
 if f==2:
  # Two separable *integer sums*, rounded only once after the full 2-D sum.
  horizontal=zero()
  for y in range(h):
   row=y*w
   for x in range(1,w-1):i=row+x;horizontal[i]=a[i-1]+2*a[i]+a[i+1]
  for y in range(1,h-1):
   row=y*w
   for x in range(1,w-1):i=row+x;b[i]=(horizontal[i-w]+2*horizontal[i]+horizontal[i+w]+8)//16
 elif f==1:
  for y in range(1,h-1):
   for x in range(1,w-1):i=y*w+x;b[i]=sorted([a[i-w-1],a[i-w],a[i-w+1],a[i-1],a[i],a[i+1],a[i+w-1],a[i+w],a[i+w+1]])[4]
 mag=zero();direction=zero();grad=zero();ns=zero();nm=zero();support=zero();edge=zero();strong=zero();weak=zero();classes=zero()
 for y in range(r,h-r):
  for x in range(r,w-r):
   i=y*w+x;gx=-b[i-w-1]+b[i-w+1]-2*b[i-1]+2*b[i+1]-b[i+w-1]+b[i+w+1];gy=b[i-w-1]+2*b[i-w]+b[i-w+1]-b[i+w-1]-2*b[i+w]-b[i+w+1];ax=abs(gx);ay=abs(gy);mag[i]=ax+ay;grad[i]=1;direction[i]=0 if ay*128<=ax*53 else 2 if ax*128<=ay*53 else 1 if gx*gy>=0 else 3
 offsets=[(-1,1),(-w+1,w-1),(-w,w),(-w-1,w+1)]
 for y in range(r+1,h-r-1):
  for x in range(r+1,w-r-1):
   i=y*w+x;ns[i]=1;p,q=offsets[direction[i]]
   if mag[i]>mag[i+p] and mag[i]>=mag[i+q]:nm[i]=mag[i]
   strong[i]=int(nm[i]>0 and nm[i]>=hi);weak[i]=int(nm[i]>0 and hi//2<=nm[i]<hi);classes[i]=2 if strong[i] else 1 if weak[i] else 0
 for y in range(r+2,h-r-2):
  for x in range(r+2,w-r-2):
   i=y*w+x;support[i]=1;edge[i]=int(strong[i] or weak[i] and (strong[i-w-1] or strong[i-w] or strong[i-w+1] or strong[i-1] or strong[i+1] or strong[i+w-1] or strong[i+w] or strong[i+w+1]))
 words=[]
 for y in range(h):
  for x in range(w):
   i=y*w+x;j=i-w-1;lm=min(255,mag[j]) if x and y else 0;lb=int(bool(x and y and grad[j] and lm>=hi));ov=int(grad[i] and mag[i]>=hi);ng=min(nm[i],255)
   rgb=[a[i]*0x010101,lm*0x010101,lb*0xffffff,0xff0000 if ov else a[i]*0x010101,ng*0x010101,edge[i]*0xffffff,0xff0000 if edge[i] else a[i]*0x010101][mode]
   words.append(a[i]|lm<<8|lb<<16|grad[i]<<17|ov<<18|ng<<19|ns[i]<<27|support[i]<<28|edge[i]<<29|mag[i]<<30|direction[i]<<42|rgb<<44|classes[i]<<92|b[i]<<94)
 return words,edge
