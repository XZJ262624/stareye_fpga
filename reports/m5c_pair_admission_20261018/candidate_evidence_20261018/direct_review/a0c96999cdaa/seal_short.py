from pathlib import Path
import json,hashlib,importlib.util
R=Path.cwd();D=R/'reports/m5c_pair_admission_20261018/implementation'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
runs=['lifecycle_160429','queue_160619','queue_v2_160916','queue_mutant_160747','edges_161040','edges_v2_161319','edges_v3_161620','highsid_161341','sameedge_match_161124']
checks=[];paths=set()
for n in runs:
 d=D/n;v=json.loads((d/'RESULT.json').read_text());inputs=json.loads((d/'INPUTS.json').read_text());mismatch=[]
 for x in inputs:
  p=Path(x['path']);b=p.read_bytes();assert len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==x['sha256'],p;paths.add(p)
 for x in json.loads((d/'TOOLS.json').read_text()):
  p=Path(x['path']);assert hashlib.sha256(p.read_bytes()).hexdigest()==x['sha256']
 for step in v['steps']:
  p=Path(step['log']['path']);assert rec(p)['sha256']==step['log']['sha256']
  assert step['exit']==0
 checks.append(dict(run=n,status=v['status'],source_unchanged=v['source_unchanged'],inputs_verified=len(inputs),steps=[dict(stage=z['stage'],ok=z['ok'],exit=z['exit'],seconds=z['seconds']) for z in v['steps']]))
 for p in d.rglob('*'):
  if p.is_file() and 'work' not in p.relative_to(d).parts and p.name!='transcript':paths.add(p)
p=R/'scripts/m5c_pair_decode_pack5.py';spec=importlib.util.spec_from_file_location('trusted',p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);paths.add(p)
wires=[]
for n,c in [('lifecycle_160429',0),('lifecycle_160429',1),('queue_v2_160916',0),('edges_v2_161319',2),('edges_v3_161620',3),('edges_v3_161620',4)]:
 f=D/n/f'case{c}'/'system_uart.hex';b=bytes(int(x,16) for x in f.read_text().split());v=m.decode_pair(b,test_sizes=(1600,512,512));assert v['pair_count']==(0 if n=='lifecycle_160429' and c==1 else 1)
 if n=='lifecycle_160429' and c==1:assert v['failures'][0]['reason']==3
 wires.append(dict(run=n,case=c,sha256=hashlib.sha256(b).hexdigest(),result=v))
(D/'SOFTWARE_WIRE_FINAL.json').write_text(json.dumps(dict(decoder=rec(p),scope='parameterized real bytes; not full720p',records=wires),indent=2))
hand=dict(status='PASS_BOUNDED_LATEST_REQUEST_REPAIR_WITH_EXPLICIT_SCOPE',backend=rec(R/'rtl/m5c_pair_diag/m5c_pair_backend.sv'),runs=checks,wire=rec(D/'SOFTWARE_WIRE_FINAL.json'),positive_scopes=['normal+kill real lifecycle','stale queued SID retained latest then same-publication legitimate current complete','no request/reset','sameedge valid matching and nonmatching','same low32 different high32 through actual arm'],negative='single guard removal: compile0 unique LATEST_SID_STALE_ACQUIRE_SELECTED, raw nativeexit0 disclosed',preserved_failures=['queue highSID fullage rejection17','edges inherited highSID rejection17','reset fixture sent before mailbox source resetrelease'],limits=['control fixtures explicit eligible1 and modeled pending/release; no fullvideo','prior param0 lifecycle/negative limited before PIX eligibility','source busy intermediate frames not exhaustively enumerated','8attempt/terminal/controller pixelguards unchanged source inherited','latest observed UI SID is not instantaneous PIXseq'],next='Work activation required before fresh native build/remote V3; no Git/hardware')
(D/'SHORT_HANDBACK.json').write_text(json.dumps(hand,indent=2))
for p in D.iterdir():
 if p.is_file() and p.name!='SHORT_MANIFEST.json':paths.add(p)
paths.add(R/'rtl/m5c_pair_diag/m5c_pair_backend.sv')
(D/'SHORT_MANIFEST.json').write_text(json.dumps(dict(scope='short repair raw evidence plus exact inputs; ModelSim libraries excluded',records=[rec(p) for p in sorted(paths)]),indent=2))
print(rec(D/'SHORT_HANDBACK.json'));print(rec(D/'SHORT_MANIFEST.json'));print('records',len(paths))
