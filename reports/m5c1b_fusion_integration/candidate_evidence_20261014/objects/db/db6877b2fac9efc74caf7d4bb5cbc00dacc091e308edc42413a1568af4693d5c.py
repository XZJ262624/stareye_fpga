from pathlib import Path
import re,json,hashlib,collections
F=Path(__file__).resolve().parent;R=F.parents[2];P=F/'mirror/efinity/m5c_fusion_i3';S=R/'reports/m5c1b_fusion_integration/selected_route_diagnostic_20261013_070000'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(name,a):
 p=F/name
 if p.exists():
  assert name in ['GLOBAL_D_COVERAGE_CURRENT.json','CONTROL_COVERAGE_CURRENT.json'] and json.loads(p.read_text())==a;return
 p.write_text(json.dumps(a,indent=2))
def parse(p):
 text=p.read_text(errors='replace');assert re.search(r'Timing Model\s*:\s*I3',text),str(p)
 rows=[]
 for block in re.split(r'\+{4} Path \d+ \+{4,}',text)[1:]:
  def val(label):
   m=re.search(r'^'+re.escape(label)+r'\s*:\s*([^\r\n]+)',block,re.M);return m[1].strip() if m else None
  def num(label):
   v=val(label);return float(v.split()[0]) if v else None
  rows.append(dict(begin=val('Path Begin'),end=val('Path End'),slack=num('Slack'),cq_data=num('+ Clock To Q + Data Path Delay'),arrival=num('End-of-path arrival time')))
 assert rows,str(p);assert all(x['slack'] is not None and x['slack']>=0 for x in rows),(str(p),min(x['slack'] for x in rows));return rows
plan=json.loads((F/'QUERY_DERIVATION.json').read_text());stages=[]
for x in plan['queries']:
 w=F/('sta_'+x['name']);r=json.loads((w/'RESULT.json').read_text());assert r['status']=='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION' and r['exit']==0 and not r['timeout'];log=(w/'tool.log').read_text(errors='replace');assert 'ACTUAL_TIMING_MODEL I3' in log and 'FRESH_QUERY_COMPLETE '+x['name'] in log;stages.append(rec(w/'RESULT.json'))
allpins={x.strip('{}') for x in (P/'selected_allpins.txt').read_text().split()};struct=json.loads((F/'full_inventory/ALL_SEQUENTIAL_INPUTS.json').read_text());pins={x['endpoint']:x for x in struct['pins']};assert len(pins)==61480
native={}
for line in (P/'v4_pin_nets.txt').read_text().splitlines():
 k,v=line.split('\t',1);assert k not in native;native[k]=v.strip('{}')
assert len(native)==1631
sdc=(P/'Ti60_Demo_I3.sdc').read_text();groups=json.loads((F/'EXACT_SELECTOR_GATE.json').read_text())['groups'];gd={g['name']:set(g['pins']) for g in groups};cuts={};holdcuts={}
for line in sdc.splitlines():
 if line.startswith('set_false_path'):
  dest=re.search(r'-to \$(\w+)',line)
  if dest and dest[1] in gd:
   for pin in gd[dest[1]]:(holdcuts if '-hold' in line else cuts).setdefault(pin,[]).append(line)
# Source-bound hardware configuration, not old diagnostic values.
raw=(P/'outflow/Ti60_Demo.map.v').read_text();i=raw.index('EFX_DSP48 \\u_m5b1/fusion/reader/mult_23 ');end=raw.index('*/ ;',i)+4;dsp=raw[i:end];assert "B_REG=1'b0" in dsp
through=[]
for bit in range(5,9):
 for mode in ['setup','hold']:
  p=P/f'outflow/v5_B{bit}_{mode}.rpt';rows=parse(p);assert all(f'u_m5b1/fusion/reader/mult_23|B[{bit}]' in b for b in re.split(r'\+{4} Path \d+ \+{4,}',p.read_text())[1:]);through.append(dict(pin=f'u_m5b1/fusion/reader/mult_23|B[{bit}]',mode=mode,count=len(rows),min_slack=min(x['slack'] for x in rows),report=rec(p)))
