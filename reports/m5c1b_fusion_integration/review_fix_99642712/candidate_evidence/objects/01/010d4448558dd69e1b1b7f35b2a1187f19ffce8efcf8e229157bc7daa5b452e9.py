from pathlib import Path
import json,hashlib,re
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3';Q=A/'queries'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert json.loads((A/'sta_01_bundle_global_Dsetup/RESULT.json').read_text())['status']=='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION'
cs=json.loads((A/'mapped_inventory_v2/SEQUENTIAL_BOUNDARIES.json').read_text())['cells'];pins={x.strip('{}') for x in (P/'selected_allpins.txt').read_text().split()};sets={};constant=[]
for kind in ['D','CE','SR','RAM','DSP']:
 targets=[]
 for c in cs:
  if c['kind']=='EFX_FF' and kind in ['D','CE','SR']:
   v=c['ports'].get(kind,[]);pin=c['name']+'|'+kind
   if v and v!=['CONST']:assert pin in pins,pin;targets.append(pin)
   elif v:constant.append(dict(pin=pin,classification='MAPPED_CONSTANT_PENDING_NATIVE_RECONCILIATION'))
  elif (kind=='RAM' and c['kind']=='EFX_RAM10') or (kind=='DSP' and c['kind']=='EFX_DSP48'):
   allowed={'WADDR','RADDR','WDATA','WCLKE','RADDREN','WADDREN','RE','WE','RST'} if kind=='RAM' else {'A','B','C','OP','SHIFT_ENA','CE','RST'}
   targets.extend(p for p in pins if p.startswith(c['name']+'|') and p.split('|')[-1].split('[')[0] in allowed)
 sets[kind]=sorted(set(targets));assert targets,kind
name='02_scoped_D_CE_SR_RAM_DSP_IO';t=[f'puts "FRESH_QUERY_START {name}"','set_timing_model I3','puts "ACTUAL_TIMING_MODEL [get_timing_model]"','if {[get_timing_model] ne "I3"} {error "WRONG_TIMING_MODEL"}','set actual [get_pins {*|*}]','array set valid {}','foreach p $actual {set valid($p) 1}'];ix=0
def report(mode,target,filename,label):
 global ix
 ix+=1;t.extend([f'puts "FRESH_REPORT_BEGIN {name} {ix}"',f'puts "V2_REPORT_BEGIN {label} {mode}"',f'report_timing -{mode} {target} -nworst 1 -detail full_path -file {filename}',f'puts "V2_REPORT_END {label} {mode}"',f'puts "FRESH_REPORT_END {name} {ix}"'])
for kind,values in sets.items():
 t.extend(['set selected {']+[' {'+p+'}' for p in values]+['}','foreach p $selected {if {![info exists valid($p)]} {error "MISSING_V2_PIN $p"}}',f'puts "V2_TARGETS {kind} [llength $selected]"','set targets [join $selected " "]'])
 for mode in (['hold'] if kind=='D' else ['setup','hold']):report(mode,'-to $targets -npaths [llength $selected]',f'v2_{kind}_{mode}.rpt',kind)
for label,opt,ports in [('ddrout','to','addr* ba* ras cas we cke odt cs o_dq* o_dm* o_dqs*'),('ddrin','from','i_dq* i_dqs*'),('hdmi','to','hdmi_txd* hdmi_txc*')]:
 for mode in ['setup','hold']:report(mode,f'-{opt} [get_ports {{{ports}}}] -npaths 200',f'v2_{label}_{mode}.rpt',label)
t.append(f'puts "FRESH_QUERY_COMPLETE {name}"');p=Q/(name+'.tcl');assert not p.exists();p.write_text('\n'.join(t)+'\n');(A/'CURRENT_SCOPED_TARGETS.json').write_text(json.dumps(dict(sets=sets,constant=constant,map=rec(P/'outflow/Ti60_Demo.map.v'),native=rec(P/'selected_allpins.txt'),structure=rec(A/'mapped_inventory_v2/SEQUENTIAL_BOUNDARIES.json'),counts={k:len(v) for k,v in sets.items()}),indent=2));(A/'QUERY02_DERIVATION.json').write_text(json.dumps(dict(queries=[dict(name=name,query=rec(p),reports=ix)],generator=rec(Path(__file__)),scope='Actualarea mapped cells plus currentnativepinset; same scoped FF DCE/SR/RAM/DSP and externalport semantics, no historicalconstantwaivers.'),indent=2));print({k:len(v) for k,v in sets.items()})
