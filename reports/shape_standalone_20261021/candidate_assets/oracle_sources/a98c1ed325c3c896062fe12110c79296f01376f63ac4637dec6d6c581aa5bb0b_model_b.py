"""Independent integer geometry model B; no RTL/simulator result imports."""
import math

def chord_value(b):
    n=16*(4096-(2*b+1-64)**2);r=math.isqrt(n)
    return r+int((2*r+1)**2<=4*n)

def cap_veto(rows,width,height):
    k=(height+63)//64;count=0;bad=[]
    for row in rows:
        if row['segments']<=2:continue
        r=row['r'];outer=r<k or height-1-r<k
        if not outer:bad.append('FRAGMENT_OUTSIDE_OUTERMOST_BAND');continue
        count=min(7,count+1)
        if row['center_error']>16:bad.append('CAP_CENTER')
        if (row['row_width']-row['expected_width'])*10>width:bad.append('CAP_WIDTH_UPPER')
    if count>k:bad.append('CAP_ROW_BUDGET')
    return not bad,dict(limit=k,count=count,reasons=sorted(set(bad)))

def classify(rows):
    points=[(y,x) for y,row in enumerate(rows) for x in range(512) if row>>x&1]
    if not points:return 0,False,dict(reason='blank')
    xmin=min(x for y,x in points);xmax=max(x for y,x in points);ymin=min(y for y,x in points);ymax=max(y for y,x in points)
    w=xmax-xmin+1;h=ymax-ymin+1;valid=xmin>=16 and xmax<=495 and ymin>=16 and ymax<=367
    if not valid or not (80<=w<=280 and 80<=h<=280):return 0,valid,dict(reason='domain',bbox=[xmin,ymin,w,h])
    scan=[[x for x in range(512) if rows[y]>>x&1] for y in range(ymin,ymax+1)]
    ref=scan[h//2];rw_ref=ref[-1]-ref[0]+1 if ref else 0
    middle=[];bars=[];bad=False;features=[]
    for r,p in enumerate(scan):
        if not p:bad=True;continue
        segments=1+sum(b-a>=4 for a,b in zip(p,p[1:]));rw=p[-1]-p[0]+1;center=abs(p[-1]+p[0]-xmin-xmax)
        b=min(63,(r*64+32)//h);expected=(w*chord_value(b)+128)//256
        features.append(dict(r=r,segments=segments,row_width=rw,expected_width=expected,center_error=center))
        if h<=r*10<h*9 and (segments>2 or center>16):bad=True
        density=min(7,(len(p)*8+rw//2)//rw);bars.append((r,h-1-r,rw*density//8))
        if h<=r*10<h*9:middle.append((abs(rw-rw_ref),abs(rw-expected)))
    n=len(middle)
    rect=n>0 and sum(e<=3 or e*100<=rw_ref*4 for e,_ in middle)*10>=n*9 and sum(v for r,_,v in bars if r*10<h)*4>=rw_ref*3 and sum(v for _,r,v in bars if r*10<h)*4>=rw_ref*3 and w*2>=h and h*2>=w
    cap_ok,cap=cap_veto(features,w,h)
    circle=cap_ok and n>0 and sum(e*10<=w for _,e in middle)*10>=n*9 and sum(e for _,e in middle)*100<=n*w*6 and h*90<=w*100<=h*110
    return (0 if bad or rect==circle else 2 if rect else 1),valid,dict(bbox=[xmin,ymin,w,h],rect=rect,circle=circle,contour_bad=bad,cap=cap,fragment_rows=[r for r in features if r['segments']>2],middle_rows=n,circle_chord_good=sum(e*10<=w for _,e in middle),circle_error=sum(e for _,e in middle))
