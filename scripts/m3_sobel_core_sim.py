"""Actual HDL simulation, independent spatial golden model, and negative tests."""
from pathlib import Path
import argparse,subprocess,json,random,sys,copy,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
REPORT=ROOT/'reports/m3_sobel_core_i3/sim'
TB=ROOT/'tb/m3_sobel_core'; MODELSIM=Path('E:/Modelsim_10.1c/win64')
FIELDS='cycle rst lb_valid win_valid p00 p01 p02 p10 p11 p12 p20 p21 p22 gradient_valid gx gy mag_valid abs_gx abs_gy magnitude mag_gray out_valid edge_gray binary de hs vs display x y cx cy'.split()
def run(command,log):
    with log.open('wb') as f: p=subprocess.run([str(x) for x in command],cwd=TB,stdout=f,stderr=subprocess.STDOUT)
    if p.returncode: raise RuntimeError(f'command exit {p.returncode}: {log}')
    if re.search(r'\*\* (?:Fatal|Error):',log.read_text(errors='replace')):
        raise RuntimeError('HDL simulator error: '+str(log))
    return p.returncode
def compile_hdl():
    TB.mkdir(parents=True,exist_ok=True); REPORT.mkdir(parents=True,exist_ok=True)
    if not (TB/'work').exists(): run([MODELSIM/'vlib.exe','work'],REPORT/'vlib.log')
    run([MODELSIM/'vlog.exe','-sv','-work','work',*sorted((ROOT/'rtl/m3_sobel_core').glob('*.v')),TB/'tb_stream.sv'],REPORT/'vlog.log')
def sobel(p):
    # Signed unbounded Python integers and explicit 2-D kernels, no RTL shifts.
    kx=[[-1,0,1],[-2,0,2],[-1,0,1]]; ky=[[1,2,1],[0,0,0],[-1,-2,-1]]
    gx=sum(p[r*3+c]*kx[r][c] for r in range(3) for c in range(3))
    gy=sum(p[r*3+c]*ky[r][c] for r in range(3) for c in range(3))
    mag=abs(gx)+abs(gy)
    return dict(gx=gx,gy=gy,abs_gx=abs(gx),abs_gy=abs(gy),magnitude=mag,mag_gray=min(mag,255))
