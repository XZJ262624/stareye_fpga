"""Reproducible synthetic coverage and exact accelerated scan accounting."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import random
import time
from models import bfs_gold, raster_literal, raster_event, jacobi_literal, pack, unpack, burst_plan


def pattern(name, w, h):
    c = bytearray(w*h)
    if name == 'single_strong': c[(h//2)*w+w//2] = 2
    elif name in ('short_chain','long_chain'):
        for x in range(min(w, 8) if name == 'short_chain' else w): c[w*(h//2)+x] = 1
        c[w*(h//2)] = 2
    elif name in ('all_strong','all_weak','all_zero'):
        c[:] = bytes([{'all_strong':2,'all_weak':1,'all_zero':0}[name]]) * len(c)
    elif name == 'disconnected':
        for y in range(1,h-1):
            for x in range(1,w-1):
                if x < w//3 or x > 2*w//3: c[y*w+x]=1
        c[w+1] = 2
    elif name == 'diagonal':
        for i in range(min(w,h)): c[i*w+i]=1
        c[0]=2
    elif name == 'ring':
        for x in range(1,w-1): c[w+x]=c[(h-2)*w+x]=1
        for y in range(1,h-1): c[y*w+1]=c[y*w+w-2]=1
        c[w+1]=2
    elif name == 'tree':
        for y in range(h):
            c[y*w+w//2]=1
            if y%4==1:
                for x in range(1,w-1): c[y*w+x]=1
        c[w//2]=2
    elif name in ('snake','snake_vertical'):
        # Horizontal tracks every second row; alternating endpoint connectors.
        # BFS accounts for true 8-neighbor corner shortcuts, never assumes 4-neighbor length.
        if name=='snake':
            for y in range(0,h,2):
                c[y*w:(y+1)*w]=bytes([1])*w
                if y+2<h: c[(y+1)*w+(w-1 if (y//2)%2==0 else 0)]=1
        else:
            for x in range(0,w,2):
                for y in range(h): c[y*w+x]=1
                if x+2<w: c[(h-1 if (x//2)%2==0 else 0)*w+x+1]=1
        c[0]=2
    elif name == 'checkerboard':
        for y in range(h):
            for x in range(w):
                if (x+y)%2==0: c[y*w+x]=1
        c[0]=2
    elif name in ('random_sparse','random_dense'):
        rng=random.Random(0x5B000 + w + h)
        density=.12 if name=='random_sparse' else .82
        for i in range(len(c)):
            r=rng.random(); c[i]=2 if r<.005 else 1 if r<density else 0
    else: raise ValueError(name)
    return c


def execute(outdir, exhaustive=True):
    outdir.mkdir(parents=True, exist_ok=True)
    results=[]; cross=0
    # All 3^9 inputs: candidate uses full eight-neighbor all-order visibility.
    population=itertools.product(range(3),repeat=9) if exhaustive else (tuple(random.Random(i).choices(range(3), k=9)) for i in range(300))
    for vals in population:
        c=bytearray(vals); gold,d,_,_=bfs_gold(c,3,3)
        a,ac=jacobi_literal(c,3,3); b,bc,bt,changes=raster_literal(c,3,3); e,ec,et=raster_event(c,3,3)
        assert a==b==e==gold and ac==max(0,d)+1 and bc==ec and bt==et
        assert changes==[et.count(s) for s in range(1,ec+1)]
        cross+=1
    names=['single_strong','short_chain','long_chain','disconnected','diagonal','ring','tree','snake','snake_vertical','checkerboard','all_strong','all_weak','all_zero','random_sparse','random_dense']
    sizes=[(31,19),(1280,720)]
    for w,h in sizes:
        for name in names:
            t=time.perf_counter(); c=pattern(name,w,h)
            gold,d,visited,peak=bfs_gold(c,w,h)
            got,scans,times=raster_event(c,w,h)
            assert got==gold, (name,w,h)
            literal=w*h<1000
            if literal:
                b,bc,bt,changes=raster_literal(c,w,h)
                a,ac=jacobi_literal(c,w,h)
                assert b==a==gold and bc==scans and bt==times and ac==max(0,d)+1
            for bits,data in ((2,c),(1,got)):
                assert unpack(pack(data,bits),len(data),bits)==data
            # Last zero-change PAIR included. Capture, initialization, finalize copy.
            class_b=((w*2+127)//128)*16*h
            mask_b=((w+127)//128)*16*h
            traffic=class_b+(class_b+mask_b)+scans*(class_b+2*mask_b)+2*mask_b
            results.append(dict(name=name,width=w,height=h,pixels=w*h,strong=c.count(2),weak=c.count(1),retained=sum(gold),bfs_visited=visited,bfs_queue_peak=peak,max_weak_distance=max(0,d),jacobi_scans=max(0,d)+1,raster_scans=scans,raster_pairs=scans//2,raster_read_pixels=2*w*h*scans,raster_write_pixels=w*h*scans,class_bytes=class_b,mask_bytes=mask_b,raster_scan_bytes=class_b+2*mask_b,total_job_bytes=traffic,equals_bfs=True,literal_checked=literal,method='literal+event' if literal else 'exact event-arrival solver; Jacobi scans derived from BFS distance',input_sha256=hashlib.sha256(c).hexdigest(),output_sha256=hashlib.sha256(gold).hexdigest(),cpu_seconds=round(time.perf_counter()-t,6)))
            print(name,w,h,'scans',scans,'Jacobi',max(0,d)+1,flush=True)
    # A diagonal chain is 8-connected but NOT 4-connected. Explicitly kill regression.
    diag=bytearray([2,0,0,0,1,0,0,0,1]); assert sum(bfs_gold(diag,3,3)[0])==3
    # Invalid 11 is a whole-job error, never silently promoted/dropped.
    invalid=0
    for fn in (bfs_gold,raster_event,raster_literal,jacobi_literal):
        try: fn(bytearray([3]),1,1)
        except ValueError: invalid+=1
    assert invalid==4
    for bad in ([-1],[1.5],['1']):
        for fn in (bfs_gold,raster_event,raster_literal,jacobi_literal):
            try: fn(bad,1,1)
            except ValueError: pass
            else: raise AssertionError('invalid type/value accepted')
    for n in (16,160,320,115200,230400,921600):
        for start in (0x1000000,0x1000010,0x1000ff0):
            bursts=burst_plan(start,n)
            assert sum(k for _,k in bursts)==n
            assert all(0<k<=2048 and a//4096==(a+k-1)//4096 for a,k in bursts)
    summary=dict(status='PASS_SOFTWARE_ONLY',exhaustive_3x3=cross,cases=results,full_frame_cases=sum(r['pixels']==921600 for r in results),invalid_class_rejected=invalid,real_scene_frames=0,hardware_cycles_measured=False)
    (outdir/'MODEL_RESULTS.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
    lines=['# 软件实验结果','',f'软件PASS；穷举3×3分类图{cross}张，完整720p合成图15张。没有真实分类帧，没有硬件周期/吞吐率实测。','', '| pattern | shape | weak | retained | Jacobi扫描 | 双向扫描/双向轮 | 方法 |','|---|---|---:|---:|---:|---:|---|']
    for r in results:
        lines.append(f"|{r['name']}|{r['width']}×{r['height']}|{r['weak']}|{r['retained']}|{r['jacobi_scans']}|{r['raster_scans']}/{r['raster_pairs']}|{'literal+事件等价' if r['literal_checked'] else '事件精确推导'}|")
    lines+=['','每项逐像素等于独立坐标BFS。小图同时逐像素、逐激活扫描号验证literal与事件加速等价；Jacobi扫描数=最大最短弱路径距离+1，含最终无变化确认扫描。双向轮含最终两次无变化扫描。软件CPU耗时仅记录于JSON，不能当作FPGA耗时。','蛇形每隔一行空白、交替端点连通，八邻域允许拐角对角捷径；实际距离由独立BFS计算，不套四邻域长度。全帧并非逐像素×数十万扫描暴力执行。','随机图seed固定；合成稀疏/密集图不能替代真实M5A分类的分布、阈值及运动统计。']
    (outdir/'SOFTWARE_RESULTS.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    return summary

if __name__=='__main__':
    p=argparse.ArgumentParser(); p.add_argument('--output',type=Path,default=Path(__file__).parent); p.add_argument('--quick',action='store_true'); a=p.parse_args(); execute(a.output,not a.quick)
