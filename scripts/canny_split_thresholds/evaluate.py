"""Offline dual-threshold feasibility study. Standard library only.

The image-coordinate oracle never imports RTL state. Labels are geometric
boundaries of the CLEAN input, with a fixed Chebyshev radius of two pixels.
Static reference=current is deliberately retained: persistent sensor/texture
noise is not removed by row matching. Independent temporal noise is also tested.
This script does NOT implement or qualify a new production FPGA design.
"""
from pathlib import Path
from array import array
from collections import deque, defaultdict
from datetime import datetime, timezone
import csv, hashlib, importlib.util, json, math, random, struct, time, zlib

R = Path(__file__).resolve().parents[2]
O = R / 'reports/canny_split_thresholds_20261022'
START = time.time()

def save(name, value):
    p = O / name
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf8')

def sha(data):
    return hashlib.sha256(data).hexdigest()

def rec(p):
    return dict(path=p.relative_to(R).as_posix(), bytes=p.stat().st_size, sha256=sha(p.read_bytes()))

def beat(phase, **kw):
    now = datetime.now(timezone.utc).isoformat()
    save('HEARTBEAT.json', dict(status='RUNNING', running=True, phase=phase,
         updated_unix=time.time(), updated_utc=now, elapsed_seconds=time.time()-START, **kw))
    save('PHASE_RESULT.json', dict(status='RUNNING', running=True, phase=phase, **kw))
    save('NOTIFICATION_CONTEXT.json', dict(job='canny-split-thresholds', codex_checked_utc=now,
         codex_observation='GPT-6 Astra ultra / supported Fast priority 正在阶段1离线量化评估；没有新RTL或BIT',
         hardware_next='否。先评估，若实施也必须停用户独立A审查。'))

def png(path, w, h, rgb):
    def chunk(t, b):
        return struct.pack('>I', len(b))+t+b+struct.pack('>I', zlib.crc32(t+b)&0xffffffff)
    raw = b''.join(b'\0'+rgb[y*w*3:(y+1)*w*3] for y in range(h))
    path.write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR', struct.pack('>IIBBBBB',w,h,8,2,0,0,0))+
                     chunk(b'IDAT', zlib.compress(raw,6))+chunk(b'IEND',b''))

def interior(w,h,r):
    b=bytearray(w*h)
    for y in range(r,h-r): b[y*w+r:y*w+w-r]=b'\1'*(w-2*r)
    return b

def dilate(a,w,h,r):
    b=bytearray(w*h)
    for i,v in enumerate(a):
        if v:
            y,x=divmod(i,w)
            lo,hi=max(0,x-r),min(w,x+r+1)
            for yy in range(max(0,y-r),min(h,y+r+1)):b[yy*w+lo:yy*w+hi]=b'\1'*(hi-lo)
    return b

def frontend(a,w,h):
    """GAU round(+8)/16, L1 Sobel, integer 53/128 direction, asymmetric NMS."""
    n=w*h;b=bytearray(n);mag=array('H',[0])*n;dire=bytearray(n);nm=array('H',[0])*n
    for y in range(1,h-1):
        for x in range(1,w-1):
            i=y*w+x
            b[i]=(a[i-w-1]+2*a[i-w]+a[i-w+1]+2*a[i-1]+4*a[i]+2*a[i+1]+a[i+w-1]+2*a[i+w]+a[i+w+1]+8)//16
    for y in range(2,h-2):
        for x in range(2,w-2):
            i=y*w+x
            gx=-b[i-w-1]+b[i-w+1]-2*b[i-1]+2*b[i+1]-b[i+w-1]+b[i+w+1]
            gy=b[i-w-1]+2*b[i-w]+b[i-w+1]-b[i+w-1]-2*b[i+w]-b[i+w+1]
            ax,ay=abs(gx),abs(gy);mag[i]=ax+ay
            dire[i]=0 if ay*128<=ax*53 else 2 if ax*128<=ay*53 else 1 if gx*gy>=0 else 3
    ds=((-1,1),(-w+1,w-1),(-w,w),(-w-1,w+1))
    for y in range(3,h-3):
        for x in range(3,w-3):
            i=y*w+x;p,q=ds[dire[i]]
            if mag[i]>mag[i+p] and mag[i]>=mag[i+q]:nm[i]=mag[i]
    return nm

def classify(nm,hi):
    lo=hi//2
    return bytearray(2 if v and v>=hi else 1 if v and v>=lo else 0 for v in nm)

def local(cls,w,h):
    z=bytearray(w*h);ds=(-w-1,-w,-w+1,-1,1,w-1,w,w+1)
    for y in range(4,h-4):
        for x in range(4,w-4):
            i=y*w+x
            z[i]=cls[i]==2 or cls[i]==1 and any(cls[i+d]==2 for d in ds)
    return z

