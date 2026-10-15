from pathlib import Path
import json,hashlib,re,sys
R=Path(__file__).resolve().parents[1]
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
for arg in sys.argv[1:]:
 d=Path(arg); result=json.loads((d/'RESULT.json').read_text()); inputs=json.loads((d/'INPUTS.json').read_text())
 assert result['status']=='PASS_SIM_PENDING_SOFTWARE' and result['inputs_unchanged']
 assert len(result['steps'])==3 and all(s['exit']==0 and not s['timeout'] for s in result['steps'])
 for s in result['steps']:
  assert rec(Path(s['log']['path']))==s['log']
  assert not re.search(r'\*\* (?:Fatal|Error):',Path(s['log']['path']).read_text(errors='replace'))
 for x in inputs:
  b=(d/'snapshots'/Path(x['path']).name).read_bytes()
  assert len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==x['sha256']
 log=(d/'sim.log').read_text(errors='replace'); markers=re.findall(r'DIAG_BACKEND_SLOT_PASS ([^\r\n]+)',log);assert len(markers)==1
 fields={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',markers[0])};case=fields['case']
 if case==4:assert fields==dict(case=4,cold_cancel=1,original_fault_report_done=1)
 else:
  period=1000000 if case==1 else 3000000 if case==3 else 1500000
  active=case in (0,3)
  assert fields==dict(case=case,cycles=period+32,duration=675542 if active else 0,oldtake=2 if case==3 else 1,requests=1,accepted=1,starts=int(active),done=int(active))
 out=dict(status='PASS_BACKEND_SLOT_DIFFERENTIAL_ONLY',case=case,observed=fields,input_snapshots_verified=len(inputs),scope='Actual backend enabled/disabled edge comparison and transport scheduling; no completed DDR publication or fusion-reader recovery claim; wire CRC proven separately by coupled tests.',bindings=[rec(d/n) for n in ['RESULT.json','INPUTS.json','sim.log','OWNER_2.json']]+[rec(Path(__file__))])
 (d/'SOFTWARE_ORACLE.json').write_text(json.dumps(out,indent=2));print(d.name,out['status'])
