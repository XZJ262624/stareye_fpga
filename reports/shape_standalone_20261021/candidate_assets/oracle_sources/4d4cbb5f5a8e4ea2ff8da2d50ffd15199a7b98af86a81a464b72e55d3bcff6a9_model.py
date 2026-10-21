"""Independent geometry labels and row-feature reference; no RTL import."""
from pathlib import Path
import json, math, hashlib
import numpy as np

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'reports/shape_recognition_20261019'
Y,X=np.mgrid[0:384,0:512]

def geometry(kind,cx,cy,w,h,angle=0):
    a=math.radians(angle)
    u=(X-cx)*math.cos(a)+(Y-cy)*math.sin(a)
    v=-(X-cx)*math.sin(a)+(Y-cy)*math.cos(a)
    ellipse=(u/(w/2))**2+(v/(h/2))**2<=1
    rect=(abs(u)<w/2)&(abs(v)<h/2)
    if kind=='circle' or kind=='ellipse': return ellipse
    if kind=='rect': return rect
    if kind=='triangle':return (v>=-h/2)&(v<h/2)&(abs(u)<(v+h/2)*w/h/2)
    if kind=='ring':return ellipse & ((u/(w*.32))**2+(v/(h*.32))**2>=1)
    if kind=='double':return ((u+w*.3)**2+v*v<(w*.22)**2)|((u-w*.3)**2+v*v<(w*.22)**2)
    if kind=='text':return rect & ((abs(u+w*.3)<w*.07)|(abs(u-w*.3)<w*.07)|(abs(v)<h*.07))
    if kind=='blank':return np.zeros_like(rect)
    if kind=='truncated':return (abs(X-8)<w/2)&(abs(Y-cy)<h/2)
    if kind=='shadow':return rect & (u<(v+h/2)*.35-w*.1)
    raise ValueError(kind)

def boundary(mask):
    interior=mask.copy()
    for dy,dx in [(0,1),(0,-1),(1,0),(-1,0)]:
        interior &= np.roll(mask,(dy,dx),(0,1))
    return mask & ~interior

