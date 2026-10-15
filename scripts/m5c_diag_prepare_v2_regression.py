from pathlib import Path
import hashlib,json
R=Path(__file__).resolve().parents[1]
tb=R/'tb/m5c_diagnostics/tb_diag_observer.sv';runner=R/'scripts/m5c_diag_run_stage1.py'
newtb=R/'tb/m5c_diagnostics/tb_diag_observer_v2.sv';newrunner=R/'scripts/m5c_diag_run_v2_regression.py'
assert not newtb.exists() and not newrunner.exists()
t=tb.read_text();t=t.replace('module tb_diag_observer;','module tb_diag_observer_v2;').replace('m5c_diag_observer #','m5c_diag_observer_v2 #').replace('.clk(clk),.rst_n(rst),.context_event','.clk(clk),.read_clk(clk),.record_cancel(1\'b0),.admit_mode(mode),.rst_n(rst),.context_event')
newtb.write_text(t)
s=runner.read_text().replace("('stage1_'","('stage2_v2reg_'").replace("rtl/m5c_diagnostics/m5c_diag_observer.sv","rtl/m5c_diagnostics/m5c_diag_observer_v2.sv").replace('tb/m5c_diagnostics/tb_diag_observer.sv','tb/m5c_diagnostics/tb_diag_observer_v2.sv').replace("'tb_diag_observer'","'tb_diag_observer_v2'")
newrunner.write_text(s)
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(R/'reports/m5c_diagnostics/stage2_binding/V2_REGRESSION_DERIVATION.json').write_text(json.dumps(dict(parents=[rec(tb),rec(runner)],derived=[rec(newtb),rec(newrunner)],changes=['Unique TB module and current observer_v2 module','Connect synchronous read_clk to test clock, cancellation disabled for inherited cases, admit mode to actual mode','New output prefix, new TB/RTL paths; all inherited positive checks and four mutants unchanged'],oracle=rec(R/'scripts/m5c_diag_oracle.py')),indent=2))
