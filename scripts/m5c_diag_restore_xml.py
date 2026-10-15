from pathlib import Path
import subprocess,hashlib,json,datetime
R=Path(__file__).resolve().parents[1];p=R/'efinity/m5c_fusion_i3/Ti60_Demo.xml'
d=R/'reports/m5c_diagnostics/stage2_binding'/('xml_exact_'+datetime.datetime.now().strftime('%H%M%S'));d.mkdir()
base=subprocess.check_output(['git','-c','safe.directory='+R.as_posix(),'show','3b49a1f701798a817fed42b8097f724cbc9d6160:efinity/m5c_fusion_i3/Ti60_Demo.xml'],cwd=R)
old=p.read_bytes();(d/'before.xml').write_bytes(old);(d/'head.xml').write_bytes(base)
anchor=b'    <efx:design_file name="../../rtl/m5c_fusion/m5b1_uart.sv" version="system_verilog" library="default" />'
assert base.count(anchor)==1
nl=b'\r\n' if b'\r\n' in base else b'\n'
extra=b''.join(nl+b'    <efx:design_file name="../../rtl/m5c_diagnostics/'+name+b'" version="system_verilog" library="default" />' for name in [b'm5c_diag_observer_v2.sv',b'm5c_diag_record_bridge.sv',b'm5c_diag_slot_guard.sv'])
new=base.replace(anchor,anchor+extra);assert new.replace(extra,b'',1)==base
p.write_bytes(new);(d/'after.xml').write_bytes(new)
def sha(b):return hashlib.sha256(b).hexdigest()
(d/'RECEIPT.json').write_text(json.dumps(dict(baseline_commit='3b49a1f701798a817fed42b8097f724cbc9d6160',before_sha=sha(old),baseline_sha=sha(base),after_sha=sha(new),inverse_byte_exact=True,insertions=3,other_changes=0,prior_format_rewrite_cause='UNKNOWN'),indent=2))
print(d)
