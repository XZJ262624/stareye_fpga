from pathlib import Path
import sys,json,hashlib,shutil
R=Path(__file__).resolve().parents[3]
M=Path(__file__).resolve().parent
P=M/'legacy_remaining_v1'; O=M/'legacy_remaining_tap28_v3'
assert not O.exists(); O.mkdir()
sys.path.insert(0,str(R/'scripts'))
from m5a_streaming_canny_gold import generate
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
old=R/'reports/m5b1_global_canny_i3/review_fix_264962e0/final/tap'
base=old/'generated/small'; cases=[tuple(map(int,x.split())) for x in (base/'cases.txt').read_text().splitlines()]
assert len(cases)==26
extra=[(5,96,0,6),(6,48,1,7)]
assert all(x not in cases for x in extra)
G=O/'gold28';generate(G,240,48,cases+extra)
preserved=[]
for i in range(26):
 p=base/f'frame_{i}.hex';q=G/p.name
 assert p.read_bytes()==q.read_bytes(),i
 preserved.append(dict(original=rec(p),derived=rec(q)))
assert (G/'cases.txt').read_bytes().startswith((base/'cases.txt').read_bytes())
classes=bytearray()
for i,(_,threshold,_,_) in enumerate(cases+extra):
 for line in (G/f'frame_{i}.hex').read_text().splitlines():
  v=int(line,16);nms=(v>>19)&255;good=(v>>27)&1
  c=2 if good and nms and nms>=threshold else 1 if good and nms and nms>=threshold//2 else 0
  classes.extend(f'{c}\n'.encode())
oldclasses=(old/'small_classes.hex').read_bytes()
assert classes[:len(oldclasses)]==oldclasses
(O/'classes28.hex').write_bytes(classes)
allcases=json.loads((P/'CASES.json').read_text()); remaining=allcases[8:];checks=[]
for c in remaining:
 args=c['args']; ds=[x[5:] for x in args if x.startswith('+DIR=')]
 if ds and Path(ds[0])==base:
  c['args']=[x for x in args if not x.startswith(('+DIR=','+TAP_FILE=','-gFRAMES='))]+['-gFRAMES=28','+DIR='+str(G),'+TAP_FILE='+str(O/'classes28.hex')]
  c['gold']=[str(p.relative_to(R)).replace('\\','/') for p in [G/'cases.txt',*sorted(G.glob('frame_*.hex')),O/'classes28.hex']]
 if c['top']=='tb_m5c1b_capture_identity' and not any(x=='-gTAG_DIRECT=1' for x in c['args']):
  par=dict(WIDTH=240,HEIGHT=48,FRAMES=28)
  for a in c['args']:
   if a.startswith('-g'):
    k,v=a[2:].split('=');par[k]=int(v)
  d=Path(next(x[5:] for x in c['args'] if x.startswith('+DIR=')))
  t=Path(next(x[10:] for x in c['args'] if x.startswith('+TAP_FILE=')))
  n=len((d/'cases.txt').read_text().splitlines()); assert n==par['FRAMES'],(c['name'],n,par)
  pixels=par['WIDTH']*par['HEIGHT'];assert len(t.read_text().splitlines())==pixels*n
  assert all(len((d/f'frame_{i}.hex').read_text().splitlines())==pixels for i in range(n))
  checks.append(dict(case=c['name'],parameters=par,frames=n,class_values=pixels*n))
(O/'CASES.json').write_text(json.dumps(remaining,indent=2))
runner=(P/'run_cases_v2.py').read_text();(O/'run_cases_v3.py').write_text(runner)
(O/'DERIVATION.json').write_text(json.dumps(dict(status='PRECHECK_PASS_NOT_SIMULATED',parent=[rec(P/'CASES.json'),rec(P/'run_cases_v2.py'),rec(P/'TAP_SMALL_FAILURE_RECEIPT_0947.json'),rec(R/'scripts/m5a_streaming_canny_gold.py'),rec(Path(__file__))],added_cases=extra,original26_preserved=preserved,original_classes=rec(old/'small_classes.hex'),new_classes=rec(O/'classes28.hex'),prechecks=checks,targets=[c['name'] for c in remaining],boundary='Only new gold and runner inputs; original 26 images/case prefix/class prefix byte identical. Independent software array reference generated 2 distinct cases. No RTL/TB edits or prior engine reruns.'),indent=2))
print(O, 'targets',len(remaining),'tap_prechecks',len(checks))
