"""Independent row-geometry arithmetic; no RTL, numpy or simulator imports."""
import math
def classify(rows):
    points=[(y,x) for y,row in enumerate(rows) for x in range(512) if row>>x&1]
    if not points:return 0,False,{'reason':'blank'}
    ymin=min(y for y,x in points);ymax=max(y for y,x in points);xmin=min(x for y,x in points);xmax=max(x for y,x in points)
    w=xmax-xmin+1;h=ymax-ymin+1;valid=xmin>=16 and xmax<=495 and ymin>=16 and ymax<=367
    if not valid or not(80<=w<=280 and 80<=h<=280):return 0,valid,{'reason':'domain','bbox':[xmin,ymin,w,h]}
    ref=[x for x in range(512) if rows[ymin+h//2]>>x&1];rw_ref=ref[-1]-ref[0]+1 if ref else 0
    middle=[];bars=[];bad=False;circle_bad=False
    for y in range(ymin,ymax+1):
        p=[x for x in range(512) if rows[y]>>x&1];r=y-ymin
        if not p:bad=True;continue
        segments=1+sum(b-a>=4 for a,b in zip(p,p[1:]));rw=p[-1]-p[0]+1
        circle_bad|=segments>2
        if h<=r*10<h*9 and (segments>2 or abs(p[-1]+p[0]-xmin-xmax)>16):bad=True
        density=min(7,(len(p)*8+rw//2)//rw);bars.append((r,h-1-r,rw*density//8))
        if h<=r*10<h*9:
            b=min(63,(r*64+32)//h);chord=math.floor(256*math.sqrt(1-((b+.5)/32-1)**2)+.5)
            middle.append((abs(rw-rw_ref),abs(rw-(w*chord+128)//256)))
    n=len(middle)
    rect=n>0 and sum(e<=3 or e*100<=rw_ref*4 for e,_ in middle)*10>=n*9 and sum(v for r,_,v in bars if r*10<h)*4>=rw_ref*3 and sum(v for _,r,v in bars if r*10<h)*4>=rw_ref*3 and w*2>=h and h*2>=w
    circle=not circle_bad and n>0 and sum(e*10<=w for _,e in middle)*10>=n*9 and sum(e for _,e in middle)*100<=n*w*6 and h*90<=w*100<=h*110
    return (0 if bad or rect==circle else 2 if rect else 1),valid,dict(bbox=[xmin,ymin,w,h],rect=rect,circle=circle,contour_bad=bad)

def read_edges(path):
    lines=path.read_text().splitlines();assert len(lines)==384 and all(len(x)==128 for x in lines)
    return [int(s,16) for s in lines]

def gold_edges(path):
    rows=[0]*384;count=0
    with path.open() as f:
        for i,line in enumerate(f):
            y,x=divmod(i,1280);v=int(line,16);count+=1
            if 168<=y<552 and 384<=x<896 and v>>29&1:rows[y-168]|=1<<(x-384)
    assert count==921600
    return rows
