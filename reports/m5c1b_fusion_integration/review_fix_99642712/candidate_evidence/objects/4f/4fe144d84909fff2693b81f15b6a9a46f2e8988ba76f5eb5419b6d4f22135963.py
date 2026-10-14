from pathlib import Path
import json,re,hashlib,collections
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
r=json.loads((A/'sta_03_connections/RESULT.json').read_text());assert r['status']=='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION' and r['exit']==0 and not r['timeout']
target=json.loads((A/'CURRENT_CONNECTION_TARGETS.json').read_text());native={}
for line in (P/'v4_pin_nets.txt').read_text().splitlines():
 k,v=line.split('\t',1);assert k not in native;native[k]=v.strip('{}')
assert set(native)==set(target['targets']);pins={x['endpoint']:x for x in json.loads((A/'full_inventory/ALL_SEQUENTIAL_INPUTS.json').read_text())['pins']};gd={g['name']:set(g['pins']) for g in json.loads((A/'EXACT_SELECTOR_GATE_V2.json').read_text())['groups']};cuts={};holdcuts={};sdc=(P/'Ti60_Demo_I3.sdc').read_text()
for line in sdc.splitlines():
 if line.startswith('set_false_path'):
  d=re.search(r'-to \$(\w+)',line)
  if d and d[1] in gd:
   for pin in gd[d[1]]:(holdcuts if '-hold' in line else cuts).setdefault(pin,[]).append(line)
rows=[];unknown=[];vendor=[];ram=[];pending=[]
allmiss=[('global_D_setup','setup',p) for p in target['global_missing']]+[(g,g.rsplit('_',1)[1],p) for g,ps in target['control_missing'].items() for p in ps]
for group,mode,pin in allmiss:
 st=pins.get(pin);net=native[pin];evidence=None
 if pin in cuts:cat='EXACT_CUT';evidence=cuts[pin]
 elif mode=='hold' and pin in holdcuts:cat='EXACT_HOLD_CUT';evidence=holdcuts[pin]
 elif net in ['gnd','vcc']:
  if st and st['classification']=='CONSTANT':cat='CURRENT_NATIVE_MAP_CONSTANT'
  elif st and st['kind']=='EFX_RAM10' and st['port'] in ['RADDR','WADDR']:cat='CURRENT_PHYSICAL_RAM_CONSTANT_LOGICAL_MAPPING_DIFFERENCE';ram.append(pin)
  elif st is None and (pin.startswith('ddr3_ctl_axi/') or pin=='dsi_resetn_o~FF|D'):cat='CURRENT_VENDOR_NATIVE_CONSTANT';vendor.append(pin)
  else:cat='UNKNOWN_CONSTANT_MAPPING_DIFFERENCE';unknown.append(pin)
 elif re.fullmatch(r'u_controls/key_meta\[[01]\]~FF\|D',pin):
  k=pin.split('[')[1][0];assert net==f'key_n[{k}]' and f'set_false_path -from [get_ports {{key_n[{k}]}}] -to $key{k}_meta_d' in sdc;cat='KEY_PI_EXACT_CUT'
 elif re.fullmatch(r'u_m5b1/fusion/reader/mult_23\|B\[[5-8]\]',pin):cat='PENDING_CURRENT_DSP_THROUGH_REPORT';pending.append(pin)
 else:cat='UNKNOWN';unknown.append(pin)
 rows.append(dict(group=group,mode=mode,pin=pin,classification=cat,native_net=net,logical=st,sdc=evidence))
p=A/'QUERY03_PRELIMINARY_CLASSIFICATION.json';assert not p.exists();p.write_text(json.dumps(dict(status='UNKNOWN_BLOCKED' if unknown else 'TYPED_CLASSIFIED_PENDING_RAM_CONFIG_DSP_THROUGH_FULLAUDIT',counts=dict(collections.Counter(x['classification'] for x in rows)),unknown=sorted(set(unknown)),vendor_current=sorted(set(vendor)),RAM_differences=sorted(set(ram)),DSP_pending=sorted(set(pending)),native_count=len(native),rows=rows,native=rec(P/'v4_pin_nets.txt'),map=rec(P/'outflow/Ti60_Demo.map.v'),targets=rec(A/'CURRENT_CONNECTION_TARGETS.json')),indent=2));print('unknown',len(set(unknown)),'vendor',len(set(vendor)),'ram',len(set(ram)),'DSPpending',len(set(pending)))
