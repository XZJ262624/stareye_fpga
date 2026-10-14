from pathlib import Path
import json,re,hashlib
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert json.loads((A/'sta_06_backend_cleanup_controls/RESULT.json').read_text())['status']=='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION'
sets=json.loads((A/'BACKEND_CONTROL_TARGETS.json').read_text())['sets'];missing={};targets=set();reports=[]
for group,vals in sets.items():
 for mode in ['setup','hold']:
  p=P/('outflow/all_D_setup.rpt' if group=='D' and mode=='setup' else f'outflow/backend_{group}_{mode}.rpt');s=p.read_text();assert re.search(r'Timing Model\s*:\s*I3',s);actual=re.findall(r'^Path End\s*:\s*(\S+)',s,re.M);assert len(actual)==len(set(actual));slacks=[float(v) for v in re.findall(r'^Slack\s*:\s*([+-]?[0-9.]+)',s,re.M)];assert slacks and min(slacks)>=0
  if group!='D' or mode!='setup':assert set(actual)<=set(vals)
  miss=set(vals)-set(actual);missing[group+'_'+mode]=sorted(miss);targets|=miss;reports.append(rec(p))
name='07_backend_connections';t=[f'puts "FRESH_QUERY_START {name}"','set_timing_model I3','puts "ACTUAL_TIMING_MODEL [get_timing_model]"','if {[get_timing_model] ne "I3"} {error "WRONG_TIMING_MODEL"}','set f [open backend_pin_nets.txt w]']
for p in sorted(targets):t+=['set one [get_pins -regexp {^'+re.escape(p)+'$}]','if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}','puts $f "[lindex $one 0]\\t[get_nets $one]"']
t+=['close $f',f'puts "FRESH_QUERY_COMPLETE {name}"'];p=A/'queries'/(name+'.tcl');assert not p.exists();p.write_text('\n'.join(t)+'\n');(A/'BACKEND_MISSING_TARGETS.json').write_text(json.dumps(dict(targets=sorted(targets),missing=missing,reports=reports,scope='Everybackend FF Dsetup/global+Dhold+CE/SR observedabsence to currentnative typedconnection, no blanketconstant waiver.'),indent=2));(A/'QUERY07_DERIVATION.json').write_text(json.dumps(dict(queries=[dict(name=name,query=rec(p),reports=0)],targets=rec(A/'BACKEND_MISSING_TARGETS.json'),generator=rec(Path(__file__))),indent=2));print('BACKEND_MISSING_TYPED_TARGETS',len(targets))
