import hashlib,json,sys
from pathlib import Path
R=Path(__file__).resolve().parents[2]; D=Path(__file__).resolve().parent
sys.path.insert(0,str(R/'scripts'))
from m5c_pair_decode_pack5 import decode_pair
def ident(p):
 b=p.read_bytes();return dict(path=str(p.relative_to(R)).replace('\\','/'),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
cases=[('fixed_repro_230536',0,0,[23]),('early_deadline_230731',0,0,[23]),('windows_231101',0,0,[23]),('windows_231101',1,0,[23]),('inflight_deadline_v3_231239',0,1,[]),('inflight_deadline_v5_232054',1,0,[3,23]),('deadline_backpressure_v2_232428',0,1,[])]
out=[]
for run,case,pairs,reasons in cases:
 p=D/run/f'case{case}'/'system_uart.hex';raw=bytes.fromhex(p.read_text());v=decode_pair(raw,test_sizes=(1600,512,512))
 assert v['pair_count']==pairs,(run,v)
 actual=[x['reason'] for x in v['failures']];assert actual==reasons,(run,actual)
 result=json.loads((D/run/'RESULT.json').read_text());step=next(x for x in result['steps'] if x['stage']==f'case{case}')
 assert step['ok'] and step['exit']==0 and result['source_unchanged']
 out.append(dict(run=run,case=case,input=ident(p),result=v,native=step))
(D/'SHORT_WIRE_CHECK.json').write_text(json.dumps(dict(status='PASS_PARAMETERIZED_REAL_WIRE',decoder=ident(R/'scripts/m5c_pair_decode_pack5.py'),cases=out),indent=2)+'\n')
files=[]
for p in sorted(D.rglob('*')):
 if not p.is_file() or 'work' in p.parts or p.suffix.lower() in ('.wlf','.dbs','.dat') or p.name=='SHORT_MANIFEST.json':continue
 if p.name in ('_info','_lib.qdb','_lib1_0.qdb','_vmake'):continue
 if p.suffix.lower() in ('.py','.sv','.json','.log','.hex','.md','.do'):files.append(ident(p))
(D/'SHORT_MANIFEST.json').write_text(json.dumps(dict(records=files,count=len(files),bytes=sum(x['bytes'] for x in files)),indent=2)+'\n')
print('PASS',len(out),'wire cases;',len(files),'sealed files')
