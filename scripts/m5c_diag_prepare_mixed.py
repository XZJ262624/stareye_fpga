from pathlib import Path
import subprocess,json,hashlib
R=Path(__file__).resolve().parents[1];b=subprocess.check_output(['git','-c','safe.directory='+R.as_posix(),'show','3b49a1f701798a817fed42b8097f724cbc9d6160:rtl/m5c_fusion/m5b1_uart.sv'],cwd=R)
derived=b.replace(b'm5b1_packet_tx',b'baseline_m5b1_packet_tx').replace(b'm5b1_uart',b'baseline_m5b1_uart');assert derived.replace(b'baseline_m5b1_packet_tx',b'm5b1_packet_tx').replace(b'baseline_m5b1_uart',b'm5b1_uart')==b
p=R/'tb/m5c_diagnostics/baseline_uart.sv';p.write_bytes(derived)
(R/'reports/m5c_diagnostics/stage2_binding/BASELINE_UART_DERIVATION.json').write_text(json.dumps(dict(commit='3b49a1f701798a817fed42b8097f724cbc9d6160',original_sha256=hashlib.sha256(b).hexdigest(),derived_sha256=hashlib.sha256(derived).hexdigest(),inverse_byte_exact=True,change='Only module and instance type symbols prefixed baseline_'),indent=2))
s=(R/'scripts/m5c_diag_run_backend_slot.py').read_text().replace("'stage2_slot_'","'stage2_mixed_'").replace('tb_diag_backend_slot','tb_diag_mixed_uart').replace('DIAG_BACKEND_SLOT_PASS','DIAG_MIXED_UART_PASS')
s=s.replace("R/'tb/m5c_diagnostics/tb_diag_mixed_uart.sv'","R/'tb/m5c_diagnostics/tb_diag_mixed_uart.sv',R/'tb/m5c_diagnostics/baseline_uart.sv'")
(R/'scripts/m5c_diag_run_mixed.py').write_text(s)
