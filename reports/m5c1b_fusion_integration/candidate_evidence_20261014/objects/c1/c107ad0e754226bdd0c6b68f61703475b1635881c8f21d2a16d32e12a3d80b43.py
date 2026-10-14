from pathlib import Path
import json,hashlib,re,collections
O=Path(__file__).resolve().parent;R=O.parents[3];F=O/'aba_two_fence_1821';F.mkdir(exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=O/'tb_replay_aba.sv';s=p.read_text();t=s.replace('module tb_replay_aba;','''module tb_aba_two_fence;
 integer aba_stage=0,aba_arm_sources=0,aba_arm_ui=0,aba_arm_takes=0,aba_off_events=0,aba_b2_events=0,aba_a3_events=0;
 reg [63:0] aba_arm_seq=0,aba_b2_seq=0;reg [7:0] aba_pending_high=64;reg [63:0] aba_pending_generation=1;
 wire aba_context_quiet;
 wire aba_full_quiet;
''')
old='''initial begin wait(arst_n);repeat(80)@(negedge pix_clk);if(FUS_ENABLE)begin key_n=0;repeat(100)@(negedge pix_clk);key_n=3;end
 forever begin @(posedge pix_sof);repeat(100)@(negedge pix_clk);key_n=0;repeat(20)@(negedge pix_clk);key_n=3;end end'''
assert t.count(old)==1;t=t.replace(old,'// All actual key writes are owned by the serialized two-fence stimulus below.')
a=t.index(' initial begin\n  wait(healthy>=1);\n  // Wait for the real previous context')
b=t.index(' always @(posedge ui_clk)if(aba_window',a)
oldblock=t[a:b]
armassert=next(line for line in oldblock.splitlines() if 'ABA_BOUNDARY_NOT_TRULY_DRAINED' in line)
new='''
 assign aba_context_quiet=dut.fusion.state==dut.fusion.IDLE&&!dut.fusion.req_busy&&!dut.fusion.req_valid&&!dut.fusion.offer_busy&&!dut.fusion.offer_valid&&!dut.fusion.rel_busy&&!dut.fusion.rel_valid&&!dut.fusion.cap_busy&&!dut.fusion.cap_valid&&dut.fusion.cap_drained&&dut.fusion.reader_drained&&dut.fusion.cache_empty&&!dut.fusion.context_confirmed&&!dut.fusion.reader_busy&&dut.fusion.response_quiet&&fusion_context_quiet&&fusion_context_block&&dut.pair_leased==0;
 assign aba_full_quiet=aba_context_quiet&&!dut.fusion.telemetry_pending&&!dut.telemetry_ready&&!dut.fusion.export_exclusive&&end_ui_raw_idle&&end_pix_raw_idle&&end_counts_equal;
 task aba_check_ttl;
 begin
  if(real_a1_descriptor[63:0]!=epoch||real_a1_descriptor[383:320]>display_seq||real_a1_descriptor[575:512]>pixel_ticks||display_seq-real_a1_descriptor[383:320]>120||pixel_ticks-real_a1_descriptor[575:512]>148500000)$fatal(1,"ABA_REAL_A1_TTL");
  if(dut.background.tick>BG_REQUEST_CYCLES-8000000)$fatal(1,"ABA_NATURAL_WINDOW_TOO_SHORT");
 end endtask
 task aba_log_fence;
 begin
  $display("ABA_FENCE stage=%0d time=%0t UI=%0d seq=%0d state=%0d reqbusy=%b reqvalid=%b offerbusy=%b offervalid=%b relbusy=%b relvalid=%b capbusy=%b capvalid=%b capdrained=%b readerdrained=%b cacheempty=%b confirmed=%b readerbusy=%b responsequiet=%b displayquiet=%b block=%b leased=%b pending=%b ready=%b export=%b mailbusy=%b mailvalid=%b building=%b rawvalid=%b packetbusy=%b src=%0d ui=%0d start=%0d done=%0d take=%0d",aba_stage,$time,ui_cycles,display_seq,dut.fusion.state,dut.fusion.req_busy,dut.fusion.req_valid,dut.fusion.offer_busy,dut.fusion.offer_valid,dut.fusion.rel_busy,dut.fusion.rel_valid,dut.fusion.cap_busy,dut.fusion.cap_valid,dut.fusion.cap_drained,dut.fusion.reader_drained,dut.fusion.cache_empty,dut.fusion.context_confirmed,dut.fusion.reader_busy,dut.fusion.response_quiet,fusion_context_quiet,fusion_context_block,dut.pair_leased,dut.fusion.telemetry_pending,dut.telemetry_ready,dut.fusion.export_exclusive,dut.telemetry.mail_busy,dut.telemetry.mail_valid,dut.telemetry.building,dut.telemetry.raw_valid,dut.background.packet_busy,end_src_count,end_ui_count,end_start_count,end_done_count,end_take_count);
 end endtask
 initial begin
  wait(arst_n);repeat(80)@(negedge pix_clk);if(FUS_ENABLE)begin key_n=0;repeat(100)@(negedge pix_clk);key_n=3;end
  wait(healthy>=1&&publishes>=1);@(negedge pix_clk);
  key_n=0;repeat(100)@(negedge pix_clk);key_n=3;
  wait(!control_fusion);@(negedge pix_clk);aba_off_events=aba_off_events+1;aba_stage=1;
  $display("ABA_REAL_OFF seq=%0d time=%0t gen=%0d H=%0d",display_seq,$time,test_generation,test_high);
  wait(aba_full_quiet);@(negedge ui_clk);while(!aba_full_quiet)@(negedge ui_clk);
ARM_ASSERT
  if(!aba_full_quiet||control_fusion)$fatal(1,"ABA_ARM_FULL_FENCE");aba_log_fence;
  if(!dut.fusion.result_valid||dut.fusion.result_descriptor[447:384]!=1)$fatal(1,"ABA_REAL_A1_REFERENCE_REQUIRED");
  if(dut.fusion.result_descriptor[735:576]!==fusion_config||test_high!=64||test_generation!=1)$fatal(1,"ABA_ARM_A64_SIGNATURE");
  real_a1_descriptor=dut.fusion.result_descriptor;aba_check_ttl;aba_window=1;aba_arm_seq=display_seq;
  aba_arm_sources=end_src_count;aba_arm_ui=end_ui_count;aba_arm_takes=end_take_count;
  aba_pending_high=80;aba_pending_generation=2;aba_stage=2;
  $display("ABA_ARM_REAL_A1 seq=%0d tick=%0d sourceframe=%0d sourcetick=%0d identity=%0192h",display_seq,dut.background.tick,real_a1_descriptor[383:320],real_a1_descriptor[575:512],real_a1_descriptor);
  @(negedge pix_clk);key_n=0;repeat(100)@(negedge pix_clk);key_n=3;
  wait(aba_stage==4);
  forever begin @(posedge pix_sof);repeat(100)@(negedge pix_clk);key_n=0;repeat(20)@(negedge pix_clk);key_n=3;end
 end
 // Both controls and external config commit via NBA on the same accepted SOF.
 always @(posedge pix_clk)if(arst_n&&pix_sof)begin
  if(aba_stage==2&&controls.pending_fusion)begin
   if(control_fusion||!aba_context_quiet)$fatal(1,"ABA_B2_CONTEXT_OR_ENABLE_PREEDGE");
   aba_check_ttl;aba_log_fence;
   if(display_seq-aba_arm_seq>4)$fatal(1,"ABA_ARM_WINDOW_MISSED");
   test_high<=aba_pending_high;test_generation<=aba_pending_generation;fault_active<=1;aba_stage<=3;aba_b2_seq<=display_seq+1;aba_b2_events<=aba_b2_events+1;
   #1;if(!control_fusion||test_high!=80||test_generation!=2)$fatal(1,"ABA_B2_NBA_CONFIG_ENABLE");
   $display("ABA_B2_BEGIN seq=%0d UI=%0d gen=%0d H=%0d L=%0d enable=%b telemetry_pending=%b src=%0d ui=%0d take=%0d",display_seq,ui_cycles,test_generation,test_high,{1'b0,test_high[7:1]},control_fusion,dut.fusion.telemetry_pending,end_src_count,end_ui_count,end_take_count);
  end else if(aba_stage==3)begin
   if(!control_fusion||test_high!=80||test_generation!=2||display_seq!=aba_b2_seq)$fatal(1,"ABA_B2_FULL_RASTER_CONFIG");
   aba_check_ttl;test_high<=64;test_generation<=3;fault_active<=0;fault_complete<=1;aba_stage<=4;aba_a3_events<=aba_a3_events+1;
   #1;if(test_high!=64||test_generation!=3||!control_fusion)$fatal(1,"ABA_A3_NBA_CONFIG");
   $display("ABA_A3_BEGIN seq=%0d UI=%0d gen=%0d H=%0d L=%0d sourcecount=%0d uicount=%0d takecount=%0d",display_seq,ui_cycles,test_generation,test_high,{1'b0,test_high[7:1]},end_src_count,end_ui_count,end_take_count);
  end
 end
 always @(negedge ui_clk)if(arst_n&&aba_stage==2)begin
  if(!aba_context_quiet||dut.fusion.acquire||dut.fusion.read_accept)$fatal(1,"ABA_OFF_ARM_CONTEXT_REACQUIRE");
  if(display_seq-aba_arm_seq>4)$fatal(1,"ABA_ARM_WINDOW_MISSED");
 end
 always @(posedge pix_clk)if(arst_n&&aba_stage>=2&&fusion_frame_done)
  $display("ABA_NEW_TELEMETRY_SOURCE stage=%0d seq=%0d accepted=%b full480=%0120h",aba_stage,display_seq,!dut.telemetry.mail_busy,fusion_telemetry_snapshot);
 always @(posedge pix_clk)if(arst_n&&fusion_request&&aba_stage>=3)begin
  if(fusion_config[159:96]!==test_generation||fusion_config[55:48]!==test_high)$fatal(1,"ABA_SOURCE_REQUEST_CONFIG");
  $display("ABA_SOURCE_REQUEST seq=%0d config=%040h",fusion_request_seq,fusion_config);
 end
'''.replace('ARM_ASSERT',armassert)
t=t[:a]+new+t[b:]
needle='rejected_result_descriptor[447:384]==1)aba_rejects=aba_rejects+1;'
assert t.count(needle)==1;t=t.replace(needle,'''rejected_result_descriptor[447:384]==1)begin
    aba_check_ttl;
    if(rejected_result_descriptor!==real_a1_descriptor||aba_stage!=4||aba_off_events!=1||aba_b2_events!=1||aba_a3_events!=1)$fatal(1,"ABA_GENUINE_TWO_FENCE_WITNESS");
    aba_rejects=aba_rejects+1;
   end''')
q=F/'tb_aba_two_fence.sv';q.write_text(t)
fa=lambda x:collections.Counter(re.findall(r'\$fatal\(.*?;',x,re.S))
assert not(fa(s)-fa(t)),fa(s)-fa(t)
runner=(O/'run_replay.py').read_text().replace("O=Path(__file__).resolve().parent;M=O.parent;","F=Path(__file__).resolve().parent;O=F.parent;M=O.parent;")
runner=runner.replace("args=a.parse_args()","args=a.parse_args();assert args.kind=='aba' and args.compile_only and not args.mutant, 'Preparation only: no native long ABA authorized'")
runner=runner.replace("O/('tb_replay_'+args.kind+'.sv')","F/'tb_aba_two_fence.sv'")
runner=runner.replace("deps=list(dict.fromkeys(deps));","deps += [F/'DERIVATION.json',O/'prepare_aba_two_fence.py',M.parent/'ABA_TWO_FENCE_PREPARATION_FREEZE_20261013_1821.md']\nfor x in json.loads((F/'DERIVATION.json').read_text())['derived']:assert rec(R/x['path'])==x\ndeps=list(dict.fromkeys(deps));")
runner=runner.replace("'work.'+case['top']","'work.tb_aba_two_fence'")
u=F/'compile_only.py';u.write_text(runner)
d=dict(status='PREPARATION_ONLY_NOT_RUN',parent=[rec(p),rec(O/'run_replay.py')],derived=[rec(q),rec(u)],generator=rec(Path(__file__)),fatal_original=sum(fa(s).values()),fatal_derived=sum(fa(t).values()),fatal_missing=[],contract='Original full-drain assertion retained at ARM with stronger complete context/source/packet ledger. SOF only context-fence required; new telemetry independently conserved. Actual long keys OFF/ON, pending external B2/A3 NBA at realSOF. No production edits or long execution authorized.',freeze=rec(O.parent.parent/'ABA_TWO_FENCE_PREPARATION_FREEZE_20261013_1821.md'))
(F/'DERIVATION.json').write_text(json.dumps(d,indent=2));print(rec(F/'DERIVATION.json'))