ram_difference={x['pin']:x for x in json.loads((F/'RAM_PHYSICAL_CONSTANT_DIFFERENCES.json').read_text())['records']};assert len(ram_difference)==36
def classify(pin,mode):
 st=pins.get(pin);net=native.get(pin)
 if pin in cuts:return dict(pin=pin,classification='EXACT_CUT',sdc=cuts[pin],structural=st,native_net=net)
 if mode=='hold' and pin in holdcuts:return dict(pin=pin,classification='EXACT_HOLD_CUT',sdc=holdcuts[pin],structural=st,native_net=net)
 if net in ['gnd','vcc']:
  if pin in ram_difference:
   ev=ram_difference[pin];assert ev['native_net']==net and ev['logical']==st and ev['primitive']=='EFX_RAM10'
   return dict(pin=pin,classification=ev['classification'],native_net=net,structural=st,mapping_evidence=ev)
  assert st is None or st['classification']=='CONSTANT',(pin,st,net)
  return dict(pin=pin,classification='NATIVE_CONSTANT',native_net=net,structural=st,vendor_or_unparsed=st is None)
 if pin in ['u_controls/key_meta[0]~FF|D','u_controls/key_meta[1]~FF|D']:
  k=pin.split('[')[1][0];assert net==f'key_n[{k}]';assert f'set_false_path -from [get_ports {{key_n[{k}]}}] -to $key{k}_meta_d' in sdc
  return dict(pin=pin,classification='KEY_PI_EXACT_CUT',native_net=net,structural=st)
 if re.fullmatch(r'u_m5b1/fusion/reader/mult_23\|B\[[5-8]\]',pin):
  assert st and st['classification']=='REGISTERED_SAME_CLOCK' and net==st['net'];ev=[x for x in through if x['pin']==pin and x['mode']==mode];assert len(ev)==1
  return dict(pin=pin,classification='DSP_B_UNREGISTERED_COMBINATIONAL_THROUGH_TIMED',structural=st,native_net=net,through=ev)
 raise AssertionError(('UNCLASSIFIED_CURRENT_MISSING',pin,mode,st,net))
# Global D expected from native pin database, actual fresh paths.
rows=parse(P/'outflow/all_D_setup.rpt');expected={p for p in allpins if p.endswith('~FF|D')};actual={x['end'] for x in rows};assert actual<=expected and len(actual)==len(rows);missing=[classify(p,'setup') for p in sorted(expected-actual)];assert len(expected)==18992 and len(rows)==18834 and len(missing)==158
put('GLOBAL_D_COVERAGE_CURRENT.json',dict(status='PASS_CURRENT_GLOBAL_D_EXPLICIT_CLASSIFICATION',expected=len(expected),reported=len(rows),missing=missing,counts=dict(collections.Counter(x['classification'] for x in missing)),report=rec(P/'outflow/all_D_setup.rpt'),native_pins=rec(P/'selected_allpins.txt')))
sets=json.loads((F/'CURRENT_SCOPED_TARGETS.json').read_text())['sets'];scoped=[]
for group,targets in sets.items():
 for mode in ['hold'] if group=='D' else ['setup','hold']:
  p=P/f'outflow/v2_{group}_{mode}.rpt';rows=parse(p);actual={x['end'] for x in rows};assert actual<=set(targets) and len(actual)==len(rows);missing=[classify(x,mode) for x in sorted(set(targets)-actual)];scoped.append(dict(group=group,mode=mode,expected=len(targets),reported=len(rows),minimum_slack=min(x['slack'] for x in rows),missing=missing,report=rec(p)))
