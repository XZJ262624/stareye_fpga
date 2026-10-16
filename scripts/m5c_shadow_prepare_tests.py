from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016';records=[]
def derive(src,dst,fn):
 p=R/src;q=R/dst;assert not q.exists();s=fn(p.read_text());q.write_text(s)
 records.append(dict(parent=src,parent_sha=hashlib.sha256(p.read_bytes()).hexdigest(),derived=dst,derived_sha=hashlib.sha256(q.read_bytes()).hexdigest()))
def tb(s):
 s=s.replace('tb_diag_observer_v2','tb_shadow_observer').replace('m5c_diag_observer_v2','m5c_diag_observer_v3')
 s=s.replace(' wire promoted=', ' wire sh64=equal_row||py%2==0||py%5==0,sh128=equal_row||py%2==0;\n wire strongrow=py%5==0,illegalrow=!equal_row&&py%7==0;\n wire promoted=')
 # ModelSim10.1c requires loop variables declared before wire expressions.
 s=s.replace(' reg qual=', ' integer px=0,py=0;\n reg qual=').replace('tracefile,outfile,k,px,py,recordno','tracefile,outfile,k,recordno')
 s=s.replace('.row_complete(complete)', '.shadow_valid(complete&&rtag),.shadow64(sh64),.shadow128(sh128),.strong_loss_row(strongrow),.illegal_row(illegalrow),.row_complete(complete)')
 s=s.replace('%0d\\n",recordno', '%0d %0d %0d %0d %0d %0d\\n",recordno').replace('cc,rc,ticks);','cc,rc,ticks,complete&&rtag,sh64,sh128,strongrow,illegalrow);')
 seed='force dut.complete_fail=32\'hfffffffe;force dut.tag_fail=32\'hfffffffe;force dut.equal_fail=32\'hfffffffe;force dut.tile64_count=32\'hfffffffe;force dut.tile128_count=32\'hfffffffe;force dut.strong_loss_count=32\'hfffffffe;force dut.illegal_count=32\'hfffffffe;'
 release='release dut.complete_fail;release dut.tag_fail;release dut.equal_fail;release dut.tile64_count;release dut.tile128_count;release dut.strong_loss_count;release dut.illegal_count;'
 s=s.replace('  for(py=0;py<40;', "  if(CASE==4||CASE==8)begin "+seed+" @(posedge clk);#1;"+release+"@(negedge clk);end\n  for(py=0;py<40;")
 s=s.replace('equal_row=py%3!=0;', 'equal_row=py%3!=0;complete=py%11!=0;rtag=py%17!=0;')
 return s
derive('tb/m5c_diagnostics/tb_diag_observer_v2.sv','tb/m5c_diagnostics/tb_shadow_observer.sv',tb)
def oracle(s):
 s=s.replace('counts=[MAX-1]*5 if case==4 else [0]*5','counts=([MAX-1]*5 if case==4 else [0]*5)+([MAX-1]*7 if case in (4,8) else [0]*7)')
 s=s.replace('cc,rc,tick=row','cc,rc,tick,sv,s64,s128,strongrow,illegalrow=row')
 s=s.replace('   if tail:events[:4]=[False]*4','   sq=p0 and complete and rtag and sv\n   events += [p0 and not complete,p0 and not rtag,p0 and not equal,sq and not illegalrow and s64,sq and not illegalrow and s128,sq and strongrow,sq and illegalrow]\n   if tail:events[:4]=[False]*4;events[5:]=[False]*7')
 s=s.replace('words[0]=1|','words[0]=2|')
 s=s.replace('  words[32:40]=', '  words[26]=counts[5]|(counts[6]<<32);words[27]=counts[7]|(counts[8]<<32);words[28]=counts[9]|(counts[10]<<32);words[29]=counts[11]\n  words[32:40]=')
 s=s.replace('rows[0][-1]-1-(1 if case==4 else 0)','rows[0][28]-1-(1 if case==4 else 0)-(1 if case in (4,8) else 0)')
 return s
