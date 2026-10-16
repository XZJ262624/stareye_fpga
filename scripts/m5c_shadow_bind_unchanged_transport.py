from pathlib import Path
import json,hashlib,subprocess
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
names=['rtl/m5c_fusion/m5b1_backend.sv','rtl/m5c_fusion/m5b1_uart.sv','rtl/m5c_diagnostics/m5c_diag_record_bridge.sv','rtl/m5c_diagnostics/m5c_diag_slot_guard.sv']
modules=[]
for n in names:
 b=subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga','show','1786858c:'+n],cwd=R);x=rec(R/n);assert hashlib.sha256(b).hexdigest()==x['sha256'] and len(b)==x['bytes'];modules.append(x)
cases=[]
for name in ['stage2_slot_20261015_152737','stage2_slot_20261015_152802','stage2_slot_20261015_152809','stage2_slot_20261015_153145','stage2_slot_20261015_153159','stage2_mixed_20261015_154501']:
 w=R/'reports/m5c_diagnostics'/name;z=json.loads((w/'RESULT.json').read_bytes());sw=json.loads((w/'SOFTWARE_ORACLE.json').read_bytes());assert z['status']=='PASS_SIM_PENDING_SOFTWARE' and z['inputs_unchanged'] and sw['status'].startswith('PASS_')
 for st in z['steps']:
  assert st['exit']==0 and not st['timeout'];p=Path(st['log']['path']);v=rec(p);assert v['sha256']==st['log']['sha256'] and v['bytes']==st['log']['bytes']
 inputs=json.loads((w/'INPUTS.json').read_bytes());bound=[];changed=[]
 for i in inputs:
  p=Path(i['path']);v=rec(p)
  if v['sha256']!=i['sha256'] or v['bytes']!=i['bytes']:changed.append(dict(historical=i,current=v))
  if p.relative_to(R).as_posix() in names:
   assert v['sha256']==i['sha256'] and v['bytes']==i['bytes'];bound.append(v)
 assert any(x['path'].endswith('m5b1_uart.sv') for x in bound)
 cases.append(dict(case=name,native=rec(w/'RESULT.json'),software=rec(w/'SOFTWARE_ORACLE.json'),inputs=rec(w/'INPUTS.json'),bound_unchanged_transport=bound,historical_other_input_changes=changed,logs=[rec(w/f'step{i}.log') for i in range(3)],scope='Historical transport/slot contract only. Other compiled modules may have old versions; not evidence of current observer/row implementation. Current enabled system, new legal-header default UART and bridge sensitivity are separate new executions.'))
p=A/'UNCHANGED_TRANSPORT_INHERITANCE.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_EXPLICIT_UNCHANGED_TRANSPORT_ONLY_INHERITANCE',baseline='1786858c7ae9a0c756cc37c43beceb93eca92b9e',modules=modules,cases=cases,generator=rec(Path(__file__)),boundary='No claim these historical native runs were repeated. Schema transport length remains324B; schema2 meaning validated by new oracle. Default speed finite packets do not prove full-system real-time throughput.'),indent=2))
print('TRANSPORT_INHERITANCE',len(cases),rec(p))
