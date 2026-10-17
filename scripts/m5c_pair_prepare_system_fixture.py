from pathlib import Path
import json,hashlib
R=Path.cwd();P=R/'reports/m5c_shadow_stats_20261016/system_fixture';F=R/'reports/m5c_pair_capture_20261016/system_fixture';F.mkdir(exist_ok=False)
def rec(p):b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
s=(P/'tb_shadow_system.sv').read_text().replace('tb_shadow_system','tb_pair_system')
s=s.replace('m5b1_system #(.DIAGNOSTICS(1)) dut(','''m5c_pair_system #(.DIAGNOSTICS(0)) dut(
 .pair_cov(selected_mode==6&&control_fusion),.pair_sof(diag_sof),.pair_admit(diag_admit),.pair_kill(diag_kill),
 .pair_identity_ok(fusion_config==fusion_descriptor[735:576]&&epoch==fusion_descriptor[63:0]&&fusion_eligible),
 .pair_pixel_session(diag_sid),.pair_pixel_source(tag_id),.pair_pixel_ticks(pixel_ticks),.pair_pixel_seq(display_seq),
 .pair_de(out_de),.pair_x(out_x),.pair_y(out_y),.pair_class(pair_final_class),.pair_support(diag_support),.pair_local(out_ce),
 .pair_domain(!fusion_context_block&&!fusion_context_tail_fault&&diag_tag&&fusion_frame_ok&&fusion_eligible),.pair_row_complete(diag_rc),.pair_row_tag(diag_rt),''')