derive('scripts/m5c_diag_oracle.py','scripts/m5c_shadow_oracle.py',oracle)
def runner(s):
 s=s.replace('from m5c_diag_oracle import check','from m5c_shadow_oracle import check').replace("R/'reports/m5c_diagnostics'/('stage2_v2reg_'", "R/'reports/m5c_shadow_stats_20261016'/('observer_'")
 s=s.replace('m5c_diag_observer_v2','m5c_diag_observer_v3').replace('tb_diag_observer_v2','tb_shadow_observer').replace('m5c_diag_oracle.py','m5c_shadow_oracle.py')
 s=s.replace('range(8)','range(9)').replace('len(results)==8','len(results)==9').replace('len(results)==12','len(results)==16')
 s=s.replace(" for name,case,before,after,fatal in mutants:", ''' mutants += [('schema',0,"aborted,1'b1,32'd2}","aborted,1'b1,32'd1}",'SHADOW_SCHEMA_VERSION'),('equal_counter',0,'equal_fail<=inc(equal_fail);','equal_fail<=equal_fail;','SHADOW_EQUAL_COUNT'),('tile_select',0,'if(shadow_events[3])tile64_count','if(shadow_events[4])tile64_count','SHADOW64_COUNTER_SELECT')]
 for name,case,before,after,fatal in mutants:''')
 return s
derive('scripts/m5c_diag_run_v2_regression.py','scripts/m5c_shadow_run_observer.py',runner)
def coupled(s):
 s=s.replace('tb_diag_coupled','tb_shadow_coupled').replace('m5c_diag_observer_v2','m5c_diag_observer_v3')
 s=s.replace('    wire diag_ctx,','    wire shvalid,sh64,sh128,shstrong,shillegal;\n    wire diag_ctx,')
 s=s.replace('        .mode(MODE),.admit_mode', '        .shadow_valid(shvalid),.shadow64(sh64),.shadow128(sh128),.strong_loss_row(shstrong),.illegal_row(shillegal),\n        .mode(MODE),.admit_mode')
 s=s.replace('.diag_tag_good(diag_tag)', '.diag_shadow_valid(shvalid),.diag_shadow64(sh64),.diag_shadow128(sh128),.diag_strong_loss(shstrong),.diag_illegal(shillegal),.diag_tag_good(diag_tag)')
 return s
derive('tb/m5c_diagnostics/tb_diag_coupled.sv','tb/m5c_diagnostics/tb_shadow_coupled.sv',coupled)
def cr(s):
 return s.replace("R/'reports/m5c_diagnostics'/('stage2_coupled_'","R/'reports/m5c_shadow_stats_20261016'/('coupled_'").replace("glob('*v2.sv')","glob('*v3.sv')").replace('tb_diag_coupled','tb_shadow_coupled')
derive('scripts/m5c_diag_run_coupled.py','scripts/m5c_shadow_run_coupled.py',cr)
def co(s):
 s=s.replace('p0=p1=p4=0','p0=p1=p4=0;s64=s128=0')
 s=s.replace('  p0+=candidate;p1+=candidate and y!=110','  p0+=candidate;p1+=candidate and y!=110\n  s64+=candidate and not(y==110 and x//64==163//64)\n  s128+=candidate and not(y==110 and x//128==163//128)')
 s=s.replace('W[0]=1|','W[0]=2|').replace('payload=struct.pack', 'W[26]=0;W[27]=(p0-p1)|(s64<<32);W[28]=s128;W[29]=0\npayload=struct.pack')
 return s
derive('scripts/m5c_diag_check_coupled.py','scripts/m5c_shadow_check_coupled.py',co)
(B/'TEST_DERIVATION.json').write_text(json.dumps(records,indent=2)+'\n');print('DERIVED',len(records))
