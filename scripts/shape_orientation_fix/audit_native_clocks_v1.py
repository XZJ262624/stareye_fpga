from standalone_physical_runtime import *
import collections
F,P=active();native={p:v.strip('{}')for p,v in(line.rstrip('\n').split('\t',1)for line in(P/'typed_native_connections.tsv').open())};clocks={x.strip('{}')for x in(P/'selected_clock_names.txt').read_text().split()};mapcells=json.loads((F/'MAPPED_ALL_CELLS.json').read_text());ff=json.loads((F/'NATIVE_ALL_FF_COVERAGE.json').read_text());raw=(P/'outflow/Ti60_Demo.map.v').read_text();params={}
for m in re.finditer(r'defparam\s+(\\\S+|\w+)\s*\.(\w+)\s*=\s*([^;]+);',raw):params.setdefault(m[1].lstrip('\\'),{})[m[2]]=m[3].strip()
rows=[]
for name in ff['all_native_FF_cells']:
 pin=name+'|CLK';net=native[pin];assert net in clocks;(rows.append(dict(kind='EFX_FF',cell=name,pin=pin,clock=net,classification='CURRENT_DEFINED_CLOCK')))
for name,c in mapcells.items():
 kind=c['type'];ports=['RCLK','WCLK']if kind=='EFX_RAM10'else['CLK']if kind in['EFX_DSP48','EFX_SRL8']else[]
 for port in ports:
  pin=name+'|'+port;net=native[pin]
  if kind=='EFX_DSP48'and net in['gnd','vcc']:
   regs={k:v for k,v in params[name].items()if k.endswith('_REG')};assert regs and all(v=="1'b0"for v in regs.values());cls='COMBINATIONAL_DSP_ALL_REGS_DISABLED_THROUGH_TIMING_REQUIRED'
  else:assert net in clocks;cls='CURRENT_DEFINED_CLOCK'
  rows.append(dict(kind=kind,cell=name,pin=pin,clock=net,classification=cls,register_parameters=regs if kind=='EFX_DSP48'and net in['gnd','vcc']else{}))
counts=collections.Counter(r['kind']for r in rows);assert counts['EFX_FF']==6731 and counts['EFX_RAM10']==210 and counts['EFX_DSP48']==9 and counts['EFX_SRL8']==586
save(F/'NATIVE_PRIMITIVE_CLOCK_COVERAGE.json',dict(passed=True,native_clocks=sorted(clocks),pin_counts=counts,FF_clock_counts=collections.Counter(r['clock']for r in rows if r['kind']=='EFX_FF'),records=rows,undefined=[],scope='All6731 nativeFF (including1987encryptedDDR),105RAM both read/write clocks,9DSP clocks/registerparams,586SRL clocks. CombinationalDSP clockgnd is accepted only with every_REG=0 and current through timing checked separately; inherited PLL asyncSR and external timing limitations remain explicit.',bindings=[rec(P/'typed_native_connections.tsv'),rec(P/'selected_clock_names.txt'),rec(F/'NATIVE_ALL_FF_COVERAGE.json'),rec(P/'outflow/Ti60_Demo.map.v')]));print('ALL_NATIVE_PRIMITIVE_CLOCKS_COVERED',counts,flush=True)
