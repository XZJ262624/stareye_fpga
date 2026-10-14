"""Independent spatial fusion and protocol/byte oracles; no HDL imports."""
from collections import deque
import hashlib,json,sys,zlib
from pathlib import Path
import numpy as np
sys.dont_write_bytecode=True
from m5a_streaming_canny_gold import spatial,image,support
ROOT=Path(__file__).resolve().parents[1]

def bfs(c):
    h,w=c.shape; out=c==2; q=deque(map(int,np.flatnonzero(out)))
    while q:
        y,x=divmod(q.popleft(),w)
        for yy in range(max(0,y-1),min(h,y+2)):
            for xx in range(max(0,x-1),min(w,x+2)):
                if c[yy,xx]==1 and not out[yy,xx]:
                    out[yy,xx]=True;q.append(yy*w+xx)
    return out

def fuse(c,ref,historical,local,valid_support,eligible=True,rows_ready=None):
    good=np.all((c==ref)&(c<3)&(ref<3),axis=1)
    if rows_ready is None:rows_ready=np.ones(c.shape[0],bool)
    # Missing reference poisons this and subsequent rows; mere mismatch does not.
    ready=np.logical_and.accumulate(rows_ready)
    added=eligible & good[:,None] & ready[:,None] & (c==1) & historical & valid_support & ~local
    return local|added,added

def eligible(seq,tick,source_seq,source_tick,config,source_config):
    return config==source_config and 0<=seq-source_seq<=120 and 0<=tick-source_tick<=148500000

def signature(generation,high=64,low=32,median=True):
    return (generation<<96)|(1<<88)|(1<<80)|(1280<<68)|(720<<56)|(high<<48)|(low<<40)|(int(median)<<39)|((3 if median else 2)<<36)|(1<<28)

def pack_classes(c):
    flat=c.ravel();assert len(flat)%4==0
    return bytes((flat[0::4]|(flat[1::4]<<2)|(flat[2::4]<<4)|(flat[3::4]<<6)).tolist())

def rec(p):
    b=p.read_bytes();return {'path':p.relative_to(ROOT).as_posix(),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}

def generate(out):
    out=out.resolve()
    out.mkdir(parents=True,exist_ok=False)
    raw=image(1280,720,11); s=spatial(raw,1,64)
    c=np.where(s['strong'],2,np.where(s['weak'],1,0)).astype(np.uint8)
    hist=bfs(c);valid=support(1280,720,3)
    fused,added=fuse(c,c,hist,s['canny'].astype(bool),valid)
    assert added.sum()>0
    changed=c.copy();changed[360,-1]=(int(changed[360,-1])+1)%3
    assert not fuse(changed,c,hist,s['canny'].astype(bool),valid)[1][360].any()
    illegal=c.copy();illegal[360,:]=3
    assert not fuse(illegal,illegal,hist,s['canny'].astype(bool),valid)[1][360].any()
    rows=np.ones(720,bool);rows[10]=False
    assert not fuse(c,c,hist,s['canny'].astype(bool),valid,rows_ready=rows)[1][10:].any()
    conf=signature(1)
    for frames in (119,120,121):assert eligible(frames,0,0,0,conf,conf)==(frames<=120)
    for ticks in (148499999,148500000,148500001):assert eligible(0,ticks,0,0,conf,conf)==(ticks<=148500000)
    assert not eligible(0,0,1,0,conf,conf)
    assert not eligible(0,0,0,1,conf,conf)
    assert not eligible(1,1,0,0,signature(3),signature(1))
    # Repeated/skipped camera IDs cannot rejuvenate a reference: no source-ID age arithmetic.
    replay=[7,7,7,91,91,2]
    assert all(eligible(i,i*1237500,0,0,conf,conf) for i,_ in enumerate(replay))
    assert not eligible(121,121*1237500,0,0,conf,conf)
    ref=np.zeros((9,9),np.uint8);ref[2:7,4]=1;ref[2,4]=2
    cur=ref.copy();cur[2,4]=0
    assert fuse(cur,ref,bfs(ref),cur==2,np.ones_like(ref,bool))[1][5,4] and not bfs(cur)[5,4]
    words=s['raw'].astype(np.uint64)
    for key,shift in [('legacy_mag',8),('legacy_bin',16),('support',17),('overlay',18),('nms_support',27),('canny_support',28),('canny',29)]:
        words|=s[key].astype(np.uint64)<<np.uint64(shift)
    words|=np.minimum(s['nms'],255).astype(np.uint64)<<np.uint64(19)
    words|=c.astype(np.uint64)<<np.uint64(30)
    words|=hist.astype(np.uint64)<<np.uint64(32)
    words|=added.astype(np.uint64)<<np.uint64(33)
    np.savetxt(out/'pixels.hex',words.ravel(),fmt='%09x')
    (out/'class.bin').write_bytes(pack_classes(c))
    (out/'mask.bin').write_bytes(np.packbits(hist.ravel(),bitorder='little').tobytes())
    (out/'raw.bin').write_bytes(raw.astype(np.uint8).tobytes())
    result={'status':'PASS_GOLDEN_FROZEN_BEFORE_HDL_CHANGES','pixels':921600,'promotions_per_healthy_frame':int(added.sum()),'healthy_frames_required':60,
            'sources':[rec(Path(__file__)),rec(ROOT/'scripts/m5a_streaming_canny_gold.py')],
            'files':[rec(p) for p in sorted(out.iterdir())], 'historical_counterexample_proved':True,
            'byte_crc32':{p.name:f'{zlib.crc32(p.read_bytes()):08x}' for p in out.glob('*.bin')}}
    (out/'GOLDEN_FREEZE.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('status','pixels','promotions_per_healthy_frame')}),flush=True)
if __name__=='__main__':generate(Path(sys.argv[1]))
