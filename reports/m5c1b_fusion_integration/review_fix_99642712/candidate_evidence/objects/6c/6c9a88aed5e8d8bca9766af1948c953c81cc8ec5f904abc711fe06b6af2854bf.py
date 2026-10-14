from pathlib import Path
import json,re,hashlib
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3';Q=A/'queries'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert json.loads((A/'sta_02_scoped_D_CE_SR_RAM_DSP_IO/RESULT.json').read_text())['status']=='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION'
sets=json.loads((A/'CURRENT_SCOPED_TARGETS.json').read_text())['sets'];allpins={x.strip('{}') for x in (P/'selected_allpins.txt').read_text().split()};targets=set(sets['RAM']+sets['DSP']);reports=[]
def ends(p):
 s=p.read_text();assert re.search(r'Timing Model\s*:\s*I3',s),p;reports.append(rec(p));return set(re.findall(r'^Path End\s*:\s*(\S+)',s,re.M))
globalmissing={p for p in allpins if p.endswith('~FF|D')}-ends(P/'outflow/all_D_setup.rpt');targets|=globalmissing;missing={}
for g,values in sets.items():
 for mode in (['hold'] if g=='D' else ['setup','hold']):
  p=P/f'outflow/v2_{g}_{mode}.rpt';actual=ends(p);assert actual<=set(values);miss=set(values)-actual;missing[g+'_'+mode]=sorted(miss);targets|=miss
name='03_connections';t=[f'puts "FRESH_QUERY_START {name}"','set_timing_model I3','puts "ACTUAL_TIMING_MODEL [get_timing_model]"','if {[get_timing_model] ne "I3"} {error "WRONG_TIMING_MODEL"}','set f [open v4_pin_nets.txt w]']
for p in sorted(targets):
 assert p in allpins,p
 t.extend(['set one [get_pins -regexp {^'+re.escape(p)+'$}]','if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}','puts $f "[lindex $one 0]\\t[get_nets $one]"'])
t.extend(['close $f',f'puts "FRESH_QUERY_COMPLETE {name}"']);p=Q/(name+'.tcl');assert not p.exists();p.write_text('\n'.join(t)+'\n');(A/'CURRENT_CONNECTION_TARGETS.json').write_text(json.dumps(dict(targets=sorted(targets),global_missing=sorted(globalmissing),control_missing=missing,reports=reports,nativepins=rec(P/'selected_allpins.txt'),scope='Typed actual pin to net connections; no assumedconstant whitelist.'),indent=2));(A/'QUERY03_DERIVATION.json').write_text(json.dumps(dict(queries=[dict(name=name,query=rec(p),reports=0)],generator=rec(Path(__file__)),targets=rec(A/'CURRENT_CONNECTION_TARGETS.json')),indent=2));print('CURRENT_NATIVE_TARGETS',len(targets),'globalmissing',len(globalmissing))