def classify(edge):
    yy,xx=np.nonzero(edge)
    if not len(xx):return 0,{'reason':'blank'}
    xmin,xmax,ymin,ymax=map(int,(xx.min(),xx.max(),yy.min(),yy.max()))
    w,h=xmax-xmin+1,ymax-ymin+1
    if xmin<16 or xmax>495 or ymin<16 or ymax>367 or not(80<=w<=280 and 80<=h<=280):
        return 0,{'reason':'domain','bbox':[xmin,ymin,w,h]}
    ref=np.flatnonzero(edge[ymin+h//2]);rw_ref=int(ref[-1]-ref[0]+1) if len(ref) else 0
    middle=[];bars=[];bad=False;circle_segments_bad=False
    for row in range(ymin,ymax+1):
        p=np.flatnonzero(edge[row]);r=row-ymin
        if len(p)==0:bad=True;continue
        segments=1+int(np.sum(np.diff(p)>=4))
        rw=int(p[-1]-p[0]+1)
        if segments>2:circle_segments_bad=True
        if h<=r*10<h*9 and (segments>2 or abs(int(p[-1]+p[0])-xmin-xmax)>16):bad=True
        density=min(7,(len(p)*8+rw//2)//rw)
        bars.append((r,h-1-r,(rw*density)//8))
        if h<=r*10<h*9:
            # Mathematical LUT generated independently; rounding half up.
            b=min(63,(r*64+32)//h)
            chord=math.floor(256*math.sqrt(1-((b+.5)/32-1)**2)+.5)
            expected=(w*chord+128)//256
            middle.append((abs(rw-rw_ref),abs(rw-expected)))
    n=len(middle)
    rect=n>0 and sum(e<=3 or e*100<=rw_ref*4 for e,_ in middle)*10>=n*9 and sum(b for r,_,b in bars if r*10<h)*4>=rw_ref*3 and sum(b for _,r,b in bars if r*10<h)*4>=rw_ref*3 and w*2>=h and h*2>=w
    circle=not circle_segments_bad and n>0 and sum(e*10<=w for _,e in middle)*10>=n*9 and sum(e for _,e in middle)*100<=n*w*6 and h*90<=w*100<=h*110
    c=0 if bad or rect==circle else (2 if rect else 1)
    return c,{'bbox':[xmin,ymin,w,h],'contour_bad':bad,'rect':rect,'circle':circle,'middle_rows':n}

def generate():
    OUT.mkdir(parents=True,exist_ok=True)
    data=OUT/'data';data.mkdir(exist_ok=True)
    cases=[]
    for i in range(60):
        kind='circle' if i<30 else 'rect';j=i%30
        w=[82,100,126,160,220,276][j%6]
        h=w if kind=='circle' else max(82,min(276,round(w*[1,.75,1.25][(j//6)%3])))
        cx=256+[-50,0,50][(j//2)%3];cy=192+[-24,0,24][(j//3)%3]
        angle=0 if kind=='circle' else [0,-1,1,-3,3][j//6]
        cases.append(dict(kind=kind,cx=cx,cy=cy,w=w,h=h,angle=angle,label=1 if kind=='circle' else 2))
    for kind in ['triangle','ellipse','ring','double','text','blank','truncated','shadow']:
        for j in range(5):cases.append(dict(kind=kind,cx=256,cy=192,w=140+j*20,h=(100+j*10 if kind=='ellipse' else 140+j*20),angle=0,label=0))
    # Preserve every original sample; four supplemental positives compensate
    # for original rotated 276px geometries whose measured bbox exceeded 280.
    for angle in [1,-3,3,3]:cases.append(dict(kind='rect',cx=256,cy=192,w=260,h=260,angle=angle,label=2))
    for i,c in enumerate(cases):
        mask=geometry(**{k:c[k] for k in ['kind','cx','cy','w','h','angle']})
        e=boundary(mask)
        c['id']=i;c['contrast']=[80,120,180][i%3];c['gray_noise_amplitude']=[0,1,3,5][i%4]
        c['model'],c['features']=classify(e)
        yy,xx=np.nonzero(e)
        c['valid']=int(len(xx)>0 and xx.min()>=16 and xx.max()<=495 and yy.min()>=16 and yy.max()<=367)
        c['in_domain']=bool(c['label'] and c['valid'] and 80<=xx.max()-xx.min()+1<=280 and 80<=yy.max()-yy.min()+1<=280)
        # Packed 512-bit rows, x=0 in bit0; compact but retains every ROI pixel.
        rows=[''.join(f'{b:02x}' for b in np.packbits(row,bitorder='little')[::-1]) for row in e]
        (data/f'edge_{i:03}.hex').write_text('\n'.join(rows)+'\n')
        if i in [0,12,30,42,60,70,85]:
            rng=np.random.default_rng(1701+i)
            gray=np.full((720,1280),220,dtype=np.int16)
            gray[168:552,384:896]-=mask.astype(np.int16)*c['contrast']
            a=c['gray_noise_amplitude'];gray+=rng.integers(-a,a+1,gray.shape,dtype=np.int16)
            (data/f'gray_{i:03}.hex').write_text('\n'.join(f'{v:02x}' for v in np.clip(gray,0,255).flat)+'\n')
    (data/'expected.hex').write_text('\n'.join(str(c['model']) for c in cases)+'\n')
    (data/'expected_valid.hex').write_text('\n'.join(str(c['valid']) for c in cases)+'\n')
    (OUT/'CASES.json').write_text(json.dumps(cases,indent=2)+'\n')
    pos=[c for c in cases if c['in_domain']];neg=[c for c in cases if c['label']==0]
    positive=sum(c['model']==c['label'] for c in pos);false_accept=sum(c['model']!=0 for c in neg)
    score=dict(version=3,positive_correct=positive,positive_total=len(pos),negative_false_accept=false_accept,negative_total=len(neg),out_of_domain_original_ids=[c['id'] for c in cases[:60] if not c['in_domain']],out_of_domain_accepts=[c['id'] for c in cases[:60] if not c['in_domain'] and c['model']],gate='PASS' if len(pos)>=60 and positive*100>=len(pos)*95 and false_accept==0 else 'FAIL',note='Ideal geometric boundaries only; grayscale contrast/noise affect actual pixel-chain cases, not ideal edges.')
    (OUT/'MODEL_SCORE.json').write_text(json.dumps(score,indent=2)+'\n')
    print(json.dumps(score))
    print('LUT', [math.floor(256*math.sqrt(1-((b+.5)/32-1)**2)+.5) for b in range(32)])

if __name__=='__main__':generate()
