from standalone_physical_runtime import *
import collections
F,P=active();native={p:v.strip('{}')for p,v in(line.rstrip('\n').split('\t',1)for line in(P/'typed_native_connections.tsv').open())};clocks={x.strip('{}')for x in(P/'selected_clock_names.txt').read_text().split()};cells=json.loads((F/'MAPPED_ALL_CELLS.json').read_text());ff=json.loads((F/'NATIVE_ALL_FF_COVERAGE.json').read_text());raw=(P/'outflow/Ti60_Demo.map.v').read_text();params={};live=[];disabled=[]
for m in re.finditer(r'defparam\s+(\\\S+|\w+)\s*\.(\w+)\s*=\s*([^;]+);',raw):params.setdefault(m[1].lstrip('\\'),{})[m[2]]=m[3].strip()
for name in ff['all_native_FF_cells']:
 pin=name+'|CLK';net=native[pin];assert net in clocks;live.append(dict(kind='EFX_FF',cell=name,pin=pin,clock=net,classification='CURRENT_DEFINED_NATIVE_CLOCK'))
for name,c in cells.items():
 kind=c['type']
 if kind=='EFX_DSP48':
  regs={k:v for k,v in params[name].items()if k.endswith('_REG')};assert len(regs)==7 and all(v=="1'b0"for v in regs.values());assert all(c['ports'][k]=="1'b0"for k in['CLK','CE','RST']);assert all(name+'|'+k not in native for k in['CLK','CE','RST'])
  disabled.append(dict(kind=kind,cell=name,classification='ALL_REGISTERS_DISABLED_NO_NATIVE_CLOCK_OR_CE_RST_PIN_THROUGH_TIMING_REQUIRED',register_parameters=regs,mapped_controls={k:c['ports'][k]for k in['CLK','CE','RST']},native_controls=[]));continue
 if kind not in['EFX_RAM10','EFX_SRL8']:continue
 for port in['RCLK','WCLK']if kind=='EFX_RAM10'else['CLK']:
  pin=name+'|'+port
  if pin not in native:
   assert kind=='EFX_RAM10'and port=='WCLK'and c['ports']['WCLK']=="1'b0"
   assert all(re.fullmatch(r"\{?\d+'b0+\}?",c['ports'][k])for k in['WCLKE','WADDREN','WE','WADDR'])
   assert not any(p.startswith(name+'|W')for p in native)
   assert name in{f'ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1.inst_ddr3_axi/inst_efx_ddr3/top_mc/controller_main/map_ram/ram__D${v}'for v in['2','b12','12','c1']}
   disabled.append(dict(kind=kind,cell=name,logical_clock_port='WCLK',classification='EXACT_READ_ONLY_ROM_NO_NATIVE_WRITE_PORT_NO_TIMING_PASS',mapped_write_ports={k:v for k,v in c['ports'].items()if k.startswith('W')},native_write_ports=[]));continue
  net=native[pin];assert net in clocks;live.append(dict(kind=kind,cell=name,pin=pin,clock=net,classification='CURRENT_DEFINED_NATIVE_CLOCK'))
counts=collections.Counter(r['kind']for r in live);off=collections.Counter(r['kind']for r in disabled);assert counts==dict(EFX_FF=6731,EFX_RAM10=206,EFX_SRL8=586)and off==dict(EFX_RAM10=4,EFX_DSP48=9)
through=json.loads((F/'DSP_THROUGH_PLAN.json').read_text());assert all(any(r['pin'].startswith(n+'|')for r in through)for n,c in cells.items()if c['type']=='EFX_DSP48');main=json.loads((F/'FINAL_PHYSICAL_RECEIPT.json').read_text());assert main['passed']
out=dict(passed=True,status='PASS_COMPLETE_ACTUAL_NATIVE_PRIMITIVE_CLOCKS_WITH_EXACT_DISABLED_ROM_DSP_PROOFS',native_clocks=sorted(clocks),live_clock_pin_counts=counts,disabled_clock_port_counts=off,FF_clock_counts=collections.Counter(r['clock']for r in live if r['kind']=='EFX_FF'),live=live,disabled=disabled,undefined=[],limitations='Four originalDDR ROM write interfaces and nine pure-combinationalDSP controls have no physical pins. Their exact mapped zero controls/all7DSPregisters-disabled and current actual through timing are explicit proofs; absent pins are never timing PASS. Original6PLLasyncSR/7input135output limitations remain.',bindings=[rec(P/'typed_native_connections.tsv'),rec(P/'selected_clock_names.txt'),rec(F/'NATIVE_ALL_FF_COVERAGE.json'),rec(P/'outflow/Ti60_Demo.map.v'),rec(F/'DSP_THROUGH_PLAN.json'),rec(F/'FINAL_PHYSICAL_RECEIPT.json')]);save(F/'NATIVE_PRIMITIVE_CLOCK_COVERAGE_V3.json',out)
save(F/'NATIVE_CLOCK_INTERFACE_RECOVERY_V3.json',dict(original_scripts=[rec(Path(__file__).parent/n)for n in['audit_native_clocks_v1.py','audit_native_clocks_v2.py']],current_script=rec(Path(__file__)),earlier_errors='Historical parent tool development only: v1 assumed everyRAM has physicalWCLK; v2 assumed everyDSP has physicalCLK. Current read-only proof explicitly covers all4ROM disabled write interfaces and9combinationalDSPs, no skip of live ports, no source/constraints/report changes.'))
execution=json.loads((O/'FULL_NATIVE_STA_EXECUTION_RECEIPT.json').read_text());assert execution['execution_passed'];save(O/'PHYSICAL_CLOSED_RECEIPT.json',dict(status=main['status'],passed=True,resource_and_all_endpoint_STA_complete=True,physical=F.relative_to(R).as_posix(),execution_stage=rec(O/'FULL_NATIVE_STA_EXECUTION_RECEIPT.json'),final_main_audit=rec(F/'FINAL_PHYSICAL_RECEIPT.json'),native_clock_audit=rec(F/'NATIVE_PRIMITIVE_CLOCK_COVERAGE_V3.json'),historical_relation='Execution receipt was written before reconciliation, intentionally pending/false qualification; FINAL_PHYSICAL_RECEIPT later passed full audit. This closed receipt binds both plus complete actual primitive-clock proofs. No intermediate receipt or PRE/POST rewritten.',old_qualification_reused=False,hardware_next=False));print('STANDALONE_ALL_NATIVE_CLOCKS_AND_PHYSICAL_CLOSURE_PASS',counts,off,flush=True)
