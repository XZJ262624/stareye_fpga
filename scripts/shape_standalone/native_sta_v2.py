"""Current routed DB, bounded native reports; successful execution is not audit PASS."""
from pathlib import Path
import json,hashlib,re,subprocess,time,os,shutil
R=Path(__file__).resolve().parents[2];D=R/'reports/shape_standalone_20261021'
from standalone_physical_runtime import active
F,P=active();Q=F/'contract_sta_queries_v2';Q.mkdir(exist_ok=False)

def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(p,x):p.write_text(json.dumps(x,indent=2))
sources=json.loads((D/'SOURCE_MANIFEST.json').read_text())+[rec(P/'Ti60_Demo_I3.sdc')]
def verify(rows):
 for x in rows:assert rec(R/x['path'])==x,x['path']
verify(sources)
while not (F/'route/RESULT.json').exists():
 save(F/'STA_CHAIN_HEARTBEAT.json',dict(state='WAIT_CURRENT_ROUTE',pid=os.getpid(),time=time.time()));time.sleep(10)
assert json.loads((F/'route/RESULT.json').read_text())['passed']
report=(P/'outflow/Ti60_Demo.route.rpt').read_text();resources={k:int(re.search(v,report)[1]) for k,v in dict(XLR=r'XLRs:\s*(\d+)',RAM=r'Memory Blocks:\s*(\d+)',DSP=r'DSP Blocks:\s*(\d+)').items()}
assert resources['XLR']<=51680 and resources['RAM']<=204 and resources['DSP']<=128,resources
save(F/'FINAL_ROUTE_RESOURCE_GATE.json',dict(resources=resources,report=rec(P/'outflow/Ti60_Demo.route.rpt'),status='PASS_RESOURCE_TIMING_PENDING'))
db=[rec(p) for p in sorted((P/'work_pnr').rglob('*')) if p.is_file() and not p.name.endswith('.prevpr.vdb')]
for x in db:
 p=R/x['path'];q=F/'routed_db_archive_v2'/p.relative_to(P/'work_pnr');q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
save(F/'CURRENT_ROUTED_DB_V2.json',dict(records=db,work_dir='work_pnr',source=rec(F/'route/RESULT.json')))
def query(name,body):
 q=Q/(name+'.tcl');q.write_text('set_timing_model I3\nputs "ACTUAL_TIMING_MODEL [get_timing_model]"\nif {[get_timing_model] ne "I3"} {error WRONG_TIMING_MODEL}\n'+body+'\nputs {CONTRACT_STA_COMPLETE '+name+'}\n');return q