def stimuli(width,height,corners=False):
    rng=random.Random(3103); a=[]; labels=[]
    def tick(r=1,v=0,d=0,h=1,s=1,f=0,g=0,t=64,m=2): a.append([r,v,d,h,s,f,g,t,m])
    def reset():
        for _ in range(3): tick(r=0)
        for _ in range(3): tick()
    def frame(name,pixels,stalls=False,blank=True):
        labels.append({'name':name,'start':len(a),'pixels':width*height})
        tick(f=1,s=0)
        for y in range(height):
            if blank:
                tick(h=0);tick(h=0)
            for x in range(width):
                if stalls and rng.randrange(4)==0:
                    for _ in range(rng.randrange(1,4)): tick(d=1,g=231,t=rng.randrange(256),m=rng.randrange(4))
                i=y*width+x
                phase=i+len(labels)-1
                tick(v=1,d=1,g=pixels[i],t=[0,64,255,(i*37)%256][phase%4],m=phase%4)
            if blank: tick()
    reset()
    if corners:
        for n in range(512): frame('corner_'+str(n),[255*((n>>i)&1) for i in range(9)],blank=False)
        for n in range(128): frame('random_window_'+str(n),[rng.randrange(256) for _ in range(9)],blank=False)
    else:
        patterns={
          'ramp':[y*width+x for y in range(height) for x in range(width)],
          'black':[0]*(width*height),'white':[255]*(width*height),
          'vertical':[255*(x>=width//2) for y in range(height) for x in range(width)],
          'horizontal':[255*(y>=height//2) for y in range(height) for x in range(width)],
          'diagonal':[255*(x>=y) for y in range(height) for x in range(width)],
          'impulse':[255*(x==width//2 and y==height//2) for y in range(height) for x in range(width)],
          'last_pixel':[255*(x==width-1 and y==height-1) for y in range(height) for x in range(width)],
          'random':[rng.randrange(256) for _ in range(width*height)]}
        for name,p in patterns.items(): frame(name,p,stalls=True)
        frame('consecutive_a',patterns['white'],blank=False);frame('consecutive_b',patterns['black'],blank=False)
        tick(f=1,s=0)
        for i in range(width*3+3): tick(v=1,d=1,g=(i*13)%256)
        # Async reset while a write/window is pending, then active midframe data
        # before next SOF. The algorithm must discard these pixels.
        tick(r=0,v=1,d=1,g=255)
        for i in range(width*3): tick(v=1,d=1,g=255)
        frame('reset_recovery',patterns['random'],stalls=True)
    for _ in range(12): tick()
    return a,labels
def golden(stim,width,height):
    events={}; expected=[]; release=0; armed=False; pixels=[]
    def event(c): return events.setdefault(c,{})
    for c,(rst,valid,de,hs,vs,sof,gray,threshold,mode) in enumerate(stim):
        ready=release>=2 and bool(rst)
        if not rst: release=0
        else: release=min(2,release+1)
        if not ready:
            events.clear();armed=False;pixels=[]
            e=dict(lb_valid=0,win_valid=0,gradient_valid=0,mag_valid=0,out_valid=0,edge_gray=0,binary=0,de=0,hs=1,vs=1,display=0,cx=0,cy=0)
        else:
            e=dict(lb_valid=0,win_valid=0,gradient_valid=0,mag_valid=0,out_valid=0,edge_gray=0,binary=0,de=0,hs=1,vs=1,display=0,cx=0,cy=0)
            future=event(c+4);future.update(de=de,hs=hs,vs=vs,display=gray if de and mode==0 else 0)
            if sof: armed=True;pixels=[]
            elif valid and armed:
                x=len(pixels)%width; y=len(pixels)//width; pixels.append(gray)
                e['lb_valid']=1
                if x>=2 and y>=2:
                    p=[pixels[(y-2+r)*width+x-2+col] for r in range(3) for col in range(3)]
                    event(c+1).update(win_valid=1,**dict(zip(FIELDS[4:13],p)))
                    calc=sobel(p)
                    event(c+2).update(gradient_valid=1,gx=calc['gx'],gy=calc['gy'])
                    event(c+3).update(mag_valid=1,**{k:calc[k] for k in ('abs_gx','abs_gy','magnitude','mag_gray')})
                    edge=calc['mag_gray'];binary=int(edge>=threshold)
                    future.update(out_valid=1,edge_gray=edge,binary=binary,x=x,y=y,cx=x-1,cy=y-1)
                    future['display']=0 if not de else gray if mode==0 else edge if mode==1 else 255*binary
                if len(pixels)==width*height: armed=False
            e.update(events.pop(c,{}))
        # Internal release output changes at this edge; processing used its OLD value.
        e['rst']=int(release>=2);e['cycle']=c;expected.append(e)
    return expected
def read_observed(path):
    result=[]
    for line in path.read_text().splitlines():
        values=line.split()
        if len(values)!=len(FIELDS): raise ValueError('observed column count')
        result.append(dict(zip(FIELDS,[int(v) if v.lstrip('-').isdigit() else v for v in values])))
    return result
def compare(expected,actual):
    if len(expected)!=len(actual): raise ValueError(f'cycle count {len(actual)} != {len(expected)}')
    for i,(e,a) in enumerate(zip(expected,actual)):
        for k,v in e.items():
            if a[k]!=v: raise ValueError(f'cycle {i} {k}: actual {a[k]} expected {v}')
def negative_checks(expected,actual):
    result=[]
    for label,key,predicate in [('data','edge_gray',lambda x:x['out_valid']),('sync','hs',lambda x:True),('coord','cx',lambda x:x['out_valid']),('window','p11',lambda x:x['win_valid']),('gradient','gx',lambda x:x['gradient_valid']),('valid','out_valid',lambda x:x['out_valid'])]:
        bad=copy.deepcopy(actual);i=next(i for i,v in enumerate(actual) if predicate(v));bad[i][key]=int(bad[i][key])+1
        try: compare(expected,bad)
        except ValueError as exc: result.append({'case':label,'rejected':True,'reason':str(exc)})
        else: raise RuntimeError('negative case accepted: '+label)
    badgold=copy.deepcopy(expected);i=next(i for i,v in enumerate(expected) if v['out_valid']);badgold[i]['binary']^=1
    try: compare(badgold,actual)
    except ValueError as exc: result.append({'case':'corrupt_golden','rejected':True,'reason':str(exc)})
    else: raise RuntimeError('corrupt golden accepted')
    try: compare(expected,actual[:-1])
    except ValueError as exc: result.append({'case':'truncated','rejected':True,'reason':str(exc)})
    else: raise RuntimeError('truncation accepted')
    return result
def main():
    compile_hdl();summary=[]
    for name,w,h,corners in [('stream',9,7,False),('minimum_corners',3,3,True)]:
        stim,labels=stimuli(w,h,corners);gold=golden(stim,w,h)
        sf=REPORT/(name+'_stim.txt');of=REPORT/(name+'_observed.txt')
        sf.write_text(''.join(' '.join(map(str,x))+'\n' for x in stim))
        (REPORT/(name+'_golden.json')).write_text(json.dumps(gold,separators=(',',':')))
        (REPORT/(name+'_cases.json')).write_text(json.dumps(labels,indent=2))
        command=[MODELSIM/'vsim.exe','-c','-novopt','work.tb_stream',f'-gWIDTH={w}',f'-gHEIGHT={h}',f'+STIM={sf.as_posix()}',f'+OBS={of.as_posix()}']
        if name=='stream': command.append(f'+WAVE={(REPORT/(name+".vcd")).as_posix()}')
        command+=['-do','onerror {quit -f -code 1}; onbreak {quit -f -code 1}; run -all; quit -f -code 0']
        run(command,REPORT/(name+'.log'))
        actual=read_observed(of);compare(gold,actual)
        negative=negative_checks(gold,actual)
        # A real child CLI must reject corrupt on-disk observation data with exit 1.
        corrupt=REPORT/(name+'_corrupt_observed.txt')
        rows=of.read_text().splitlines();v=rows[0].split();v[25]='0' if v[25]=='1' else '1';rows[0]=' '.join(v)
        corrupt.write_text('\n'.join(rows)+'\n')
        proc=subprocess.run([sys.executable,'-B',__file__,'--compare',str(REPORT/(name+'_golden.json')),str(corrupt)],capture_output=True,text=True)
        if proc.returncode!=1: raise RuntimeError('corrupt observation CLI did not fail')
        negative.append({'case':'corrupt_observation_cli','exit_code':proc.returncode,'reason':proc.stdout.strip(),'rejected':True})
        summary.append({'case':name,'width':w,'height':h,'cycles':len(stim),'valid_windows':sum(e['out_valid'] for e in gold),'negative_tests':negative,'pass':True})
    (REPORT/'summary.json').write_text(json.dumps(summary,indent=2));print('M3_SIM_PASS',json.dumps(summary))
if __name__=='__main__':
    try:
        if len(sys.argv)>1 and sys.argv[1]=='--compare':
            compare(json.loads(Path(sys.argv[2]).read_text()),read_observed(Path(sys.argv[3])))
            print('M3_COMPARE_PASS')
        else: main()
    except Exception as e: print('M3_SIM_FAIL',e);sys.exit(1)