s=s.replace('    wire diag_ctx,','    wire [1:0] pair_final_class;\n    wire diag_ctx,')
a=s.index('    m5c_diag_observer_v3 #');z=s.index(' reg source_good',a)
s=s[:a]+''' assign diag_ui_ready=0;assign diag_window=0;assign diag_byte=0;assign diag_valid=0;assign diag_pix_ready=0;
 m5a_packet_delay #(.BITS(2),.DELAY(1652)) pair_class_delay(.clk(pix_clk),.rst_n(arst_n),.ce(1'b1),.in_packet(diag_class),.out_packet(pair_final_class),.out_ready());
'''+s[z:]
a=s.index(' initial diag_file=$fopen');z=s.index('\nendmodule',a)
s=s[:a]+''' integer pair_pixels=0,pair_done_packets=0,pair_current_b=0,pair_meta_b=0,pair_current_file;
 reg [63:0] pair_selected_job=0,pair_selected_sid=0;
 reg pair_txn_write=0;reg [31:0] pair_txn_address=0;
 reg [7:0] pair_oracle_byte;reg [35:0] pair_gold;
 wire pair_recovery_complete=dut.pair_terminal&&!dut.background.pair_hold&&dut.background.pair_failure==0&&pair_done_packets==1&&dut.background.published_count>pair_selected_job;
 initial begin diag_file=$fopen("pair_events.txt","w");pair_current_file=$fopen("pair_current_oracle.hex","w");end
 always @(posedge pix_clk)if(arst_n&&dut.pair_capture.state==dut.pair_capture.CAPTURE&&out_de)begin
  pair_gold=gold[out_y*1280+out_x];
  if(pair_final_class!==pair_gold[31:30]||diag_support!==pair_gold[27]||out_ce!==pair_gold[29])
   $fatal(1,"PAIR_REAL_VIDEO_PLANE_MISALIGN x=%0d y=%0d class=%b/%b support=%b/%b local=%b/%b",out_x,out_y,pair_final_class,pair_gold[31:30],diag_support,pair_gold[27],out_ce,pair_gold[29]);
  pair_oracle_byte={3'b0,(!fusion_context_block&&!fusion_context_tail_fault&&diag_tag&&fusion_frame_ok&&fusion_eligible),pair_gold[29],pair_gold[27],pair_gold[31:30]};
  $fdisplay(pair_current_file,"%02h",pair_oracle_byte);pair_pixels=pair_pixels+1;
 end
 always @(posedge ui_clk)if(arst_n)begin
  if(dut.background.pair_selected)begin
   if(pair_selected_job!=0)$fatal(1,"PAIR_NORMAL_RETRY_UNEXPECTED");
   pair_selected_job=dut.background.active_pair_descriptor[191:128];pair_selected_sid=dut.telemetry_session;
   if(dut.pair_request_data!==dut.telemetry_session)$fatal(1,"PAIR_SELECTION_WRONG_REQUEST_SESSION");
   $fdisplay(diag_file,"SELECT %016h %016h %0192h",pair_selected_job,pair_selected_sid,dut.background.active_pair_descriptor);
  end
  if(avalid&&aready)begin pair_txn_write=atype;pair_txn_address=aaddr;end
  if(bvalid&&bready&&pair_txn_write)begin
   if(pair_txn_address>=32'h01100000&&pair_txn_address<32'h011e1000)pair_current_b=pair_current_b+1;
   if(pair_txn_address==32'h011e1000)pair_meta_b=pair_meta_b+1;
  end
  if(dut.background.packet_done&&dut.background.packet.packet_type==10)begin
   pair_done_packets=pair_done_packets+1;
   if(dut.background.pair_failure!=0||pair_pixels!=921600||pair_current_b!=1800||pair_meta_b!=1)$fatal(1,"PAIR_COMPLETE_REAL_COVERAGE");
   $fdisplay(diag_file,"PAIR_DONE pixels=%0d currentB=%0d metadataB=%0d",pair_pixels,pair_current_b,pair_meta_b);
  end
 end
'''+s[z:]
s=s.replace('m5c1b_ddr_service_model memory(',"m5c1b_ddr_service_model #(.WORDS(32'h011e2000/16)) memory(")
# Observe actual muxed packet input, not only legacy start/payload registers.
s=s.replace('dut.background.packet_start','dut.background.packet.start')
s=s.replace('$fclose(diag_file);','$fclose(diag_file);$fclose(pair_current_file);')
s=s.replace('M5C1B_PASS SELECTED_FINAL_SYSTEM','PAIR_FULL_VIDEO_PASS')
(F/'tb_pair_system.sv').write_text(s)
end=(P/'end_protocol.svh').read_text().replace('!dut.background.diag_busy&&diag_started==diag_completed&&diag_completed==diag_taken','!dut.background.pair_hold&&pair_recovery_complete')
end=end.replace('diag_taken>=2','pair_recovery_complete').replace('dut.background.packet_start','dut.background.packet.start')
(F/'end_protocol.svh').write_text(end);(F/'end_declarations.svh').write_bytes((P/'end_declarations.svh').read_bytes())
(F/'DERIVATION.json').write_text(json.dumps(dict(status='PREPARED_NOT_COMPILED_OR_RUN',parent=[rec(P/n) for n in ['tb_shadow_system.sv','end_protocol.svh','end_declarations.svh']],derived=[rec(F/n) for n in ['tb_pair_system.sv','end_protocol.svh','end_declarations.svh']],changes=['Actual pair top binding matches independent project: real videoDMA/lcd/M5A/fusion/OSD retained','Type5 removed explicitly; pair complete1800physicalB+metadataB+realpacketDONE+leaseholdclear+subsequentpublication required','All7healthy and original pixel/identity/UART/end ledgers retained; packet ledger observes muxed actual packet input','Independent golden class/support/local checks full921600 current bytes; domain is actual qualified-control ledger, not inferred all1','Physical DDR model same logic, memory parameter enlarged to exact0x011e2000 end; address/4KiB/service checks unchanged'],budget='Intended BG96M/service384/blank478667/seed50708, UART_CLOCK_HZ960000 explicit conditional100x only. Original actual4s simulation watchdog unchanged. No native launched before resourcegate.'),indent=2));print(F)