def bfs(cls,w,h):
    """Independent full eight-connected flood fill; never limited to one hop."""
    out=bytearray(v==2 for v in cls);q=deque(i for i,v in enumerate(out) if v)
    while q:
        i=q.popleft();y,x=divmod(i,w)
        for dy in (-1,0,1):
            yy=y+dy
            if not 0<=yy<h:continue
            for dx in (-1,0,1):
                xx=x+dx
                if not 0<=xx<w or (dx==0 and dy==0):continue
                j=yy*w+xx
                if cls[j] and not out[j]:out[j]=1;q.append(j)
    return out

def fusion(cur,ref,glob,loc,w,h,candidate):
    # Valid identity/config/TTL, coordinates, complete rows and source qualifiers
    # are shared preconditions. Only equality of the appropriate global class
    # and adoption of new global-strong pixels differs in the candidate model.
    rows=[cur[y*w:(y+1)*w]==ref[y*w:(y+1)*w] for y in range(h)]
    out=bytearray(w*h)
    for y in range(3,h-3):
        if rows[y]:
            for x in range(3,w-3):
                i=y*w+x;eligible=cur[i] in (1,2) if candidate else cur[i]==1
                out[i]=not loc[i] and eligible and glob[i]
    return out,rows

FAMILIES=('connected_weak_line','independent_faint_line','broken_branch','text_strokes',
          'flat','isolated_spots','weak_noise_chain','fine_texture')
NOISES=(('none',0),('gaussian',1),('gaussian',2),('gaussian',4),('gaussian',8),('salt_pepper',0.001))

