from pathlib import Path
import re,json,hashlib
R=Path(__file__).resolve().parents[1];P=R/'reports/m5c1b_fusion_integration/selected_final_matrix_20261013_071300/replay_end_v2';O=R/'reports/m5c_diagnostics/stage2_system_fixture';O.mkdir(exist_ok=False)
t=(P/'tb_replay_normal.sv').read_text();top=(R/'efinity/m5c_fusion_i3/example_top.v').read_text()
t=t.replace('module tb_replay_normal;','module tb_diag_system;')
w=top[top.index('    wire diag_ctx'):top.index('    wire diag_ctx')+top[top.index('    wire diag_ctx'):].index('\n',top[top.index('    wire diag_ctx'):].index('wire [7:0] diag_byte;'))]
t=t.replace(' m5b1_system dut(',w+'\n m5b1_system #(.DIAGNOSTICS(1)) dut(')
ports=next(x.strip() for x in top.splitlines() if '.diag_ready(diag_ui_ready)' in x)
t=t.replace('  .fusion_frame_done(fusion_frame_done),',ports+'\n  .fusion_frame_done(fusion_frame_done),')
obsports='\n'.join(x.strip() for x in top.splitlines() if any(s in x for s in ['.diag_context_valid(','.diag_compare_valid(','.diag_tag_good(']))
t=t.replace('  .frame_done(fusion_frame_done),',obsports+'\n  .frame_done(fusion_frame_done),')
a=top.index('    m5c_diag_observer_v2 u_diag_observer');b=top.index('\n',top.index('m5c_diag_slot_guard u_diag_slot',a));block=top[a:b]
mapping={'clk_pixel':'pix_clk','w_ddr3_ui_clk':'ui_clk','m5b1_epoch':'epoch','sobel_de':'out_de','final_x':'out_x','final_y':'out_y','local_edge':'out_ce','display_mode':'out_mode','fusion_enable':'control_fusion','rstn_sys':'arst_n','rstn_pixel':'arst_n'}
# Replace signal arguments, not named port identifiers.
for old,new in mapping.items():block=re.sub(r'(?<!\.)\b'+old+r'\b',new,block)
block=block.replace('m5c_diag_observer_v2 u_diag_observer','m5c_diag_observer_v2 #(.SAMPLE_FRAMES(2)) u_diag_observer')
t=t.replace(' reg source_good[0:511];',block+'\n reg source_good[0:511];')
monitor='''
 integer diag_started=0,diag_completed=0,diag_taken=0,diag_file,diag_k;reg [896:0] diag_tuple;reg diag_tuple_guard=0;
 initial diag_file=$fopen("diag_events.txt","w");
 always @(posedge pix_clk)if(arst_n)begin
  if(u_diag_observer.state==u_diag_observer.PREP&&diag_ctx)begin
   if(diag_tuple_guard&&{fusion_descriptor,diag_token,epoch,diag_source_slot}!==diag_tuple)$fatal(1,"DIAG_PRODUCTION_PREP_TUPLE_CHANGED");
   diag_tuple={fusion_descriptor,diag_token,epoch,diag_source_slot};diag_tuple_guard=1;
  end else diag_tuple_guard=0;
  if(diag_take)begin
   if(diag_pix_cancel||dut.background.packet.uart.busy||diag_completed!=diag_taken+1)$fatal(1,"DIAG_SYSTEM_ACK_ORDER");
   diag_taken=diag_taken+1;$fdisplay(diag_file,"TAKE %0d %0t",diag_taken,$time);
  end
 end
 always @(posedge ui_clk)if(arst_n)begin
  if(dut.background.diag_grant)begin
   diag_started=diag_started+1;expected_wire_bytes=expected_wire_bytes+324;
   $fwrite(diag_file,"RECORD %0d",diag_started);for(diag_k=0;diag_k<40;diag_k=diag_k+1)$fwrite(diag_file," %016h",u_diag_observer.memory[diag_k]);$fwrite(diag_file,"\\n");
  end
  if(diag_done)begin diag_completed=diag_completed+1;$fdisplay(diag_file,"DONE %0d %0t",diag_completed,$time);end
  if(diag_cancel)$fatal(1,"DIAG_SYSTEM_UNEXPECTED_CANCEL");
 end
'''
t=t.replace(' `include "end_protocol.svh"',monitor+'\n `include "end_protocol.svh"')
t=t.replace('$fclose(wirefile);$fclose(metafile);','$fclose(wirefile);$fclose(metafile);$fclose(diag_file);')
(O/'tb_diag_system.sv').write_text(t)
decl=(P/'common/end_declarations.svh').read_text();(O/'end_declarations.svh').write_text(decl)
end=(P/'common/end_protocol.svh').read_text().replace('wire end_pix_raw_idle=','wire end_pix_raw_idle=!diag_pix_ready&&').replace('wire end_ui_raw_idle=','wire end_ui_raw_idle=!diag_ui_ready&&!dut.background.diag_busy&&diag_started==diag_completed&&diag_completed==diag_taken&&').replace('!end_target_fixed&&smoke_complete&&end_checked_qualified','!end_target_fixed&&smoke_complete&&diag_taken>=2&&end_checked_qualified')
(O/'end_protocol.svh').write_text(end)
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(O/'DERIVATION.json').write_text(json.dumps(dict(parents=[rec(P/'tb_replay_normal.sv'),rec(P/'common/end_protocol.svh'),rec(R/'efinity/m5c_fusion_i3/example_top.v')],derived=[rec(O/n) for n in ['tb_diag_system.sv','end_protocol.svh','end_declarations.svh']],scope='Same actual production system/DDR/DMA/cache/fusion/OSD and independent pixel oracle. Add actual top diagnostic bindings, 2-frame conditional sample period, complete extra type5 ledger and drain. Original pixel/type4/lease/end assertions retained. UART remains explicit100x conditional divider; default rate separately proven.'),indent=2))
s=(R/'scripts/m5c_diag_run_coupled.py').read_text().replace("'stage2_coupled_'","'stage2_system_'").replace("R/'tb/m5c_diagnostics/tb_diag_coupled.sv'","R/'reports/m5c_diagnostics/stage2_system_fixture/tb_diag_system.sv',R/'tb/m5c_fusion/m5c1b_ddr_service_model.sv',R/'efinity/m5c_fusion_i3/src/lcd_driver.v',R/'reports/m5c1b_fusion_integration/osd_reference/m5a_osd_baseline_reference.v'")
s=s.replace("sources+[Path(__file__)]","sources+[Path(__file__),R/'reports/m5c_diagnostics/stage2_system_fixture/end_declarations.svh',R/'reports/m5c_diagnostics/stage2_system_fixture/end_protocol.svh',R/'reports/m5c_diagnostics/stage2_system_fixture/DERIVATION.json',R/'reports/m5c1b_fusion_integration/golden_v2/pixels.hex']")
s=s.replace("'+incdir+'+str(R/'rtl/m5c_fusion')","'+incdir+'+str(R/'rtl/m5c_fusion'),'+incdir+'+str(R/'reports/m5c_diagnostics/stage2_system_fixture')")
s=s.replace("'tb_diag_coupled','+PHASE=2','+OUT='+D.as_posix()","'tb_diag_system','-gHEALTHY_FRAMES=2','-gBG_REQUEST_CYCLES=1000000','-gSERVICE_CYCLES=384','-gCAMERA_BLANK_CYCLES=478667','+SEED=50708','+GOLD='+str(R/'reports/m5c1b_fusion_integration/golden_v2/pixels.hex')")
s=s.replace('timeout=180','timeout=7200 if i==2 else 180').replace("'CACHE_CONTEXT_PASS'","'M5C1B_PASS'")
(R/'scripts/m5c_diag_run_system.py').write_text(s)
print(O)
