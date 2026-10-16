"""New isolated negative fixtures. Prior malformed identity mutant remains NONPASS."""
from pathlib import Path
import sys,json,hashlib
R=Path(__file__).resolve().parents[1]
parent=R/'scripts/m5c_shadow_run_observer.py'
exec(compile(parent.read_text().split('results=[];positive={}')[0],str(parent),'exec'))
prior=R/'reports/m5c_shadow_stats_20261016/observer_20261016_133248'
base=rtl.read_text();mutants=[
 ('identity_v2',0,'always @(posedge read_clk) word_data<=memory[read_word];','always @(posedge read_clk) begin word_data<=memory[read_word]; if(record_ready)memory[8]<=source_descriptor[63:0]; end','DIAG_IDENTITY_EARLY_OVERWRITE'),
 ('tile128_select',0,'if(shadow_events[4])tile128_count','if(shadow_events[3])tile128_count','SHADOW128_COUNTER_SELECT'),
 ('reserved',0,"29:seal_data={32'd0,illegal_count};","29:seal_data={32'd1,illegal_count};",'SHADOW_RESERVED_WORD29'),
 ('new_saturation',8,"if((shadow_events[0]&&complete_fail==32'hffffffff)","if(1'b0&&(shadow_events[0]&&complete_fail==32'hffffffff)",'SHADOW_NEW_COUNTER_SATURATION')]
# Disable the complete new-saturation predicate, including OR terms.
sat_start=base.index('      if((shadow_events[0]');sat_end=base.index('saturated<=1;',sat_start)+len('saturated<=1;')
results=[]
for name,case,before,after,fatal in mutants:
 if name=='new_saturation':before=base[sat_start:sat_end];after="      if(1'b0)saturated<=1;"
 assert base.count(before)==1
 derived=base.replace(before,after);assert derived.replace(after,before)==base
 source=out/(name+'.sv');source.write_text(derived)
 (out/(name+'_DERIVATION.json')).write_text(json.dumps(dict(parent=rec(rtl),derived=rec(source),before=before,after=after,inverse_exact=True,expected=rec(prior/f'positive_{case}/expected_0.hex')),indent=2))
 _,r=run(case,source,name,prior/f'positive_{case}/expected_0.hex',fatal);results.append(r)
assert inputs==[rec(Path(x['path'])) for x in inputs]
(out/'SUMMARY.json').write_text(json.dumps(dict(results=results,all_pass=all(r['status']=='PASS_EXPECTED_NAMED_FATAL' for r in results),prior_malformed='Retained in observer_133248/negative_identity; never counted as rejected-by-oracle.'),indent=2));print('OUTPUT',out,flush=True)
