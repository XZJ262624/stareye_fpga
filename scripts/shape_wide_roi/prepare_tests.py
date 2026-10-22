from common import *
import importlib.util
oracle=R/'reports/shape_wider_roi_noise_20261022/assess.py';spec=importlib.util.spec_from_file_location('independent_geometry',oracle);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
T=R/'tb/shape_wide_roi';T.mkdir(exist_ok=True);D=O/'test_data';D.mkdir(exist_ok=True);cases=[]
def add(name,points,fault=0,cap=-1,last=False):
 c,features=m.classify(points);valid=bool(points)
 if points:
  l,t,r,b=m.bbox(points);valid=l>=16 and r<=943 and t>=16 and b<=523
 if fault in (1,2,3,4,5,6,8,11):c=0;valid=False
 rows=[0]*540
 for x,y in points:rows[y]|=1<<x
 p=D/f'edge_{len(cases):03}.hex';p.write_text(''.join(f'{r:0240x}\n' for r in rows))
 cases.append(dict(id=len(cases),name=name,truth_class=c,expected_valid=valid,fault=fault,expected_cap_count=cap,check_last_row=last,features=features,input=rec(p)))
for size in (79,80,280,281,384,385,439,440,441):add(f'rect_size_{size}',m.edge(m.filled('rect',size,size)))
for size in (80,280,440):add(f'circle_size_{size}',m.edge(m.filled('circle',size,size)))
for name,(cx,cy) in [('left_valid',(56,270)),('left_invalid',(55,270)),('right_valid',(904,270)),('right_invalid',(905,270)),('top_valid',(480,56)),('top_invalid',(480,55)),('bottom_valid',(480,484)),('bottom_invalid',(480,485))]:add(name,m.edge(m.filled('rect',80,80,cx,cy)))
for kind in ('triangle','ring','text','ellipse'):add(kind,m.edge(m.filled(kind,200,140 if kind=='ellipse' else 200)))
add('double',m.edge(m.filled('circle',100,100,400,270))|m.edge(m.filled('circle',100,100,560,270)))
for count in (7,8,14):
 p=set();h=440;k=7;y0=50;x0=260;positions=list(range(k))+list(range(h-k,h));fragment=set(positions[:count])
 for r in range(h):
  rw=(h*m.chord(min(63,(r*64+32)//h))+128)//256;l=x0+(h-rw)//2
  p.update([(l,y0+r),(l+rw-1,y0+r)])
  if r in fragment:p.add((l+rw//2,y0+r))
 add(f'cap440_{count}',p,cap=count)
# Outside accepted target domain, but valid ROI interior:16 outer fragments
# saturate safely at15 (greater than the largest analysis cap_limit).
p=set();h=500;k=8;y0=20;x0=230
for r in range(h):
 rw=(h*m.chord(min(63,(r*64+32)//h))+128)//256;l=x0+(h-rw)//2;p.update([(l,y0+r),(l+rw-1,y0+r)])
 if r<k or r>=h-k:p.add((l+rw//2,y0+r))
add('cap_saturation15',p,cap=15)
add('roi_last_pixel',{(959,539)},last=True);add('blank',set())
for fault in (1,2,3,4,5,6,7,8,11):add('lifecycle_fault_'+str(fault),m.edge(m.filled('rect',160,160)),fault)
add('recovery_circle',m.edge(m.filled('circle',160,160)))
save(O/'TEST_CASES.json',dict(count=len(cases),oracle=rec(oracle),cases=cases,scope='Targeted ideal edge RTL cases; original upstream pixel chain unchanged, not rerun all datasets'))
(D/'expected.hex').write_text(''.join(f'{c["truth_class"]:x}\n' for c in cases));(D/'valid.hex').write_text(''.join(f'{int(c["expected_valid"]):x}\n' for c in cases));(D/'fault.hex').write_text(''.join(f'{c["fault"]:x}\n' for c in cases));(D/'cap.hex').write_text(''.join(f'{c["expected_cap_count"]&255:02x}\n' for c in cases));(D/'last.hex').write_text(''.join(f'{int(c["check_last_row"]):x}\n' for c in cases));print('TARGETED_CASES_READY',len(cases))
