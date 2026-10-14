from pathlib import Path
import json,re,hashlib,collections
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
for n in ['06_backend_cleanup_controls','07_backend_connections']:
 r=json.loads((A/('sta_'+n)/'RESULT.json').read_text());assert r['status']=='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION' and r['exit']==0 and not r['timeout'] and r['source_db_unchanged']
sets=json.loads((A/'BACKEND_CONTROL_TARGETS.json').read_text())['sets'];expected=json.loads((A/'BACKEND_MISSING_TARGETS.json').read_text());native={}
for line in (P/'backend_pin_nets.txt').read_text().splitlines():
 k,v=line.split('\t',1);assert k not in native;native[k]=v.strip('{}')
assert set(native)==set(expected['targets'])
struct=json.loads((A/'full_inventory/ALL_SEQUENTIAL_INPUTS.json').read_text());assert struct['map_sha256']==hashlib.sha256((P/'outflow/Ti60_Demo.map.v').read_bytes()).hexdigest();pins={x['endpoint']:x for x in struct['pins']};gd={g['name']:set(g['pins']) for g in json.loads((A/'EXACT_SELECTOR_GATE_V2.json').read_text())['groups']};cuts={};holdcuts={}
for line in (P/'Ti60_Demo_I3.sdc').read_text().splitlines():
 if line.startswith('set_false_path'):
  d=re.search(r'-to \$(\w+)',line)
  if d and d[1] in gd:
   for pin in gd[d[1]]:(holdcuts if '-hold' in line else cuts).setdefault(pin,[]).append(line)
results=[]
for group,values in sets.items():
 for mode in ['setup','hold']:
  p=P/('outflow/all_D_setup.rpt' if group=='D' and mode=='setup' else f'outflow/backend_{group}_{mode}.rpt');s=p.read_text();assert re.search(r'Timing Model\s*:\s*I3',s);end=re.findall(r'^Path End\s*:\s*(\S+)',s,re.M);slacks=[float(v) for v in re.findall(r'^Slack\s*:\s*([+-]?[0-9.]+)',s,re.M)];assert len(end)==len(set(end))==len(slacks) and min(slacks)>=0
  actual=set(end)&set(values);missing=[]
  for pin in sorted(set(values)-actual):
   st=pins[pin];net=native[pin]
   if pin in cuts:cat='EXACT_CURRENT_CUT';evidence=cuts[pin]
   elif mode=='hold' and pin in holdcuts:cat='EXACT_CURRENT_HOLD_CUT';evidence=holdcuts[pin]
   elif st['classification']=='CONSTANT' and net in ['gnd','vcc']:cat='CURRENT_NATIVE_AND_MAP_CONSTANT';evidence=st
   else:raise AssertionError(('UNCLASSIFIED_BACKEND_PIN',pin,mode,net,st))
   missing.append(dict(pin=pin,classification=cat,native_net=net,evidence=evidence))
  assert len(actual)+len(missing)==len(values);results.append(dict(group=group,mode=mode,expected=len(values),reported=len(actual),minimum_report_slack=min(slacks),missing=missing,report=rec(p)))
p=A/'BACKEND_CONTROL_TIMING_AUDIT.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_CURRENT_BACKEND6808FF_D_CE_SR_PHYSICAL_COVERAGE',groups=results,native_connections=rec(P/'backend_pin_nets.txt'),targets=rec(A/'BACKEND_CONTROL_TARGETS.json'),source=rec(R/'rtl/m5c_fusion/m5b1_backend.sv'),scope='Every mapped backend FF, fullstate/owned/exported/lease/identity/token/transfer/packet/capture/engine; currentI3 only, no hardware/PVT claim.'),indent=2));print([(x['group'],x['mode'],x['reported'],len(x['missing'])) for x in results])
