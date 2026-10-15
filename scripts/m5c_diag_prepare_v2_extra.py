from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[1]
base=R/'scripts/m5c_diag_run_v2_regression.py';s=base.read_text().split('results=[];positive={}')[0]
tail='''
before="always @(posedge read_clk) word_data<=memory[read_word];"
after="always @(posedge read_clk) begin word_data<=memory[read_word]; if(record_ready)memory[8]<=source_descriptor[63:0]; end"
original=rtl.read_text();assert original.count(before)==1
mutant=out/'identity_mutant_v2.sv';mutant.write_text(original.replace(before,after));assert mutant.read_text().replace(after,before)==original
(out/'DERIVATION.json').write_text(json.dumps(dict(parent=rec(rtl),derived=rec(mutant),before=before,after=after,inverse_exact=True,prior_failure='stage2_v2reg_20261015_153956/negative_identity: syntax error from missing begin/end in derived mutant; compile failure is not oracle rejection'),indent=2))
p,result=run(0,mutant,'negative_identity',R/'reports/m5c_diagnostics/stage2_v2reg_20261015_153956/positive_0/expected_0.hex','DIAG_IDENTITY_EARLY_OVERWRITE')
(out/'SUMMARY.json').write_text(json.dumps(dict(results=[result],all_pass=result['status']=='PASS_EXPECTED_NAMED_FATAL',inputs_unchanged=inputs==[rec(Path(x['path'])) for x in inputs]),indent=2));print('OUTPUT',out)
'''
(R/'scripts/m5c_diag_run_v2_identity_retry.py').write_text(s+tail)
tb=R/'tb/m5c_diagnostics/tb_diag_observer_invalid.sv';t=tb.read_text().replace('module tb_diag_observer;','module tb_diag_observer_v2_invalid;').replace('m5c_diag_observer #','m5c_diag_observer_v2 #').replace('.clk(clk),.rst_n(rst),.context_event',".clk(clk),.read_clk(clk),.record_cancel(1'b0),.admit_mode(mode),.rst_n(rst),.context_event")
(R/'tb/m5c_diagnostics/tb_diag_observer_v2_invalid.sv').write_text(t)
s=(R/'scripts/m5c_diag_run_invalid.py').read_text().replace("('stage1_'","('stage2_invalid_'").replace('rtl/m5c_diagnostics/m5c_diag_observer.sv','rtl/m5c_diagnostics/m5c_diag_observer_v2.sv').replace('tb/m5c_diagnostics/tb_diag_observer_invalid.sv','tb/m5c_diagnostics/tb_diag_observer_v2_invalid.sv').replace("'tb_diag_observer'","'tb_diag_observer_v2_invalid'")
(R/'scripts/m5c_diag_run_v2_invalid.py').write_text(s)
