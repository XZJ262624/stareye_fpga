from pathlib import Path
import json,hashlib,re,collections
M=Path(__file__).resolve().parent;R=M.parents[2];O=M/'replay_end_v2';assert not O.exists();O.mkdir();C=O/'common';C.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
common=[]
for name in ['end_declarations.svh','end_protocol.svh']:
 p=M/'end_protocol_v1'/name;b=p.read_bytes();d=b.replace(b'end_checked_healthy',b'end_checked_qualified');assert d.replace(b'end_checked_qualified',b'end_checked_healthy')==b
 q=C/name;q.write_bytes(d);common.append(dict(parent=rec(p),derived=rec(q),inverse_equal=True))
checker=(M/'end_protocol_v1/check_end_protocol.py').read_text().replace("O.parent/'check_smoke_uart.py'","O.parents[1]/'check_smoke_uart.py'").replace('Short conditional1M cadence, not final96M matrix;','Current96M case-specific matrix;')
(C/'check_end_protocol.py').write_text(checker)
specs=[('normal','tb_selected_final_system.sv','output_healthy','1'),('nonzero','nonzero_reject/tb_selected_nonzero.sv','output_healthy','nz_fault_snapshot&&nz_recovery_snapshot'),('aba','aba_current_v8/tb_selected_aba_v8.sv','output_healthy','1'),('mixed','mixed_type1_v1/tb_selected_stats_v2.sv','output_healthy','1'),('faults','remaining_cases_v1/tb_selected_faults_v9.sv','(SCENARIO==8 ? output_off : output_healthy)','1'),('starvation','queued_starvation_v10/tb_selected_starvation_v11.sv','output_healthy','1'),('cold','remaining_cases_v1/tb_selected_faults_v9.sv',None,None)]
deriv=[]
for kind,rel,qualified,armed in specs:
 p=M/rel;s=p.read_text();orig=s;oldtop=re.search(r'module (\w+);',s).group(1);top='tb_replay_'+kind;s=s.replace('module '+oldtop+';','module '+top+';',1)
 if kind!='cold':
  s=s.replace('module '+top+';','module '+top+';\n localparam END_RESTORE_OLD=0;\n `include "end_declarations.svh"',1)
  needle='output_pos=0;output_frames=output_frames+1;';assert s.count(needle)==1
  s=s.replace(needle,f'end_checked_seq=display_seq;end_checked_qualified={qualified};\n    '+needle)
  assert s.count('smoke_complete=1;')==1
  s=s.replace('smoke_complete=1;',f'if({armed})begin smoke_complete=1;end_try_target;end')
  pattern=r'initial begin wait\(smoke_complete\);[^\n]+repeat\(20\)@\(posedge ui_clk\);'
  assert len(re.findall(pattern,s))==1
  finish='initial begin wait(end_finish_permitted);end_assert_complete;\n  $fdisplay(end_file,"FINISH %0d %0d %0d %0d %0d %0d %0d %0d %0t",end_target_seq,end_target_ui,end_src_count,end_ui_count,end_start_count,end_done_count,end_take_count,end_ui_quiet,$time);$fclose(end_file);'
  s=re.sub(pattern,lambda m:finish,s)
  idx=s.rfind('endmodule');s=s[:idx]+' `include "end_protocol.svh"\n'+s[idx:]
 else:
  # Original cold terminal remains the only reachable completion; never add common UART assertions.
  assert 'REAL_SYSTEM_HARDSTOP' in s
 fat=lambda text:collections.Counter(re.findall(r'\$fatal\s*\([^;]+;',text))
 assert fat(orig)==fat(s),(kind,'ASSERTION_CHANGED')
 q=O/(top+'.sv');q.write_text(s)
 deriv.append(dict(kind=kind,parent=rec(p),derived=rec(q),top=top,qualified=qualified,additional_arming=armed,assertion_count=sum(fat(orig).values()),assertion_inventory_unchanged=True,assertions=list(fat(orig).elements()),edits='Top symbol rename; common include declarations; independently checked final-pixel qualifier; coverage-arm hook; replace old wait+20 gap with fixed target drain. Cold: top rename only.'))
(O/'DERIVATION.json').write_text(json.dumps(dict(status='DERIVED_NOT_RUN',common=common,cases=deriv,generator=rec(Path(__file__)),freeze=rec(M.parent/'REPLAY_END_V2_EXECUTION_FREEZE.md'),plan=rec(M/'REPLAY_DERIVATION_PLAN_1009.json'),common_checker_parent=rec(M/'end_protocol_v1/check_end_protocol.py'),common_checker=rec(C/'check_end_protocol.py'),checker_edits='Resolve original unchanged strict UART checker from new directory; scope text96M only.'),indent=2))
print(O,[(x['kind'],x['assertion_count']) for x in deriv])