def scene(name,w,h):
    a=bytearray([96])*(w*h);target=bytearray(w*h);nuisance=bytearray(w*h)
    x0=w//3;ya=h//6;yb=5*h//6;width=3
    def rect(x1,y1,x2,y2,c,kind='target'):
        for y in range(y1,y2):
            for x in range(x1,x2):
                i=y*w+x;a[i]=96+c
                if kind=='target':target[i]=1
                else:nuisance[i]=1
    if name=='connected_weak_line':
        for y in range(ya,yb):
            c=32 if y<ya+(yb-ya)//5 else 18 if y<ya+(yb-ya)*2//5 else 10 if y<ya+(yb-ya)*3//5 else 14
            rect(x0,y,x0+width,y+1,c)
    elif name=='independent_faint_line':rect(x0,ya,x0+width,yb,18)
    elif name=='broken_branch':
        rect(x0,ya,x0+width,yb,14);rect(x0,ya,x0+width,ya+8,32)
        rect(x0,h//2,w*2//3,h//2+3,10)
        # Genuine geometric gap must not be labelled as an intended continuation.
        for y in range(h*2//3,h*2//3+3):
            for x in range(x0,x0+width):a[y*w+x]=96;target[y*w+x]=0
    elif name=='text_strokes':
        rect(x0,ya,x0+width,yb,18)
        for y in (ya,h//2,yb-3):rect(x0,y,w*2//3,y+3,18)
        rect(x0,ya,x0+width,ya+5,32)
    elif name=='isolated_spots':
        # Persistent low-amplitude defects: no target edges.
        for y in range(12,h-12,19):
            for x in range(12,w-12,23):rect(x,y,x+1,y+1,64,'noise')
    elif name=='weak_noise_chain':
        # Sensor/background structure deliberately includes a near-H48 seed
        # and a weaker continuation; no intended object edge.
        for y in range(ya,yb):rect(x0,y,x0+3,y+1,18 if y<ya+6 else 10,'noise')
    elif name=='fine_texture':
        for x in range(10,w-10,9):rect(x,10,x+2,h-10,16,'noise')
    elif name!='flat':raise ValueError(name)
    # Geometric clean target boundary, independent of Sobel/NMS thresholds.
    label=bytearray(w*h)
    for y in range(4,h-4):
        for x in range(4,w-4):
            i=y*w+x
            if any(target[i]!=target[j] for j in (i-1,i+1,i-w,i+w)):label[i]=1
    return a,label,nuisance,dict(background=96,stroke_width=3,x=x0,y_start=ya,y_stop=yb,
                               contrasts={'connected_weak_line':[32,18,10,14],'independent_faint_line':[18],
                               'broken_branch':[32,14,10],'text_strokes':[32,18],'flat':[],
                               'isolated_spots':[64],'weak_noise_chain':[18,10],'fine_texture':[16]}[name])

def add_noise(a,kind,amount,seed):
    if kind=='none':return a[:],bytearray(len(a))
    rng=random.Random(seed);b=bytearray(a);changed=bytearray(len(a))
    if kind=='gaussian':
        for i,v in enumerate(a):
            b[i]=min(255,max(0,round(v+rng.gauss(0,amount))));changed[i]=b[i]!=v
    else:
        for i in range(len(a)):
            if rng.random()<amount:b[i]=0 if rng.getrandbits(1) else 255;changed[i]=1
    return b,changed

def union(a,b):return bytearray(bool(x or y) for x,y in zip(a,b))
def difference(a,b):return bytearray(bool(x and not y) for x,y in zip(a,b))
def count_in(a,b):return sum(bool(x and y) for x,y in zip(a,b))
def total_metrics(edge,label,band,w,h):
    hits=dilate(edge,w,h,2)
    return dict(edge_pixels=sum(edge),target_label_pixels=sum(label),target_label_hits=count_in(hits,label),
                edge_in_target_band=count_in(edge,band),edge_outside_target_band=sum(edge)-count_in(edge,band))

def line_continuity(edge,w,h,p,family):
    if family not in ('connected_weak_line','independent_faint_line'):return None
    rows=[];x=p['x']
    for y in range(p['y_start']+3,p['y_stop']-3):
        rows.append(any(edge[yy*w+xx] for yy in range(y-2,y+3) for xx in range(x-3,x+2)))
    run=longest=0
    for hit in rows:
        run=0 if hit else run+1;longest=max(longest,run)
    return dict(sampled_rows=len(rows),hit_rows=sum(rows),longest_missing_run_rows=longest)

def panel(case,a,loc,pa,pb,label,w,h):
    # Six analytic panels: input, fixed local, baseline fused, candidate fused,
    # candidate-only additions (green=clean band, magenta=outside), label band.
    band=dilate(label,w,h,2);out=bytearray(w*h*6*3);both=[loc,union(loc,pa),union(loc,pb)]
    for y in range(h):
        for x in range(w):
            i=y*w+x;colors=[(a[i],)*3]
            for e in both:colors.append((255,255,255) if e[i] else (0,0,0))
            colors.append(((0,255,100) if band[i] else (255,0,180)) if pb[i] and not pa[i] else (0,0,0))
            colors.append((90,90,90) if band[i] else (0,0,0))
            for j,c in enumerate(colors):
                p=(y*w*6+j*w+x)*3;out[p:p+3]=bytes(c)
    path=O/'visuals'/f'{case}.png';path.parent.mkdir(exist_ok=True);png(path,w*6,h,out)

def run_case(family,w,h,kind,amount,seed,clean_cache,visual=False):
    key=(family,w,h)
    if key not in clean_cache:
        clean,label,nuisance,p=scene(family,w,h);cnm=frontend(clean,w,h)
        cc64=classify(cnm,64);cc48=classify(cnm,48);clocal=local(cc64,w,h)
        cg64=bfs(cc64,w,h);cg48=bfs(cc48,w,h)
        cp64,_=fusion(cc64,cc64,cg64,clocal,w,h,False);cp48,_=fusion(cc48,cc48,cg48,clocal,w,h,True)
        clean_cache[key]=(clean,label,nuisance,p,cnm,cc64,cc48,clocal,cg64,cg48,cp64,cp48)
    clean,label,nuisance,p,cnm,cc64,cc48,clocal,cg64,cg48,cp64,cp48=clean_cache[key]
    a,noise=add_noise(clean,kind,amount,seed);nm=cnm if kind=='none' else frontend(a,w,h)
    c64=classify(nm,64);c48=classify(nm,48)
    la=local(c64,w,h);lb=local(classify(nm,64),w,h);assert la==lb
    g64=bfs(c64,w,h);g48=bfs(c48,w,h)
    assert all(not a or b for a,b in zip(g64,g48))
    p64,rows64=fusion(c64,c64,g64,la,w,h,False);p48,rows48=fusion(c48,c48,g48,lb,w,h,True)
    fa=union(la,p64);fb=union(lb,p48);gain=difference(fb,fa);lost=difference(fa,fb)
    band=dilate(label,w,h,2);cgain=difference(union(clocal,cp48),union(clocal,cp64))
    changed_near=dilate(noise,w,h,3);nuisance_band=dilate(nuisance,w,h,3)
    ea=total_metrics(fa,label,band,w,h);eb=total_metrics(fb,label,band,w,h)
    case=f'{w}x{h}_{family}_{kind}{amount}_seed{seed}'
    result=dict(case=case,family=family,width=w,height=h,pixels=w*h,noise_kind=kind,noise_amount=amount,seed=seed,
        reference_seed=seed,temporal_mode='same_frame_static',parameters=p,
        input_sha256=sha(a),clean_input_sha256=sha(clean),label_sha256=sha(label),
        nms_sha256=sha(nm.tobytes()),local_a_sha256=sha(la),local_b_sha256=sha(lb),local_equal=True,
        local_edges=sum(la),global64_edges=sum(g64),global48_edges=sum(g48),
        global64_extra_over_local=sum(difference(g64,la)),global48_extra_over_local=sum(difference(g48,la)),
        baseline_promoted=sum(p64),candidate_promoted=sum(p48),
        new_strong48_63=sum(48<=v<=63 for v in nm),new_weak24_31=sum(24<=v<=31 for v in nm),
        added_pixels=sum(gain),lost_pixels=sum(lost),added_in_band=count_in(gain,band),
        added_outside_band=sum(gain)-count_in(gain,band),
        added_matching_clean_gain=count_in(gain,cgain),
        added_matching_clean_gain_in_band=sum(g and c and b for g,c,b in zip(gain,cgain,band)),
        added_in_band_not_clean_gain=sum(g and b and not c for g,b,c in zip(gain,band,cgain)),
        added_near_changed_noise=count_in(gain,changed_near),added_near_nuisance=count_in(gain,nuisance_band),
        added_new_strong48_63=sum(g and 48<=v<=63 for g,v in zip(gain,nm)),
        added_new_weak24_31=sum(g and 24<=v<=31 for g,v in zip(gain,nm)),
        added_old_weak32_47=sum(g and 32<=v<=47 for g,v in zip(gain,nm)),
        added_border_radius3=sum(g and (i%w in (3,w-4) or i//w in (3,h-4)) for i,g in enumerate(gain)),
        baseline=ea,candidate=eb,
        baseline_continuity=line_continuity(fa,w,h,p,family),candidate_continuity=line_continuity(fb,w,h,p,family))
    # Do not call all band-contained pixels true positives: report these exact
    # clean-location matches separately, with the remaining band pixels unknown.
    result['added_outside_band_per_million']=result['added_outside_band']*1e6/(w*h)
    oldfp=ea['edge_outside_target_band'];newfp=eb['edge_outside_target_band']
    result['false_positive_relative_increase']=None if oldfp==0 else (newfp-oldfp)/oldfp
    if kind!='none':
        ref,_=add_noise(clean,kind,amount,seed+1000003);rnm=frontend(ref,w,h)
        rc64=classify(rnm,64);rc48=classify(rnm,48)
        rg64=bfs(rc64,w,h);rg48=bfs(rc48,w,h)
        dp64,dr64=fusion(c64,rc64,rg64,la,w,h,False);dp48,dr48=fusion(c48,rc48,rg48,lb,w,h,True)
        dfa=union(la,dp64);dfb=union(lb,dp48);dgain=difference(dfb,dfa);dlost=difference(dfa,dfb)
        result['independent_reference']=dict(reference_seed=seed+1000003,baseline_equal_rows=sum(dr64),
            candidate_equal_rows=sum(dr48),baseline_promoted=sum(dp64),candidate_promoted=sum(dp48),
            added_pixels=sum(dgain),lost_pixels=sum(dlost),added_outside_band=sum(dgain)-count_in(dgain,band),
            baseline=total_metrics(dfa,label,band,w,h),candidate=total_metrics(dfb,label,band,w,h))
    if visual:panel(case,a,la,p64,p48,label,w,h)
    return result

def self_checks():
    # Compare integer oracle and local output against the existing independently
    # written parent image oracle at every pixel for GAU, including boundaries.
    p=R/'scripts/canny_gaussian_standalone/gold.py'
    spec=importlib.util.spec_from_file_location('parent_gold',p);parent=importlib.util.module_from_spec(spec);spec.loader.exec_module(parent)
    checks=[]
    for seed in (1,7,104):
        w,h=40,32;rng=random.Random(seed);a=bytearray(rng.randrange(256) for _ in range(w*h))
        nm=frontend(a,w,h);cl=classify(nm,64);le=local(cl,w,h)
        words,edges=parent.spatial(list(a),w,h,2,64,6)
        assert list(le)==edges
        assert all(cl[i]==((v>>92)&3) for i,v in enumerate(words))
        assert all(min(nm[i],255)==((v>>19)&255) for i,v in enumerate(words))
        checks.append(dict(seed=seed,pixels=w*h,local_exact=True,class_exact=True,nms_display_exact=True))
    values=[0,23,24,31,32,47,48,63,64]
    assert list(classify(values,64))==[0,0,0,0,1,1,1,1,2]
    assert list(classify(values,48))==[0,0,1,1,1,1,2,2,2]
    # Independent classification-graph witness of new strong seed + weak chain.
    w,h=32,16;nm=array('H',[0])*(w*h)
    for x in range(5,26):nm[8*w+x]=48 if x==5 else 24
    c64,c48=classify(nm,64),classify(nm,48);g64,g48=bfs(c64,w,h),bfs(c48,w,h)
    assert sum(g64)==0 and sum(g48)==21
    save('ORACLE_SELF_CHECK.json',dict(status='PASS',parent_oracle=rec(p),cases=checks,
        threshold_values=values,local_classes=list(classify(values,64)),global_classes=list(classify(values,48)),
        explicit_new_seed_weak_chain=dict(baseline_edges=0,candidate_edges=21),
        limitation='Software spatial cross-check, not new RTL simulation or hardware qualification.'))

def main():
    O.mkdir(exist_ok=True);beat('ORACLE_AND_LABEL_SELF_CHECK');self_checks()
    specs=[]
    for family in FAMILIES:
        for kind,amount in NOISES:
            for seed in ((101,) if kind=='none' else (101,202)):
                specs.append((family,160,96,kind,amount,seed))
    specs += [('connected_weak_line',1280,720,'none',0,101),
              ('independent_faint_line',1280,720,'gaussian',2,101),
              ('flat',1280,720,'gaussian',4,101),('flat',1280,720,'gaussian',8,101),
              ('isolated_spots',1280,720,'none',0,101)]
    save('EVALUATION_PLAN.json',dict(created_utc=datetime.now(timezone.utc).isoformat(),
         baseline_head='433a83e543cb40a52128d1eea4ae32ce83aecd16',local_high=64,local_low=32,
         baseline_global_high=64,baseline_global_low=32,candidate_global_high=48,candidate_global_low=24,
         tolerance_metric='Chebyshev',tolerance_pixels=2,label='Clean target geometric 4-neighbor boundary; nuisance excluded',
         cases=[dict(family=f,width=w,height=h,noise_kind=k,amount=a,seed=s) for f,w,h,k,a,s in specs],
         qualification='Software whole-row appropriate-global-class equality + supported coordinates, valid matching metadata assumed; no transport/TTL implementation claim',
         static_noise='reference=current exactly, representing persistent noise/worst admitted stability',
         temporal_noise='independent reference seed=seed+1000003, same clean object',
         scoring='Band inclusion is only potential target association; exact clean-gain locations and noisy-only band additions reported separately',
         code=rec(Path(__file__))))
    cache={};results=[]
    for j,spec in enumerate(specs):
        f,w,h,k,a,s=spec
        beat('SCENE_EVALUATION',case=j+1,total=len(specs),current=list(spec))
        v=run_case(*spec,cache,visual=(w==160 and s==101 and k in ('none','gaussian') and a in (0,4,8)))
        results.append(v);save('EVALUATION_COUNTS.partial.json',results)
        print(json.dumps(dict(index=j+1,total=len(specs),case=v['case'],added=v['added_pixels'],outside=v['added_outside_band'],
                             target_hits=[v['baseline']['target_label_hits'],v['candidate']['target_label_hits']]),ensure_ascii=False),flush=True)
    save('EVALUATION_COUNTS.json',results)
    fields=['case','family','width','height','noise_kind','noise_amount','seed','local_edges','global64_edges','global48_edges',
            'baseline_promoted','candidate_promoted','added_pixels','lost_pixels','added_in_band','added_outside_band',
            'added_outside_band_per_million','false_positive_relative_increase','added_matching_clean_gain_in_band',
            'added_in_band_not_clean_gain','added_new_strong48_63','added_new_weak24_31','added_old_weak32_47']
    with (O/'EVALUATION_COUNTS.csv').open('w',newline='',encoding='utf8') as fp:
        wr=csv.DictWriter(fp,fieldnames=fields,extrasaction='ignore');wr.writeheader();wr.writerows(results)
    summary=dict(status='EVALUATION_COUNTS_COMPLETE_PENDING_ANALYSIS',cases=len(results),small=sum(v['width']==160 for v in results),
                 full720p=sum(v['width']==1280 for v in results),local_exact_cases=sum(v['local_equal'] for v in results),
                 duration_seconds=time.time()-START,production_rtl_written=False,bit_generated=False)
    save('EVALUATION_RUN_RESULT.json',summary);beat('EVALUATION_COUNTS_COMPLETE_PENDING_ANALYSIS',summary=summary)
    print(json.dumps(summary),flush=True)

if __name__=='__main__':main()
