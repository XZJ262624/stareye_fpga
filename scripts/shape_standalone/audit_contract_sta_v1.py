"""Fail-closed current timing coverage; no prior slack or endpoint counts reused."""
from pathlib import Path
import json,re,hashlib
R=Path(__file__).resolve().parents[2]
from standalone_physical_runtime import active
F,P=active()
assert (F/'STA_CHAIN_COMPLETE.json').exists()
original_db=json.loads((F/'CURRENT_ROUTED_DB_V2.json').read_text())['records']
tail_db={x['path']:x for x in json.loads((F/'CURRENT_ROUTED_DB_V2.json').read_text())['records']}
assert all(tail_db.get(x['path'])==x for x in original_db),'TAIL_DB_DIFFERS_FROM_CURRENT_ROUTED_DB'
def rec(p):
 with p.open('rb') as f:h=hashlib.file_digest(f,'sha256').hexdigest()
 return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=h)
def parse(p):
 rows=[];row={};i3=False
 with p.open(errors='replace') as f:
  for line in f:
   if re.search(r'Timing Model\s*:\s*I3',line):i3=True
   if line.startswith('++++ Path '):
    if 'end' in row:rows.append(row)
    row={}
   for label,key in [('Path Begin','begin'),('Path End','end'),('Slack','slack'),('+ Clock To Q + Data Path Delay','cq_data'),('End-of-path arrival time','arrival')]:
    m=re.match(re.escape(label)+r'\s*:\s*(.*)',line)
    if m:row[key]=m[1].strip() if key in ['begin','end'] else float(m[1].split()[0])
 if 'end' in row:rows.append(row)
 assert i3 and all('slack' in r for r in rows),p
 return rows
groups={g['name']:g['pins'] for g in json.loads((F/'CURRENT_EXACT_GROUPS.json').read_text())['groups']};sdc=(P/'Ti60_Demo_I3.sdc').read_text();cuts={};holds={}
for line in sdc.splitlines():
 if line.startswith('set_false_path'):
  m=re.search(r'-to \$(\w+)',line)
  if m and m[1] in groups:
   for pin in groups[m[1]]:(holds if '-hold' in line else cuts).setdefault(pin,[]).append(line)
native=dict((p,v.strip('{}')) for p,v in (line.rstrip('\n').split('\t',1) for line in (P/'typed_native_connections.tsv').open()))
allpins={x.strip('{}') for x in (P/'selected_allpins.txt').read_text().split()};assert set(native)==allpins
# Unconnected output pins may have no net. A missing input path with an empty
# net stays UNRESOLVED below; empty nets are never classified as constants.
logical={r['pin']:r for r in json.loads((F/'STANDALONE_PIXEL_MAPPED_CONES_V2.json').read_text())['records']};raw=(P/'outflow/Ti60_Demo.map.v').read_text()
plan=json.loads((F/'BATCHED_ENDPOINT_PLAN.json').read_text());scopes=[];unknown=[];negative=[];legacy=[];index={}
for kind,targetslist in plan['groups'].items():
 targets=set(targetslist)
 for mode in ['setup','hold']:
  log=(F/f'sta2_02_{kind}_{mode}/native.log').read_text();rows=[]
  for b in [x for x in plan['batches'] if x['kind']==kind and x['mode']==mode]:
   rp=P/f'outflow/{b["label"]}.rpt';segment=log.split('REPORT_BEGIN '+b['label']+'\n',1)[1].split('REPORT_END '+b['label'],1)[0]
   if rp.exists():
    chunk=parse(rp);assert {x['end'] for x in chunk}<=set(b['targets']);rows+=chunk;index[rp.name]=dict(rows=chunk,report=rec(rp))
   else:assert 'No timing path is found' in segment;index[rp.name]=dict(rows=[],explicit_native_no_path=True)
  actual={r['end']:r for r in rows};assert len(actual)==len(rows) and set(actual)<=targets
  negative += [dict(kind=kind,mode=mode,**r) for r in rows if r['slack']<0];missing=[]
  for pin in sorted(targets-set(actual)):
   net=native[pin];cat='UNRESOLVED';proof=None
   if pin in cuts:cat='EXACT_CURRENT_CUT';proof=cuts[pin]
   elif mode=='hold' and pin in holds:cat='EXACT_CURRENT_HOLD_CUT';proof=holds[pin]
   elif net in ['gnd','vcc']:
    item=logical.get(pin);cat='NATIVE_CONSTANT_EXISTING' if not item else 'NATIVE_CONSTANT_MAP_AGREEMENT' if item['classification']=='CONSTANT' else 'RAM_PHYSICAL_MAPPING_PENDING'
   elif pin in {'rstn_pixel~FF|SR','rstn_sys~FF|SR','u_shape_system/u_m5b1/bridge/failed~FF|SR'} and net=='w_pll_lock':
    cell=pin.split('|')[0];m=re.search(r'EFX_FF\s+\\'+re.escape(cell)+r'\s+\(.*?\)\s*/\*.*?\*/\s*;',raw,re.S);assert m and "SR_SYNC=1'b0" in m[0] and '.SR(w_pll_lock)' in m[0];cat='INHERITED_PLL_ASYNC_SR_UNTIMED_NOT_PASS';legacy.append(dict(pin=pin,mode=mode,configuration=m[0]))
   elif re.fullmatch(r'u_shape_system/u_controls/key_meta\[[01]\]~FF\|D',pin):
    bit=pin.split('[')[1][0];proof=f'set_false_path -from [get_ports {{key_n[{bit}]}}] -to $key{bit}_meta_d';assert net==f'key_n[{bit}]' and proof in sdc;cat='INHERITED_KEY_INPUT_EXACT_CUT'
   row=dict(pin=pin,mode=mode,kind=kind,native_net=net,classification=cat,evidence=proof);missing.append(row)
   if cat in ['UNRESOLVED','RAM_PHYSICAL_MAPPING_PENDING']:unknown.append(row)
  scopes.append(dict(kind=kind,mode=mode,targets=len(targets),reported=len(actual),minimum_slack=min((r['slack'] for r in rows),default=None),missing=missing))