def run(q):
 verify(sources);verify(db);W=F/('sta2_'+q.stem);W.mkdir();save(W/'INPUTS_PRE.json',dict(sources=sources,db=db,query=rec(q),runner=rec(Path(__file__))))
 cmd='call E:\\Efinity\\2025.1\\bin\\setup.bat && E:\\Efinity\\2025.1\\bin\\efx_sta.exe --prj Ti60_Demo --output_dir outflow --tclsh '+q.as_posix()+''
 start=time.time()
 with (W/'native.log').open('wb') as log:
  p=subprocess.Popen(['cmd.exe','/d','/c',cmd],cwd=P,stdout=log,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
  owner=dict(pid=p.pid,manager_pid=os.getpid(),stage=q.stem,command=cmd,cwd=str(P),started=start,running=True);save(W/'OWNER.json',owner);print(json.dumps(owner),flush=True)
  while p.poll() is None:
   save(F/'STA_CHAIN_HEARTBEAT.json',dict(**owner,seconds=time.time()-start));time.sleep(10)
 owner.update(running=False,exit=p.returncode,seconds=time.time()-start);save(W/'OWNER.json',owner)
 verify(sources);verify(db);save(W/'INPUTS_POST.json',dict(sources=sources,db=db,query=rec(q)))
 text=(W/'native.log').read_text(errors='replace');errors=[l for l in text.splitlines() if re.search(r'\bERROR\b|SDC command error|failed to',l,re.I)]
 passed=p.returncode==0 and not errors and 'CONTRACT_STA_COMPLETE '+q.stem in text
 save(W/'RESULT.json',dict(execution_passed=passed,errors=errors,log=rec(W/'native.log'),outputs=[rec(p) for p in sorted((P/'outflow').glob('*.rpt'))],audit='PENDING'))
 
 if not passed:save(F/'FINAL_OFFLINE_RECEIPT.json',dict(status='FAIL_NATIVE_STA_QUERY',passed=False,query=rec(q),errors=errors))
 assert passed,(q,errors)
sdc=(P/'Ti60_Demo_I3.sdc').read_text();groups=[];t='proc exact {name patterns} {set result {}; foreach pat $patterns {set one [get_pins -regexp $pat];if {[llength $one]!=1} {error "EXACT_FAILURE $name $pat"};set result [concat $result $one]};puts "EXACT_GROUP $name [llength $result] $result";return [join $result " "]}\n'
for m in re.finditer(r'set (\w+) \[shape_exact \{(.*?)\}\s*(\w+)\]',sdc,re.S):
 pats=re.findall(r'\{(\^.*?)\}',m[2]);groups.append(dict(name=m[1],patterns=pats));t+='set '+m[1]+' [exact '+m[1]+' {'+''.join(' {'+p+'}' for p in pats)+'}]\n'
assert len(groups)==17
for g in groups:
 if g['name'].endswith('_destination'):
  assert len(g['patterns'])<=2048
  for mode in ['setup','hold']:t+=f'report_timing -{mode} -from ${g["name"].removesuffix("_destination")}_source -to ${g["name"]} -npaths {len(g["patterns"])} -nworst 1 -detail full_path -file bundle_{g["name"]}_{mode}.rpt\n'
for mode in ['setup','hold']:t+=f'report_timing -{mode} -npaths 200 -nworst 1 -detail full_path -file normal_{mode}.rpt\n'
t+='check_timing -verbose -file selected_check.rpt\nreport_clocks -file selected_clocks.rpt\nset f [open selected_allpins.txt w];puts $f [get_pins {*|*}];close $f\nset f [open selected_clock_names.txt w];puts $f [get_clocks {*}];close $f\n'
run(query('01_discovery',t))
normal={m:[float(x) for x in re.findall(r'^Slack\s*:\s*([-\d.]+)',(P/f'outflow/normal_{m}.rpt').read_text(),re.M)] for m in ['setup','hold']}
assert all(v and min(v)>=0 for v in normal.values()),normal
counts={k:int(v) for k,v in re.findall(r'checking (\w+) \((\d+)\)',(P/'outflow/selected_check.rpt').read_text())}
assert all(counts.get(k)==0 for k in ['no_clock','unconstrained_internal_endpoints','multiple_clock']),counts
save(F/'INITIAL_TIMING_GATE.json',dict(normal={k:min(v) for k,v in normal.items()},counts=counts,status='PASS_NORMAL_ONLY'))
pins={x.strip('{}') for x in (P/'selected_allpins.txt').read_text().split()};raw=(P/'outflow/Ti60_Demo.map.v').read_text();cells={m[2].lstrip('\\'):m[1] for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\(',raw,re.M)}

# Encrypted DDR partition FFs are omitted from readable map.v. Enumerate them
# from the real native five-port FF signature, suffix and exact map report count.
native_ports={}
for pin in pins:
 name,port=pin.rsplit('|',1);native_ports.setdefault(name,set()).add(port)
native_ff={n for n,ports in native_ports.items()if {'D','CE','SR','CLK','Q'}<=ports}
assert all(n.endswith('~FF')for n in native_ff)
visible_ff={n for n,k in cells.items()if k=='EFX_FF'};assert visible_ff<=native_ff
map_report=(P/'outflow/Ti60_Demo.map.rpt').read_text();reported_ff=int(re.search(r'EFX_FF\s*:\s*(\d+)',map_report)[1]);assert len(native_ff)==reported_ff
opaque=sorted(native_ff-visible_ff)
for n in opaque:assert n not in cells;cells[n]='EFX_FF'
save(F/'NATIVE_ALL_FF_COVERAGE.json',dict(status='ALL_NATIVE_FIVE_PORT_FFS_MATCH_SYNTHESIS_RESOURCE_COUNT',native_FF_count=len(native_ff),readable_map_FF_count=len(visible_ff),encrypted_partition_FF_count=len(opaque),encrypted_partition_cells=opaque,all_native_FF_cells=sorted(native_ff),native_signature=['D','CE','SR','CLK','Q'],suffix='~FF',map_report=rec(P/'outflow/Ti60_Demo.map.rpt'),allpins=rec(P/'selected_allpins.txt'),note='These encrypted DDR FFs must receive their own D/CE/SR setup/hold coverage. Readable map FF count alone is insufficient.'))

gg={k:[] for k in ['D','CE','SR','RAM','DSP']}
for pin in sorted(pins):
 cell,port=pin.rsplit('|',1);kind=cells.get(cell,'')
 if kind=='EFX_FF' and port in ['D','CE','SR']:gg[port].append(pin)
 if kind in ['EFX_RAM10','EFX_DPRAM10','EFX_DSP48'] and not re.match(r'^(RDATA|Q($|\[)|O($|\[)|CASCOUT|CLK$|CLKA$|CLKB$|RCLK$|WCLK$)',port):gg['DSP' if kind=='EFX_DSP48' else 'RAM'].append(pin)
ff=sum(v=='EFX_FF' for v in cells.values());assert all(len(gg[k])==ff for k in ['D','CE','SR'])
batches=[];queries=[]
for kind,targets in gg.items():
 assert targets
 for mode in ['setup','hold']:
  t=''
  for i,start in enumerate(range(0,len(targets),2048)):
   selected=targets[start:start+2048];label=f'batch_{kind}_{mode}_{i:03d}';t+='set selected {'+''.join(' {'+p+'}' for p in selected)+'}\n';t+=f'report_timing -{mode} -to [join $selected " "] -npaths {len(selected)} -nworst 1 -detail full_path -file {label}.rpt\n';batches.append(dict(kind=kind,mode=mode,label=label,targets=selected))
  t=re.sub(r'(report_timing[^\n]*-file (\S+)\.rpt)',lambda m:'puts {REPORT_BEGIN '+m[2]+'}\n'+m[1]+'\nputs {REPORT_END '+m[2]+'}',t)
  queries.append(query('02_'+kind+'_'+mode,t))
save(F/'BATCHED_ENDPOINT_PLAN.json',dict(groups=gg,batches=batches,ff_count=ff,maximum_targets_per_report=2048,queries=[rec(q) for q in queries]))
for q in queries:run(q)
t='set f [open typed_native_connections.tsv w]\nset all_native [get_pins {*|*}]\nset n 0\n'
t+='set checks {'+''.join(' {'+pin+'} {^'+re.escape(pin)+'$}' for pin in sorted(pins)[::max(1,len(pins)//64)])+'}\n'
t+='foreach_in_collection one $all_native {\n'
t+='set name [lindex $one 0];if {[dict exists $checks $name]} {set exact [get_pins -regexp [dict get $checks $name]];if {[llength $exact]!=1} {error V3_EXACT_NOT_SINGLETON};if {[get_nets $one] ne [get_nets $exact]} {error V3_NATIVE_ITERATOR_MISMATCH};puts "V3_COLLECTION_CHECK $n $one"}\n'
t+='puts $f "$one\\t[get_nets $one]";incr n\n}\nclose $f\nputs "V3_NATIVE_CONNECTION_COUNT $n"\n'
run(query('03_typed_connections',t))

clocks=[x.strip('{}') for x in (P/'selected_clock_names.txt').read_text().split()];t='';pairs=[]
for i,(a,b) in enumerate((a,b) for a in clocks for b in clocks):
 pairs.append(dict(index=i,source=a,destination=b))
 for mode in ['setup','hold']:t+=f'puts {{CLOCK_REPORT_BEGIN {i} {mode}}}\nreport_timing -{mode} -from_clock {{{a}}} -to_clock {{{b}}} -npaths 1 -nworst 1 -detail full_path -file clock_{i}_{mode}.rpt\nputs {{CLOCK_REPORT_END {i} {mode}}}\n'
save(F/'CLOCK_PAIR_PLAN.json',pairs);run(query('04_clock_pairs',t))
n=dict(line.rstrip('\n').split('\t',1) for line in (P/'typed_native_connections.tsv').open());params={}
for m in re.finditer(r'defparam\s+(\\\S+|\w+)\s*\.(\w+)\s*=\s*([^;]+);',raw):params.setdefault(m[1].lstrip('\\'),{})[m[2]]=m[3].strip()
t='';records=[]
for pin in sorted(pins):
 cell,port=pin.rsplit('|',1);base=re.sub(r'\[.*$','',port)
 if cells.get(cell)!='EFX_DSP48' or base not in ['A','B','C','OP'] or params[cell][base+'_REG']!="1'b0":continue
 net=n[pin].strip('{}');assert net;row=dict(pin=pin,net=net,constant=net in ['gnd','vcc'])
 if not row['constant']:
  idx=len(records);t+='set one [get_pins -regexp {^'+re.escape(pin)+'$}]\nif {[llength $one]!=1} {error DSP_PIN_NOT_SINGLETON}\n'
  for mode in ['setup','hold']:t+=f'report_timing -{mode} -through [join $one " "] -npaths 1 -nworst 1 -detail full_path -file dsp_{idx:03d}_{mode}.rpt\n'
 records.append(row)
save(F/'DSP_THROUGH_PLAN.json',records);run(query('05_dsp_static_through',t))
save(F/'STA_CHAIN_COMPLETE.json',dict(status='ALL_NATIVE_QUERIES_EXECUTED_FULL_AUDIT_PENDING',sources=sources,db=db,groups=17,clock_count=len(clocks),endpoints={k:len(v) for k,v in gg.items()}))
