from common import *
F=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path'];D=Path(__file__).parent
phase=json.loads((O/'PHASE_RESULT.json').read_text());phase.update(status='RUNNING',running=True,phase='REGISTERED_DSP_CLOCK_AUDIT_RECOVERY',heartbeat=time.time());save(O/'PHASE_RESULT.json',phase);heartbeat(phase['phase'])
s=(D/'audit_native_clocks_v3.py').read_text();a=s.index(" if kind=='EFX_DSP48':");b=s.index(" if kind not in['EFX_RAM10'",a)
s=s[:a]+''' if kind=='EFX_DSP48':
  regs={k:v for k,v in params[name].items()if k.endswith('_REG')};assert len(regs)==7 and all(v in ["1'b0","1'b1"]for v in regs.values())
  if all(v=="1'b0"for v in regs.values()):
   assert all(c['ports'][k]=="1'b0"for k in['CLK','CE','RST']);assert all(name+'|'+k not in native for k in['CLK','CE','RST'])
   disabled.append(dict(kind=kind,cell=name,classification='ALL_REGISTERS_DISABLED_NO_NATIVE_CLOCK_OR_CE_RST_PIN_THROUGH_TIMING_REQUIRED',register_parameters=regs,mapped_controls={k:c['ports'][k]for k in['CLK','CE','RST']},native_controls=[]))
  else:
   assert name in {f'u_shape_system/u_shape/recognize/mult_{i}'for i in [189,190]}
   assert regs['A_REG']=="1'b1" and all(v=="1'b0"for k,v in regs.items()if k!='A_REG')
   assert native[name+'|CLK']==c['ports']['CLK']=='clk_pixel' and 'clk_pixel' in clocks
   assert all(native[name+'|'+k]==c['ports'][k]for k in ['CE','RST'])
   live.append(dict(kind=kind,cell=name,pin=name+'|CLK',clock='clk_pixel',classification='CURRENT_DEFINED_NATIVE_REGISTERED_DSP_CLOCK'))
   registered.append(dict(cell=name,register_parameters=regs,controls={k:native[name+'|'+k]for k in ['CLK','CE','RST']}))
  continue
''' +s[b:]
s=s.replace('params={};live=[];disabled=[]','params={};live=[];disabled=[];registered=[]')
s=s.replace("dict(EFX_FF=6731,EFX_RAM10=206,EFX_SRL8=586)and off==dict(EFX_RAM10=4,EFX_DSP48=9)","dict(EFX_FF=6731,EFX_RAM10=206,EFX_SRL8=586,EFX_DSP48=2)and off==dict(EFX_RAM10=4,EFX_DSP48=7)")
point=s.index("out=dict(passed=True")
proof='''# Verify actual full-path captures for every live registered A/CE/RST endpoint.
plan=json.loads((F/'BATCHED_ENDPOINT_PLAN.json').read_text());targets=set(plan['groups']['DSP']);evidence={};binding=[]
for mode in ['setup','hold']:
 for batch in [b for b in plan['batches']if b['kind']=='DSP'and b['mode']==mode]:
  rp=P/('outflow/'+batch['label']+'.rpt');binding.append(rec(rp));text=rp.read_text();assert re.search(r'Timing Model\\s*:\\s*I3',text)
  for section in re.split(r'^\\+\\+\\+\\+ Path ',text,flags=re.M)[1:]:
   end=re.search(r'^Path End\\s*:\\s*(\\S+)',section,re.M);slack=re.search(r'^Slack\\s*:\\s*([-\\d.]+)',section,re.M)
   capture=re.search(r'^Capture Clock\\s*:\\s*(\\S+)',section,re.M);launch=re.search(r'^Launch Clock\\s*:\\s*(\\S+)',section,re.M)
   assert end and slack and capture and launch
   evidence[mode,end[1]]=dict(pin=end[1],mode=mode,slack=float(slack[1]),capture_clock=capture[1],launch_clock=launch[1],report=rec(rp))
coverage=[]
for row in registered:
 name=row['cell'];pins=sorted(p for p in native if p.startswith(name+'|')and re.fullmatch(r'A\\[\\d+\\]|CE|RST',p.rsplit('|',1)[1]))
 assert len(pins)==21 and name+'|CE'in pins and name+'|RST'in pins
 for pin in pins:
  assert pin in targets
  for mode in ['setup','hold']:
   if native[pin]in ['gnd','vcc']:
    coverage.append(dict(pin=pin,mode=mode,native_net=native[pin],classification='NATIVE_CONSTANT_NOT_TIMING_PASS'))
   else:
    item=evidence[mode,pin];assert item['slack']>=0 and item['capture_clock']=='clk_pixel' and item['launch_clock']=='clk_pixel';coverage.append(dict(**item,native_net=native[pin],classification='FRESH_NATIVE_TIMED_REGISTERED_DSP_ENDPOINT'))
assert len(registered)==2 and len(coverage)==84
save(F/'REGISTERED_DSP_EXACT_COVERAGE_V4.json',dict(passed=True,registered_DSPs=registered,coverage=coverage,records=len(coverage),live_clock_count=2,source_or_constraint_changes=[],unknown=[],negative=[],failure_preserved=rec(F/'orientation_manager/audit_native_clocks_v3.log'),bindings=binding+[rec(P/'outflow/Ti60_Demo.map.v'),rec(P/'typed_native_connections.tsv'),rec(F/'BATCHED_ENDPOINT_PLAN.json')],scope='Two real A-registered DSPs, 19 A inputs + CE + RST each, both setup and hold explicitly captured clk_pixel. No endpoint omitted or old timing reused.'))
'''
s=s[:point]+proof+s[point:]
s=s.replace('NATIVE_PRIMITIVE_CLOCK_COVERAGE_V3.json','NATIVE_PRIMITIVE_CLOCK_COVERAGE_V4.json').replace('NATIVE_CLOCK_INTERFACE_RECOVERY_V3.json','NATIVE_CLOCK_INTERFACE_RECOVERY_V4.json')
s=s.replace('Four originalDDR ROM write interfaces and nine pure-combinationalDSP controls have no physical pins.', 'Four originalDDR ROM write interfaces and seven pure-combinationalDSP controls have no physical pins; two actual A-registered DSPs have fully covered live CLK/CE/RST and A inputs.')
s=s.replace('all4ROM disabled write interfaces and9combinationalDSPs','all4ROM disabled write interfaces and7combinationalDSPs plus2registeredDSPs')
s=s.replace("bindings=[rec(P/'typed_native_connections.tsv')", "bindings=[rec(F/'REGISTERED_DSP_EXACT_COVERAGE_V4.json'),rec(P/'typed_native_connections.tsv')")
q=D/'audit_native_clocks_v4.py';assert not q.exists();compile(s,str(q),'exec');q.write_text(s)
src=D/'generate_offline_image_v1.py';g=src.read_text().replace('NATIVE_PRIMITIVE_CLOCK_COVERAGE_V3.json','NATIVE_PRIMITIVE_CLOCK_COVERAGE_V4.json');q2=D/'generate_offline_image_v2.py';assert not q2.exists();q2.write_text(g)
save(O/'CLOCK_AUDIT_V4_DERIVATION.json',dict(original=rec(D/'audit_native_clocks_v3.py'),derived=rec(q),image_original=rec(src),image_derived=rec(q2),production_changes=[],constraint_changes=[],queries_rerun=[],reason='Fresh map has two A_REG=1 DSPs; inherited all9combinational expectation is false. Preserve failing report; prove all real clock/control/data endpoints.'))