(F/'TIMING_REPORT_INDEX.json').write_text(json.dumps(dict(reports=index),indent=2))
log=(F/'sta2_01_discovery/native.log').read_text();actualgroups={m[1]:m[3].split() for m in re.finditer(r'^EXACT_GROUP (\w+) (\d+) (.*)$',log,re.M)};assert actualgroups==groups
bundles=[]
for name,targets in groups.items():
 if not name.endswith('_destination'):continue
 source=name.removesuffix('_destination')+'_source';rp=P/f'outflow/bundle_{name}_setup.rpt';rows=parse(rp);assert len(rows)==len(targets) and {r['end'] for r in rows}==set(targets)
 assert all(r['begin'].replace('|Q','|CLK') in groups[source] and r['slack']>=0 and r['cq_data']<=5 for r in rows)
 skew=max(r['arrival'] for r in rows)-min(r['arrival'] for r in rows);assert skew<=5
 assert f'set_false_path -hold -from ${source} -to ${name}' in sdc and not (P/f'outflow/bundle_{name}_hold.rpt').exists()
 if name=='m5c1b_held_13_destination':assert all(re.search(r'held\[(\d+)\]',r['begin'])[1]==re.search(r'source_guard\[(\d+)\]',r['end'])[1] for r in rows)
 bundles.append(dict(name=name,count=len(rows),minimum_slack=min(r['slack'] for r in rows),skew=skew,report=rec(rp)))
assert len(bundles)==6
clocks=[];nopath=0
for pair in json.loads((F/'CLOCK_PAIR_PLAN.json').read_text()):
 for mode in ['setup','hold']:
  rp=P/f'outflow/clock_{pair["index"]}_{mode}.rpt';timed=rp.exists();row=dict(**pair,mode=mode,timed=timed)
  if timed:
   rr=parse(rp);assert len(rr)==1 and rr[0]['slack']>=0;row.update(slack=rr[0]['slack'],report=rec(rp))
  else:nopath+=1;row['classification']='CURRENT_NATIVE_EXPLICIT_NO_PATH_NOT_TIMING_PASS'
  clocks.append(row)
assert len(clocks)==2*len(json.loads((F/'CLOCK_PAIR_PLAN.json').read_text()))
assert (F/'sta2_04_clock_pairs/native.log').read_text().count('No timing path is found')==nopath

dsp=[]
for i,r in enumerate(json.loads((F/'DSP_THROUGH_PLAN.json').read_text())):
 if r['constant']:continue
 for mode in ['setup','hold']:
  rp=P/f'outflow/dsp_{i:03d}_{mode}.rpt';txt=rp.read_text();rr=parse(rp);assert len(rr)==1 and rr[0]['slack']>=0 and re.search(r'^'+re.escape(r['pin'])+r'\s+dsp48_prim\s',txt,re.M);dsp.append(dict(pin=r['pin'],mode=mode,slack=rr[0]['slack'],report=rec(rp)))
keys={(r['pin'],r['mode']) for r in dsp};unresolved=[r for r in unknown if (r['pin'],r['mode']) not in keys]
out=dict(status='PENDING_RAM_MAPPING_AND_SURVIVAL' if unresolved else 'PENDING_FINAL_EVIDENCE_REVIEW',scopes=scopes,negative=negative,legacy_untimed_not_pass=legacy,unknown=unresolved,dsp_resolved=[r for r in unknown if (r['pin'],r['mode']) in keys],bundles=bundles,clock_matrix=clocks,dsp_through=dsp)
(F/'CONTRACT_STA_RECONCILIATION.json').write_text(json.dumps(out,indent=2));print('CURRENT_RECONCILIATION',len(negative),'negative',len(unresolved),'unresolved',len(legacy),'legacy UNTImED')