put('CONTROL_COVERAGE_CURRENT.json',dict(status='PASS_CURRENT_SCOPED_CONTROLS',groups=scoped,native_connections=rec(P/'v4_pin_nets.txt'),dsp_configuration=dsp,dsp_through=through))
# Explicit native report marker for each hold-cut group, never blanket absence.
query=(F/'queries/01_bundle_global_Dsetup.tcl').read_text().splitlines();log=(F/'sta_01_bundle_global_Dsetup/tool.log').read_text();bundle=[]
for g in groups:
 if not g['name'].endswith('_destination'):continue
 name=g['name'];p=P/f'outflow/bundle_{name}_setup.rpt';rows=parse(p);assert set(x['end'] for x in rows)==set(g['pins']) and len(rows)==len(g['pins']);cq=[x['cq_data'] for x in rows];arr=[x['arrival'] for x in rows];assert None not in cq and max(cq)<=5 and None not in arr and max(arr)-min(arr)<=5
 idx=next(i for i,x in enumerate(query) if x.startswith('report_timing -hold ') and f'bundle_{name}_hold.rpt' in x);start=re.search(r'puts "(.*)"',query[idx-1])[1];end=re.search(r'puts "(.*)"',query[idx+1])[1];assert log.splitlines().count(start)==1 and log.splitlines().count(end)==1;ex=log.split(start+'\n',1)[1].split(end+'\n',1)[0];assert ex.count('No timing path is found')==1
 hp=P/f'outflow/bundle_{name}_hold.rpt';assert not hp.exists() or not re.search(r'\+{4} Path \d+',hp.read_text());bundle.append(dict(group=name,count=len(rows),max_cq_data=max(cq),skew=max(arr)-min(arr),hold='EXPECTED_EXACT_CUT',native_hold_marker_excerpt=ex,setup=rec(p)))
assert len(bundle)==24 and sum(x['count'] for x in bundle)==1487
put('BUNDLE_CURRENT_AUDIT.json',dict(status='PASS_CURRENT24_GROUP1487_SETUP_AND_EXACT_HOLD_CUT',groups=bundle))
# Every explicit normal/IO/clockpair report uses the actual current I3 model and has no negative slack.
normal=[]
for p in sorted((P/'outflow').glob('*.rpt')):
 if p.name.startswith(('normal_','all_D_','v2_','v5_','clock_')):
  rows=parse(p);normal.append(dict(report=rec(p),count=len(rows),minimum_slack=min(x['slack'] for x in rows)))
check=(P/'outflow/selected_check.rpt').read_text();counts={k:int(v) for k,v in re.findall(r'checking (\w+) \((\d+)\)',check)};assert counts==dict(no_clock=0,unconstrained_internal_endpoints=0,no_input_delay=7,no_output_delay=135,multiple_clock=0)
clocklog=(F/'sta_05_clock_pairs/tool.log').read_text();cp=re.findall(r'^CLOCK_PAIR (\d+) (\S+) (\S+)',clocklog,re.M);assert cp;sources={x[1] for x in cp};destinations={x[2] for x in cp};pairs={(x[1],x[2]) for x in cp};assert sources==destinations and len(pairs)==len(cp) and pairs=={(a,b) for a in sources for b in destinations};assert {int(x[0]) for x in cp}==set(range(len(cp)));nc=len(sources);assert len(cp)==nc*nc
for index,a,b in cp:
 segment=clocklog.split(f'CLOCK_PAIR {index} {a} {b}',1)[1].split('CLOCK_PAIR ',1)[0]
 for mode,j in [('setup',1),('hold',2)]:
  p=P/f'outflow/clock_{index}_{mode}.rpt'
  if not p.exists():
   ex=segment.split(f'FRESH_REPORT_BEGIN 05_clock_pairs {j}',1)[1].split(f'FRESH_REPORT_END 05_clock_pairs {j}',1)[0];assert ex.count('No timing path is found')==1,(index,mode)
put('TIMING_CURRENT_AUDIT.json',dict(status='PASS_ACTUAL_FRESH_I3_PENDING_FINAL_ARCHIVE_PROTECTION_SEAL',query_stages=stages,resource=json.loads((F/'route/RESULT.json').read_text())['resources'],setup_min=min(x['slack'] for x in parse(P/'outflow/normal_setup.rpt')),hold_min=min(x['slack'] for x in parse(P/'outflow/normal_hold.rpt')),bundled24_dest1487_max=max(x['max_cq_data'] for x in bundle),bundled_skew_max=max(x['skew'] for x in bundle),coverage=counts,clock_pairs=len(cp),clock_sources=sorted(sources),clock_destinations=sorted(destinations),clock_pair_unique_complete=True,normal=normal,boundary='Actual I3 only; narrow positive hold is material. External7input/135output delay boundary retained, not unconstrained internal logic. No programming artifact or board claim.'))
print('CURRENT_TIMING_AUDIT PASS',counts,len(normal),len(cp),flush=True)
