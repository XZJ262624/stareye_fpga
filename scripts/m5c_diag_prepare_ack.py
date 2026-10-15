from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[1];d=R/'reports/m5c_diagnostics/stage2_binding'
t=(R/'tb/m5c_diagnostics/tb_diag_coupled.sv').read_text().replace('module tb_diag_coupled;','module tb_diag_coupled_ack;')
assert 'module tb_diag_coupled_ack;' in t
t=t.replace('endmodule','always @(posedge pix_clk)if(diag_prst&&diag_take&&!diag_pix_cancel)begin\n if(packet.uart.busy!==0||wire_count!=324)$fatal(1,"DIAG_EARLY_RECORD_ACK");\nend\nendmodule')
tb=R/'tb/m5c_diagnostics/tb_diag_coupled_ack.sv';tb.write_text(t)
s=(R/'scripts/m5c_diag_run_coupled.py').read_text().replace("'stage2_coupled_'","'stage2_ack_positive_'").replace('tb_diag_coupled','tb_diag_coupled_ack')
(R/'scripts/m5c_diag_run_ack_positive.py').write_text(s)
n=(R/'scripts/m5c_diag_run_slot_negative.py').read_text()
a=n.index("spec={");b=n.index('\nrel,old,new,case,fatal=',a)
n=n[:a]+'''spec={'earlyack':('rtl/m5c_fusion/m5b1_uart.sv','6:if(ready)begin if(crc_pos==3)state<=7;',"6:if(ready)begin if(crc_pos==3)begin diag_done<=1;state<=0;end",0,'DIAG_EARLY_RECORD_ACK')}'''+n[b:]
n=n.replace("[R/'rtl/m5c_diagnostics/m5c_diag_slot_guard.sv',R/'tb/m5c_diagnostics/tb_diag_backend_slot.sv']","[R/'rtl/m5c_diagnostics/m5c_diag_slot_guard.sv',R/'rtl/m5c_diagnostics/m5c_diag_record_bridge.sv',R/'rtl/m5c_diagnostics/m5c_diag_observer_v2.sv',R/'tb/m5c_diagnostics/tb_diag_coupled_ack.sv']")
n=n.replace("'tb_diag_backend_slot',f'-gCASE={case}'","'tb_diag_coupled_ack','+PHASE=2','+OUT='+D.as_posix()")
(R/'scripts/m5c_diag_run_ack_negative.py').write_text(n)
def rec(p):
 b=p.read_bytes();return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
(d/'ACK_DERIVATION.json').write_text(json.dumps(dict(parent=rec(R/'tb/m5c_diagnostics/tb_diag_coupled.sv'),derived=rec(tb),change='Unique top plus actual UART busy=0 and all324 received bytes required at real PIX success ACK; no pixel/CRC/original checks removed.'),indent=2))
