from pathlib import Path
import json,hashlib,re,collections
O=Path(__file__).resolve().parent;R=O.parents[3];P=O/'aba_two_fence_1821';F=O/'aba_window_v3_2107';F.mkdir(exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=P/'tb_aba_two_fence_v2.sv';s=p.read_text();t=s.replace('module tb_aba_two_fence_v2;','module tb_aba_two_fence_v3;')
margin='  if(dut.background.tick>BG_REQUEST_CYCLES-8000000)$fatal(1,"ABA_NATURAL_WINDOW_TOO_SHORT");'
assert t.count(margin)==1;t=t.replace(margin+'\n','')
anchor=' task aba_log_fence;';t=t.replace(anchor,' task aba_check_initial_margin;\n begin\n'+margin+'\n end endtask\n'+anchor)
assert t.count('aba_check_ttl;')==5 # four calls plus task declaration
t=t.replace('    aba_check_ttl;','    aba_check_ttl;if(aba_rejects==0)aba_check_initial_margin;')
t=t.replace('real_a1_descriptor=dut.fusion.result_descriptor;aba_check_ttl;','real_a1_descriptor=dut.fusion.result_descriptor;aba_check_ttl;aba_check_initial_margin;')
t=t.replace('   aba_check_ttl;aba_log_fence;','   aba_check_ttl;aba_check_initial_margin;aba_log_fence;')
t=t.replace('   aba_check_ttl;test_high<=64;','   aba_check_ttl;aba_check_initial_margin;test_high<=64;')
fatal=lambda x:collections.Counter(re.findall(r'\$fatal\(.*?;',x,re.S))
assert fatal(s)==fatal(t)
q=F/'tb_aba_two_fence_v3.sv';q.write_text(t)
tasks=[]
for name in ['aba_check_ttl','aba_check_initial_margin']:
 tasks.append(re.search(r' task '+name+r';.*?endtask',t,re.S).group())
pre='''`timescale 1ns/1ps
module guard_background;reg [31:0] tick=0;endmodule
module guard_dut;guard_background background();endmodule
module tb_guard_lifecycle;
 parameter CASE=0;localparam BG_REQUEST_CYCLES=96000000;
 reg [767:0] real_a1_descriptor=0;reg [63:0] epoch=1,display_seq=20,pixel_ticks=2000;integer aba_rejects=0;
 guard_dut dut();
TASKS
 task reject_old;
 begin
  aba_check_ttl;if(aba_rejects==0)aba_check_initial_margin;
  aba_rejects=aba_rejects+1;
  $display("GUARD_REJECTION case=%0d count=%0d tick=%0d frame_age=%0d",CASE,aba_rejects,dut.background.tick,display_seq-real_a1_descriptor[383:320]);
 end endtask
 initial begin
  real_a1_descriptor[63:0]=1;real_a1_descriptor[383:320]=10;real_a1_descriptor[575:512]=1000;
  dut.background.tick=40000000;
  // ARM/B2/A3 always retain both checks.
  repeat(3)begin aba_check_ttl;aba_check_initial_margin;end
  if(CASE==1)dut.background.tick=90000000;
  #1;reject_old;
  dut.background.tick=90000000;
  if(CASE==2)display_seq=131;
  #1;reject_old;
  if(CASE!=0||aba_rejects!=2)$fatal(1,"GUARD_EXPECTED_FAILURE_MISSING");
  $display("PASS_GUARD_LIFECYCLE_ONLY timelyfirst_laterrepeat_TTLretained");$finish;
 end
 initial begin #100;$fatal(1,"GUARD_PREFLIGHT_TIMEOUT");end
endmodule
'''.replace('TASKS','\n'.join(tasks))
g=F/'tb_guard_lifecycle.sv';g.write_text(pre)
d=dict(status='DERIVED_NOT_RUN',parent=rec(p),derived=[rec(q),rec(g)],generator=rec(Path(__file__)),fatal_inventory_equal=True,fatal_count=sum(fatal(s).values()),scope='Only split initial8M margin from always-on TTL. ARM/B2/A3 and first genuine UI rejection invoke margin; every old-result rejection still calls unchanged epoch/order/120frame/148500000tick TTL. No parameters, RTL, controls, twofence, identity, fullwire or recovery changes.',preflight='Exact two task bodies copied from v3. Synthetic scalar lifecycle inputs test guard logic only, not production ABA.',freeze=rec(O.parent.parent/'ABA_WINDOW_GUARD_RETRY_FREEZE_20261013_2107.md'))
(F/'DERIVATION.json').write_text(json.dumps(d,indent=2));print(rec(F/'DERIVATION.json'))
